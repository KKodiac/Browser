## Context

The browser uses TCA (ComposableArchitecture) with `AppFeature` as the root reducer. State is held in `AppFeature.State`, which contains `ungroupedTabs: IdentifiedArrayOf<BrowserTab>`, `tabGroups: IdentifiedArrayOf<TabGroup>`, `selectedTabId: UUID?`, and `accentColor: AccentColor`. Models are plain structs (`BrowserTab`, `TabGroup`) conforming to `Equatable` and `Identifiable`, used with `IdentifiedArrayOf` from the IdentifiedCollections library.

Currently, the app starts with a single blank `BrowserTab` every launch. There is no persistence layer for session state. The bookmarks feature (in progress) establishes a precedent of JSON file storage in Application Support.

## Goals / Non-Goals

**Goals:**
- Save full session state (tabs, groups, selected tab, accent color) when the app quits
- Restore session state on the next launch so the user sees their previous tabs and groups
- Save periodically during use to guard against crashes
- Handle missing, empty, or corrupt session files gracefully (fall back to default state)

**Non-Goals:**
- Multi-window session state (only single-window supported today)
- Undo close window / reopen last session manually
- Preserving WKWebView internal state (scroll position, form data, cookies) — only URLs are restored
- Saving/restoring navigation history per tab (back/forward stack)
- Tab suspension or lazy loading of restored tabs

## Decisions

### 1. JSON file in Application Support

**Decision:** Persist session state as a single JSON file at `<Application Support>/Browser/session.json`.

**Rationale:** Consistent with the bookmarks storage approach. JSON + Codable is simple, human-readable for debugging, and has no external dependencies. The session payload is small (URLs, titles, group metadata) so performance is not a concern.

**Alternatives considered:**
- *UserDefaults*: Not suited for structured collections with nested arrays.
- *SQLite/GRDB*: Overkill for a single document of session state.
- *NSCoding/archiver*: Less portable and harder to debug than JSON.

### 2. Codable conformance on BrowserTab and TabGroup

**Decision:** Add `Codable` conformance to `BrowserTab`, `TabGroup`, `GroupColor`, and `AccentColor`. Only persist the properties needed to reconstruct the session: `id`, `url`, `title`, `suggestedURL` for tabs; `id`, `label`, `color`, `isCollapsed`, `tabs` for groups. Transient properties (`isLoading`, `canGoBack`, `canGoForward`, `requestedLoad`) are excluded from encoding via `CodingKeys`.

**Rationale:** These transient properties represent runtime WebView state that will be re-established when pages reload. Encoding them would be misleading (a restored tab is not "loading" until the WebView actually reloads it).

### 3. Save on quit and periodically

**Decision:** Save session on two triggers:
1. `NSApplication.willTerminateNotification` — guarantees a save on normal quit
2. Periodically (debounced, e.g., every 30 seconds after state changes) — guards against crashes

**Rationale:** Quit-time save alone risks data loss on force-quit or crash. Periodic save alone risks a stale file if the interval is too long. Combining both provides reliable coverage.

### 4. Restore on launch, reload URLs

**Decision:** On launch, if `session.json` exists and decodes successfully, replace the default state with the restored state. Each restored tab's `requestedLoad` is set to `true` so the WebView reloads its URL. If the file is missing or corrupt, fall back to the default single-blank-tab state.

**Rationale:** WKWebView state cannot be serialized — the only way to restore a page is to reload its URL. Setting `requestedLoad` reuses the existing WebView loading mechanism without adding new code paths.

### 5. SessionStore as a TCA dependency

**Decision:** Create a `SessionStore` struct that conforms to TCA's `DependencyKey` pattern, providing `save(_:)` and `load()` methods. The `AppFeature` reducer calls these via effects.

**Rationale:** Keeps I/O out of the reducer's pure logic. Makes the store testable (can inject a mock/in-memory implementation). Follows the existing TCA patterns in the codebase.

## Risks / Trade-offs

- **WKWebView state not preserved** — Restored tabs reload from the URL, losing scroll position, form inputs, and JavaScript state. This is a fundamental WebKit limitation. Mitigation: Acceptable trade-off; users expect a page reload similar to Safari's session restore behavior.
- **Stale URLs** — A saved URL may 404 or redirect by the time the session is restored. Mitigation: No special handling needed; the WebView will show the server's error or redirect as it normally would.
- **IdentifiedArrayOf Codable** — `IdentifiedArrayOf` from IdentifiedCollections already conforms to `Codable` when its element is `Codable`, so no custom encoding is needed for the collections.
- **Large session size** — A user with many tabs could produce a large JSON file. Mitigation: Even hundreds of tabs produce only tens of KB of JSON; this is not a practical concern.
- **Race condition on periodic save** — If the app crashes during a write, the file could be corrupted. Mitigation: Write to a temporary file first, then atomically rename. `Data.write(to:options:)` with `.atomic` handles this.

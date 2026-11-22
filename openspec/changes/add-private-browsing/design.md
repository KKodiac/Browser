## Context

The browser uses a single `WindowGroup` scene in `BrowserApp`, with all state managed via a ComposableArchitecture `Store`. `WebView` creates a `WKWebView` with a default `WKWebViewConfiguration`, which uses the shared persistent `WKWebsiteDataStore`. This means all cookies, cache, and site data accumulate across sessions.

There is currently no concept of window types — every window is identical. The app has no history feature yet, but when one is added, private windows must be excluded.

## Goals / Non-Goals

**Goals:**
- Open a private window that uses an ephemeral (non-persistent) WebKit data store
- All tabs in a private window share the same ephemeral data store (so logins carry across tabs within the session)
- Cookies, cache, and site data from private windows are discarded when the window closes
- Private windows are visually distinct from normal windows
- Menu bar integration with Cmd+Shift+N keyboard shortcut
- Warn users if they try to bookmark a page from a private window

**Non-Goals:**
- Per-tab private mode (privacy is window-level only, not per-tab)
- Clearing data from normal browsing sessions
- Private tab indicators within the tab bar (the entire window is private)
- Traffic anonymization or VPN-like features
- Blocking screenshots or screen recording in private windows

## Decisions

### 1. Use `WKWebsiteDataStore.nonPersistent()` for private windows

**Decision:** Create a single `WKWebsiteDataStore.nonPersistent()` instance per private window and inject it into the `WKWebViewConfiguration` for all WebViews in that window.

**Rationale:** This is WebKit's built-in mechanism for ephemeral browsing. The non-persistent store keeps cookies and data in memory only — they are automatically discarded when the data store is deallocated (i.e., when the window closes). No manual cleanup needed.

**Alternatives considered:**
- *Manual data clearing on window close:* Error-prone, requires enumerating data types, and risks leaving traces if the app crashes.
- *Separate WKProcessPool per private window:* Unnecessary isolation overhead; non-persistent data store already provides the needed guarantees.

### 2. Window-level privacy, not per-tab

**Decision:** Privacy is a property of the entire window. All tabs in a private window use the same ephemeral data store. There is no "private tab" concept.

**Rationale:** Matches Safari and Chrome behavior. Per-tab private mode creates confusing UX (which tab is private?) and complicates data store management. A clear window-level boundary is easier to understand.

### 3. Visual indicator via dark title bar tint and badge

**Decision:** Private windows use a dark/muted background tint on the title bar area and display a "Private" text badge near the window title. This provides an always-visible distinction from normal windows.

**Rationale:** A subtle but persistent visual cue prevents users from accidentally thinking they are in a normal window. Safari uses a dark URL bar; Chrome uses a dark theme. A tint on the title bar area is the macOS-native equivalent.

### 4. Separate window scene for private windows

**Decision:** Use a second `WindowGroup` (or `Window` scene) with a distinct identifier for private windows, passing an `isPrivate` environment or configuration flag to `ContentView`.

**Rationale:** SwiftUI's `WindowGroup` model makes it natural to have separate window types with different configurations. This avoids mixing private and normal state in the same window and gives the system a clear lifecycle boundary — when the private window closes, its data store is deallocated.

### 5. Bookmark warning in private windows

**Decision:** When a user triggers "Add Bookmark" in a private window, show an alert warning that the page was visited in a private session and ask for confirmation before saving.

**Rationale:** Bookmarking a private page creates a persistent record of the visit, which may defeat the user's intent. A confirmation dialog makes the trade-off explicit without blocking the action entirely.

## Risks / Trade-offs

- **Separate WindowGroup complexity** → SwiftUI's multi-scene support on macOS is functional but has rough edges around state sharing. Mitigation: The private window gets its own independent `Store` instance, keeping state fully isolated.
- **No shared login state** → Users logged in on a normal window will not be logged in on a private window (different data stores). This is expected behavior but may surprise some users. Mitigation: This matches Safari/Chrome behavior; no action needed.
- **Data store lifecycle** → The ephemeral data store must be retained for the lifetime of the private window. If SwiftUI recreates views, the data store reference must be stable. Mitigation: Hold the data store in the `Store` or a `StateObject` that outlives individual view updates.
- **Future history integration** → When history is added later, it must check the `isPrivate` flag and skip recording. Mitigation: The `isPrivate` flag on the window/state makes this a simple conditional check.

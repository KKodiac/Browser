## Context

The browser currently has no browsing history. Tabs and groups are in-memory only. If bookmarks land first, JSON persistence in Application Support will already be established; history follows the same pattern. The app uses TCA (ComposableArchitecture) with `StoreOf<AppFeature>` in ContentView and `@Observable` models for tabs and groups.

## Goals / Non-Goals

**Goals:**
- Automatically record every page navigation with URL, title, and timestamp
- Persist history entries to disk across app launches
- Searchable history panel toggled via Cmd+Y
- Display entries grouped by date (Today, Yesterday, then by calendar date)
- Clear history by time range: last hour, today, all time
- Delete individual history entries

**Non-Goals:**
- Syncing history across devices
- Frecency scoring or visit-count tracking
- History suggestions in the URL bar (separate autocomplete feature)
- Private/incognito mode that skips history recording (separate feature)
- Limiting history size or automatic pruning

## Decisions

### 1. JSON file storage via Codable
**Decision:** Persist history entries as a single JSON file in Application Support.
**Rationale:** Consistent with the app's existing zero-dependency approach and the pattern established by bookmarks. A flat JSON file is simple and sufficient for a single-user local browser.
**Alternatives:** SQLite/GRDB (better for large datasets but adds a dependency), Core Data (heavy for append-only log), UserDefaults (not suited for large collections).

### 2. HistoryStore as @Observable class
**Decision:** A `HistoryStore` class marked `@Observable` that owns the entries array and handles load/save/search/clear operations.
**Rationale:** Consistent with existing model patterns (BrowserTab, TabGroup). Can be integrated into TCA state or passed via environment.
**Alternatives:** Pure TCA reducer-only approach (possible but history is a cross-cutting concern best encapsulated in its own store), Actor-based store (unnecessary complexity for UI-bound state).

### 3. Sheet or sidebar for history panel
**Decision:** Present history as a sheet overlay or trailing sidebar, toggled by Cmd+Y.
**Rationale:** History is a browse-and-dismiss interaction, unlike bookmarks which benefit from persistent sidebar access. A sheet keeps the main content area uncluttered. A sidebar is an acceptable alternative if the layout supports it.
**Alternatives:** Separate window (disruptive for quick lookups), popover (too small for scrolling through history), dedicated tab (unconventional for macOS browsers).

### 4. Grouped-by-date display
**Decision:** Group history entries by calendar date with section headers: "Today", "Yesterday", then formatted dates (e.g., "February 12, 2026").
**Rationale:** This is the standard pattern used by Safari, Chrome, and Firefox. Users think about history temporally -- "I saw that page yesterday."
**Alternatives:** Flat chronological list (harder to scan), grouped by domain (useful but secondary to time-based grouping).

### 5. Auto-record on navigation commit
**Decision:** Record a history entry whenever a page navigation commits (URL changes and the page begins loading), using the page's final URL and title.
**Rationale:** Recording on commit (not on link click) avoids logging failed navigations and redirects. Title may update after initial commit, so the entry should be updated when the title becomes available.
**Alternatives:** Record on page finish load (misses pages that fail partway), record on every URL change including fragment changes (too noisy).

## Risks / Trade-offs

- **JSON scalability** -- A single JSON file works for moderate history sizes but will degrade with thousands of entries. Acceptable for now; can migrate to SQLite if needed.
- **No size limit** -- Without automatic pruning, the history file grows indefinitely. This is a deliberate non-goal for the initial implementation; a future enhancement can add retention policies.
- **Title availability** -- Page titles may not be available at navigation commit time. The implementation must handle updating the title after the page finishes loading.
- **Duplicate entries** -- Reloading a page or navigating to the same URL creates a new entry each time. This matches standard browser behavior (each visit is a distinct event).

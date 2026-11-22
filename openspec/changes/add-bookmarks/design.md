## Context

The browser currently has no persistence layer — tabs and groups are in-memory only. Bookmarks will be the first persisted feature, so the storage approach here sets a precedent for session persistence and history later.

The app uses `@Observable` models (BrowserTab, TabGroup) managed directly in ContentView. There is no shared store or dependency injection pattern yet.

## Goals / Non-Goals

**Goals:**
- Save/remove/edit bookmarks with title, URL, and folder
- Organize bookmarks into a flat folder hierarchy (one level deep)
- Sidebar UI to browse and open bookmarks
- Keyboard shortcuts: Cmd+D (add), Cmd+Shift+B (toggle sidebar)
- Persist bookmarks to disk as JSON

**Non-Goals:**
- Bookmark bar (horizontal strip under tab bar) — future enhancement
- Bookmark sync across devices
- Bookmark import/export (Safari, Chrome formats)
- Nested folder hierarchy (folders within folders)
- Favicon fetching/caching (separate feature)

## Decisions

### 1. JSON file storage via Codable
**Decision:** Persist bookmarks as a single JSON file in Application Support.
**Rationale:** Simple, no dependencies, sufficient for local-only bookmarks. Matches the app's current zero-dependency approach.
**Alternatives:** SQLite/GRDB (overkill for flat bookmark list), UserDefaults (not suited for structured collections), Core Data (heavy for this use case).

### 2. BookmarkStore as @Observable singleton
**Decision:** A `BookmarkStore` class marked `@Observable` that owns the bookmark array and handles load/save.
**Rationale:** Consistent with existing patterns (no DI container exists). Can be passed via `.environment()` for testability later.
**Alternatives:** Actor-based store (unnecessary complexity for UI-bound state), TCA reducer (app doesn't use TCA).

### 3. Sidebar over popover
**Decision:** Show bookmarks in a sidebar (leading edge) rather than a dropdown or popover.
**Rationale:** Sidebar supports browsing/organizing large collections, is standard on macOS browsers, and works well with NavigationSplitView or HSplitView.
**Alternatives:** Popover (poor for large lists), sheet (blocks content), separate window (disruptive).

### 4. Flat folder model (one level)
**Decision:** Folders are top-level only — no nesting.
**Rationale:** Keeps the model simple (folder is just a name/id, bookmarks have an optional folderId). Nesting can be added later without breaking the schema.

## Risks / Trade-offs

- **First persistence pattern** → Sets precedent for future features. Keeping it simple (JSON + Codable) avoids locking into a heavy framework but may need migration if we later adopt SQLite.
- **No conflict handling** → Single JSON file means no concurrent write safety. Acceptable for single-window; needs revisiting for multi-window.
- **Sidebar layout** → Adding a sidebar changes ContentView's layout structure. Need to ensure it doesn't interfere with existing tab bar / WebView layout.

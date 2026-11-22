## Why

Users have no way to save pages for later. Every session starts blank, and finding a previously visited page requires remembering and retyping the URL. Bookmarks are a fundamental browser capability.

## What Changes

- Add a `Bookmark` model with title, URL, favicon URL, and creation date
- Add a `BookmarkFolder` model for hierarchical organization
- Add a bookmarks sidebar toggled via toolbar button or Cmd+Shift+B
- Add "Add Bookmark" action (Cmd+D) to save the current page
- Persist bookmarks to disk across sessions (JSON or plist)
- Add context menu items on bookmarked pages (edit, delete, move)

## Capabilities

### New Capabilities
- `bookmarks`: Bookmark model, storage, CRUD operations, and folder organization
- `bookmarks-ui`: Bookmarks sidebar, toolbar integration, keyboard shortcuts, and context menus

### Modified Capabilities

_(none — no existing spec requirements change)_

## Impact

- New files: `Bookmark.swift`, `BookmarkFolder.swift`, `BookmarkStore.swift`, `BookmarksSidebar.swift`
- Modified: `ContentView.swift` (sidebar toggle, toolbar button), `BrowserApp.swift` (menu commands)
- New dependency on file-system persistence (JSON encoding)

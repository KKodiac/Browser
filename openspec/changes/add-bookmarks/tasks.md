## 1. Models

- [x] 1.1 Create `Bookmark` struct (Codable, Identifiable) with id, title, url, folderId, createdAt
- [x] 1.2 Create `BookmarkFolder` struct (Codable, Identifiable) with id, name, sortOrder

## 2. Storage

- [x] 2.1 Create `BookmarkStore` (@Observable) with load/save to Application Support JSON file
- [x] 2.2 Implement add, remove, update operations for bookmarks
- [x] 2.3 Implement add, remove, rename operations for folders
- [x] 2.4 Auto-save on any mutation; load on init

## 3. Sidebar UI

- [x] 3.1 Create `BookmarksSidebar` view showing folders and unfiled bookmarks
- [x] 3.2 Add sidebar toggle to ContentView (leading edge, collapsible)
- [x] 3.3 Add Cmd+Shift+B keyboard shortcut to toggle sidebar
- [x] 3.4 Add toolbar button to toggle sidebar

## 4. Bookmark Actions

- [x] 4.1 Add "Add Bookmark" action (Cmd+D) that creates bookmark from current tab
- [x] 4.2 Handle Cmd+D when page is already bookmarked (select for editing)
- [x] 4.3 Click bookmark in sidebar to navigate current tab to that URL

## 5. Context Menus & Editing

- [x] 5.1 Add context menu on sidebar bookmarks (Edit, Delete, Move to Folder)
- [x] 5.2 Add context menu on sidebar folders (Rename, Delete)
- [x] 5.3 Add "New Folder" action in sidebar
- [x] 5.4 Implement inline edit for bookmark title and folder name

## 6. URL Bar Integration

- [x] 6.1 Show bookmark indicator icon in URL bar (filled if bookmarked, outlined if not)
- [x] 6.2 Update indicator reactively as user navigates between pages

## 7. Menu Bar

- [x] 7.1 Add Bookmarks menu with "Add Bookmark" (Cmd+D) and "Show Bookmarks" (Cmd+Shift+B)

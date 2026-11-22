## 1. Command List

- [x] 1.1 Create `BrowserCommand` (id, title, icon, shortcut label, availability, run closure)
- [x] 1.2 Add `BrowserCommand.all` with New Tab, New Window, New Private Window, Close Tab, Reopen Closed Tab, Show Bookmarks/History/Downloads, Find, Zoom In/Out/Actual Size, Toggle Split View, Pin/Unpin Tab, Add Bookmark

## 2. Search

- [x] 2.1 Match open tabs of the current window by title and URL
- [x] 2.2 Match commands by title
- [x] 2.3 Match bookmarks and history through `SuggestionEngine`, splitting results into Bookmarks and History
- [x] 2.4 Rank prefix matches above substring matches, case-insensitive
- [x] 2.5 Group results as Tabs, Commands, Bookmarks, History and cap the list at 12 rows
- [x] 2.6 Add a first "Search for “…”" / "Go to …" row when no result matches the query exactly

## 3. Command Bar UI

- [x] 3.1 Add `toggleCommandBar` action and trigger counter to `AppFeature`
- [x] 3.2 Add "Command Bar…" menu item with ⌘K
- [x] 3.3 Show the command bar as a floating overlay with a search field and grouped result rows
- [x] 3.4 Handle Up/Down to move the selection and Return to run it
- [x] 3.5 Open bookmarks, history and searches in a new tab with ⌘-Return or ⌘-click
- [x] 3.6 Close on Escape, ⌘K or a click outside the command bar

## 4. Verification

- [x] 4.1 Build the app with `xcodebuild`
- [ ] 4.2 Manually test keyboard and mouse interaction in the running app

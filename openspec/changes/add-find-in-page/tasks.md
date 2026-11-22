## 1. State Management

- [x] 1.1 Add find-in-page state fields to `AppFeature.State`: `isFindBarVisible: Bool`, `findText: String`, `findMatchCount: Int`, `findMatchIndex: Int`
- [x] 1.2 Add TCA actions: `toggleFindBar`, `dismissFindBar`, `findNext`, `findPrevious`, `updateFindResults(count: Int, index: Int)`
- [x] 1.3 Implement reducer cases for find bar visibility toggle and dismiss (clear all find state)
- [x] 1.4 Implement reducer cases for `findNext` and `findPrevious` (index cycling with wrap-around)
- [x] 1.5 Update `selectTab` action to dismiss find bar and clear find state on tab switch

## 2. Find Bar UI

- [x] 2.1 Create find bar view with text field, match count label ("X of Y"), and previous/next buttons
- [x] 2.2 Add find bar as `.overlay(alignment: .topTrailing)` on the content area in `ContentView`
- [x] 2.3 Conditionally show the find bar based on `store.isFindBarVisible`
- [x] 2.4 Bind text field to `store.findText` and match count display to `store.findMatchCount` / `store.findMatchIndex`

## 3. Keyboard Shortcuts

- [x] 3.1 Add Cmd+F keyboard shortcut to toggle find bar visibility
- [x] 3.2 Add Cmd+G keyboard shortcut to navigate to next match
- [x] 3.3 Add Cmd+Shift+G keyboard shortcut to navigate to previous match
- [x] 3.4 Add Escape keyboard shortcut to dismiss find bar (only when find bar is visible)

## 4. WebView Search Integration

- [x] 4.1 Add JavaScript evaluation method on `WKWebView` to execute `window.find()` for match navigation
- [x] 4.2 Add JavaScript to count total matches and report current match index back to Swift
- [x] 4.3 Add JavaScript to clear all highlights when find bar is dismissed
- [x] 4.4 Wire `findText` changes to trigger JavaScript search on `currentWebView` (with debounce)
- [x] 4.5 Wire `findNext` / `findPrevious` actions to call `window.find()` with forward/backward direction
- [x] 4.6 Dispatch `updateFindResults` action from JavaScript callback to update match count and index in state

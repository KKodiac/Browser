## 1. NewTabPageView

- [x] 1.1 Create `NewTabPageView` SwiftUI view with a vertically centered layout containing the search field and content sections
- [x] 1.2 Style the view to match the app's dark theme and accent color system

## 2. Search Field

- [x] 2.1 Add a centered search field with placeholder text ("Search or enter URL")
- [x] 2.2 Wire search field tap to focus the URL bar via the existing `focusURLBarTrigger` mechanism

## 3. Frequently Visited Grid

- [x] 3.1 Add a grid section displaying frequently visited sites as rounded-rect tiles with favicon (or letter placeholder) and title
- [x] 3.2 Accept frequently visited site data from history store when available
- [x] 3.3 Wire tile tap to navigate the current tab to the selected site's URL
- [x] 3.4 Hide the grid section when no history data is available

## 4. Favorites Section

- [x] 4.1 Add a favorites/bookmarks section displaying saved sites with favicon (or letter placeholder) and title
- [x] 4.2 Accept favorites data from bookmarks store when available
- [x] 4.3 Wire favorite tap to navigate the current tab to the selected site's URL
- [x] 4.4 Hide the favorites section when no bookmarks data is available

## 5. Empty State

- [x] 5.1 Show a welcome message and search field when neither history nor bookmarks data is available
- [x] 5.2 Hide empty grids — do not show placeholder tiles or empty section headers

## 6. ContentView Integration

- [x] 6.1 Update `contentArea` in ContentView to show `NewTabPageView` when the selected tab has `url == nil`
- [x] 6.2 Show `WebView` when the tab has a URL (existing behavior)
- [x] 6.3 Ensure transition from NTP to WebView occurs when the user submits a URL from the URL bar

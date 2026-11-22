## Why

New tabs currently show a blank white page. This is unhelpful — users must immediately type a URL or search term with no visual guidance. Every major browser provides a new tab page (NTP) with quick access to frequently visited sites and a search entry point. A custom NTP makes the browser feel complete and gives users a productive starting point every time they open a tab.

## What Changes

- Add a `NewTabPageView` SwiftUI view with a centered search field, a frequently visited sites grid, and a favorites/bookmarks section
- Show `NewTabPageView` instead of `WebView` when the selected tab has no URL (nil or empty)
- Tapping the NTP search field focuses the URL bar for input
- Display a clean empty state for first-launch users who have no history or favorites yet
- Populate the frequently visited grid from browsing history when the history capability is available
- Populate the favorites section from bookmarks when the bookmarks capability is available

## Capabilities

### New Capabilities
- `new-tab-page`: New tab page view with centered search field, frequently visited sites grid (favicon + title), favorites/bookmarks section, and first-launch empty state

### Modified Capabilities

_(none -- no existing spec requirements change)_

## Impact

- **ContentView.swift**: Content area conditionally shows `NewTabPageView` instead of `WebView` when the selected tab has no URL
- New file: `NewTabPageView.swift`
- When history and bookmarks capabilities land, the NTP will consume their data to populate the grid and favorites section; until then, the NTP shows the empty state
- No new dependencies -- pure SwiftUI view

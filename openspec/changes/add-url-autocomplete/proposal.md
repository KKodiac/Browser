## Why

Users must type full URLs or search queries manually every time they want to revisit a page. There is no type-ahead assistance, no recall of previously visited sites, and no shortcut to popular destinations. This makes navigation slow and error-prone, especially for long or complex URLs the user has visited before.

## What Changes

- Add a suggestion engine that matches user input against browsing history, bookmarks, and a small built-in list of popular sites
- Add an autocomplete dropdown that appears below the URL bar as the user types, showing ranked suggestions
- Add keyboard navigation (arrow keys, Enter, Escape) to interact with the dropdown
- Add inline URL completion that auto-fills the top match in the text field

## Capabilities

### New Capabilities
- `url-autocomplete`: Suggestion engine (local matching, ranking, debouncing) and dropdown UI (suggestion list, keyboard navigation, inline completion)

### Modified Capabilities

_(none -- no existing spec requirements change)_

## Impact

- **ContentView.swift**: URL bar gains an autocomplete dropdown overlay positioned above the text field, input handling changes to trigger suggestions on text change
- **Depends on history/bookmarks data when available**: The suggestion engine will match against history and bookmark stores if they exist; without them, it falls back to popular sites only
- No new external dependencies -- uses only SwiftUI and Foundation

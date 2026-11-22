## 1. Suggestion Engine

- [x] 1.1 Create `AutocompleteSuggestion` model with title, url, and source (history/bookmark/popular)
- [x] 1.2 Create a built-in popular sites list (top ~50 domains with titles)
- [x] 1.3 Implement matching logic: prefix and substring matching against URL and title, case-insensitive
- [x] 1.4 Implement relevance ranking: prefix matches above substring matches, frequency as tiebreaker
- [x] 1.5 Implement deduplication across data sources (same URL appears once, highest-ranked source wins)
- [x] 1.6 Limit results to top 8
- [x] 1.7 Implement 150ms debounce on input changes

## 2. URL Bar Dropdown UI

- [x] 2.1 Create suggestion dropdown view showing title and URL per row
- [x] 2.2 Position dropdown above the URL bar (overlay on web content area)
- [x] 2.3 Show dropdown when URL bar is focused and at least one suggestion matches
- [x] 2.4 Hide dropdown when no suggestions match or URL bar loses focus
- [x] 2.5 Highlight the currently selected suggestion row

## 3. Keyboard Navigation

- [x] 3.1 Handle down arrow to move selection to next suggestion
- [x] 3.2 Handle up arrow to move selection to previous suggestion (or back to input)
- [x] 3.3 Handle Enter to accept the selected suggestion and navigate
- [x] 3.4 Handle Escape to dismiss the dropdown without navigating
- [x] 3.5 Implement inline completion: auto-fill top match URL with completion portion selected
- [x] 3.6 Replace inline completion text when user continues typing

## 4. Integration with History/Bookmarks Stores

- [x] 4.1 Define a data source protocol the suggestion engine queries
- [x] 4.2 Implement popular-sites data source as the default
- [x] 4.3 Add hook for history store integration (when history feature is implemented)
- [x] 4.4 Add hook for bookmark store integration (when bookmarks feature is implemented)

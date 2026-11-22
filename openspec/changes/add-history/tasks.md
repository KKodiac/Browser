## 1. Models

- [x] 1.1 Create `HistoryEntry` struct (Codable, Identifiable) with id, url, title, and visitedAt timestamp
- [x] 1.2 Add computed property for display title (page title, falling back to hostname)

## 2. Storage

- [x] 2.1 Create `HistoryStore` (@Observable) with load/save to `<Application Support>/Browser/history.json`
- [x] 2.2 Implement `addEntry(_:)` that appends a new entry and saves
- [x] 2.3 Implement `deleteEntry(_:)` that removes a single entry and saves
- [x] 2.4 Implement `clearHistory(range:)` for last hour, today, and all time
- [x] 2.5 Auto-load history on init

## 3. History Recording

- [x] 3.1 Record a history entry on page navigation commit (URL change) with URL and timestamp
- [x] 3.2 Update the most recent entry's title when the page title becomes available

## 4. History UI

- [x] 4.1 Create `HistoryPanel` view with a list of history entries grouped by date
- [x] 4.2 Add date section headers: "Today", "Yesterday", or formatted date for older entries
- [x] 4.3 Order entries within each group by timestamp, most recent first
- [x] 4.4 Add Cmd+Y keyboard shortcut to toggle history panel visibility
- [x] 4.5 Wire history panel toggle into ContentView (sheet or sidebar)

## 5. Search & Filter

- [x] 5.1 Add search field at the top of the history panel
- [x] 5.2 Implement `search(query:)` in HistoryStore that filters by title and URL, case-insensitively
- [x] 5.3 Update displayed entries in real time as the user types

## 6. Clear History

- [x] 6.1 Add "Clear History" button/menu in the history panel with options: Last Hour, Today, All History
- [x] 6.2 Remove matching entries from the store and update the panel display
- [x] 6.3 Show empty state when all entries are cleared

## 7. Entry Actions

- [x] 7.1 Click a history entry to navigate the current tab to that URL and dismiss the panel
- [x] 7.2 Add context menu on history entries with "Delete" option
- [x] 7.3 Implement single-entry deletion from context menu

## 8. Menu Bar

- [x] 8.1 Add History menu with "Show History" (Cmd+Y) command

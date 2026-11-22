## Why

Users have no way to revisit pages they previously viewed. If a tab is closed or the app is relaunched, the only option is to remember and retype the URL. Browsing history is a fundamental browser capability that lets users retrace their steps and find previously visited content.

## What Changes

- Add a `HistoryEntry` model with URL, title, and visit timestamp
- Add a `HistoryStore` that automatically records page visits and persists them to disk
- Add a searchable history panel toggled via Cmd+Y or the menu bar
- Display history entries grouped by date (Today, Yesterday, older dates)
- Allow clearing history by time range (last hour, today, all time) or deleting individual entries
- Add search to filter history by URL or title

## Capabilities

### New Capabilities
- `history`: HistoryEntry model, persistent storage, automatic visit recording, search, and clear-by-time-range operations
- `history-ui`: History panel with grouped-by-date display, search field, click-to-navigate, clear history controls, and keyboard shortcut

### Modified Capabilities

_(none -- no existing spec requirements change)_

## Impact

- New files: `HistoryEntry.swift`, `HistoryStore.swift`, `HistoryPanel.swift`
- Modified: `ContentView.swift` (history panel toggle), `BrowserApp.swift` (menu commands), `WebView.swift` or navigation delegate (auto-record visits)
- New dependency on file-system persistence (JSON encoding in Application Support)

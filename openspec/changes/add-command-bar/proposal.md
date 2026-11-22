## Why

Reaching an open tab, a page from history or bookmarks, or a menu command means knowing where each lives: the tab bar, the history panel, the bookmarks sidebar, or a menu and its shortcut. A single keyboard-driven command bar (⌘K) lets the user type a few letters and act on any of them from one place.

## What Changes

- Add a floating command bar opened with ⌘K ("Command Bar…" in the Navigation menu); ⌘K again, Escape or clicking outside closes it
- Search in one list, grouped by kind: open tabs in the current window, commands, bookmarks and history
- Rank results case-insensitively, prefix matches above substring matches, at most 12 rows shared across groups
- When nothing matches exactly, offer a first row "Search for “…”" / "Go to …" that behaves like submitting the URL bar
- Up/Down move the selection, Return runs it; ⌘-Return (or ⌘-click) opens a bookmark, history entry or search in a new tab
- Keep the command list in one data structure (`BrowserCommand.all`) so later features can add entries

## Capabilities

### New Capabilities
- `command-bar`: ⌘K palette that searches tabs, commands, bookmarks and history and runs the selected result

### Modified Capabilities

_(none — no existing spec requirements change)_

## Impact

- **CommandBar.swift** (new): `BrowserCommand` list, `CommandBarSearch` ranking, and the `CommandBar` overlay view
- **AppFeature.swift**: `toggleCommandBar` action and `toggleCommandBarTrigger` counter
- **ContentView.swift**: shows the command bar as an overlay when the trigger changes
- **BrowserApp.swift**: "Command Bar…" menu item with ⌘K
- Reuses `SuggestionEngine` for history and bookmark matching; no new dependencies

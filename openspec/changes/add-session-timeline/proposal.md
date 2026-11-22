## Why

Session persistence only remembers the windows that were open at quit. Once a tab group or a window is closed, or tabs drift over an afternoon, there is no way back to "what I had open at 3pm". Reopen Closed Tab only covers single tabs and is lost on quit.

## What Changes

- Take automatic snapshots of every open normal window (tabs, groups, selected tab, accent color — the existing `SessionData`) every 5 minutes, and right before a window or a tab group is closed
- Skip a snapshot when nothing changed since the last one (tab URLs/titles and groups), or when no tab has a page; never include private windows
- Keep snapshots for 7 days, at most 500, pruned on save; stored as JSON in `Application Support/Browser/timeline.json`, written off the main thread
- Add History > Session Timeline… (⌥⌘Y): a sheet listing snapshots newest first, grouped by day, each showing the time, window/tab counts and the first few tabs with favicons; selecting one shows its windows, groups and tabs
- "Restore" opens each snapshot window as a new window and leaves current windows alone; "Restore Tab" opens one tab in the window the sheet belongs to
- Extend `WindowRegistry` with a small timeline restore queue that newly opened windows claim on appear (via `.restoreSession`), alongside the launch-time restore

## Capabilities

### New Capabilities
- `session-timeline`: Periodic and pre-close snapshots of normal windows, retention and pruning, a timeline browser, and restoring snapshots as new windows or single tabs

### Modified Capabilities
_None -- launch-time session restore behaves as before._

## Impact

- **New file `TimelineStore.swift`**: `TimelineSnapshot` model, snapshot timer, dedup, pruning, background JSON persistence, `SessionData.withFreshIDs()` so restored tabs never share IDs with open ones
- **New file `TimelineView.swift`**: the Session Timeline sheet
- **WindowRegistry.swift**: `normalWindowSessions()`, `queueTimelineRestore` / `nextTimelineRestore` / `hasTimelineRestore`, snapshot before a normal window unregisters
- **BrowserWindow.swift**: claims a queued timeline window on appear; presents the sheet
- **AppFeature.swift**: `showSessionTimeline` state flag
- **BrowserApp.swift**: menu item and starting the snapshot timer
- **ContentView.swift**: snapshot before Close Group
- No new dependencies

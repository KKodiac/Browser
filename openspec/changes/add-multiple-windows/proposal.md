## Why

The browser currently supports only a single window. Users who multitask across different contexts (e.g., research in one window, documentation in another) are forced to cram everything into one tab bar. This is a fundamental limitation for a macOS browser, where multiple windows are a standard expectation. Supporting multiple windows lets users spatially organize their work across the screen with separate tab bars and groups per window.

## What Changes

- Modify BrowserApp to support multiple windows via SwiftUI `WindowGroup`, with each window receiving its own independent state
- Extract per-window state (tabs, groups, selected tab, URL bar text) from ContentView into a `WindowState` model so each window is self-contained
- Add Cmd+N to open a new browser window with a default empty tab
- Support moving tabs between windows via drag-and-drop using `NSItemProvider`
- Handle window close lifecycle: closing a window closes all its tabs and releases its state

## Capabilities

### New Capabilities
- `multiple-windows`: Multi-window lifecycle management (open, close), per-window state isolation, cross-window tab transfer via drag-and-drop, and Cmd+N keyboard shortcut

### Modified Capabilities
_None -- no existing spec requirements change._

## Impact

- **BrowserApp.swift**: Change from single shared `Store` to per-window state creation; re-enable Cmd+N via `CommandGroup(replacing: .newItem)` or add explicit new-window command
- **ContentView.swift**: Receives its own store/state per window instance instead of sharing a single store; must handle incoming tab drops from other windows
- **BrowserTab.swift**: May need `Transferable` or `NSItemProvider` support for cross-window drag
- **New file**: `WindowState` or equivalent model to encapsulate per-window tab/group state
- No new dependencies -- uses SwiftUI `WindowGroup` and existing `NSItemProvider` patterns

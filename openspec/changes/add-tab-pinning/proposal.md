## Why

Users have no way to keep important tabs persistently accessible. Frequently used tabs (e.g., email, chat, dashboards) get lost in a growing tab bar and can be accidentally closed. Tab pinning lets users lock important tabs to a fixed position at the left edge of the tab bar as compact, hard-to-close items.

## What Changes

- Add an `isPinned` property to `BrowserTab` to track pin state
- Render pinned tabs as compact (narrow, fixed-width) items at the leading edge of the tab bar, before any ungrouped or grouped tabs
- Pinned tabs cannot be closed via the tab close button (no "x" shown)
- Pinned tabs are excluded from tab groups — pinning a grouped tab removes it from its group
- Add pin/unpin actions via context menu on tabs
- Navigation within a pinned tab works normally (clicking links opens in the same pinned tab)

## Capabilities

### New Capabilities
- `tab-pinning`: Pin/unpin model property, pinned tab behavior (close protection, group exclusion), and pinned tab ordering

### Modified Capabilities
- `tab-group-ui`: Tab bar layout updated to render a fixed pinned-tabs section at the leading edge, before any groups or ungrouped tabs

## Impact

- **BrowserTab.swift**: Add `isPinned: Bool` property with default `false`
- **ContentView.swift**: Tab bar layout changes (pinned section at left), context menu additions (Pin Tab / Unpin Tab), pinned tab rendering as compact items, drag constraint updates
- **AppFeature** (TCA reducer): New actions for pin/unpin, state management for pinned tab ordering

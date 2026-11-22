## Why

The browser currently shows one tab at a time in the content area. Users who need to compare pages, reference documentation while working, or cross-check information must switch back and forth between tabs. Split view lets users display two tabs side-by-side in a single window, eliminating context switching for common research and comparison workflows.

## What Changes

- Add a split view mode that displays two tabs side-by-side using `HSplitView`
- Introduce a primary/secondary tab selection model to track which tab appears in each pane
- Add "Open in Split View" action via tab context menu
- Add a close button and menu item to exit split view and return to single-tab mode
- Update the URL bar to reflect the active pane's URL
- Visually indicate which pane is currently active

## Capabilities

### New Capabilities
- `split-view`: Side-by-side tab display with primary/secondary pane management, active pane tracking, and split view lifecycle (enter/exit)

### Modified Capabilities
_None — no existing spec requirements change._

## Impact

- **ContentView.swift**: Content area layout changes from single `ZStack` of WebViews to conditional `HSplitView` with two WebView panes. Tab selection model extends to support primary and secondary selected tabs. URL bar binds to the active pane's tab.
- **AppFeature** (TCA reducer): New state for split mode, secondary tab ID, active pane. New actions for entering/exiting split view and switching active pane.
- No new dependencies — uses only SwiftUI's built-in `HSplitView`

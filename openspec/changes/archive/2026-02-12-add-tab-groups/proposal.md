## Why

The browser currently has a flat list of tabs with no organizational structure. As users open more tabs, the tab bar becomes cluttered and hard to navigate. Tab groups let users organize related tabs together with labels and colors, making it easy to visually separate contexts (e.g., "Work", "Research", "Social").

## What Changes

- Add a `TabGroup` model that holds a label, color, and ordered list of tab references
- Modify the tab bar to render tabs nested within their groups, with colored group headers
- Add UI for creating a new group (right-click tab → "Add to New Group", or drag tabs together)
- Add UI for renaming and changing the color of an existing group
- Add ability to ungroup tabs (move back to ungrouped)
- Add ability to close an entire group (closes all tabs in the group)
- Ungrouped tabs remain at the top level as they do today

## Capabilities

### New Capabilities
- `tab-grouping`: Core tab group model, group lifecycle (create, rename, recolor, delete/ungroup), and the relationship between tabs and groups
- `tab-group-ui`: Tab bar visual changes including group headers with color indicators, collapsible group sections, and context menu interactions for group management

### Modified Capabilities
_None — no existing specs to modify._

## Impact

- **BrowserTab.swift**: Add optional group association to the tab model
- **ContentView.swift**: Major changes to tab bar rendering (grouped layout), state management (`tabs` array replaced or supplemented by group-aware structure), context menus, and tab lifecycle methods (`addTab`, `closeTab`)
- **BrowserApp.swift**: Potential new keyboard shortcuts for group operations
- No new dependencies — uses only SwiftUI and Foundation

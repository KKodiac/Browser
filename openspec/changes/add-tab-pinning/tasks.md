## 1. Model Changes

- [x] 1.1 Add `isPinned: Bool` property to `BrowserTab` struct with default value `false`
- [x] 1.2 Add `isPinned` parameter to `BrowserTab.init` with default `false`

## 2. Tab Bar Layout

- [x] 2.1 Add computed property to derive pinned tabs (filtered from `ungroupedTabs` where `isPinned == true`)
- [x] 2.2 Add computed property to derive non-pinned ungrouped tabs (filtered from `ungroupedTabs` where `isPinned == false`)
- [x] 2.3 Update tab bar to render pinned tabs first in a compact fixed-width style, followed by a visual separator, then unpinned ungrouped tabs, then groups
- [x] 2.4 Create `pinnedTabButton(_:)` view rendering a narrow fixed-width tab without a close button

## 3. Pin/Unpin Actions

- [x] 3.1 Add `pinTab(id:)` action to `AppFeature` that sets `isPinned = true` and removes the tab from any group
- [x] 3.2 Add `unpinTab(id:)` action to `AppFeature` that sets `isPinned = false`
- [x] 3.3 Handle empty group deletion when pinning the last tab in a group

## 4. Context Menus

- [x] 4.1 Add "Pin Tab" option to the ungrouped tab context menu
- [x] 4.2 Add "Pin Tab" option to the grouped tab context menu
- [x] 4.3 Replace ungrouped/grouped context menu with pinned tab context menu showing only "Unpin Tab" (no "Close Tab", no group options) for pinned tabs
- [x] 4.4 Update ungrouped tab context menu to exclude pinned tabs from group-add options

## 5. Drag Constraints

- [x] 5.1 Prevent pinned tabs from being dragged into groups (reject drop on group targets)
- [x] 5.2 Prevent unpinned tabs from being dropped into the pinned section

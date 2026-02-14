## 1. Models

- [x] 1.1 Create `GroupColor` enum with 8 cases (red, orange, yellow, green, blue, purple, pink, gray) and a computed `Color` property for each
- [x] 1.2 Create `TabGroup` `@Observable` class with `id: UUID`, `label: String`, `color: GroupColor`, `isCollapsed: Bool`, and `tabs: [BrowserTab]`

## 2. State Management

- [x] 2.1 Replace `tabs: [BrowserTab]` in ContentView with `ungroupedTabs: [BrowserTab]` and `tabGroups: [TabGroup]`
- [x] 2.2 Add computed `allTabs` property that flattens ungrouped tabs and all group tabs
- [x] 2.3 Update `selectedTab` to search across both `ungroupedTabs` and `tabGroups`
- [x] 2.4 Update `addTab()` to append new tabs to `ungroupedTabs`
- [x] 2.5 Update `closeTab(_:)` to remove tabs from either `ungroupedTabs` or the containing group, and delete empty groups

## 3. Group Lifecycle

- [x] 3.1 Add `createGroup(from:)` method that creates a new `TabGroup` with a tab moved from ungrouped
- [x] 3.2 Add `addTab(_:toGroup:)` method that moves an ungrouped tab into an existing group
- [x] 3.3 Add `removeTabFromGroup(_:)` method that moves a tab back to ungrouped and deletes the group if empty
- [x] 3.4 Add `renameGroup(_:to:)` method
- [x] 3.5 Add `changeGroupColor(_:to:)` method
- [x] 3.6 Add `closeGroup(_:)` method that closes all tabs in a group and deletes it, selecting a fallback tab
- [x] 3.7 Add `ungroupAll(_:)` method that moves all tabs from a group back to ungrouped and deletes the group

## 4. Tab Bar UI

- [x] 4.1 Update tab bar to render `ungroupedTabs` first, then each `TabGroup`
- [x] 4.2 Create `groupHeader(_:)` view with disclosure chevron, colored dot, and label text
- [x] 4.3 Add tap gesture on group header to toggle `isCollapsed`
- [x] 4.4 Conditionally hide group tabs when `isCollapsed` is true
- [x] 4.5 Add colored left border or background tint to grouped tab buttons matching their group's color

## 5. Context Menus

- [x] 5.1 Add context menu on ungrouped tabs: "Add to New Group", submenu of existing groups, "Close Tab"
- [x] 5.2 Add context menu on grouped tabs: "Remove from Group", "Close Tab"
- [x] 5.3 Add context menu on group headers: "Rename", "Change Color" (color submenu), "Ungroup All", "Close Group"
- [x] 5.4 Implement inline text field for group rename interaction

## 6. Content Area

- [x] 6.1 Update `contentArea` to iterate over `allTabs` instead of the old `tabs` array
- [x] 6.2 Verify selected tab in a collapsed group still renders its web content

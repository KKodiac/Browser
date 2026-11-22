## ADDED Requirements

### Requirement: Pin tab action
The system SHALL allow the user to pin an unpinned tab. Pinning a tab SHALL set its `isPinned` property to `true`.

#### Scenario: Pin an ungrouped tab
- **WHEN** the user chooses "Pin Tab" on an unpinned, ungrouped tab
- **THEN** the tab's `isPinned` SHALL be set to `true` and the tab SHALL move to the pinned section of the tab bar

#### Scenario: Pin a grouped tab
- **WHEN** the user chooses "Pin Tab" on a tab that belongs to a group
- **THEN** the tab SHALL be removed from its group, its `isPinned` SHALL be set to `true`, and the tab SHALL move to the pinned section of the tab bar

#### Scenario: Pin last tab in a group
- **WHEN** the user pins the last remaining tab in a group
- **THEN** the tab SHALL be pinned and the now-empty group SHALL be automatically deleted

### Requirement: Unpin tab action
The system SHALL allow the user to unpin a pinned tab. Unpinning a tab SHALL set its `isPinned` property to `false`.

#### Scenario: Unpin a pinned tab
- **WHEN** the user chooses "Unpin Tab" on a pinned tab
- **THEN** the tab's `isPinned` SHALL be set to `false` and the tab SHALL move from the pinned section to the ungrouped section of the tab bar

### Requirement: Pinned tab display
Pinned tabs SHALL render as compact, narrow fixed-width items that are visually distinct from regular tabs.

#### Scenario: Pinned tab appearance
- **WHEN** a tab is pinned
- **THEN** the tab SHALL render at a narrow fixed width, display a truncated title or favicon, and SHALL NOT display a close button

#### Scenario: Pinned tab selection
- **WHEN** the user clicks a pinned tab
- **THEN** the pinned tab SHALL become the selected tab and its web content SHALL display in the content area

### Requirement: Pinned tabs stay left of unpinned tabs
Pinned tabs SHALL always appear at the leading edge of the tab bar, before any ungrouped or grouped tabs.

#### Scenario: Tab bar ordering with pinned tabs
- **WHEN** the tab bar renders with both pinned and unpinned tabs
- **THEN** all pinned tabs SHALL appear first (at the leading edge), followed by ungrouped tabs, followed by tab groups

#### Scenario: Newly pinned tab position
- **WHEN** a tab is pinned
- **THEN** the tab SHALL be appended to the end of the pinned section (rightmost among pinned tabs)

### Requirement: Pinned tabs excluded from tab groups
Pinned tabs SHALL NOT belong to any tab group. The context menu for pinned tabs SHALL NOT offer group-related options.

#### Scenario: Context menu on pinned tab
- **WHEN** the user right-clicks a pinned tab
- **THEN** the context menu SHALL show "Unpin Tab" and SHALL NOT show "Add to New Group", "Add to Group", or "Close Tab"

#### Scenario: Drag pinned tab to group
- **WHEN** the user attempts to drag a pinned tab into a group
- **THEN** the system SHALL NOT allow the drop and the tab SHALL remain pinned

### Requirement: Pinned tab navigation
Clicking links within a pinned tab SHALL navigate within the same pinned tab. The pinned tab SHALL NOT spawn new tabs for in-page navigation.

#### Scenario: Navigate within pinned tab
- **WHEN** the user clicks a link in a pinned tab's web content
- **THEN** the pinned tab SHALL navigate to the new URL and SHALL remain pinned

### Requirement: Pinned tab close protection
Pinned tabs SHALL NOT be closable via the tab close button or the "Close Tab" context menu action.

#### Scenario: No close button on pinned tab
- **WHEN** a pinned tab is selected
- **THEN** the tab SHALL NOT display a close button (x icon)

#### Scenario: Close group containing no pinned tabs
- **WHEN** the user closes a tab group
- **THEN** only unpinned tabs in the group SHALL be closed; pinned tabs are never in groups so this operation does not affect pinned tabs

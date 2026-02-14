## ADDED Requirements

### Requirement: Tab group model
The system SHALL provide a `TabGroup` model that holds a unique identifier, a user-editable label, a color from a fixed palette, a collapsed state, and an ordered list of `BrowserTab` references.

#### Scenario: New group created with defaults
- **WHEN** a new tab group is created
- **THEN** it SHALL have a unique UUID, a default label of "New Group", a default color of blue, collapsed set to false, and an empty tab list

### Requirement: Fixed color palette
The system SHALL offer exactly 8 group colors: red, orange, yellow, green, blue, purple, pink, and gray.

#### Scenario: Color options available
- **WHEN** a user selects a color for a group
- **THEN** the system SHALL present exactly 8 color options: red, orange, yellow, green, blue, purple, pink, gray

### Requirement: Create group from tab
The system SHALL allow creating a new group from an existing ungrouped tab. The tab SHALL be moved into the new group.

#### Scenario: Create group from ungrouped tab
- **WHEN** the user chooses "Add to New Group" on an ungrouped tab
- **THEN** a new group SHALL be created with default label and color, and the tab SHALL be moved from the ungrouped list into the new group

### Requirement: Add tab to existing group
The system SHALL allow adding an ungrouped tab to an existing group.

#### Scenario: Add ungrouped tab to group
- **WHEN** the user chooses "Add to [group name]" on an ungrouped tab
- **THEN** the tab SHALL be removed from the ungrouped list and appended to the end of the selected group's tab list

### Requirement: Remove tab from group
The system SHALL allow removing a tab from its group, returning it to the ungrouped list.

#### Scenario: Ungroup a single tab
- **WHEN** the user chooses "Remove from Group" on a grouped tab
- **THEN** the tab SHALL be removed from its group and appended to the ungrouped tab list

#### Scenario: Last tab removed from group
- **WHEN** the user removes the last tab from a group
- **THEN** the empty group SHALL be automatically deleted

### Requirement: Rename group
The system SHALL allow renaming a group's label.

#### Scenario: Rename via context menu
- **WHEN** the user chooses "Rename" on a group header and enters a new name
- **THEN** the group's label SHALL be updated to the new name

### Requirement: Change group color
The system SHALL allow changing a group's color.

#### Scenario: Change color via context menu
- **WHEN** the user chooses "Change Color" on a group header and selects a new color
- **THEN** the group's color SHALL be updated to the selected color

### Requirement: Close group
The system SHALL allow closing an entire group, which closes all tabs within it and deletes the group.

#### Scenario: Close group with tabs
- **WHEN** the user chooses "Close Group" on a group
- **THEN** all tabs in the group SHALL be closed and the group SHALL be deleted

#### Scenario: Close group when selected tab is inside
- **WHEN** the user closes a group that contains the currently selected tab
- **THEN** the selected tab SHALL change to the first available tab (ungrouped or in another group), or a new empty tab SHALL be created if no tabs remain

### Requirement: Ungroup all tabs
The system SHALL allow ungrouping all tabs in a group, moving them back to the ungrouped list and deleting the group.

#### Scenario: Ungroup all
- **WHEN** the user chooses "Ungroup All" on a group header
- **THEN** all tabs in the group SHALL be moved to the ungrouped list and the group SHALL be deleted

### Requirement: New tab creation
When a new tab is created, it SHALL be added to the ungrouped list by default.

#### Scenario: Add new tab
- **WHEN** the user clicks the "+" button to add a new tab
- **THEN** the new tab SHALL appear in the ungrouped tab list, not in any group

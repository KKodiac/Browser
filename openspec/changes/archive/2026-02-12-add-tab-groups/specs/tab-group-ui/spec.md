## ADDED Requirements

### Requirement: Tab bar layout with groups
The tab bar SHALL render ungrouped tabs first, followed by each group. Groups SHALL be visually separated from ungrouped tabs and from each other.

#### Scenario: Mixed ungrouped and grouped tabs
- **WHEN** the tab bar renders with both ungrouped tabs and groups
- **THEN** ungrouped tabs SHALL appear first, followed by each group with its header and contained tabs

### Requirement: Group header display
Each group SHALL display a header row showing a disclosure chevron, a colored indicator matching the group's color, and the group's label.

#### Scenario: Group header rendering
- **WHEN** a group is displayed in the tab bar
- **THEN** its header SHALL show a chevron icon, a circle or dot in the group's color, and the group's label text

### Requirement: Group collapse and expand
Clicking the disclosure chevron or group header SHALL toggle the group's collapsed state, hiding or showing its tabs.

#### Scenario: Collapse a group
- **WHEN** the user clicks the chevron on an expanded group
- **THEN** the group's tabs SHALL be hidden from the tab bar and the chevron SHALL point in the collapsed direction

#### Scenario: Expand a collapsed group
- **WHEN** the user clicks the chevron on a collapsed group
- **THEN** the group's tabs SHALL become visible in the tab bar and the chevron SHALL point in the expanded direction

#### Scenario: Selected tab in collapsed group
- **WHEN** the selected tab belongs to a collapsed group
- **THEN** the tab's web content SHALL remain visible in the content area even though the tab is hidden in the tab bar

### Requirement: Group color indicator on tabs
Tabs within a group SHALL display a subtle visual indicator of their group's color (e.g., a colored left border or background tint).

#### Scenario: Grouped tab appearance
- **WHEN** a tab belongs to a group
- **THEN** the tab button SHALL display a colored left border or subtle background tint matching the group's color

### Requirement: Context menu on ungrouped tabs
Right-clicking an ungrouped tab SHALL show a context menu with options to add the tab to a new group or to an existing group.

#### Scenario: Context menu with no existing groups
- **WHEN** the user right-clicks an ungrouped tab and no groups exist
- **THEN** the context menu SHALL show "Add to New Group" and "Close Tab"

#### Scenario: Context menu with existing groups
- **WHEN** the user right-clicks an ungrouped tab and groups exist
- **THEN** the context menu SHALL show "Add to New Group", a submenu listing each existing group by name, and "Close Tab"

### Requirement: Context menu on grouped tabs
Right-clicking a grouped tab SHALL show a context menu with options to remove the tab from its group and close the tab.

#### Scenario: Context menu on grouped tab
- **WHEN** the user right-clicks a tab that belongs to a group
- **THEN** the context menu SHALL show "Remove from Group" and "Close Tab"

### Requirement: Context menu on group headers
Right-clicking a group header SHALL show a context menu with group management options.

#### Scenario: Group header context menu
- **WHEN** the user right-clicks a group header
- **THEN** the context menu SHALL show "Rename", "Change Color" (with color submenu), "Ungroup All", and "Close Group"

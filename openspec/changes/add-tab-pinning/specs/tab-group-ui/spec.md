## MODIFIED Requirements

### Requirement: Tab bar layout with groups and pinned tabs
The tab bar SHALL render pinned tabs in a fixed section at the leading edge, followed by ungrouped tabs, followed by each group. Pinned tabs, ungrouped tabs, and groups SHALL be visually separated from each other.

#### Scenario: Tab bar with pinned, ungrouped, and grouped tabs
- **WHEN** the tab bar renders with pinned tabs, ungrouped tabs, and groups
- **THEN** pinned tabs SHALL appear first at the leading edge as compact items, followed by ungrouped tabs, followed by each group with its header and contained tabs

#### Scenario: Tab bar with only pinned tabs
- **WHEN** all tabs are pinned and no ungrouped or grouped tabs exist
- **THEN** the tab bar SHALL show only the pinned section followed by the add-tab button

#### Scenario: Visual separation of pinned section
- **WHEN** pinned tabs and unpinned tabs are both present in the tab bar
- **THEN** a visual divider or spacing SHALL separate the pinned section from the ungrouped section

### Requirement: Context menu on ungrouped tabs includes pin option
Right-clicking an ungrouped tab SHALL include a "Pin Tab" option in its context menu.

#### Scenario: Context menu with pin option
- **WHEN** the user right-clicks an unpinned, ungrouped tab
- **THEN** the context menu SHALL show "Pin Tab" in addition to the existing group and close options

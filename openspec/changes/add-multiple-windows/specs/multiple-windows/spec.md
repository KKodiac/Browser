## ADDED Requirements

### Requirement: New window creation
The system SHALL allow the user to open a new browser window via Cmd+N. Each new window SHALL start with a single empty tab.

#### Scenario: Open new window via keyboard shortcut
- **WHEN** the user presses Cmd+N
- **THEN** a new browser window SHALL open with its own tab bar containing a single empty tab

#### Scenario: Multiple windows open simultaneously
- **WHEN** the user opens multiple new windows
- **THEN** each window SHALL be independently usable with its own tab bar, URL bar, and content area

### Requirement: Independent window state
Each window SHALL have its own independent set of tabs, tab groups, selected tab, and URL bar text. Changes in one window SHALL NOT affect any other window.

#### Scenario: Tabs are window-scoped
- **WHEN** the user adds a tab in Window A
- **THEN** the new tab SHALL appear only in Window A and SHALL NOT appear in Window B

#### Scenario: Groups are window-scoped
- **WHEN** the user creates a tab group in Window A
- **THEN** the group SHALL exist only in Window A and SHALL NOT appear in Window B

#### Scenario: Selection is window-scoped
- **WHEN** the user selects a tab in Window A
- **THEN** the selected tab in Window B SHALL remain unchanged

### Requirement: Close window closes its tabs
When a window is closed, all tabs and tab groups within that window SHALL be closed and their resources released.

#### Scenario: Close window with multiple tabs
- **WHEN** the user closes a window containing 5 tabs and 2 groups
- **THEN** all 5 tabs and 2 groups SHALL be disposed and their WebViews released

#### Scenario: Close last window
- **WHEN** the user closes the last remaining window
- **THEN** the application SHALL terminate (standard macOS behavior)

### Requirement: Move tab between windows via drag-and-drop
The system SHALL allow the user to drag a tab from one window and drop it into another window's tab bar. The tab SHALL be removed from the source window and added to the target window.

#### Scenario: Drag ungrouped tab to another window
- **WHEN** the user drags an ungrouped tab from Window A and drops it on Window B's tab bar
- **THEN** the tab SHALL be removed from Window A and a new tab SHALL be created in Window B with the same URL and title

#### Scenario: Drag grouped tab to another window
- **WHEN** the user drags a grouped tab from Window A and drops it on Window B's tab bar
- **THEN** the tab SHALL be removed from its group in Window A (deleting the group if it was the last tab) and a new ungrouped tab SHALL be created in Window B with the same URL and title

#### Scenario: Source window after tab transfer
- **WHEN** a tab is moved to another window and it was the last tab in the source window
- **THEN** the source window SHALL create a new empty tab to maintain the minimum one tab requirement

### Requirement: Minimum one tab per window
Each window SHALL always contain at least one tab. If the last tab is closed or moved to another window, a new empty tab SHALL be created automatically.

#### Scenario: Close last tab in window
- **WHEN** the user closes the only remaining tab in a window
- **THEN** a new empty tab SHALL be created and selected in that window

#### Scenario: Move last tab out of window
- **WHEN** the user drags the only remaining tab to another window
- **THEN** the source window SHALL create a new empty tab after the transfer completes

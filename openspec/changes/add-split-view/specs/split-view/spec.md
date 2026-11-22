## ADDED Requirements

### Requirement: Enter split view
The system SHALL allow the user to enter split view from a tab's context menu by selecting "Open in Split View". The right-clicked tab SHALL become the secondary pane tab, and the currently selected tab SHALL remain in the primary pane.

#### Scenario: Open tab in split view
- **WHEN** the user right-clicks a tab and selects "Open in Split View"
- **THEN** the content area SHALL display two panes side-by-side, with the previously selected tab in the primary (left) pane and the right-clicked tab in the secondary (right) pane

#### Scenario: Open in split view on the already-selected tab
- **WHEN** the user right-clicks the currently selected tab and selects "Open in Split View"
- **THEN** the system SHALL NOT enter split view, because primary and secondary would be the same tab

### Requirement: Display two tabs side-by-side
When split view is active, the content area SHALL display two tabs side-by-side in a horizontal split layout, with the primary tab on the left and the secondary tab on the right.

#### Scenario: Split view layout
- **WHEN** split view is active
- **THEN** the content area SHALL show an `HSplitView` with the primary tab's WebView on the left and the secondary tab's WebView on the right

### Requirement: Independent pane navigation
Each pane SHALL support independent navigation. Navigation controls (back, forward, reload) in the URL bar SHALL operate on the active pane's tab.

#### Scenario: Navigate in the active pane
- **WHEN** the user submits a URL in the URL bar while the secondary pane is active
- **THEN** the secondary pane's tab SHALL navigate to the submitted URL, and the primary pane's tab SHALL remain unchanged

### Requirement: Close split view
The system SHALL allow the user to close split view and return to single-tab mode. The primary pane's tab SHALL remain selected.

#### Scenario: Close split view via button
- **WHEN** the user clicks the close button on the secondary pane
- **THEN** split view SHALL be deactivated and the content area SHALL return to showing only the primary pane's tab

#### Scenario: Close split view via menu
- **WHEN** the user selects "Close Split View" from the View menu
- **THEN** split view SHALL be deactivated and the content area SHALL return to showing only the primary pane's tab

#### Scenario: Close the secondary pane's tab
- **WHEN** the user closes the tab that is displayed in the secondary pane (via tab bar close button)
- **THEN** split view SHALL be deactivated and the content area SHALL return to showing only the primary pane's tab

#### Scenario: Close the primary pane's tab
- **WHEN** the user closes the tab that is displayed in the primary pane (via tab bar close button)
- **THEN** the secondary pane's tab SHALL be promoted to the primary selection, split view SHALL be deactivated, and the content area SHALL show the promoted tab

### Requirement: URL bar shows active pane's URL
The URL bar SHALL display the URL of the tab in the currently active pane.

#### Scenario: Switch active pane updates URL bar
- **WHEN** the user clicks in the secondary pane to make it active
- **THEN** the URL bar text SHALL update to show the secondary pane's tab URL

#### Scenario: Active pane navigates
- **WHEN** the active pane's tab navigates to a new page
- **THEN** the URL bar text SHALL update to reflect the new URL

### Requirement: Active pane indicated visually
The system SHALL visually indicate which pane is currently active using an accent-colored border.

#### Scenario: Primary pane active
- **WHEN** the primary pane is the active pane
- **THEN** the primary pane SHALL display a subtle accent-colored border, and the secondary pane SHALL NOT

#### Scenario: Secondary pane active
- **WHEN** the user clicks in the secondary pane
- **THEN** the secondary pane SHALL display a subtle accent-colored border, and the primary pane SHALL NOT

#### Scenario: Default active pane on entering split view
- **WHEN** split view is activated
- **THEN** the primary (left) pane SHALL be the active pane by default

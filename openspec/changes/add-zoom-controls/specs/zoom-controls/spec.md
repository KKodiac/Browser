## ADDED Requirements

### Requirement: Per-tab zoom level
The system SHALL maintain a zoom level for each tab. The zoom level SHALL default to 1.0 (100%) and represent a multiplier applied to the page content.

#### Scenario: Default zoom level
- **WHEN** a new tab is created
- **THEN** its zoom level SHALL be 1.0

#### Scenario: Zoom level preserved on tab switch
- **WHEN** the user switches from a tab at 150% zoom to another tab and back
- **THEN** the first tab SHALL still be at 150% zoom

### Requirement: Zoom in
The system SHALL allow the user to zoom in on the current tab's page content via Cmd+Plus.

#### Scenario: Zoom in from default
- **WHEN** the user presses Cmd+Plus on a tab at 100% zoom
- **THEN** the tab's zoom level SHALL increase to 110%

#### Scenario: Zoom in from non-default
- **WHEN** the user presses Cmd+Plus on a tab at 140% zoom
- **THEN** the tab's zoom level SHALL increase to 150%

### Requirement: Zoom out
The system SHALL allow the user to zoom out on the current tab's page content via Cmd+Minus.

#### Scenario: Zoom out from default
- **WHEN** the user presses Cmd+Minus on a tab at 100% zoom
- **THEN** the tab's zoom level SHALL decrease to 90%

#### Scenario: Zoom out from non-default
- **WHEN** the user presses Cmd+Minus on a tab at 70% zoom
- **THEN** the tab's zoom level SHALL decrease to 60%

### Requirement: Reset zoom
The system SHALL allow the user to reset the current tab's zoom level to 100% via Cmd+0.

#### Scenario: Reset from zoomed in
- **WHEN** the user presses Cmd+0 on a tab at 150% zoom
- **THEN** the tab's zoom level SHALL be set to 1.0 (100%)

#### Scenario: Reset when already at default
- **WHEN** the user presses Cmd+0 on a tab at 100% zoom
- **THEN** the tab's zoom level SHALL remain at 1.0 (100%)

### Requirement: Zoom range limits
The system SHALL clamp the zoom level to a minimum of 50% and a maximum of 200%.

#### Scenario: Zoom in at maximum
- **WHEN** the user presses Cmd+Plus on a tab at 200% zoom
- **THEN** the tab's zoom level SHALL remain at 200%

#### Scenario: Zoom out at minimum
- **WHEN** the user presses Cmd+Minus on a tab at 50% zoom
- **THEN** the tab's zoom level SHALL remain at 50%

### Requirement: WKWebView pageZoom binding
The system SHALL apply the tab's zoom level to the `WKWebView.pageZoom` property so that the page content is visually scaled.

#### Scenario: Zoom applied to web view
- **WHEN** a tab's zoom level is changed to 1.5
- **THEN** the active WKWebView's `pageZoom` SHALL be set to 1.5

#### Scenario: Zoom applied on tab switch
- **WHEN** the user switches to a tab with a zoom level of 0.8
- **THEN** the WKWebView SHALL update its `pageZoom` to 0.8

### Requirement: Zoom indicator in URL bar
The system SHALL display the current zoom level as a percentage in the URL bar when the zoom level is not 100%.

#### Scenario: Indicator shown when zoomed
- **WHEN** a tab's zoom level is 150%
- **THEN** the URL bar SHALL display a "150%" indicator

#### Scenario: Indicator hidden at default zoom
- **WHEN** a tab's zoom level is 100%
- **THEN** the URL bar SHALL NOT display a zoom indicator

### Requirement: Menu bar zoom commands
The system SHALL provide zoom commands in the View menu: "Zoom In" (Cmd+Plus), "Zoom Out" (Cmd+Minus), and "Actual Size" (Cmd+0).

#### Scenario: Zoom in via menu
- **WHEN** the user selects "Zoom In" from the View menu
- **THEN** the current tab's zoom level SHALL increase by 10%

#### Scenario: Zoom out via menu
- **WHEN** the user selects "Zoom Out" from the View menu
- **THEN** the current tab's zoom level SHALL decrease by 10%

#### Scenario: Reset zoom via menu
- **WHEN** the user selects "Actual Size" from the View menu
- **THEN** the current tab's zoom level SHALL be set to 100%

### Requirement: Zoom step size
Each zoom in or zoom out action SHALL change the zoom level by exactly 10 percentage points (0.1 multiplier).

#### Scenario: Consistent step size
- **WHEN** the user zooms in three times from 100%
- **THEN** the zoom level SHALL be 130%

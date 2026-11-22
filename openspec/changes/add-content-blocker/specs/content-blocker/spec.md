## ADDED Requirements

### Requirement: Content rule compilation
The system SHALL compile content-blocking rules from a bundled JSON file into a `WKContentRuleList` using `WKContentRuleListStore`. Compilation SHALL occur at app launch.

#### Scenario: Rules compiled at launch
- **WHEN** the app launches
- **THEN** the system SHALL compile the bundled block list JSON into a `WKContentRuleList` and hold it in memory

#### Scenario: Compilation failure
- **WHEN** the block list JSON fails to compile
- **THEN** the system SHALL log the error and continue without content blocking (no crash)

### Requirement: Apply rules to web views
The system SHALL apply the compiled content rule list to all web views when content blocking is enabled.

#### Scenario: New web view with blocking enabled
- **WHEN** a new web view is created and content blocking is enabled
- **THEN** the compiled `WKContentRuleList` SHALL be added to the web view's user content controller

#### Scenario: New web view with blocking disabled
- **WHEN** a new web view is created and content blocking is disabled
- **THEN** no content rule list SHALL be added to the web view's user content controller

### Requirement: Toggle content blocking
The system SHALL allow the user to toggle content blocking on or off globally via a toolbar button. The toggle state SHALL persist across app launches.

#### Scenario: Disable content blocking
- **WHEN** the user toggles content blocking off
- **THEN** content rule lists SHALL be removed from all existing web views and the state SHALL be saved to UserDefaults

#### Scenario: Enable content blocking
- **WHEN** the user toggles content blocking on
- **THEN** the compiled content rule list SHALL be added to all existing web views and the state SHALL be saved to UserDefaults

#### Scenario: Toggle state persists
- **WHEN** the user disables content blocking and relaunches the app
- **THEN** content blocking SHALL remain disabled

#### Scenario: Default state
- **WHEN** the app launches for the first time
- **THEN** content blocking SHALL be enabled by default

### Requirement: Bundled default block list
The system SHALL bundle a default block list JSON file in the WebKit content blocker format. The list SHALL include rules for common ad-serving and tracker domains.

#### Scenario: Block list format
- **WHEN** the block list JSON is loaded
- **THEN** it SHALL be a valid JSON array of objects, each with a "trigger" and an "action" field conforming to the WebKit content blocker specification

#### Scenario: Block list coverage
- **WHEN** a page loads resources from known ad or tracker domains included in the block list
- **THEN** those resource requests SHALL be blocked and not loaded

### Requirement: Page load without blocked resources
The system SHALL load pages normally with blocked resources omitted. Blocking a resource SHALL not prevent the rest of the page from loading.

#### Scenario: Page loads with some resources blocked
- **WHEN** a page references both allowed and blocked resources
- **THEN** allowed resources SHALL load normally and blocked resources SHALL be silently dropped

#### Scenario: Page with no blocked resources
- **WHEN** a page references no resources matching the block list
- **THEN** the page SHALL load identically to when content blocking is disabled

### Requirement: Toolbar toggle indicator
The system SHALL display a shield icon in the toolbar that reflects the current content-blocking state.

#### Scenario: Blocking enabled indicator
- **WHEN** content blocking is enabled
- **THEN** the toolbar SHALL display a filled shield icon

#### Scenario: Blocking disabled indicator
- **WHEN** content blocking is disabled
- **THEN** the toolbar SHALL display an outlined (unfilled) shield icon

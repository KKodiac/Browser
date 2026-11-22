## ADDED Requirements

### Requirement: Session file storage
The system SHALL persist session state as a JSON file at `<Application Support>/Browser/session.json`.

#### Scenario: Storage file location
- **WHEN** the session is saved
- **THEN** the file SHALL be written to `<Application Support>/Browser/session.json`

#### Scenario: Application Support directory created if missing
- **WHEN** the session is saved and the `<Application Support>/Browser/` directory does not exist
- **THEN** the system SHALL create the directory before writing the file

### Requirement: Save session on app quit
The system SHALL save the current session state when the application terminates normally.

#### Scenario: Normal quit saves session
- **WHEN** the user quits the application
- **THEN** the system SHALL write the current session state (all tabs, tab groups, selected tab ID, and accent color) to the session file

### Requirement: Periodic session save
The system SHALL save the session state periodically during use to guard against data loss from crashes.

#### Scenario: Periodic save after state changes
- **WHEN** session-relevant state changes (tabs opened, closed, navigated, or groups modified) and at least 30 seconds have elapsed since the last save
- **THEN** the system SHALL write the current session state to the session file

### Requirement: Restore session on launch
The system SHALL restore the previous session state when the application launches, if a valid session file exists.

#### Scenario: Restore tabs and groups from session file
- **WHEN** the application launches and a valid `session.json` file exists
- **THEN** the system SHALL restore all tabs with their URLs and titles, all tab groups with their labels, colors, collapsed states, and tab membership, the previously selected tab, and the accent color

#### Scenario: Restored tabs reload their URLs
- **WHEN** a tab is restored from the session file with a non-nil URL
- **THEN** the tab's `requestedLoad` SHALL be set to `true` so the WebView loads the URL

### Requirement: Session includes tab data
The system SHALL persist each tab's `id`, `url`, `title`, and `suggestedURL`. Transient properties (`isLoading`, `canGoBack`, `canGoForward`, `requestedLoad`) SHALL NOT be persisted.

#### Scenario: Tab data round-trip
- **WHEN** a tab with URL "https://example.com" and title "Example" is saved and restored
- **THEN** the restored tab SHALL have the same `id`, `url`, `title`, and `suggestedURL` as the original

#### Scenario: Transient properties reset on restore
- **WHEN** a tab is restored from the session file
- **THEN** `isLoading` SHALL be `false`, `canGoBack` SHALL be `false`, and `canGoForward` SHALL be `false`

### Requirement: Session includes group data
The system SHALL persist each group's `id`, `label`, `color`, `isCollapsed` state, and ordered list of member tabs.

#### Scenario: Group data round-trip
- **WHEN** a group labeled "Work" with color red and two tabs is saved and restored
- **THEN** the restored group SHALL have the same label, color, collapsed state, and the same two tabs in the same order

### Requirement: Selected tab restored
The system SHALL persist and restore the `selectedTabId` so the previously active tab is selected on relaunch.

#### Scenario: Selected tab preserved
- **WHEN** the user has tab B selected, quits, and relaunches
- **THEN** tab B SHALL be the selected tab after restore

#### Scenario: Selected tab ID references a missing tab
- **WHEN** the restored `selectedTabId` does not match any restored tab
- **THEN** the system SHALL select the first available tab

### Requirement: Graceful handling of missing session file
The system SHALL start with default state (one blank tab) if no session file exists.

#### Scenario: First launch with no session file
- **WHEN** the application launches and no `session.json` file exists
- **THEN** the system SHALL start with a single blank tab, no groups, and default accent color

### Requirement: Graceful handling of corrupt session file
The system SHALL start with default state if the session file exists but cannot be decoded.

#### Scenario: Corrupt session file
- **WHEN** the application launches and `session.json` contains invalid or unparseable data
- **THEN** the system SHALL log a warning, discard the corrupt file, and start with default state

### Requirement: Atomic file writes
The system SHALL write the session file atomically to prevent corruption if the app is terminated during a write.

#### Scenario: Crash during write does not corrupt session
- **WHEN** the application crashes or is force-quit while a session save is in progress
- **THEN** the previous valid session file SHALL remain intact

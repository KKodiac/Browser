## ADDED Requirements

### Requirement: Preferences window via keyboard shortcut
The system SHALL provide a Preferences window accessible via the standard macOS Cmd+, keyboard shortcut.

#### Scenario: Open preferences
- **WHEN** the user presses Cmd+,
- **THEN** the Preferences window SHALL open

#### Scenario: Single instance
- **WHEN** the Preferences window is already open and the user presses Cmd+, again
- **THEN** the existing Preferences window SHALL be brought to front rather than opening a second window

### Requirement: Tabbed preferences layout
The Preferences window SHALL use a tabbed layout with three tabs: General, Appearance, and Privacy.

#### Scenario: Default tab
- **WHEN** the Preferences window opens
- **THEN** the General tab SHALL be selected by default

#### Scenario: Switch between tabs
- **WHEN** the user clicks a tab header (General, Appearance, or Privacy)
- **THEN** the corresponding tab content SHALL be displayed

### Requirement: General tab contents
The General tab SHALL contain settings for default search engine, home page URL, and default download location.

#### Scenario: Search engine picker
- **WHEN** the user views the General tab
- **THEN** a picker SHALL display the current search engine with options: Google, DuckDuckGo, Bing

#### Scenario: Home page text field
- **WHEN** the user views the General tab
- **THEN** a text field SHALL display the current home page URL (or be empty if unset)

#### Scenario: Download location selector
- **WHEN** the user views the General tab
- **THEN** a button or file picker SHALL display the current download folder path and allow selecting a new folder

### Requirement: Appearance tab contents
The Appearance tab SHALL contain the accent color picker and any future appearance settings.

#### Scenario: Accent color picker in Appearance tab
- **WHEN** the user views the Appearance tab
- **THEN** the accent color picker SHALL be displayed with all available accent colors

#### Scenario: Change accent color from Appearance tab
- **WHEN** the user selects a new accent color in the Appearance tab
- **THEN** the app's accent color SHALL update immediately across all windows

### Requirement: Privacy tab contents
The Privacy tab SHALL contain toggles for tracker blocking and clearing data on quit.

#### Scenario: Privacy toggles displayed
- **WHEN** the user views the Privacy tab
- **THEN** toggles for "Block Trackers" and "Clear Browsing Data on Quit" SHALL be displayed with their current states

#### Scenario: Toggle tracker blocking
- **WHEN** the user toggles "Block Trackers" in the Privacy tab
- **THEN** the setting SHALL update immediately and persist

#### Scenario: Toggle clear data on quit
- **WHEN** the user toggles "Clear Browsing Data on Quit" in the Privacy tab
- **THEN** the setting SHALL update immediately and persist

### Requirement: Settings persist via UserDefaults
All settings changed in the Preferences window SHALL be saved to UserDefaults immediately upon change. No explicit "Save" button SHALL be required.

#### Scenario: Immediate persistence
- **WHEN** the user changes any setting in the Preferences window
- **THEN** the change SHALL be written to UserDefaults immediately without requiring a save action

#### Scenario: Settings reflect in app
- **WHEN** the user changes the search engine in Preferences and returns to the browser window
- **THEN** the next search query SHALL use the newly selected engine

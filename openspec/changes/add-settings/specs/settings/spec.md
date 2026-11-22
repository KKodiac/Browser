## ADDED Requirements

### Requirement: Search engine setting
The system SHALL provide a setting to choose the default search engine from a list of preset options: Google, DuckDuckGo, and Bing.

#### Scenario: Default search engine
- **WHEN** the app launches for the first time
- **THEN** the default search engine SHALL be Google

#### Scenario: Search uses configured engine
- **WHEN** the user types a search query in the URL bar and submits
- **THEN** the system SHALL construct the search URL using the configured search engine's URL template

#### Scenario: Change search engine
- **WHEN** the user changes the search engine setting to DuckDuckGo
- **THEN** all subsequent searches SHALL use `https://duckduckgo.com/?q=`

#### Scenario: Search engine persists across launches
- **WHEN** the user sets the search engine to Bing and relaunches the app
- **THEN** the search engine SHALL still be set to Bing

### Requirement: Home page setting
The system SHALL provide a setting to configure a home page URL. New tabs SHALL optionally load this URL instead of showing a blank page.

#### Scenario: Default home page
- **WHEN** no home page has been configured
- **THEN** new tabs SHALL open as blank ("New Tab") as they do today

#### Scenario: Set home page
- **WHEN** the user sets the home page to "https://example.com"
- **THEN** new tabs SHALL load "https://example.com" automatically

#### Scenario: Invalid home page URL
- **WHEN** the user enters an invalid URL as the home page
- **THEN** the system SHALL not save the invalid URL and SHALL keep the previous value

### Requirement: Default download location
The system SHALL provide a setting to choose the default download location on disk.

#### Scenario: Default download location
- **WHEN** no download location has been configured
- **THEN** the default download location SHALL be the user's Downloads folder

#### Scenario: Change download location
- **WHEN** the user selects a new folder as the download location
- **THEN** subsequent downloads SHALL save to the selected folder

#### Scenario: Download location persists
- **WHEN** the user sets a download location and relaunches the app
- **THEN** the download location SHALL remain as configured

### Requirement: Block trackers setting
The system SHALL provide a toggle to enable or disable tracker blocking.

#### Scenario: Default tracker blocking state
- **WHEN** the app launches for the first time
- **THEN** tracker blocking SHALL be disabled by default

#### Scenario: Enable tracker blocking
- **WHEN** the user enables the "Block Trackers" toggle
- **THEN** the system SHALL configure WKWebView content rules to block known tracking scripts

#### Scenario: Tracker blocking persists
- **WHEN** the user enables tracker blocking and relaunches the app
- **THEN** the tracker blocking toggle SHALL remain enabled

### Requirement: Clear data on quit setting
The system SHALL provide a toggle to clear browsing data (cookies, cache, history) when the app quits.

#### Scenario: Default clear-on-quit state
- **WHEN** the app launches for the first time
- **THEN** the "Clear Data on Quit" toggle SHALL be disabled by default

#### Scenario: Enable clear data on quit
- **WHEN** the user enables "Clear Data on Quit" and quits the app
- **THEN** the system SHALL clear cookies, website data, and cache before termination

#### Scenario: Clear-on-quit persists
- **WHEN** the user enables "Clear Data on Quit" and relaunches the app
- **THEN** the toggle SHALL remain enabled

### Requirement: Settings persistence via UserDefaults
All settings SHALL be persisted to UserDefaults so they survive app restarts.

#### Scenario: All settings persist
- **WHEN** the user configures settings and relaunches the app
- **THEN** all settings (search engine, home page, download location, privacy toggles) SHALL retain their configured values

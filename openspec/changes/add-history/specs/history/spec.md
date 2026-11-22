## ADDED Requirements

### Requirement: HistoryEntry model
The system SHALL provide a `HistoryEntry` model with a unique ID, URL, title, and visit timestamp. URL and timestamp SHALL be required. Title SHALL default to the URL's hostname if unavailable.

#### Scenario: Create a history entry
- **WHEN** a history entry is created for URL "https://example.com" with title "Example"
- **THEN** it SHALL have a unique UUID, the given URL and title, and the current date/time as visit timestamp

#### Scenario: Create entry with no title
- **WHEN** a history entry is created for a page with no title
- **THEN** the title SHALL default to the URL's hostname (e.g., "example.com")

### Requirement: History storage
The system SHALL persist history entries to a JSON file in the app's Application Support directory. The file SHALL be loaded on app launch and saved when entries are added or removed.

#### Scenario: History persists across launches
- **WHEN** the user visits a page and relaunches the app
- **THEN** the visited page SHALL appear in the history list

#### Scenario: Storage file location
- **WHEN** history is saved
- **THEN** the file SHALL be written to `<Application Support>/Browser/history.json`

### Requirement: Automatic recording on navigation
The system SHALL automatically record a history entry when a page navigation commits. Each navigation SHALL create a new entry, even if the URL was previously visited.

#### Scenario: Navigate to a page
- **WHEN** the user navigates to "https://example.com"
- **THEN** a history entry SHALL be created with that URL and the current timestamp

#### Scenario: Visit same page twice
- **WHEN** the user navigates to "https://example.com" at 10:00 and again at 10:05
- **THEN** two separate history entries SHALL exist, each with its own timestamp

#### Scenario: Title updates after page load
- **WHEN** a page's title becomes available after the initial navigation commit
- **THEN** the most recent history entry for that navigation SHALL be updated with the page title

### Requirement: Search history
The system SHALL allow searching history entries by query string. The search SHALL match against both URL and title, case-insensitively.

#### Scenario: Search by title
- **WHEN** the user searches for "example"
- **THEN** all entries with "example" in the title SHALL be returned

#### Scenario: Search by URL
- **WHEN** the user searches for "github.com"
- **THEN** all entries with "github.com" in the URL SHALL be returned

#### Scenario: Empty search query
- **WHEN** the search query is empty
- **THEN** all history entries SHALL be returned (no filter applied)

### Requirement: Clear history by time range
The system SHALL allow clearing history by time range. Supported ranges SHALL include: last hour, today, and all time.

#### Scenario: Clear last hour
- **WHEN** the user clears history for "last hour"
- **THEN** all entries with a visit timestamp within the last 60 minutes SHALL be removed, and older entries SHALL remain

#### Scenario: Clear today
- **WHEN** the user clears history for "today"
- **THEN** all entries with a visit timestamp on the current calendar day SHALL be removed, and entries from previous days SHALL remain

#### Scenario: Clear all history
- **WHEN** the user clears "all" history
- **THEN** every history entry SHALL be removed and the storage file SHALL be emptied

### Requirement: Delete individual history entry
The system SHALL allow the user to delete a single history entry.

#### Scenario: Delete one entry
- **WHEN** the user deletes a specific history entry
- **THEN** that entry SHALL be removed from the history list and from persistent storage, and all other entries SHALL remain

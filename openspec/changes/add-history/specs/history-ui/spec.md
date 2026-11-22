## ADDED Requirements

### Requirement: History panel toggle
The system SHALL provide a history panel that can be toggled open and closed. The panel SHALL be accessible via the Cmd+Y keyboard shortcut and from the menu bar.

#### Scenario: Open history panel with keyboard shortcut
- **WHEN** the user presses Cmd+Y
- **THEN** the history panel SHALL become visible

#### Scenario: Close history panel with keyboard shortcut
- **WHEN** the history panel is visible and the user presses Cmd+Y
- **THEN** the history panel SHALL be dismissed

#### Scenario: Open history panel from menu bar
- **WHEN** the user selects "Show History" from the History menu
- **THEN** the history panel SHALL become visible

### Requirement: Search field in history panel
The system SHALL display a search field at the top of the history panel. Typing in the search field SHALL filter the displayed history entries in real time.

#### Scenario: Type search query
- **WHEN** the user types "swift" in the history search field
- **THEN** only history entries with "swift" in the title or URL SHALL be displayed

#### Scenario: Clear search query
- **WHEN** the user clears the search field
- **THEN** all history entries SHALL be displayed again, grouped by date

### Requirement: Grouped-by-date display
The system SHALL display history entries grouped by date with section headers. Entries from the current day SHALL appear under "Today", entries from the previous day under "Yesterday", and older entries under their formatted calendar date (e.g., "February 12, 2026"). Within each group, entries SHALL be ordered by timestamp, most recent first.

#### Scenario: Entries from today
- **WHEN** the history panel is open and there are entries from today
- **THEN** those entries SHALL appear under a "Today" section header, ordered most recent first

#### Scenario: Entries from yesterday
- **WHEN** there are entries from the previous calendar day
- **THEN** those entries SHALL appear under a "Yesterday" section header

#### Scenario: Entries from older dates
- **WHEN** there are entries from February 10, 2026
- **THEN** those entries SHALL appear under a "February 10, 2026" section header

### Requirement: Click history entry to navigate
The system SHALL allow the user to click a history entry to navigate to its URL. The URL SHALL load in the current tab.

#### Scenario: Click a history entry
- **WHEN** the user clicks a history entry with URL "https://example.com"
- **THEN** the current tab SHALL navigate to "https://example.com"

#### Scenario: Click entry while history panel is open
- **WHEN** the user clicks a history entry
- **THEN** the history panel SHALL be dismissed after navigation begins

### Requirement: Clear history controls
The system SHALL provide controls in the history panel to clear history by time range. The available options SHALL be "Last Hour", "Today", and "All History".

#### Scenario: Clear history button in panel
- **WHEN** the history panel is visible
- **THEN** a "Clear History" button or menu SHALL be present with options for "Last Hour", "Today", and "All History"

#### Scenario: Clear with confirmation
- **WHEN** the user selects "All History" from the clear options
- **THEN** the system SHALL remove all history entries and update the panel to show an empty state

### Requirement: Delete individual entry from panel
The system SHALL allow the user to delete a single history entry from the panel via context menu or swipe action.

#### Scenario: Right-click history entry
- **WHEN** the user right-clicks a history entry in the panel
- **THEN** a context menu SHALL appear with a "Delete" option

#### Scenario: Delete entry via context menu
- **WHEN** the user selects "Delete" from the context menu on a history entry
- **THEN** that entry SHALL be removed from the panel and from persistent storage

## ADDED Requirements

### Requirement: Find bar activation
The system SHALL display a find bar overlay when the user triggers the find action.

#### Scenario: Open find bar with Cmd+F
- **WHEN** the user presses Cmd+F
- **THEN** the find bar SHALL appear overlaid at the top of the content area with the text field focused

#### Scenario: Open find bar when already visible
- **WHEN** the user presses Cmd+F while the find bar is already visible
- **THEN** the find bar text field SHALL be re-focused and its contents SHALL be selected

### Requirement: Text search with highlighting
The system SHALL search the current web page for the text entered in the find bar and highlight matching occurrences.

#### Scenario: Search for text with matches
- **WHEN** the user types a search term in the find bar and the page contains matching text
- **THEN** the system SHALL highlight all matching occurrences on the page and scroll to the first match

#### Scenario: Search for text with no matches
- **WHEN** the user types a search term in the find bar and the page contains no matching text
- **THEN** the system SHALL display a match count of 0 and no highlights SHALL appear on the page

#### Scenario: Search with empty text
- **WHEN** the find bar text field is empty
- **THEN** no highlights SHALL appear on the page and the match count SHALL not be displayed

### Requirement: Match count display
The system SHALL display the total number of matches and the index of the currently active match.

#### Scenario: Display match count
- **WHEN** the user searches for text that has matches on the page
- **THEN** the find bar SHALL display the current match index and total count in the format "X of Y" (e.g., "1 of 5")

#### Scenario: Display zero matches
- **WHEN** the user searches for text that has no matches on the page
- **THEN** the find bar SHALL display "0 of 0" or a "No matches" indicator

### Requirement: Next and previous match navigation
The system SHALL allow the user to navigate between matches using keyboard shortcuts and buttons.

#### Scenario: Navigate to next match with Cmd+G
- **WHEN** the user presses Cmd+G while the find bar is visible and matches exist
- **THEN** the system SHALL advance to the next match, scroll it into view, and update the current match index

#### Scenario: Navigate to previous match with Cmd+Shift+G
- **WHEN** the user presses Cmd+Shift+G while the find bar is visible and matches exist
- **THEN** the system SHALL go back to the previous match, scroll it into view, and update the current match index

#### Scenario: Next match wraps around
- **WHEN** the user is on the last match and presses Cmd+G
- **THEN** the system SHALL wrap around to the first match

#### Scenario: Previous match wraps around
- **WHEN** the user is on the first match and presses Cmd+Shift+G
- **THEN** the system SHALL wrap around to the last match

#### Scenario: Navigate via find bar buttons
- **WHEN** the user clicks the next or previous button in the find bar
- **THEN** the system SHALL navigate to the corresponding match, equivalent to Cmd+G or Cmd+Shift+G

### Requirement: Dismiss find bar
The system SHALL dismiss the find bar and clear all highlights when the user presses Escape.

#### Scenario: Dismiss with Escape
- **WHEN** the user presses Escape while the find bar is visible
- **THEN** the find bar SHALL be hidden, all highlights SHALL be removed from the page, and the find text SHALL be cleared

### Requirement: Find bar clears on tab switch
The system SHALL dismiss the find bar and clear find state when the user switches to a different tab.

#### Scenario: Switch tab while find bar is open
- **WHEN** the user switches to a different tab while the find bar is visible
- **THEN** the find bar SHALL be hidden, find text SHALL be cleared, and highlights on the previous tab's page SHALL be removed

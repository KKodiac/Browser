## ADDED Requirements

### Requirement: Suggestion engine
The system SHALL provide a suggestion engine that accepts user input text and returns an ordered list of matching suggestions from available data sources (history, bookmarks, popular sites).

#### Scenario: Suggestions from popular sites
- **WHEN** the user types "git" in the URL bar and no history or bookmarks exist
- **THEN** the engine SHALL return suggestions matching "git" from the built-in popular sites list

#### Scenario: Suggestions from multiple sources
- **WHEN** the user types a query and history, bookmarks, and popular sites all contain matches
- **THEN** the engine SHALL return a merged, deduplicated list ranked by relevance

### Requirement: Matching against URL and page title
The system SHALL match user input against both the URL and the page title of each candidate, case-insensitively.

#### Scenario: Match by URL
- **WHEN** the user types "github.com"
- **THEN** suggestions SHALL include entries whose URL contains "github.com"

#### Scenario: Match by title
- **WHEN** the user types "GitHub"
- **THEN** suggestions SHALL include entries whose page title contains "GitHub"

### Requirement: Relevance ranking
The system SHALL rank suggestions with prefix matches above substring matches. Among equal match types, entries with higher visit frequency SHALL rank higher.

#### Scenario: Prefix match ranks higher
- **WHEN** the user types "app" and candidates include "apple.com" (prefix match on URL) and "myapp.example.com" (substring match on URL)
- **THEN** "apple.com" SHALL appear above "myapp.example.com" in the results

### Requirement: Result limit
The system SHALL return at most 8 suggestions.

#### Scenario: More than 8 matches
- **WHEN** the input matches 20 candidates
- **THEN** the engine SHALL return only the top 8 ranked results

### Requirement: Debounced input
The system SHALL debounce suggestion computation, waiting at least 150ms after the last keystroke before computing results.

#### Scenario: Rapid typing
- **WHEN** the user types "example" quickly (less than 150ms between keystrokes)
- **THEN** the engine SHALL compute suggestions only once, after the final keystroke plus 150ms

### Requirement: Suggestions appear while typing
The system SHALL display a suggestion dropdown while the user is typing in the URL bar and at least one suggestion matches the input.

#### Scenario: Dropdown appears
- **WHEN** the user focuses the URL bar and types text that matches at least one suggestion
- **THEN** a dropdown list of suggestions SHALL appear above the URL bar

#### Scenario: No matches
- **WHEN** the user types text that matches no suggestions
- **THEN** the dropdown SHALL not be displayed

### Requirement: Dropdown positioning
The suggestion dropdown SHALL appear above the URL bar, overlaying the web content area.

#### Scenario: Dropdown position
- **WHEN** the suggestion dropdown is visible
- **THEN** it SHALL be positioned directly above the URL bar with its bottom edge adjacent to the URL bar's top edge

### Requirement: Suggestion row display
Each suggestion row SHALL display the page title and URL.

#### Scenario: Suggestion row content
- **WHEN** a suggestion for "GitHub" at "https://github.com" is displayed
- **THEN** the row SHALL show the title "GitHub" and the URL "https://github.com"

### Requirement: Keyboard navigation
The user SHALL be able to navigate suggestions using arrow keys and select a suggestion with Enter.

#### Scenario: Arrow key navigation
- **WHEN** the dropdown is visible and the user presses the down arrow key
- **THEN** the selection SHALL move to the next suggestion in the list

#### Scenario: Arrow up wraps or stops at top
- **WHEN** the first suggestion is selected and the user presses the up arrow key
- **THEN** the selection SHALL move back to the text field input (no suggestion selected)

#### Scenario: Select suggestion with Enter
- **WHEN** a suggestion is highlighted and the user presses Enter
- **THEN** the URL bar SHALL be filled with the suggestion's URL and the browser SHALL navigate to it

### Requirement: Dismiss with Escape
The user SHALL be able to dismiss the suggestion dropdown by pressing Escape.

#### Scenario: Escape closes dropdown
- **WHEN** the suggestion dropdown is visible and the user presses Escape
- **THEN** the dropdown SHALL close and the URL bar text SHALL remain as the user typed it

### Requirement: Dismiss on blur
The suggestion dropdown SHALL close when the URL bar loses focus.

#### Scenario: Click outside URL bar
- **WHEN** the suggestion dropdown is visible and the user clicks outside the URL bar
- **THEN** the dropdown SHALL close

### Requirement: Inline URL completion
The system SHALL auto-fill the URL bar with the top suggestion's URL, with the completed portion shown as selected text.

#### Scenario: Inline completion appears
- **WHEN** the user types "gith" and the top suggestion is "https://github.com"
- **THEN** the URL bar text SHALL show "github.com" with "ub.com" selected (auto-completed portion)

#### Scenario: Continue typing replaces completion
- **WHEN** inline completion is showing and the user types another character
- **THEN** the selected completion text SHALL be replaced by the new character and suggestions SHALL update

#### Scenario: Accept inline completion
- **WHEN** inline completion is showing and the user presses Enter without arrow-key selecting a different suggestion
- **THEN** the browser SHALL navigate to the inline-completed URL

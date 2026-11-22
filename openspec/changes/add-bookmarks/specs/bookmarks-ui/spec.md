## ADDED Requirements

### Requirement: Bookmarks sidebar
The system SHALL provide a sidebar on the leading edge that displays all bookmarks organized by folder. Unfiled bookmarks SHALL appear in a separate section.

#### Scenario: Toggle sidebar visibility
- **WHEN** the user presses Cmd+Shift+B or clicks the bookmarks toolbar button
- **THEN** the bookmarks sidebar SHALL toggle between visible and hidden

#### Scenario: Sidebar displays folders and bookmarks
- **WHEN** the sidebar is visible
- **THEN** it SHALL show all folders with their bookmarks, and an "Unfiled" section for bookmarks without a folder

### Requirement: Add bookmark shortcut
The system SHALL provide a Cmd+D keyboard shortcut to bookmark the current page. If the page is already bookmarked, Cmd+D SHALL select the existing bookmark for editing.

#### Scenario: Cmd+D on unbookmarked page
- **WHEN** the user presses Cmd+D on a page that is not bookmarked
- **THEN** a new bookmark SHALL be created for the current page

#### Scenario: Cmd+D on already-bookmarked page
- **WHEN** the user presses Cmd+D on a page that is already bookmarked
- **THEN** the existing bookmark SHALL be selected for editing in the sidebar

### Requirement: Open bookmark
The system SHALL allow the user to open a bookmark by clicking it in the sidebar. The bookmark's URL SHALL load in the current tab.

#### Scenario: Click bookmark in sidebar
- **WHEN** the user clicks a bookmark in the sidebar
- **THEN** the current tab SHALL navigate to the bookmark's URL

### Requirement: Bookmark context menu
The system SHALL provide a context menu on bookmarks in the sidebar with options to edit, delete, and move to a folder.

#### Scenario: Right-click bookmark
- **WHEN** the user right-clicks a bookmark in the sidebar
- **THEN** a context menu SHALL appear with "Edit", "Delete", and "Move to Folder" options

### Requirement: Folder management in sidebar
The system SHALL allow creating, renaming, and deleting folders from the sidebar.

#### Scenario: Create new folder
- **WHEN** the user chooses "New Folder" in the sidebar
- **THEN** a new folder SHALL be created with an editable name field

#### Scenario: Rename folder
- **WHEN** the user renames a folder via context menu
- **THEN** the folder name SHALL update in the sidebar and in persistent storage

### Requirement: Toolbar bookmark indicator
The system SHALL display a visual indicator in the URL bar when the current page is bookmarked.

#### Scenario: Visit bookmarked page
- **WHEN** the user navigates to a URL that matches an existing bookmark
- **THEN** a filled bookmark icon SHALL appear in the URL bar

#### Scenario: Visit non-bookmarked page
- **WHEN** the user navigates to a URL that is not bookmarked
- **THEN** an outlined (unfilled) bookmark icon SHALL appear in the URL bar

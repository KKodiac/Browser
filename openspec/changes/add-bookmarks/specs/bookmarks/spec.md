## ADDED Requirements

### Requirement: Bookmark model
The system SHALL provide a `Bookmark` model with a unique ID, title, URL, optional folder ID, and creation date. All fields except folder ID SHALL be required.

#### Scenario: Create a bookmark
- **WHEN** a bookmark is created with a title and URL
- **THEN** it SHALL have a unique UUID, the given title and URL, a nil folder ID, and the current date as creation date

### Requirement: Bookmark folder model
The system SHALL provide a `BookmarkFolder` model with a unique ID, name, and sort order.

#### Scenario: Create a folder
- **WHEN** a folder is created with a name
- **THEN** it SHALL have a unique UUID, the given name, and a default sort order of 0

### Requirement: Bookmark storage
The system SHALL persist bookmarks and folders to a JSON file in the app's Application Support directory. Changes SHALL be saved automatically when bookmarks or folders are added, removed, or edited.

#### Scenario: Bookmarks persist across launches
- **WHEN** the user adds a bookmark and relaunches the app
- **THEN** the bookmark SHALL appear in the bookmark list

#### Scenario: Storage file location
- **WHEN** bookmarks are saved
- **THEN** the file SHALL be written to `<Application Support>/Browser/bookmarks.json`

### Requirement: Add bookmark
The system SHALL allow the user to bookmark the current page. The bookmark title SHALL default to the page title, and the URL SHALL be the current page URL.

#### Scenario: Bookmark current page
- **WHEN** the user triggers "Add Bookmark" on a page with title "Example" at URL "https://example.com"
- **THEN** a bookmark SHALL be created with title "Example" and URL "https://example.com"

#### Scenario: Bookmark page with no title
- **WHEN** the user bookmarks a page with no title
- **THEN** the bookmark title SHALL default to the page's hostname

### Requirement: Remove bookmark
The system SHALL allow the user to delete a bookmark.

#### Scenario: Delete a bookmark
- **WHEN** the user deletes a bookmark
- **THEN** it SHALL be removed from the bookmark list and from persistent storage

### Requirement: Edit bookmark
The system SHALL allow the user to edit a bookmark's title, URL, and folder assignment.

#### Scenario: Rename a bookmark
- **WHEN** the user edits a bookmark's title to "New Title"
- **THEN** the bookmark's title SHALL update to "New Title" and the change SHALL be persisted

### Requirement: Organize bookmarks into folders
The system SHALL allow bookmarks to be assigned to a folder. Bookmarks without a folder SHALL appear in an "Unfiled" section.

#### Scenario: Move bookmark to folder
- **WHEN** the user moves a bookmark into a folder named "Work"
- **THEN** the bookmark's folder ID SHALL reference the "Work" folder

#### Scenario: Remove folder
- **WHEN** the user deletes a folder
- **THEN** all bookmarks in that folder SHALL become unfiled (folder ID set to nil)

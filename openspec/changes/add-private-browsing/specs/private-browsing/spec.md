## ADDED Requirements

### Requirement: Ephemeral data store for private windows
Private windows SHALL use a `WKWebsiteDataStore.nonPersistent()` instance for all WebViews within the window. The data store SHALL be shared across all tabs in the same private window.

#### Scenario: Private window uses non-persistent data store
- **WHEN** a private window is opened
- **THEN** all WebViews created in that window SHALL use a non-persistent `WKWebsiteDataStore`

#### Scenario: Tabs in same private window share data store
- **WHEN** a user logs into a site in one tab of a private window and opens another tab in the same window
- **THEN** the login session SHALL be available in the second tab (shared ephemeral data store)

### Requirement: Open private window via keyboard shortcut
The system SHALL provide a keyboard shortcut Cmd+Shift+N to open a new private window.

#### Scenario: Open private window with shortcut
- **WHEN** the user presses Cmd+Shift+N
- **THEN** a new private window SHALL open with a single empty tab

### Requirement: Open private window via menu
The system SHALL provide a "New Private Window" menu item in the File menu (or equivalent menu location).

#### Scenario: Open private window from menu
- **WHEN** the user selects "New Private Window" from the menu bar
- **THEN** a new private window SHALL open with a single empty tab

### Requirement: No cookies persisted after private window closes
Cookies and site data from a private window SHALL NOT persist after the private window is closed.

#### Scenario: Cookies discarded on close
- **WHEN** a user visits a site in a private window, closes the private window, and then opens a new private window
- **THEN** the site SHALL NOT have any cookies from the previous private session

#### Scenario: Normal window cookies unaffected
- **WHEN** a user browses in a private window
- **THEN** cookies in normal (non-private) windows SHALL NOT be affected

### Requirement: No history recorded in private windows
Browsing activity in private windows SHALL NOT be recorded in the browser's history.

#### Scenario: Private navigation excluded from history
- **WHEN** a user navigates to pages in a private window
- **THEN** those pages SHALL NOT appear in the browser's history

#### Scenario: Normal window history unaffected
- **WHEN** a user browses in both a private window and a normal window simultaneously
- **THEN** only the normal window's navigation SHALL be recorded in history

### Requirement: Visual distinction from normal windows
Private windows SHALL be visually distinct from normal windows so users can identify them at a glance.

#### Scenario: Private window appearance
- **WHEN** a private window is displayed
- **THEN** the window SHALL display a dark title bar tint or background and a "Private" badge or label visible in the title bar area

#### Scenario: Normal window unchanged
- **WHEN** a normal (non-private) window is displayed
- **THEN** it SHALL NOT display any private browsing visual indicators

### Requirement: Bookmark warning in private windows
The system SHALL warn the user when they attempt to bookmark a page from a private window, because bookmarking creates a persistent record.

#### Scenario: Bookmark attempt in private window
- **WHEN** the user triggers "Add Bookmark" while in a private window
- **THEN** the system SHALL display a confirmation dialog warning that bookmarking will create a persistent record of the visited page

#### Scenario: Bookmark confirmed after warning
- **WHEN** the user confirms the bookmark warning dialog
- **THEN** the bookmark SHALL be saved normally

#### Scenario: Bookmark cancelled after warning
- **WHEN** the user cancels the bookmark warning dialog
- **THEN** no bookmark SHALL be created

### Requirement: Private window independence
Each private window SHALL have its own independent ephemeral data store. Closing one private window SHALL NOT affect other open private windows.

#### Scenario: Multiple private windows
- **WHEN** two private windows are open and the user closes one
- **THEN** the remaining private window SHALL continue functioning with its own data store intact

#### Scenario: Private and normal windows independent
- **WHEN** a private window and a normal window are open simultaneously
- **THEN** they SHALL NOT share cookies, cache, or site data

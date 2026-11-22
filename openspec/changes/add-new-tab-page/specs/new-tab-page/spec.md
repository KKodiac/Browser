## ADDED Requirements

### Requirement: New tab page display
The system SHALL display a new tab page instead of a blank page when a tab has no URL.

#### Scenario: Open a new tab
- **WHEN** the user opens a new tab
- **THEN** the system SHALL display the new tab page view instead of a blank WebView

#### Scenario: Tab URL becomes nil
- **WHEN** a tab's URL is nil or empty
- **THEN** the content area SHALL show the new tab page for that tab

#### Scenario: Navigate away from new tab page
- **WHEN** the user submits a URL or search term from a tab showing the new tab page
- **THEN** the system SHALL replace the new tab page with the WebView and begin loading the requested page

### Requirement: Search field on new tab page
The system SHALL display a centered search field on the new tab page that focuses the URL bar when activated.

#### Scenario: Tap search field on NTP
- **WHEN** the user clicks the search field on the new tab page
- **THEN** the URL bar SHALL become focused and ready for text input

#### Scenario: Search field placeholder
- **WHEN** the new tab page is displayed
- **THEN** the search field SHALL show placeholder text indicating the user can search or enter a URL

### Requirement: Frequently visited sites grid
The system SHALL display a grid of frequently visited sites on the new tab page when history data is available.

#### Scenario: History data available
- **WHEN** the new tab page is displayed and browsing history contains visited sites
- **THEN** the system SHALL show a grid of frequently visited sites, each displaying a favicon (or letter placeholder) and the site title or hostname

#### Scenario: No history data
- **WHEN** the new tab page is displayed and no browsing history is available
- **THEN** the frequently visited sites grid SHALL not be displayed

#### Scenario: Click a frequently visited site
- **WHEN** the user clicks a site tile in the frequently visited grid
- **THEN** the current tab SHALL navigate to that site's URL

### Requirement: Favorites section
The system SHALL display a favorites/bookmarks section on the new tab page when bookmarks data is available.

#### Scenario: Bookmarks data available
- **WHEN** the new tab page is displayed and the user has saved bookmarks
- **THEN** the system SHALL show a favorites section displaying bookmarked sites with favicon (or letter placeholder) and title

#### Scenario: No bookmarks data
- **WHEN** the new tab page is displayed and no bookmarks are available
- **THEN** the favorites section SHALL not be displayed

#### Scenario: Click a favorite
- **WHEN** the user clicks a site in the favorites section
- **THEN** the current tab SHALL navigate to that site's URL

### Requirement: Empty state for first launch
The system SHALL display a clean empty state when neither history nor bookmarks data is available.

#### Scenario: New user with no data
- **WHEN** the new tab page is displayed and there is no browsing history and no bookmarks
- **THEN** the system SHALL show the search field and a welcome message, with no empty grids or placeholder tiles

#### Scenario: Partial data
- **WHEN** the new tab page is displayed and only one data source (history or bookmarks) has entries
- **THEN** the system SHALL show only the section with data and omit the empty section

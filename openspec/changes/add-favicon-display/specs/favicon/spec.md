## ADDED Requirements

### Requirement: Favicon URL extraction
The system SHALL extract the favicon URL from a loaded web page by querying the DOM for `<link>` elements with `rel="icon"` or `rel="shortcut icon"`. If no such element is found, the system SHALL fall back to `{origin}/favicon.ico`.

#### Scenario: Page with link[rel=icon]
- **WHEN** a page finishes loading and contains `<link rel="icon" href="/images/favicon.png">`
- **THEN** the tab's favicon URL SHALL be set to the absolute URL resolved from that href

#### Scenario: Page with no favicon link element
- **WHEN** a page finishes loading at `https://example.com/page` and contains no `<link rel="icon">` or `<link rel="shortcut icon">` element
- **THEN** the tab's favicon URL SHALL be set to `https://example.com/favicon.ico`

#### Scenario: New Tab page
- **WHEN** a tab has no URL loaded (New Tab state)
- **THEN** the tab's favicon URL SHALL be nil

### Requirement: Favicon display in tab bar
The system SHALL display the favicon image to the left of the tab title in each tab bar item. The favicon SHALL be rendered at 16x16 points.

#### Scenario: Tab with loaded favicon
- **WHEN** a tab has a valid favicon URL and the image has been fetched
- **THEN** a 16x16 favicon image SHALL appear to the left of the tab title

#### Scenario: Tab with no favicon
- **WHEN** a tab has no favicon URL (e.g., New Tab)
- **THEN** no favicon image or fallback icon SHALL be displayed in the tab bar item

### Requirement: Favicon display in URL bar
The system SHALL display the active tab's favicon in the URL bar, to the left of the URL text field.

#### Scenario: Active tab has favicon
- **WHEN** the active tab has a loaded favicon image
- **THEN** a 16x16 favicon image SHALL appear to the left of the URL text field

#### Scenario: Active tab has no favicon
- **WHEN** the active tab has no favicon (New Tab or failed load)
- **THEN** a fallback icon SHALL appear to the left of the URL text field, or no icon if the tab has no URL

### Requirement: Fallback icon
The system SHALL display a fallback icon when a favicon is unavailable or fails to load. The fallback icon SHALL show the first letter of the page's domain in a styled rounded rectangle.

#### Scenario: Favicon load failure
- **WHEN** a tab's favicon URL returns an error or an invalid image
- **THEN** the system SHALL display a fallback icon with the first letter of the domain

#### Scenario: Fallback icon appearance
- **WHEN** a fallback icon is displayed
- **THEN** it SHALL be a rounded rectangle at 16x16 points containing a single uppercase letter centered within it

### Requirement: Favicon caching
The system SHALL cache fetched favicon images in memory to avoid redundant network requests. The cache SHALL be keyed by favicon URL.

#### Scenario: Revisiting a page with a cached favicon
- **WHEN** a tab navigates to a page whose favicon URL is already in the cache
- **THEN** the cached image SHALL be displayed immediately without a new network request

#### Scenario: Memory pressure
- **WHEN** the system is under memory pressure
- **THEN** the favicon cache SHALL allow entries to be evicted automatically

#### Scenario: Duplicate favicon URLs across tabs
- **WHEN** multiple tabs share the same favicon URL (e.g., two tabs on the same domain)
- **THEN** the favicon image SHALL be fetched and cached only once

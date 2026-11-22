## ADDED Requirements

### Requirement: Downloads toolbar button
The system SHALL display a downloads button in the URL bar area. The button SHALL show a badge with the count of active (in-progress) downloads when at least one download is active.

#### Scenario: No active downloads
- **WHEN** there are no active downloads
- **THEN** the downloads button SHALL appear without a badge

#### Scenario: Active downloads present
- **WHEN** there are two downloads in progress
- **THEN** the downloads button SHALL display a badge showing "2"

### Requirement: Downloads popover
The system SHALL show a popover anchored to the downloads toolbar button when clicked. The popover SHALL list active downloads followed by completed downloads.

#### Scenario: Open downloads popover
- **WHEN** the user clicks the downloads toolbar button
- **THEN** a popover SHALL appear showing the downloads list

#### Scenario: Empty downloads list
- **WHEN** the popover is shown and there are no downloads
- **THEN** the popover SHALL display a message indicating no downloads

### Requirement: Download progress display
The system SHALL display a progress bar for each active download showing the proportion of bytes received to total bytes. The filename and a percentage or byte count SHALL be shown alongside the progress bar.

#### Scenario: Download in progress with known size
- **WHEN** a download is in progress with 5 MB received of 10 MB total
- **THEN** the popover SHALL show the filename, a progress bar at 50%, and the byte counts

#### Scenario: Download in progress with unknown size
- **WHEN** a download is in progress and the total size is unknown
- **THEN** the popover SHALL show the filename and an indeterminate progress indicator

### Requirement: Cancel download from popover
The system SHALL provide a cancel button on each active download in the popover.

#### Scenario: Cancel from popover
- **WHEN** the user clicks the cancel button on an active download in the popover
- **THEN** the download SHALL be cancelled and the item SHALL show a cancelled state

### Requirement: Open completed download
The system SHALL allow the user to open a completed download by clicking it or clicking an "Open" button. Opening SHALL reveal the file in Finder.

#### Scenario: Open completed download
- **WHEN** the user clicks a completed download in the popover
- **THEN** the system SHALL reveal the downloaded file in Finder

### Requirement: Clear completed downloads
The system SHALL provide a "Clear" action to remove completed (and failed/cancelled) downloads from the list.

#### Scenario: Clear completed downloads
- **WHEN** the user clicks "Clear" in the downloads popover
- **THEN** all completed, failed, and cancelled downloads SHALL be removed from the list, leaving only active downloads

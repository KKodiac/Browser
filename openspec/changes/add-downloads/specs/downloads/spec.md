## ADDED Requirements

### Requirement: Download item model
The system SHALL provide a `DownloadItem` model with a unique ID, source URL, filename, download state (pending, downloading, completed, failed, cancelled), bytes received, total bytes, and destination file URL.

#### Scenario: Create a download item
- **WHEN** a download is initiated for a URL
- **THEN** a `DownloadItem` SHALL be created with a unique ID, the source URL, a filename derived from the URL or server response, state set to pending, and zero bytes received

### Requirement: Download initiation
The system SHALL intercept download requests from WKWebView. When a navigation action results in a file download (e.g., `Content-Disposition: attachment` header or a MIME type that cannot be displayed), the system SHALL create a `WKDownload` and begin tracking it.

#### Scenario: Server responds with download header
- **WHEN** a navigation response includes `Content-Disposition: attachment`
- **THEN** the system SHALL initiate a download instead of loading the content in the web view

#### Scenario: Non-displayable MIME type
- **WHEN** a navigation response has a MIME type that WKWebView cannot display (e.g., `application/zip`)
- **THEN** the system SHALL initiate a download for that response

### Requirement: Download progress tracking
The system SHALL track download progress by updating bytes received and total bytes on the `DownloadItem` as data is received.

#### Scenario: Progress updates during download
- **WHEN** a download receives data
- **THEN** the `DownloadItem` SHALL update its bytes received and its state SHALL be set to downloading

#### Scenario: Total bytes known
- **WHEN** the server provides a `Content-Length` header
- **THEN** the `DownloadItem` SHALL store the total expected bytes

### Requirement: Download completion
The system SHALL move the downloaded file to the destination directory when the download completes. The `DownloadItem` state SHALL be set to completed and the destination file URL SHALL be set.

#### Scenario: Download finishes successfully
- **WHEN** a download completes
- **THEN** the file SHALL be moved to the default download location and the `DownloadItem` state SHALL be set to completed

#### Scenario: Filename conflict at destination
- **WHEN** a file with the same name already exists at the destination
- **THEN** the system SHALL append a numeric suffix (e.g., `file-1.zip`) to avoid overwriting the existing file

### Requirement: Download cancellation
The system SHALL allow the user to cancel an in-progress download. Cancelling SHALL stop the `WKDownload`, remove any partial file, and set the `DownloadItem` state to cancelled.

#### Scenario: Cancel an active download
- **WHEN** the user cancels a downloading item
- **THEN** the `WKDownload` SHALL be cancelled, the partial file SHALL be removed, and the `DownloadItem` state SHALL be set to cancelled

### Requirement: Download failure handling
The system SHALL handle download failures by setting the `DownloadItem` state to failed and storing an error description.

#### Scenario: Download fails due to network error
- **WHEN** a download fails with an error
- **THEN** the `DownloadItem` state SHALL be set to failed and the error message SHALL be stored

### Requirement: Default download location
The system SHALL save downloaded files to `~/Downloads` by default.

#### Scenario: Download destination
- **WHEN** a download completes and no custom location is configured
- **THEN** the file SHALL be saved to the user's `~/Downloads` directory

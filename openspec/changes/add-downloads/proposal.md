## Why

The browser currently cannot handle file downloads. When a user clicks a download link, nothing happens — the file is silently ignored or the navigation fails. Downloading files is a fundamental browser capability that users expect to work out of the box.

## What Changes

- Add a `DownloadItem` model with URL, filename, progress, state, and destination path
- Add a `DownloadManager` (@Observable) to track active and completed downloads
- Integrate WKDownloadDelegate into the WebView coordinator to intercept download requests
- Add a downloads toolbar button with an active-download badge
- Add a downloads popover showing active downloads with progress and completed downloads with open/clear actions
- Configure a default download location (~/Downloads)

## Capabilities

### New Capabilities
- `downloads`: Download initiation via WKDownload API, progress tracking, completion handling, cancellation, and default download location configuration
- `downloads-ui`: Downloads toolbar button with badge, downloads popover with progress bars, open-file action, and clear-completed action

### Modified Capabilities

_(none — no existing spec requirements change)_

## Impact

- **WebView.swift**: Coordinator gains WKDownloadDelegate conformance to handle download navigation actions and download lifecycle
- **ContentView.swift**: Add downloads toolbar button to the URL bar area
- New files: `DownloadItem.swift`, `DownloadManager.swift`, `DownloadsPopover.swift`
- No new dependencies — uses WKDownload (WebKit), Foundation file management, and SwiftUI

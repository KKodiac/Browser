## 1. Models

- [x] 1.1 Create `DownloadState` enum with cases: pending, downloading, completed, failed, cancelled
- [x] 1.2 Create `DownloadItem` class (@Observable, Identifiable) with id, sourceURL, filename, state, bytesReceived, totalBytes, destinationURL, errorMessage

## 2. DownloadManager

- [x] 2.1 Create `DownloadManager` (@Observable) with `downloads: [DownloadItem]` array
- [x] 2.2 Add `startDownload(_:suggestedFilename:)` method that creates a DownloadItem and returns a destination URL
- [x] 2.3 Add `updateProgress(id:bytesReceived:totalBytes:)` method
- [x] 2.4 Add `completeDownload(id:destinationURL:)` method that moves file to ~/Downloads and handles filename conflicts
- [x] 2.5 Add `failDownload(id:error:)` method
- [x] 2.6 Add `cancelDownload(id:)` method that cancels the WKDownload and removes partial files
- [x] 2.7 Add `clearCompleted()` method that removes completed, failed, and cancelled items
- [x] 2.8 Add computed properties: `activeDownloads`, `completedDownloads`, `activeCount`

## 3. WKDownload Integration

- [x] 3.1 Add `WKDownloadDelegate` conformance to WebView Coordinator
- [x] 3.2 Implement `navigationAction` delegate to handle download-triggering navigations
- [x] 3.3 Implement `navigationResponse` delegate to detect non-displayable responses and convert to downloads
- [x] 3.4 Implement `download(_:decideDestinationUsing:suggestedFilename:)` to set download destination
- [x] 3.5 Implement `download(_:didReceive:totalBytesWritten:totalBytesExpectedToWrite:)` for progress updates (via DownloadManager)
- [x] 3.6 Implement `downloadDidFinish(_:)` and `download(_:didFailWithError:)` to update DownloadManager

## 4. Downloads UI

- [x] 4.1 Create `DownloadsPopover` view with sections for active and completed downloads
- [x] 4.2 Add progress bar row for each active download with filename, progress indicator, and cancel button
- [x] 4.3 Add completed download row with filename and open-in-Finder action
- [x] 4.4 Add empty state message when no downloads exist
- [x] 4.5 Add "Clear" button to remove completed/failed/cancelled downloads

## 5. Toolbar Integration

- [x] 5.1 Add downloads button to URL bar area in ContentView
- [x] 5.2 Add badge overlay on downloads button showing active download count
- [x] 5.3 Wire button to toggle DownloadsPopover visibility

## 6. Menu Bar

- [x] 6.1 Add "Downloads" menu item or keyboard shortcut to toggle the downloads popover

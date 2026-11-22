## Context

The browser uses a `WebView` NSViewRepresentable wrapping WKWebView, with a `Coordinator` that conforms to `WKNavigationDelegate` and `WKUIDelegate`. The coordinator communicates state changes back to the app via a `send` closure dispatching `AppFeature.Action` values. The app uses ComposableArchitecture (TCA).

Currently, when a page triggers a file download (e.g., `Content-Disposition: attachment` or a blob URL), the browser has no handler — the download is ignored.

## Goals / Non-Goals

**Goals:**
- Intercept download requests from WKWebView (navigation actions and response policy decisions)
- Track download progress with bytes received / total bytes
- Move completed downloads to the destination directory
- Allow cancellation of in-progress downloads
- Show a downloads popover with active and completed downloads
- Provide a toolbar button with a badge indicating active download count
- Allow opening completed files in Finder
- Allow clearing completed downloads from the list
- Default download location: ~/Downloads

**Non-Goals:**
- Pause and resume downloads — future enhancement
- Download queue limits or throttling
- Custom per-download save location (file picker) — future enhancement
- Download history persistence across app launches
- Drag-and-drop of downloaded files

## Decisions

### 1. WKDownload API for download handling
**Decision:** Use WKWebView's native `WKDownload` API (iOS 14.5+ / macOS 11.3+) via `WKNavigationDelegate` and `WKDownloadDelegate`.
**Rationale:** This is the standard WebKit approach. It handles authentication, cookies, and redirects automatically. No custom URLSession download needed.
**Alternatives:** Custom URLSession downloads (loses cookie/session context from WebView), intercepting via JavaScript (fragile, incomplete).

### 2. DownloadManager as @Observable class
**Decision:** A `DownloadManager` class marked `@Observable` that owns an array of `DownloadItem` values and manages `WKDownload` instances.
**Rationale:** Consistent with existing patterns (BrowserTab, TabGroup are @Observable). Integrates naturally with SwiftUI views. Can be integrated into TCA state as needed.
**Alternatives:** TCA reducer for downloads (adds complexity for async download lifecycle), actor-based manager (unnecessary for UI-bound state).

### 3. Popover from toolbar button
**Decision:** Show downloads in a popover anchored to a toolbar button in the URL bar, rather than a sidebar or sheet.
**Rationale:** Downloads are transient — users check progress and dismiss. A popover is non-disruptive and follows macOS browser conventions (Safari, Chrome). Sidebar would conflict with potential bookmarks sidebar.
**Alternatives:** Sidebar (conflicts with bookmarks, overkill for a list), sheet (blocks content), separate window (disruptive for quick checks).

### 4. Default to ~/Downloads
**Decision:** Save all downloads to `~/Downloads` by default. No file picker on each download.
**Rationale:** Matches user expectations and macOS conventions. Reduces friction. A per-download save dialog can be added later as a setting.

## Risks / Trade-offs

- **WKDownload API availability** — Requires macOS 11.3+. The app's deployment target must support this. If targeting earlier macOS, a fallback would be needed.
- **No persistence** — Download list is in-memory only. Completed downloads disappear on relaunch. Acceptable for v1; persistence can reuse the pattern established by bookmarks.
- **File conflicts** — If a file with the same name exists in ~/Downloads, we need a naming strategy (e.g., append `-1`). Must handle this to avoid silent overwrites.
- **TCA integration** — DownloadManager lives outside the TCA store. The WebView coordinator will own the delegate callbacks and update DownloadManager directly. This is pragmatic but means download state is not in the TCA store.

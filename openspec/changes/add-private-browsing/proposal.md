## Why

The browser currently has no privacy option. Every browsing session leaves traces — history entries, cookies, and site data persist indefinitely. Users who want to browse without leaving a record (e.g., gift shopping, signing into shared accounts, testing logged-out flows) have no way to do so. Private browsing is a fundamental expectation of any modern browser.

## What Changes

- Add a private window mode that uses an ephemeral `WKWebsiteDataStore` (non-persistent)
- Add a menu item and keyboard shortcut (Cmd+Shift+N) to open a new private window
- Add a visual indicator (dark title bar tint or "Private" badge) so users can distinguish private windows from normal ones
- Ensure private windows do not record history or persist cookies/site data after the window closes
- Show a warning if the user attempts to bookmark a page from a private window

## Capabilities

### New Capabilities
- `private-browsing`: Ephemeral browsing sessions using non-persistent data stores, private window lifecycle, visual distinction, and data isolation

### Modified Capabilities
_(none — no existing spec requirements change)_

## Impact

- **BrowserApp.swift**: New window group or scene for private windows, menu bar command for "New Private Window" (Cmd+Shift+N)
- **WebView.swift**: Accept an optional `WKWebsiteDataStore` parameter; use `WKWebsiteDataStore.nonPersistent()` for private windows instead of the default persistent store
- **ContentView.swift**: Accept an `isPrivate` flag to drive visual indicator and suppress history recording
- **BrowserTab.swift**: No changes expected — tabs remain data-agnostic; privacy is a window-level concern
- No new dependencies — uses only WebKit's built-in `WKWebsiteDataStore.nonPersistent()`

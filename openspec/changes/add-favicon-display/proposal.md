## Why

Tabs in the browser currently display only title text. When many tabs are open, users must read each title to identify a tab, which is slow and error-prone — especially when multiple tabs share similar titles (e.g., several GitHub pages). Favicons provide an instant visual anchor that lets users locate tabs at a glance, matching the behavior users expect from every major browser.

## What Changes

- Extract the favicon URL from loaded pages via WKWebView (JavaScript injection to read `<link rel="icon">` or fall back to `/favicon.ico`)
- Add a `faviconURL` property to `BrowserTab`
- Cache fetched favicon images in memory using `NSCache`
- Display the favicon beside the tab title in the tab bar
- Display the favicon in the URL bar for the active tab
- Show a first-letter fallback icon when no favicon is available

## Capabilities

### New Capabilities
- `favicon`: Favicon URL extraction from web pages, in-memory image caching, favicon display in the tab bar and URL bar, and fallback icon generation

### Modified Capabilities

_(none — no existing spec requirements change)_

## Impact

- **BrowserTab.swift**: Add optional `faviconURL: URL?` property
- **ContentView.swift**: Update `tabButtonContent` to show favicon image; update `urlBar` to show favicon for active tab
- **WebView.swift**: Add JavaScript evaluation to extract favicon URL on page load
- New file: `FaviconCache.swift` (NSCache wrapper for favicon images)
- No new external dependencies — uses Foundation, SwiftUI, and WebKit

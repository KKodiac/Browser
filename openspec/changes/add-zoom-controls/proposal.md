## Why

The browser has no way to adjust page zoom. Users who find text too small or too large on a page must rely on each site's own font sizing. This is a basic accessibility gap — every major browser supports per-tab zoom via Cmd+Plus/Cmd+Minus/Cmd+0, and users expect it. Without zoom controls, the browser is unusable for visually impaired users or on high-density displays where default text is too small.

## What Changes

- Add a `zoomLevel` property to `BrowserTab` to track per-tab zoom (default 1.0 / 100%)
- Apply `zoomLevel` to the `WKWebView` via its `pageZoom` property when the tab is active
- Add keyboard shortcuts: Cmd+Plus (zoom in), Cmd+Minus (zoom out), Cmd+0 (reset to 100%)
- Add corresponding menu bar commands under View menu
- Show a zoom level indicator in the URL bar when zoom is not 100%
- Clamp zoom range to 50%–200% in 10% increments

## Capabilities

### New Capabilities
- `zoom-controls`: Per-tab zoom state management, WKWebView pageZoom binding, keyboard shortcuts, menu commands, and URL bar zoom indicator

### Modified Capabilities

_(none — no existing spec requirements change)_

## Impact

- **BrowserTab.swift**: Add `zoomLevel: Double` property (default 1.0)
- **WebView.swift**: Apply `tab.zoomLevel` to `webView.pageZoom` in `updateNSView`
- **ContentView.swift**: Add zoom indicator to URL bar area, wire up zoom actions
- **BrowserApp.swift**: Add View menu commands for Zoom In, Zoom Out, Reset Zoom with keyboard shortcuts
- No new dependencies — uses only existing WKWebView API

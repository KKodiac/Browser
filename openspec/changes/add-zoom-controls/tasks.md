## 1. BrowserTab Zoom State

- [x] 1.1 Add `zoomLevel: Double` property to `BrowserTab` with default value of `1.0`
- [x] 1.2 Add `zoomLevel` to `BrowserTab.init` parameters with default

## 2. WKWebView pageZoom Binding

- [x] 2.1 Apply `tab.zoomLevel` to `webView.pageZoom` in `WebView.updateNSView`

## 3. Zoom Actions

- [x] 3.1 Add zoom in action that increases current tab's `zoomLevel` by 0.1, clamped to 2.0
- [x] 3.2 Add zoom out action that decreases current tab's `zoomLevel` by 0.1, clamped to 0.5
- [x] 3.3 Add reset zoom action that sets current tab's `zoomLevel` to 1.0
- [x] 3.4 Round `zoomLevel` to one decimal place after each zoom operation to avoid floating point drift

## 4. Keyboard Shortcuts

- [x] 4.1 Add Cmd+Plus keyboard shortcut for zoom in
- [x] 4.2 Add Cmd+Minus keyboard shortcut for zoom out
- [x] 4.3 Add Cmd+0 keyboard shortcut for reset zoom

## 5. Menu Bar Commands

- [x] 5.1 Add "Zoom In" command to View menu with Cmd+Plus shortcut
- [x] 5.2 Add "Zoom Out" command to View menu with Cmd+Minus shortcut
- [x] 5.3 Add "Actual Size" command to View menu with Cmd+0 shortcut

## 6. URL Bar Zoom Indicator

- [x] 6.1 Add zoom percentage label to URL bar area (e.g., "150%") visible when `zoomLevel != 1.0`
- [x] 6.2 Hide zoom indicator when `zoomLevel` is 1.0

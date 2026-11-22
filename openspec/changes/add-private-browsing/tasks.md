## 1. Ephemeral WKWebsiteDataStore

- [x] 1.1 Add an `isPrivate` flag to the app state (or introduce a per-window state container) to distinguish private from normal windows
- [x] 1.2 Create a non-persistent `WKWebsiteDataStore` instance per private window, held in state so it outlives view updates
- [x] 1.3 Update `WebView` to accept an optional `WKWebsiteDataStore` and apply it to `WKWebViewConfiguration` in `makeNSView`

## 2. Private Window Command

- [x] 2.1 Add a second `WindowGroup` (or `Window` scene) in `BrowserApp` with a distinct identifier for private windows
- [x] 2.2 Pass the `isPrivate` flag and ephemeral data store to `ContentView` in the private window scene
- [x] 2.3 Ensure each private window opens with a single empty tab and its own independent state

## 3. Visual Indicator

- [x] 3.1 Apply a dark title bar tint or background to `ContentView` when `isPrivate` is true
- [x] 3.2 Display a "Private" badge or label in the title bar area of private windows
- [x] 3.3 Verify normal windows do not display private browsing indicators

## 4. History and Cookie Isolation

- [x] 4.1 Ensure the non-persistent data store discards all cookies and site data when the private window closes (verify via data store deallocation)
- [x] 4.2 Add an `isPrivate` check to any history-recording code path so private navigation is excluded
- [x] 4.3 Verify that normal window cookies and data are unaffected by private window activity

## 5. Menu Bar Integration

- [x] 5.1 Add "New Private Window" menu item with Cmd+Shift+N keyboard shortcut to the menu bar
- [x] 5.2 Add bookmark warning dialog that triggers when "Add Bookmark" is used in a private window
- [x] 5.3 Implement confirmation and cancellation paths for the bookmark warning dialog

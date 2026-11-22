## 1. State Extraction

- [x] 1.1 Remove the shared `@State private var store` from BrowserApp and instead let each WindowGroup instance create its own `Store(initialState: AppFeature.State())`
- [x] 1.2 Verify each window's ContentView receives an independent store with its own tabs and groups

## 2. WindowGroup Setup

- [x] 2.1 Remove `CommandGroup(replacing: .newItem) {}` from BrowserApp to re-enable Cmd+N
- [x] 2.2 Confirm SwiftUI's default WindowGroup behavior creates a new window with a fresh AppFeature.State on Cmd+N
- [x] 2.3 Set minimum window size (minWidth: 800, minHeight: 600) per window

## 3. New Window Command

- [x] 3.1 Verify Cmd+N opens a new window with a single empty tab
- [x] 3.2 Verify the new window has an independent tab bar, URL bar, and content area
- [x] 3.3 Add "New Window" to the File menu if SwiftUI does not provide it by default

## 4. Cross-Window Drag

- [x] 4.1 Look up the dragged tab's source window through `WindowRegistry` (the drag payload stays the tab UUID; tabs only move between windows of the same kind, normal or private)
- [x] 4.2 Update drop handler to detect cross-window drops (UUID not found in local store) and create a new BrowserTab from the serialized data
- [x] 4.3 Remove the tab from the source window (`detachTab`) when the drop lands in another window
- [x] 4.4 Handle edge case: if moved tab was the last tab in source window, create a new empty tab in source
- [x] 4.5 Handle edge case: if moved tab was the last tab in its group, delete the empty group in source window

## 5. Window Lifecycle

- [x] 5.1 Verify closing a window deallocates its store and releases all WebViews
- [x] 5.2 Verify the app terminates when the last window is closed (standard macOS behavior)
- [x] 5.3 Ensure minimum one tab per window is enforced across all tab close and tab move operations

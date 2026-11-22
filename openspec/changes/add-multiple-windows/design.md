## Context

The browser uses a single `WindowGroup` in `BrowserApp.swift` with a single `Store(initialState: AppFeature.State())` shared across the app. All tab and group state lives inside `AppFeature.State`, which ContentView accesses via `@Bindable var store: StoreOf<AppFeature>`. The app currently replaces the default Cmd+N behavior with an empty `CommandGroup(replacing: .newItem) {}`, effectively disabling new window creation.

Tabs are `@Observable` models (`BrowserTab`), groups are `@Observable` models (`TabGroup`), and drag-and-drop within a window already works via `NSItemProvider` with UUID strings.

## Goals / Non-Goals

**Goals:**
- Users can open multiple independent browser windows via Cmd+N
- Each window has its own tabs, tab groups, selected tab, and URL bar state
- Users can move a tab from one window to another via drag-and-drop
- Closing a window closes all tabs within it and releases its state
- Each window enforces a minimum of one tab (new empty tab created if last tab is closed)

**Non-Goals:**
- Tab syncing or shared state between windows (each window is fully independent)
- Window-specific settings or preferences (e.g., per-window accent color)
- Merging all tabs from one window into another
- Remembering window positions/sizes across app launches
- Tab duplication across windows (move only, not copy)

## Decisions

### 1. SwiftUI WindowGroup with per-window Store

**Decision:** Keep using `WindowGroup` but create a new `Store(initialState: AppFeature.State())` for each window instance rather than sharing one store. Each window gets its own independent TCA store with its own tabs and groups.

**Rationale:** SwiftUI's `WindowGroup` already handles multi-window lifecycle (open, close, restore). Giving each window its own store ensures complete state isolation with no cross-window side effects. This matches how TCA is designed to work -- each feature instance owns its state.

**Alternatives considered:**
- *Single global store with per-window sub-state*: Adds complexity (keyed state, window registry) for no user benefit since windows are independent.
- *`Window` (singular) scene*: Only allows one instance, which defeats the purpose.

### 2. Extract per-window state into AppFeature.State (already done)

**Decision:** `AppFeature.State` already holds tabs, groups, selected tab, and URL bar text. Each window creates its own `AppFeature.State` instance, so no new model extraction is needed.

**Rationale:** The current `AppFeature.State` is already the right granularity for per-window state. Creating a separate `WindowState` wrapper would be redundant.

### 3. Cmd+N opens a new window

**Decision:** Remove the `CommandGroup(replacing: .newItem) {}` that currently disables Cmd+N. Let SwiftUI's default `WindowGroup` behavior handle Cmd+N, which opens a new window with a fresh `AppFeature.State`.

**Rationale:** SwiftUI's built-in Cmd+N support for `WindowGroup` already does what we need. No custom command handling required.

### 4. Cross-window tab drag-and-drop via NSItemProvider serialization

**Decision:** When a tab is dragged out of a window, serialize the tab's essential data (URL, title, history) into the `NSItemProvider` payload. When dropped in another window, deserialize and create a new `BrowserTab` in the target window. The source window removes the original tab on successful transfer.

**Rationale:** Since each window has its own independent store, we cannot pass object references between windows. Serializing tab data through the pasteboard is the standard macOS approach for cross-window/cross-app drag-and-drop. The tab's `WKWebView` cannot be transferred, so the target window creates a fresh WebView that loads the tab's URL.

**Alternatives considered:**
- *Shared tab registry with move semantics*: Requires a global store or coordinator, contradicting decision #1.
- *NSItemProvider with UUID only*: UUIDs are meaningless across independent stores; the target window cannot look up a UUID it doesn't own.

### 5. Window close disposes all tabs

**Decision:** When a window is closed, its store is deallocated, which naturally disposes all tabs and their WebViews. No explicit cleanup code needed beyond SwiftUI's standard lifecycle.

**Rationale:** Since each window owns its own store, SwiftUI's window lifecycle handles teardown automatically. The `@State` store in the window's view hierarchy is released when the window closes.

## Risks / Trade-offs

- **WebView reload on cross-window move** -- Moving a tab to another window requires creating a new WKWebView and reloading the URL. Page state (scroll position, form input, JavaScript state) is lost. This is acceptable because it matches Safari's behavior and avoids the complexity of WKWebView reparenting.
- **No undo for cross-window tab moves** -- Once a tab is moved, the original window removes it. There is no built-in undo. Mitigation: The user can drag it back.
- **Drag feedback across windows** -- SwiftUI's built-in drag-and-drop across windows may have visual limitations (e.g., no custom drag preview between windows). macOS handles this at the system level, so it should work, but testing is needed.
- **Memory growth** -- Each window has its own set of WebViews. Many windows with many tabs will consume proportionally more memory. This is expected behavior consistent with other browsers.

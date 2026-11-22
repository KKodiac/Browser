## Context

The browser currently renders a single selected tab's WebView in a `ZStack`-based content area. All tabs have their WebViews created and kept alive, with only the selected tab's WebView visible (opacity 1, hit-testing enabled). The app uses TCA (ComposableArchitecture) with an `AppFeature` reducer, and state includes `selectedId: UUID?` to track the single active tab. The URL bar reads from `selectedTab` to show the current page's URL.

## Goals / Non-Goals

**Goals:**
- Display two tabs side-by-side in a horizontal split view
- Track which pane (primary or secondary) is active for URL bar and keyboard focus
- Enter split view from a tab context menu ("Open in Split View")
- Exit split view via a close button on the secondary pane or a menu item
- URL bar shows the active pane's tab URL
- Visually distinguish the active pane from the inactive pane

**Non-Goals:**
- Vertical split (top/bottom) — only horizontal (left/right)
- More than two panes (no triple split or grid)
- Resizable split ratio via dragging (use equal 50/50 split; `HSplitView` provides this)
- Independent navigation controls per pane (back/forward/reload stay in the shared URL bar, operating on the active pane)
- Split view persistence across app launches

## Decisions

### 1. HSplitView with two WebView panes

**Decision:** When split view is active, replace the single-tab `ZStack` content area with an `HSplitView` containing two `ZStack` panes, each showing one tab's WebView.

**Rationale:** `HSplitView` is the native macOS SwiftUI component for side-by-side layouts. It handles the divider automatically. Each pane uses the same `ZStack`-of-all-WebViews approach as the current single-tab layout, just filtered to its assigned tab.

**Alternatives considered:**
- *GeometryReader with manual split* — reinvents what `HSplitView` provides natively.
- *Two windows* — breaks the "single window, two panes" requirement and loses shared tab bar context.

### 2. Primary/secondary tab selection model

**Decision:** Extend state with `secondaryTabId: UUID?` and `activePane: Pane` (enum: `.primary`, `.secondary`). When `secondaryTabId` is non-nil, split view is active. The existing `selectedId` serves as the primary pane's tab.

**Rationale:** Minimal state change. Split mode is simply `secondaryTabId != nil`, so no separate boolean is needed. `activePane` determines which pane receives URL bar input and navigation commands.

**Alternatives considered:**
- *Separate `isSplitViewActive` boolean* — redundant with `secondaryTabId != nil` and adds a synchronization risk.
- *Array of pane IDs* — over-engineered for a two-pane maximum.

### 3. Enter split view via tab context menu

**Decision:** Add "Open in Split View" to the context menu on both ungrouped and grouped tabs. This sets the right-clicked tab as the secondary pane tab while the currently selected tab stays in the primary pane.

**Rationale:** Context menu is the established pattern for tab actions in this app. The right-clicked tab becomes the secondary pane because the user is expressing intent to view *that* tab alongside the current one.

**Alternatives considered:**
- *Menu bar only* — less discoverable.
- *Drag tab to edge of content area* — complex gesture handling, not standard in SwiftUI.

### 4. Close split view with button or menu

**Decision:** Show a small close button (X) on the secondary pane's top-trailing corner. Also add a View menu item "Close Split View". Both set `secondaryTabId = nil`, returning to single-tab mode with the primary pane's tab selected.

**Rationale:** The close button provides direct manipulation; the menu item provides keyboard-accessible and discoverable access.

### 5. Active pane indicated by border highlight

**Decision:** The active pane gets a subtle accent-colored border. Clicking anywhere in a pane (including its WebView) sets that pane as active.

**Rationale:** Consistent with the app's existing accent color theming. A border is visible without being intrusive.

## Risks / Trade-offs

- **Two WKWebViews visible simultaneously** — Both panes render active WebViews, doubling the rendering cost for visible tabs. All other tabs remain alive but hidden as they do today. Mitigation: This is inherent to split view; memory impact is bounded to one extra visible WebView.
- **Active tab ambiguity** — Users may be confused about which pane the URL bar and navigation controls apply to. Mitigation: Clear visual border on the active pane, and the URL bar text updates to reflect the active pane's URL.
- **Tab closed while in split view** — If the user closes the tab shown in one of the panes, split view must gracefully degrade. Mitigation: Closing the secondary pane's tab exits split view. Closing the primary pane's tab promotes the secondary tab to primary and exits split view.

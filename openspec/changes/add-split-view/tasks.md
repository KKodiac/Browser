## 1. Split State Model

- [x] 1.1 Add `Pane` enum (`.primary`, `.secondary`) to AppFeature state
- [x] 1.2 Add `secondaryTabId: UUID?` to AppFeature state (nil means split view inactive)
- [x] 1.3 Add `activePane: Pane` to AppFeature state (defaults to `.primary`)
- [x] 1.4 Add computed `isSplitViewActive` property (`secondaryTabId != nil`)

## 2. HSplitView Layout

- [x] 2.1 Update `contentArea` to conditionally render `HSplitView` when split view is active
- [x] 2.2 Primary pane shows the `selectedId` tab's WebView
- [x] 2.3 Secondary pane shows the `secondaryTabId` tab's WebView
- [x] 2.4 Add close button (X) at the top-trailing corner of the secondary pane

## 3. Tab Context Menu Integration

- [x] 3.1 Add "Open in Split View" to ungrouped tab context menu
- [x] 3.2 Add "Open in Split View" to grouped tab context menu
- [x] 3.3 Guard against opening split view when right-clicked tab is the already-selected tab

## 4. Active Pane Tracking

- [x] 4.1 Add action to set active pane when user clicks in a pane
- [x] 4.2 Add accent-colored border to the active pane
- [x] 4.3 Set active pane to `.primary` by default when entering split view

## 5. URL Bar Binding

- [x] 5.1 Update URL bar text binding to read from active pane's tab (primary or secondary)
- [x] 5.2 Update URL bar submission to navigate the active pane's tab
- [x] 5.3 Update back/forward/reload controls to operate on the active pane's WebView

## 6. Close Split Action

- [x] 6.1 Add `closeSplitView` action that sets `secondaryTabId = nil` and `activePane = .primary`
- [x] 6.2 Handle closing the secondary pane's tab: exit split view, keep primary tab selected
- [x] 6.3 Handle closing the primary pane's tab: promote secondary tab to primary, exit split view

## 7. Menu Bar

- [x] 7.1 Add "Close Split View" item to the View menu (enabled only when split view is active)

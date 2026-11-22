## Context

The browser uses a TCA (Composable Architecture) `AppFeature` reducer with `@ObservableState`. The view layer is in `ContentView`, which holds a `@Bindable var store: StoreOf<AppFeature>` and a local `@State private var currentWebView: WKWebView?` reference. The `WebView` is an `NSViewRepresentable` wrapping `WKWebView`, with a `Coordinator` that calls `send` to dispatch TCA actions back to the reducer for navigation events.

The content area renders each tab's `WebView` in an overlay stack. There is currently no overlay UI on top of the web content.

## Goals / Non-Goals

**Goals:**
- Cmd+F opens a find bar overlaid on the web content area
- Typing in the find bar searches the current page and highlights matches
- Display total match count and current match index (e.g., "3 of 12")
- Cmd+G and Cmd+Shift+G navigate to next/previous match
- Escape dismisses the find bar and clears highlights
- Switching tabs dismisses the find bar and clears state

**Non-Goals:**
- Cross-tab search (searching across all open tabs)
- Regular expression or advanced search options
- Find and replace
- Persisting the last search query across sessions

## Decisions

### 1. JavaScript-based text search via evaluateJavaScript

**Decision:** Use `WKWebView.evaluateJavaScript()` with `window.find()` for match navigation, combined with CSS highlight injection for visual match highlighting and a counting script to report total matches.

**Rationale:** `window.find()` is the standard browser API for in-page text search and handles scrolling to matches natively. WKWebView does not expose a native Swift find API on macOS, so JavaScript is the only viable approach. This avoids private API usage and works with any web content.

**Alternatives considered:**
- *WKWebView `_findString:options:` private API*: Functional but private, could break between OS versions, and risks App Store rejection.
- *Custom DOM traversal and highlighting*: Significantly more complex, would need to handle iframes, shadow DOM, and text node splitting.

### 2. Find bar as a SwiftUI overlay at the top of the content area

**Decision:** Render the find bar as a SwiftUI `overlay(alignment: .top)` on the content area, not as part of the tab bar or URL bar.

**Rationale:** This is the standard browser convention (Chrome, Safari, Firefox all overlay find at the top-right of content). Keeping it as a SwiftUI overlay means it layers on top of the WebView without affecting layout. It also avoids modifying the existing tab bar or URL bar structure.

**Alternatives considered:**
- *Inline in the URL bar*: Would repurpose the URL bar, conflicting with its navigation role.
- *Separate toolbar row*: Would shift content down and add visual noise.

### 3. Find state in AppFeature reducer

**Decision:** Add find-in-page state fields to `AppFeature.State`: `isFindBarVisible: Bool`, `findText: String`, `findMatchCount: Int`, `findMatchIndex: Int`. Add corresponding actions: `toggleFindBar`, `updateFindText`, `findNext`, `findPrevious`, `updateFindResults`, `dismissFindBar`.

**Rationale:** Consistent with the existing TCA pattern. State belongs in the reducer so that tab switches and other actions can clear find state predictably. The view dispatches actions, the reducer owns state transitions.

### 4. Clear find state on tab switch

**Decision:** When `selectTab` is dispatched, automatically dismiss the find bar and clear find state.

**Rationale:** Find in Page is scoped to a single page. Keeping stale search state across tab switches would be confusing -- the highlighted matches belong to the previous page's DOM.

## Risks / Trade-offs

- **`window.find()` browser compatibility** -- `window.find()` is non-standard but universally supported in WebKit. If a future WebKit update removes it, the search would need to fall back to custom DOM traversal. Low risk given WebKit's long history of supporting it.
- **Match count accuracy** -- Counting matches requires a separate JavaScript pass (e.g., using `TextIterator` or string search on `document.body.innerText`). This may not perfectly match `window.find()` results in edge cases (hidden text, text within `<script>` tags). Acceptable for an initial implementation.
- **No iframe support** -- `window.find()` only searches the top-level frame. Pages with content in iframes (e.g., embedded documents) will not be fully searchable. This is consistent with how many browsers handle basic find.
- **Performance on large pages** -- The JavaScript counting pass runs on the main thread. On extremely large pages, this could cause a brief delay. Mitigation: debounce the search input so JavaScript is not fired on every keystroke.

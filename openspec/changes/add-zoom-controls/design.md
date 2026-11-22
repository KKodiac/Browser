## Context

The browser renders web content via `WKWebView` wrapped in an `NSViewRepresentable` (`WebView.swift`). Each tab is a `BrowserTab` struct with properties like URL, title, and loading state. The `WebView` coordinator manages navigation events and applies tab state to the underlying `WKWebView` in `updateNSView`.

`WKWebView` has a built-in `pageZoom` property (a `CGFloat`, default 1.0) that scales the entire page content. This is the standard API for page-level zoom on macOS WebKit.

The URL bar is part of `ContentView` and displays the current URL with navigation controls. There is currently no indicator or accessory view in the URL bar area beyond the URL text field and navigation buttons.

## Goals / Non-Goals

**Goals:**
- Per-tab zoom level that persists as the user switches between tabs
- Keyboard shortcuts: Cmd+Plus (zoom in), Cmd+Minus (zoom out), Cmd+0 (reset)
- Menu bar commands under View for all three zoom actions
- Zoom range clamped to 50%–200% in 10% increments
- Zoom indicator in the URL bar showing the current percentage when not at 100%

**Non-Goals:**
- Per-site zoom memory (remembering zoom for specific domains across tabs/sessions)
- Pinch-to-zoom gesture support (WKWebView handles this natively at the content level)
- Zoom level persistence across app launches
- Customizable zoom step size or range
- Zoom controls in a toolbar or floating panel

## Decisions

### 1. Store zoom level on BrowserTab as a Double

**Decision:** Add a `zoomLevel: Double` property to `BrowserTab` with a default of `1.0`. Values represent the multiplier (e.g., 1.5 = 150%).

**Rationale:** BrowserTab already holds all per-tab state (URL, title, loading, navigation). Zoom is per-tab state, so it belongs here. A Double maps directly to `WKWebView.pageZoom` with no conversion.

**Alternatives considered:**
- *Storing as Int percentage (e.g., 100)*: Requires conversion to/from Double for WKWebView. Adds unnecessary indirection.
- *Separate zoom state dictionary*: Scatters per-tab state across multiple locations.

### 2. Apply pageZoom in WebView.updateNSView

**Decision:** Set `webView.pageZoom = tab.zoomLevel` in `updateNSView` so the zoom level is applied whenever the tab state changes.

**Rationale:** `updateNSView` is already the single place where tab state flows into the WKWebView. Adding pageZoom here follows the existing pattern and ensures zoom is applied on tab switches automatically.

### 3. 10% step increments, 50%–200% range

**Decision:** Each zoom in/out action changes the zoom level by 0.1 (10%). The minimum is 0.5 (50%) and the maximum is 2.0 (200%).

**Rationale:** 10% steps match Safari's behavior and provide a good balance between granularity and quick adjustment. The 50%–200% range covers practical use cases without allowing absurdly small or large zoom levels.

### 4. Show percentage indicator in URL bar only when not at 100%

**Decision:** Display a small text label (e.g., "150%") in the URL bar area when the zoom level differs from 1.0. Hide it at the default zoom level to keep the UI clean.

**Rationale:** At 100% zoom there is nothing noteworthy to display. Showing the indicator only when zoom is active draws attention to the non-default state and provides a visual cue that zoom can be reset.

### 5. Menu bar commands under View menu

**Decision:** Add "Zoom In" (Cmd+Plus), "Zoom Out" (Cmd+Minus), and "Actual Size" (Cmd+0) to the View menu.

**Rationale:** Standard macOS browser convention. Users who prefer menu-driven interaction or forget shortcuts can discover the commands here.

## Risks / Trade-offs

- **Zoom resets on tab close** → Since BrowserTab is not persisted, zoom levels are lost when tabs are closed or the app quits. Acceptable for now; persistence is a separate concern.
- **Floating point rounding** → Repeated 0.1 increments can cause floating point drift (e.g., 0.7000000001). Mitigation: round to one decimal place after each zoom operation.
- **No visual feedback during zoom** → The page re-renders immediately via pageZoom, which provides inherent visual feedback. The URL bar indicator confirms the current level. No toast or animation is needed.

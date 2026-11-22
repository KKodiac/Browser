## Context

The browser uses TCA (ComposableArchitecture) with `StoreOf<AppFeature>` in ContentView. Tabs are modeled as `BrowserTab` structs with an optional `url: URL?` — new tabs have `url = nil` and title "New Tab". The content area currently renders a `WebView` for every tab in a ZStack, even when a tab has no URL to load. There is no history or bookmarks system yet; those are planned as separate capabilities.

## Goals / Non-Goals

**Goals:**
- Show a custom new tab page instead of a blank white page when a tab has no URL
- Provide a centered search field that, when tapped, focuses the URL bar
- Display a grid of frequently visited sites (favicon + title) sourced from history when available
- Display a favorites/bookmarks section sourced from bookmarks when available
- Show a clean, informative empty state for new users with no history or favorites

**Non-Goals:**
- Custom backgrounds or wallpaper on the NTP
- News feed, weather, or other content widgets
- User-customizable layout or sections
- Syncing NTP data across devices
- Showing recently closed tabs on the NTP

## Decisions

### 1. SwiftUI native view instead of loading a local HTML page

**Decision:** Render the new tab page as a native SwiftUI view (`NewTabPageView`), shown in place of the `WebView` when a tab has no URL.

**Rationale:** A native view integrates naturally with the TCA store, SwiftUI focus system, and the app's existing styling. It avoids the complexity of bundling and loading a local HTML file into WKWebView, and makes it trivial to bind to app state (history, bookmarks, accent color).

**Alternatives considered:**
- *Local HTML file loaded in WebView*: Would require bridge communication for clicks and data, harder to style consistently with the app.
- *`about:newtab` URL scheme*: Adds URL-scheme handling complexity and still requires rendering custom content in WebView.

### 2. Search field focuses the URL bar

**Decision:** The NTP search field is a visual element that, when tapped, focuses the existing URL bar at the bottom of the window. No separate search is performed from the NTP.

**Rationale:** Avoids duplicating search/navigation logic. The URL bar already handles search-or-URL resolution. The NTP search field serves as a visual cue and affordance, not a second input system.

**Alternatives considered:**
- *Functional search field on NTP*: Would duplicate URL bar logic and create ambiguity about which input to use.

### 3. Graceful degradation without history/bookmarks

**Decision:** The NTP checks whether history and bookmarks data sources are available. When they are not (initial implementation, or new user with no data), the NTP shows a minimal empty state with a welcome message and the search field.

**Rationale:** The NTP should ship before history and bookmarks are implemented. Hard-coding sample data would be misleading. A clean empty state is honest and still useful (the search field remains functional).

**Alternatives considered:**
- *Block NTP until history/bookmarks ship*: Delays a useful improvement unnecessarily.
- *Show hardcoded suggested sites*: Adds maintenance burden and may not match user interests.

### 4. Frequently visited grid layout

**Decision:** Display frequently visited sites in a grid of rounded-rect tiles, each showing the site's favicon (or a letter placeholder) and the site's title or hostname.

**Rationale:** This is the established convention across Safari, Chrome, and Firefox new tab pages. Users recognize and expect this pattern. A grid provides scannable, click-friendly targets.

**Alternatives considered:**
- *List layout*: Less visually appealing and wastes horizontal space on a wide content area.
- *Icon-only grid (no titles)*: Favicons alone are not always recognizable; titles improve usability.

## Risks / Trade-offs

- **No data sources yet** -- Until history and bookmarks capabilities are implemented, the NTP will only show the empty state and search field. This is acceptable; the NTP is still an improvement over a blank page.
- **Favicon availability** -- Favicons require either a favicon-fetching mechanism or reliance on the history/bookmarks system to store them. The initial implementation can use letter-based placeholders until favicon display is available.
- **Content area switching** -- Toggling between `NewTabPageView` and `WebView` based on the tab's URL state must handle the transition when the user submits a URL. The WebView should appear as soon as navigation begins.

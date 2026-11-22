## Context

The browser uses a `WebView` NSViewRepresentable that creates a `WKWebView` with a default `WKWebViewConfiguration`. There is no content filtering — every resource requested by a page is loaded. The `WKWebViewConfiguration` is created fresh in `makeNSView` with no custom rules attached.

WebKit provides `WKContentRuleListStore` for compiling JSON content-blocking rules (the same format used by Safari Content Blockers) into optimized `WKContentRuleList` objects. These can be attached to a `WKWebViewConfiguration` via `add(_:)` before the web view is created, or to the user content controller.

## Goals / Non-Goals

**Goals:**
- Block common ad and tracker domains using WebKit's native content rule list API
- Bundle a default block list in JSON format within the app
- Compile rules at launch so they are available immediately
- Users can toggle content blocking on or off globally
- Blocked resources are simply not loaded — no placeholder UI needed

**Non-Goals:**
- Custom user-defined filter lists (future enhancement)
- Per-site whitelist / exemption list (future enhancement)
- Displaying a count of blocked resources per page
- Supporting ABP/uBlock filter syntax (only WebKit JSON format)
- Automatic block list updates from a remote server

## Decisions

### 1. Use WKContentRuleListStore with bundled JSON rules

**Decision:** Compile content-blocking rules from a bundled JSON file using `WKContentRuleListStore.default().compileContentRuleList()`. The JSON follows WebKit's content blocker format (array of trigger/action objects).

**Rationale:** This is WebKit's native, high-performance mechanism for content blocking. Rules are compiled into an optimized bytecode format and evaluated at the network layer — no JavaScript injection or request interception needed. Safari extensions use the same format.

**Alternatives considered:**
- *WKNavigationDelegate interception*: Would require canceling requests in `decidePolicyFor`, which is slower, less reliable, and misses subresource loads.
- *JavaScript injection*: Fragile, can be circumvented, and runs too late to prevent resource downloads.

### 2. Compile rules at app launch

**Decision:** Compile the block list once during app startup and cache the resulting `WKContentRuleList` in memory. Reuse it for all web views.

**Rationale:** Compilation is async but typically fast (~100ms for a moderate list). Doing it once at launch avoids per-tab compilation overhead. The compiled rule list is thread-safe and can be shared.

**Alternatives considered:**
- *Lazy compilation on first web view*: Adds latency to the first page load. Startup compilation is simpler.
- *Persisted compiled rules*: `WKContentRuleListStore` already caches compiled rules to disk via its identifier-based API; explicit persistence is unnecessary.

### 3. Global toggle stored in UserDefaults

**Decision:** Store the content-blocking enabled/disabled state in `UserDefaults` as a boolean. Default to enabled.

**Rationale:** Simple, persists across launches, no new persistence infrastructure needed. A global toggle is the minimum viable UX — per-site controls can be layered on later.

### 4. Apply rules via WKWebViewConfiguration

**Decision:** When content blocking is enabled, add the compiled `WKContentRuleList` to the `WKWebViewConfiguration.userContentController` before creating each `WKWebView`. When disabled, do not add it.

**Rationale:** Rules must be on the configuration at web view creation time to take effect. Toggling requires re-creating web views or using `add`/`removeAllContentRuleLists` on the user content controller for existing views.

### 5. Toolbar toggle button

**Decision:** Add a shield icon button to the toolbar that toggles content blocking on/off. The icon state reflects whether blocking is active.

**Rationale:** A toolbar button provides quick, discoverable access. A shield icon is the established convention for content/privacy controls in browsers.

## Risks / Trade-offs

- **Block list maintenance** — The bundled list is static and will become outdated. Mitigation: Keep the list focused on well-known, stable ad/tracker domains. Remote update capability can be added later.
- **Site breakage** — Overly broad rules may break site functionality (e.g., blocking CDN domains used for both ads and content). Mitigation: Keep rules conservative; the global toggle lets users disable blocking when a site breaks.
- **Toggle requires web view awareness** — Changing the toggle state for already-loaded tabs requires adding/removing the rule list from existing user content controllers, or reloading the page. Mitigation: Apply the change to existing web views via `userContentController.add`/`removeAllContentRuleLists` and reload the active tab.

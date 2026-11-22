## Why

The browser currently loads all content on every page without filtering. Users are exposed to ads, tracking scripts, and unwanted third-party resources that slow down page loads, consume bandwidth, and compromise privacy. Content blocking is a core browser capability that users expect.

## What Changes

- Add a `ContentBlockerManager` that compiles WebKit-format JSON rule lists into `WKContentRuleList` objects using `WKContentRuleListStore`
- Bundle a default block list JSON file containing rules for common ad and tracker domains
- Apply compiled content rules to all web views via `WKWebViewConfiguration`
- Add a global toggle in the toolbar to enable/disable content blocking
- Compile rules at app launch so they are ready before the first page load

## Capabilities

### New Capabilities
- `content-blocker`: Content rule compilation from JSON, rule application to web views, global enable/disable toggle, and bundled default block list

### Modified Capabilities
_None — no existing spec requirements change._

## Impact

- **WebView.swift**: Update `WKWebViewConfiguration` to attach compiled `WKContentRuleList` when content blocking is enabled
- **ContentView.swift**: Add toolbar toggle button for content blocking on/off state
- New files: `ContentBlockerManager.swift`, `default-blocklist.json`
- No new dependencies — uses only WebKit's built-in `WKContentRuleListStore` API

## 1. Block List JSON

- [x] 1.1 Create `default-blocklist.json` in WebKit content blocker format with trigger/action rules for common ad-serving domains
- [x] 1.2 Add rules for common tracker domains (analytics, fingerprinting)
- [x] 1.3 Bundle the JSON file in the app target

## 2. Rule Compilation

- [x] 2.1 Create `ContentBlockerManager` class that loads the bundled JSON and compiles it via `WKContentRuleListStore`
- [x] 2.2 Compile rules at app launch and store the resulting `WKContentRuleList` in memory
- [x] 2.3 Handle compilation errors gracefully (log and continue without blocking)

## 3. WKWebView Integration

- [x] 3.1 Update `WebView.makeNSView` to add the compiled `WKContentRuleList` to the `WKWebViewConfiguration.userContentController` when blocking is enabled
- [x] 3.2 Support adding/removing the rule list on existing web views when the toggle changes
- [x] 3.3 Reload the active tab after toggling content blocking state

## 4. Toggle UI

- [x] 4.1 Add content-blocking enabled/disabled state persisted via `UserDefaults` (default: enabled)
- [x] 4.2 Add shield icon toolbar button to toggle content blocking on/off
- [x] 4.3 Update shield icon appearance to reflect current state (filled = enabled, outlined = disabled)

## 5. Bundled Default Rules

- [x] 5.1 Verify block list rules conform to WebKit content blocker JSON specification
- [x] 5.2 Test that blocked domains are not loaded on pages that reference them
- [x] 5.3 Test that non-blocked resources load normally with blocking enabled

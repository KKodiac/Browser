## Why

The browser has no way to search for text within a loaded web page. Users must visually scan pages to find specific content. Find in Page (Cmd+F) is a fundamental browser capability that lets users locate text quickly, see how many matches exist, and jump between them.

## What Changes

- Add a find bar overlay at the top of the content area with a text field, match count, and prev/next buttons
- Integrate with WKWebView's JavaScript-based text search to highlight matches
- Add keyboard shortcuts: Cmd+F (open), Cmd+G (next match), Cmd+Shift+G (previous match), Escape (dismiss)
- Add find-in-page state to the TCA AppFeature reducer (search text, match count, active match index, visibility)
- Clear find bar state when the user switches tabs

## Capabilities

### New Capabilities
- `find-in-page`: Find bar UI overlay, WKWebView text search integration, match highlighting, match count display, next/previous match navigation, and keyboard shortcuts

### Modified Capabilities

_(none -- no existing spec requirements change)_

## Impact

- **ContentView.swift**: Add find bar overlay on the content area, keyboard shortcut handlers for Cmd+F, Cmd+G, Cmd+Shift+G, Escape
- **WebView.swift**: Add methods to execute find/highlight JavaScript on the WKWebView, communicate match results back via TCA actions
- **AppFeature.swift**: New find-in-page state fields and actions (toggle find bar, update search text, next/previous match, clear find state)
- No new dependencies -- uses WKWebView's `evaluateJavaScript` with standard DOM APIs

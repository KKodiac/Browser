## Context

The browser's URL bar is a plain `TextField` at the bottom of the window in `ContentView`. The user types a URL or search query and presses Enter to navigate. There is no type-ahead, no suggestion list, and no recall of previously visited pages. The URL bar text is bound to `store.urlBarText` and submission triggers `store.send(.urlBarSubmitted)`.

History and bookmarks features are planned but not yet implemented. The suggestion engine must work without them initially (falling back to a built-in popular sites list) and integrate with them when they become available.

## Goals / Non-Goals

**Goals:**
- Show autocomplete suggestions as the user types in the URL bar
- Match against page titles and URLs from history, bookmarks, and popular sites
- Rank results by relevance (prefix match > substring match, frequency as tiebreaker)
- Support keyboard navigation: arrow keys to select, Enter to accept, Escape to dismiss
- Inline completion: auto-fill the top match in the text field (distinguished from user input)
- Debounce input to avoid excessive computation on every keystroke
- Limit results to top 8 suggestions

**Non-Goals:**
- Remote suggestion API (no network requests for suggestions)
- Search engine suggestions (Google/Bing autocomplete)
- Suggestion personalization or ML-based ranking
- Syncing suggestion data across devices
- Favicons in the suggestion list (depends on favicon feature)

## Decisions

### 1. Local-only matching
**Decision:** All matching happens locally against in-memory data sources (history, bookmarks, popular sites). No network requests.
**Rationale:** Keeps the feature simple, fast, and privacy-respecting. Network-based suggestions add latency, require API keys, and raise privacy concerns. Local matching is sufficient for revisiting known pages.
**Alternatives:** Google Suggest API (privacy concern, external dependency), hybrid local + remote (unnecessary complexity for initial version).

### 2. Dropdown list positioned above the URL bar
**Decision:** Show suggestions in a floating list that appears above the URL bar (since the bar is at the bottom of the window). The list overlays the web content area.
**Rationale:** The URL bar is at the bottom edge of the window. A dropdown below it would be clipped or off-screen. Rendering above keeps suggestions visible and follows the spatial convention of completions appearing adjacent to the input.
**Alternatives:** Dropdown below (clipped by window edge), inline expansion (pushes content, disruptive).

### 3. Fuzzy matching on title and URL
**Decision:** Match user input against both the page title and URL. Use prefix matching first (higher rank), then substring matching. Case-insensitive.
**Rationale:** Users may remember a page by its title ("GitHub") or by part of the URL ("github.com"). Matching both fields maximizes recall. Prefix matches rank higher because they indicate stronger intent.

### 4. Debounced input (150ms)
**Decision:** Debounce the suggestion computation by 150ms after the last keystroke.
**Rationale:** Prevents recomputing suggestions on every character while keeping the UI responsive. 150ms is fast enough to feel instant but avoids wasted work during rapid typing.

### 5. Top 8 results
**Decision:** Show at most 8 suggestions in the dropdown.
**Rationale:** 8 results fit comfortably in a compact list without overwhelming the user or obscuring too much content. Matches common autocomplete conventions.

### 6. Inline completion of top match
**Decision:** The top suggestion's URL is auto-filled in the text field with the completion portion selected (highlighted). Pressing Enter navigates to the completed URL; continuing to type replaces the completion.
**Rationale:** Standard browser behavior. Lets the user accept the top match with a single Enter press without looking at the dropdown.

## Risks / Trade-offs

- **No data sources yet** -- History and bookmarks are not implemented. The initial version will only match against a small built-in popular sites list, making the feature feel limited until those stores exist. Mitigation: Design the engine with a pluggable data source interface so history/bookmarks integrate cleanly later.
- **Overlay positioning** -- The dropdown overlays web content, which could obscure important page elements. Mitigation: The dropdown is temporary (dismissed on Escape, blur, or navigation) and limited to 8 items, keeping its height modest.
- **Debounce latency** -- 150ms delay means very fast typists may notice a brief gap before suggestions appear. Mitigation: 150ms is below most users' perception threshold; can be tuned lower if needed.

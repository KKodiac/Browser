## Context

The browser uses a `BrowserTab` struct with title, URL, and loading state, but no favicon information. Tabs are rendered as text-only buttons in a horizontal `ScrollView` tab bar. The `WebView` wrapper already communicates page state (title, URL, loading) back to the parent via TCA actions. Favicon extraction and display can follow the same pattern.

The app uses Composable Architecture (TCA) with `AppFeature` managing tab state. The `WebView` is an `NSViewRepresentable` wrapping `WKWebView`.

## Goals / Non-Goals

**Goals:**
- Extract favicon URL from loaded web pages automatically
- Display favicons in tab bar items next to the tab title
- Display the active tab's favicon in the URL bar
- Cache favicon images in memory to avoid redundant network requests
- Show a styled fallback icon (first letter of domain) when no favicon is available

**Non-Goals:**
- Favicon display in bookmarks (separate feature, depends on bookmarks implementation)
- Persistent favicon cache on disk (memory cache is sufficient for session lifetime)
- Custom favicon database or manual favicon assignment
- Favicon display for "New Tab" pages (no URL loaded)
- High-resolution favicon selection (use whatever the site provides)

## Decisions

### 1. Extract favicon URL via JavaScript injection
**Decision:** After a page finishes loading, evaluate JavaScript in the WKWebView to find `<link rel="icon">` or `<link rel="shortcut icon">` elements. If none found, fall back to `{origin}/favicon.ico`.
**Rationale:** This is the most reliable approach — it reads what the page actually declares. WKWebView already supports `evaluateJavaScript`, and the WebView wrapper already runs delegate callbacks on page load.
**Alternatives:** WKWebView's `serverTrust` or HTTP response headers (don't carry favicon info), Google's favicon service `https://www.google.com/s2/favicons?domain=` (adds external dependency and privacy concern), parsing HTML manually (unnecessary when JS can query the DOM).

### 2. In-memory cache with NSCache
**Decision:** Cache downloaded favicon `NSImage` instances in an `NSCache<NSURL, NSImage>` keyed by favicon URL.
**Rationale:** `NSCache` handles memory pressure automatically (evicts under memory pressure), is thread-safe, and requires no cleanup code. Favicons are small (typically 16x16 or 32x32) so memory usage is negligible. No need for disk persistence since favicons are re-fetched cheaply on next launch.
**Alternatives:** `URLCache` (caches raw data, not decoded images — still need decode step), Dictionary (no auto-eviction), disk cache (overkill for small session-lived images).

### 3. AsyncImage for display with NSImage fallback
**Decision:** Use `AsyncImage` for displaying favicons in SwiftUI views when the image is not yet cached. When the image is in the `NSCache`, wrap it in an `Image(nsImage:)` directly.
**Rationale:** `AsyncImage` handles loading states natively. Combining it with the cache avoids flicker for already-loaded favicons. This keeps the view code simple and declarative.
**Alternatives:** Custom `@Observable` image loader (more code, same result), raw `URLSession` in the view (violates SwiftUI patterns).

### 4. First-letter fallback icon
**Decision:** When no favicon URL is available (or the favicon fails to load), display a small rounded rectangle with the first letter of the domain, styled with a muted color.
**Rationale:** Avoids an empty gap in the tab bar. A letter provides some visual identity. Globe icons (the common alternative) all look identical and don't help differentiation.
**Alternatives:** Globe system icon `globe` (generic, doesn't help identify tabs), empty space (looks broken), colored dot (no semantic meaning).

## Risks / Trade-offs

- **JavaScript injection timing** — The favicon `<link>` tag may be added dynamically after initial page load (e.g., SPAs). The current approach extracts once on `didFinishNavigation`. If this proves insufficient, a `MutationObserver`-based approach can be added later.
- **Favicon load failures** — Some sites serve broken favicon URLs or block cross-origin image requests. The fallback icon handles this gracefully, but there may be a brief flicker between "loading" and "fallback" states.
- **Tab bar width** — Adding a 16x16 favicon image to each tab increases the minimum tab width slightly. This is acceptable given the current 150pt max-width constraint on tab titles.
- **Memory usage** — NSCache will hold favicon images for all open tabs. At typical sizes (16x16 to 32x32, ~4KB each), even 100 tabs would use under 1MB. NSCache auto-evicts under memory pressure.

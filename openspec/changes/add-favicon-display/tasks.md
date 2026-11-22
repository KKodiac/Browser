## 1. Favicon Extraction

- [x] 1.1 Add optional `faviconURL: URL?` property to `BrowserTab`
- [x] 1.2 Add TCA action for favicon URL updates (e.g., `.tabFaviconUpdated(id:url:)`)
- [x] 1.3 Inject JavaScript in `WebView` on `didFinishNavigation` to extract `<link rel="icon">` href
- [x] 1.4 Fall back to `{origin}/favicon.ico` when no link element is found
- [x] 1.5 Send extracted favicon URL back to the store via the send closure

## 2. Favicon Caching

- [x] 2.1 Create `FaviconCache` class wrapping `NSCache<NSURL, NSImage>`
- [x] 2.2 Implement `image(for:)` returning cached `NSImage?` and `store(_:for:)` to insert
- [x] 2.3 Implement async `fetchImage(for:)` that checks cache first, then downloads via URLSession

## 3. Tab Bar Display

- [x] 3.1 Update `tabButtonContent` in `ContentView` to show favicon image (16x16) left of tab title
- [x] 3.2 Load favicon from cache or asynchronously via `FaviconCache.fetchImage(for:)`
- [x] 3.3 Show fallback icon while favicon is loading or when favicon URL is nil (skip for New Tab)

## 4. URL Bar Display

- [x] 4.1 Add favicon image (16x16) to `urlBar` in `ContentView`, left of the URL text field
- [x] 4.2 Show active tab's favicon or fallback icon; show nothing when no URL is loaded

## 5. Fallback Icon

- [x] 5.1 Create a reusable `FaviconFallbackView` that displays the first letter of the domain in a rounded rectangle
- [x] 5.2 Use fallback in tab bar and URL bar when favicon is unavailable or fails to load

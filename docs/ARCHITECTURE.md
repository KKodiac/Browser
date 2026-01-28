# Browser Architecture

## BrowserEngineKit (Apple) — Context

[Designing your browser architecture](https://developer.apple.com/documentation/BrowserEngineKit/designing-your-browser-architecture) describes Apple’s **BrowserEngineKit** framework for building browsers with **alternative engine** support.

### What BrowserEngineKit Is

- **Purpose**: Enables third-party browsers to use rendering engines other than WebKit on **iOS/iPadOS**.
- **Availability**: Currently available under strict conditions in the **European Union** (entitlements, WPT/Test262, security policies).
- **Architecture**: Multi-process, with four process types:
  - **Main** — App launch, user interaction, UI.
  - **Networking** — Network requests and responses.
  - **Rendering** — GPU and compositing.
  - **WebContent** — DOM, layout, and JavaScript (possibly JIT).

Processes communicate via **XPC**. You run one Networking and one Rendering process, and multiple WebContent processes as needed.

### Can We Use BrowserEngineKit for This App?

- **On macOS**: BrowserEngineKit is documented for **iOS/iPadOS**. There is no public macOS API for alternative engines in the same way.
- **Everywhere else**: Outside the EU (or without the required entitlements), you cannot use BrowserEngineKit for an alternative engine.
- **Conclusion**: For a **single, runnable browser app** on macOS that doesn’t depend on EU entitlements, we use **WebKit (WKWebView)** and structure the app so that:
  - The **conceptual** split (UI vs. engine vs. networking) is clear.
  - A future **BrowserEngineKit-based** iOS version could replace the WebKit “engine” layer with the framework’s multi-process engine.

---

## Our Browser Design

### High-Level Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│  App (Main process)                                              │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────────┐   │
│  │  Toolbar    │  │  Tab bar    │  │  Content area            │   │
│  │  URL, nav   │  │  Tab list   │  │  Active WebView / Tab    │   │
│  └─────────────┘  └─────────────┘  └─────────────────────────┘   │
│                              │                                    │
│  ┌───────────────────────────▼───────────────────────────────┐   │
│  │  Tab model & navigation state (per tab)                    │   │
│  │  url, title, loading, canGoBack, canGoForward              │   │
│  └───────────────────────────┬───────────────────────────────┘   │
│                              │                                    │
│  ┌───────────────────────────▼───────────────────────────────┐   │
│  │  Web engine layer (WKWebView today; BrowserEngineKit later)│   │
│  │  Load URL, back/forward, reload, evaluate JS               │   │
│  └───────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────┘
```

- **Main process**: SwiftUI app — window, toolbar, tab bar, URL bar, and coordination of tabs.
- **Web engine layer**: Today this is **WKWebView** (WebKit). On iOS in the EU, this could be replaced by a BrowserEngineKit-backed implementation (different process model, same logical interface).

### Functional Scope

| Feature            | Description                                      |
|--------------------|--------------------------------------------------|
| **URL bar**        | Enter URL or search; load on submit.             |
| **Navigation**     | Back, Forward, Reload.                           |
| **Tabs**           | Multiple tabs; add, close, switch.               |
| **Web content**    | Render pages via WKWebView (WebKit).             |
| **Title**          | Show page title in tab and/or window.           |
| **Loading state**  | Indicate when a page is loading.                 |

Optional later: bookmarks, history, new-window/popup handling.

### Technology Choices

- **Platform**: macOS (SwiftUI + AppKit where needed).
- **UI**: SwiftUI.
- **Web**: `WKWebView` via `NSViewRepresentable` (WebKit is process-isolated by the system).
- **State**: `ObservableObject` for app and per-tab state; SwiftUI for binding.

### Mapping to BrowserEngineKit Concepts

| BrowserEngineKit | Our app (macOS, WebKit)                |
|------------------|----------------------------------------|
| Main process     | SwiftUI app (window, toolbar, tabs)   |
| WebContent       | WKWebView (WebKit’s own process)      |
| Networking       | Handled inside WebKit / WKWebView    |
| Rendering        | Handled inside WebKit / WKWebView     |

So we don’t implement separate Networking or Rendering processes; we rely on WebKit. A BrowserEngineKit-based iOS version would introduce explicit Networking and Rendering processes and multiple WebContent processes, while the **UI and tab model** could stay conceptually the same.

---

## Summary

- **BrowserEngineKit** is the right framework for **alternative engines on iOS in the EU**; it is not used in this macOS app.
- This app is a **WebKit-based macOS browser** with a clear structure (UI, tab model, engine layer) so it could later inform or align with a BrowserEngineKit-based design.
- All core browser functionality (URL bar, navigation, tabs, loading state) is implemented in the **Main** app process, with the **Web** engine (WKWebView) behind a simple abstraction.

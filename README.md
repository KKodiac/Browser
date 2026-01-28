# Browser

A native macOS browser built with **SwiftUI** and **WebKit (WKWebView)**, designed with [Apple’s BrowserEngineKit architecture](https://developer.apple.com/documentation/BrowserEngineKit/designing-your-browser-architecture) in mind.

## BrowserEngineKit vs This App

- **BrowserEngineKit** is Apple’s framework for **alternative browser engines** on **iOS/iPadOS** in the **EU** (entitlements, WPT/Test262, security requirements). It uses a multi-process design: Main, Networking, Rendering, WebContent.
- **This app** runs on **macOS** and uses **WebKit (WKWebView)** so it works without special entitlements. The architecture (UI, tabs, engine layer) is structured so it could later align with a BrowserEngineKit-style design.

See [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) for the full design and mapping to BrowserEngineKit.

## Features

- **URL bar** — Enter a URL or search; loads HTTPS and falls back to Google search.
- **Navigation** — Back, Forward, Reload (toolbar and gestures).
- **Tabs** — Multiple tabs; add (+), close (×), switch by clicking.
- **Page title** — Shown in the tab; loading state in the toolbar.

## Requirements

- **macOS 14.0+** (Sonoma)
- **Xcode 15+** (Swift 5.9)

## Build and Run

1. Open the project in Xcode:
   ```bash
   open Browser.xcodeproj
   ```
2. Select the **Browser** scheme and a Mac destination.
3. Press **⌘R** to build and run.

The app uses the **App Sandbox** with **Outgoing network (client)** so it can load web pages.

## Project Structure

```
Browser/
├── Browser.xcodeproj/
├── Browser/
│   ├── BrowserApp.swift    # @main App, window
│   ├── ContentView.swift   # Toolbar, tab bar, content area
│   ├── WebView.swift       # WKWebView wrapper (NSViewRepresentable)
│   ├── BrowserTab.swift    # Tab model (url, title, loading, nav state)
│   ├── Info.plist
│   └── Browser.entitlements
└── docs/
    └── ARCHITECTURE.md     # Design and BrowserEngineKit mapping
```

## License

Use and modify as you like.

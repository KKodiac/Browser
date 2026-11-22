## Why

The browser currently has no user-configurable settings. Search queries are hardcoded to Google, there is no home page setting, and the accent color picker lives inline in the URL bar rather than in a dedicated preferences pane. Users cannot change their default search engine, configure privacy preferences, or choose a download location. A Settings / Preferences window is a fundamental browser capability that every user expects behind Cmd+,.

## What Changes

- Add a `Settings` model that holds all user preferences (search engine, home page URL, download location, privacy toggles)
- Persist settings to UserDefaults via `@AppStorage`
- Add a SwiftUI `Settings` scene accessible via Cmd+, (standard macOS Preferences)
- Organize preferences into three tabs: General, Appearance, Privacy
- Move the accent color picker from the URL bar into the Appearance tab
- Update the URL submission logic in `AppFeature` to use the configured search engine instead of hardcoded Google
- Add "clear browsing data on quit" behavior when the privacy toggle is enabled

## Capabilities

### New Capabilities
- `settings`: Preferences model and UserDefaults-backed storage for search engine, home page, download location, and privacy toggles
- `settings-ui`: Preferences window with tabbed layout (General, Appearance, Privacy), accessible via Cmd+,

### Modified Capabilities
_None — no existing spec requirements change._

## Impact

- **BrowserApp.swift**: Add a `Settings` scene for the preferences window; Cmd+, is handled automatically by SwiftUI
- **AppFeature.swift**: Read configured search engine from UserDefaults when constructing search URLs in `urlBarSubmitted`; read home page URL for new tabs if configured
- **ContentView.swift**: Remove inline accent color picker from URL bar (moved to Appearance settings tab)
- **TabGroup.swift**: AccentColor enum remains but is now set from the preferences window instead of the URL bar menu
- No new dependencies — uses only SwiftUI, Foundation, and UserDefaults

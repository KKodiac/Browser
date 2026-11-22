## 1. Settings Model

- [x] 1.1 Create `SearchEngine` enum (google, duckduckgo, bing) with `searchURLPrefix` computed property and RawRepresentable conformance for UserDefaults storage
- [x] 1.2 Define UserDefaults keys as constants (searchEngine, homePageURL, downloadLocation, blockTrackers, clearDataOnQuit, accentColor)

## 2. UserDefaults Storage

- [x] 2.1 Add `@AppStorage` properties for search engine (default: google), home page URL (default: empty), download location (default: ~/Downloads)
- [x] 2.2 Add `@AppStorage` properties for block trackers (default: false) and clear data on quit (default: false)
- [x] 2.3 Migrate accent color from in-memory `AppFeature.State` to `@AppStorage` so it persists across launches

## 3. Preferences Window

- [x] 3.1 Add `Settings` scene to `BrowserApp.body` (provides Cmd+, automatically)
- [x] 3.2 Create `SettingsView` with `TabView` containing General, Appearance, and Privacy tabs
- [x] 3.3 Set appropriate window size and tab icons (gear, paintbrush, lock)

## 4. General Tab

- [x] 4.1 Create `GeneralSettingsTab` view with search engine picker (Picker with `SearchEngine.allCases`)
- [x] 4.2 Add home page URL text field with validation (must be valid URL or empty)
- [x] 4.3 Add download location selector using folder picker button that displays the current path

## 5. Appearance Tab

- [x] 5.1 Create `AppearanceSettingsTab` view with accent color picker (move from URL bar)
- [x] 5.2 Remove inline accent color picker from ContentView URL bar
- [x] 5.3 Ensure accent color changes propagate reactively to all views via `@AppStorage`

## 6. Privacy Tab

- [x] 6.1 Create `PrivacySettingsTab` view with "Block Trackers" toggle
- [x] 6.2 Add "Clear Browsing Data on Quit" toggle
- [x] 6.3 Implement clear-data-on-quit behavior via `NSApplication.willTerminate` notification (clear WKWebsiteDataStore)

## 7. Integration with Existing Features

- [x] 7.1 Update `AppFeature.urlBarSubmitted` to read search engine from UserDefaults instead of hardcoded Google URL
- [x] 7.2 Update `AppFeature.addTab` to load the configured home page URL if set
- [x] 7.3 Wire tracker blocking setting to WKWebView content rule list configuration in `WebView.swift`
- [x] 7.4 Update `BrowserApp` to observe `clearDataOnQuit` and register termination handler when enabled

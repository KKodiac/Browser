## Context

The browser uses ComposableArchitecture (TCA) with an `AppFeature` reducer managing all state. Search queries are hardcoded to `https://www.google.com/search?q=` in the `urlBarSubmitted` action. An `AccentColor` enum and picker currently live inline in the URL bar. There is no persistence layer for user preferences — the accent color resets on every launch.

The app defines its scene in `BrowserApp.swift` as a single `WindowGroup`. SwiftUI provides a built-in `Settings` scene type that automatically registers a Preferences window accessible via Cmd+, on macOS.

## Goals / Non-Goals

**Goals:**
- Provide a Preferences window (Cmd+,) with tabbed layout
- Let users choose a default search engine (Google, DuckDuckGo, Bing)
- Let users set a home page URL
- Let users choose a default download location
- Let users toggle tracker blocking and clear-data-on-quit
- Persist all settings across launches via UserDefaults
- Move accent color selection into the Appearance preferences tab

**Non-Goals:**
- Settings sync across devices or iCloud
- User profiles (multiple settings configurations)
- Per-site settings or exceptions
- Extension or plugin settings
- Import/export settings
- Custom search engine URLs (only preset engines)

## Decisions

### 1. UserDefaults via @AppStorage for persistence

**Decision:** Store all settings in UserDefaults using `@AppStorage` property wrappers.
**Rationale:** Settings are simple key-value pairs (strings, bools, enums). UserDefaults is the standard macOS approach for app preferences and integrates naturally with SwiftUI's `@AppStorage`. No file management, no migration, no serialization code.
**Alternatives considered:**
- *JSON file in Application Support*: Overkill for flat key-value settings; appropriate for structured data like bookmarks but not for preferences.
- *TCA state persistence*: Would couple settings to the reducer lifecycle; `@AppStorage` is simpler and lets the Settings scene be independent.

### 2. SwiftUI Settings scene with TabView

**Decision:** Use SwiftUI's `Settings` scene type with a `TabView` containing three tabs: General, Appearance, Privacy.
**Rationale:** `Settings` scene is the idiomatic SwiftUI way to create a Preferences window on macOS. It automatically handles Cmd+,, window lifecycle, and single-instance behavior. A `TabView` with `.tabViewStyle(.automatic)` renders as the standard macOS tabbed preferences layout.
**Alternatives considered:**
- *Custom window via `Window` scene*: Would require manual Cmd+, handling and lacks single-instance behavior.
- *Sheet or popover*: Non-standard for macOS preferences; users expect a separate window.

### 3. Search engine as an enum with preset URLs

**Decision:** Define a `SearchEngine` enum with cases `google`, `duckduckgo`, `bing`, each providing a search URL template string. Store the raw value in UserDefaults.
**Rationale:** Three engines cover the vast majority of users. An enum is type-safe, trivially serializable, and avoids the complexity of custom URL template validation.
**Alternatives considered:**
- *Free-text URL template*: Flexible but error-prone; users could enter invalid templates. Can be added later.

### 4. Settings model as a standalone struct, not in TCA state

**Decision:** Settings are read directly from `@AppStorage` where needed rather than being part of `AppFeature.State`. The `AppFeature` reducer reads UserDefaults directly when it needs the search engine URL.
**Rationale:** Settings rarely change (only when the user edits preferences). Putting them in TCA state would mean every settings change triggers a full state diff. `@AppStorage` provides reactive updates in SwiftUI views and simple reads in the reducer.
**Alternatives considered:**
- *Settings as TCA child reducer*: Adds boilerplate for something that is fundamentally key-value storage. Could be adopted later if settings logic grows complex.

## Risks / Trade-offs

- **@AppStorage outside TCA** → Settings reads bypass the TCA state management pattern. This is a pragmatic trade-off: settings are inherently global and rarely change. If settings grow complex (e.g., per-site rules), migrating to a TCA child feature would be straightforward.
- **Accent color migration** → Moving the accent color picker from the URL bar to Settings changes existing UX. Users who rely on quick accent switching lose the inline control. Mitigation: The Cmd+, shortcut is well-known, and accent color is not a frequently changed setting.
- **No custom search engines** → Power users who want Kagi, Startpage, or other engines cannot add them. Mitigation: Explicitly a non-goal for this change; the enum can be extended later.
- **Clear data on quit** → The "clear browsing data on quit" toggle requires hooking into the app termination lifecycle. If the app is force-killed, data may not be cleared. Mitigation: Use `NSApplication.willTerminate` notification for best-effort cleanup.

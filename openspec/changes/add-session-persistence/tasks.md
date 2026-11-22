## 1. Codable Conformance

- [x] 1.1 Add `Codable` conformance to `BrowserTab` with `CodingKeys` that excludes transient properties (`isLoading`, `canGoBack`, `canGoForward`, `requestedLoad`)
- [x] 1.2 Add `Codable` conformance to `GroupColor` enum (raw value String already enables this — verify it works)
- [x] 1.3 Add `Codable` conformance to `AccentColor` enum (raw value String already enables this — verify it works)
- [x] 1.4 Add `Codable` conformance to `TabGroup` struct

## 2. SessionStore

- [x] 2.1 Create `SessionStore` as a TCA dependency with `save(_:)` and `load()` methods
- [x] 2.2 Define a `SessionData` struct (Codable) holding `ungroupedTabs`, `tabGroups`, `selectedTabId`, and `accentColor`
- [x] 2.3 Implement file path resolution to `<Application Support>/Browser/session.json`
- [x] 2.4 Implement `save(_:)` — encode `SessionData` to JSON and write atomically
- [x] 2.5 Implement `load()` — read and decode `SessionData`, return nil on missing or corrupt file

## 3. Save Logic

- [x] 3.1 Add `saveSession` action and effect to `AppFeature` that calls `SessionStore.save`
- [x] 3.2 Wire `NSApplication.willTerminateNotification` in `BrowserApp` to trigger `saveSession`
- [x] 3.3 Add debounced periodic save (e.g., every 30 seconds after state changes)

## 4. Restore Logic

- [x] 4.1 Add `loadSession` action and effect to `AppFeature` that calls `SessionStore.load`
- [x] 4.2 Add `sessionLoaded(SessionData?)` action that replaces state with restored data or falls back to defaults
- [x] 4.3 Set `requestedLoad = true` on each restored tab that has a non-nil URL
- [x] 4.4 Validate `selectedTabId` references an existing tab; fall back to first tab if not

## 5. Lifecycle Hooks

- [x] 5.1 Trigger `loadSession` on `onAppear` (before the existing selectedTabId logic)
- [x] 5.2 Register for `willTerminateNotification` in `BrowserApp` and send `saveSession` to the store

## 6. Edge Cases

- [x] 6.1 Handle first launch (no session file) — start with default state
- [x] 6.2 Handle corrupt session file — log warning, start with default state
- [x] 6.3 Handle empty session (all tabs were closed before quit) — start with one blank tab
- [x] 6.4 Ensure Application Support directory is created if it does not exist

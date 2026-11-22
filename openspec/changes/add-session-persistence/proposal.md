## Why

Every tab and tab group is lost when the user quits the browser. The next launch always starts with a single blank tab, forcing users to manually reopen everything. Session persistence saves and restores the full browsing session across app launches — tabs, groups, selected tab, and URL bar state — so users can pick up exactly where they left off.

## What Changes

- Add `Codable` conformance to `BrowserTab`, `TabGroup`, `GroupColor`, and `AccentColor`
- Introduce a `SessionStore` that serializes the relevant slice of `AppFeature.State` to a JSON file in Application Support
- Save session state on app quit (via `NSApplication` termination notification) and periodically during use
- Restore session state on launch, replacing the default single-blank-tab state
- Handle edge cases: missing file (first launch), corrupt file (fall back to default state), empty session

## Capabilities

### New Capabilities
- `session-persistence`: Save and restore browsing session state (tabs, tab groups, selected tab, accent color) across app launches using a JSON file in Application Support

### Modified Capabilities
_None — no existing spec requirements change._

## Impact

- **BrowserTab.swift**: Add `Codable` conformance (all stored properties are already Codable-compatible types)
- **TabGroup.swift**: Add `Codable` conformance to `TabGroup`, `GroupColor`, and `AccentColor`
- **AppFeature.swift**: Add save/restore actions and effects; wire session save on state changes or termination; load session on `onAppear`
- **BrowserApp.swift**: Register for `NSApplication.willTerminateNotification` to trigger final save
- New file: `SessionStore.swift` — handles JSON encoding/decoding and file I/O
- No new dependencies — uses only Foundation (`JSONEncoder`/`JSONDecoder`, `FileManager`)

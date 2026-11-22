## Why

Tabs pile up: the same page gets opened several times, old tabs are never looked at again, and related tabs are scattered across the tab bar. Grouping and cleaning them up by hand is tedious. The on-device Foundation Models framework can suggest sensible groups without sending any browsing data off the Mac.

## What Changes

- Add an "Organize Tabs…" command (⌥⌘O, Tab menu) that opens a triage sheet for the focused window
- Ask the on-device model (`LanguageModelSession` with `@Generable` guided generation) to group the window's unpinned tabs, given only each tab's title and host; ungrouped tabs by default, already-grouped tabs optionally
- Find duplicate tabs (same URL, ignoring fragment and trailing slash) deterministically in code
- Find stale tabs (not selected for 3+ days) using a new `lastActiveAt` date on `BrowserTab`, set when a tab is selected and persisted with the session
- Show each suggested group (color, editable name, tab checkboxes), duplicates and stale tabs with checkboxes, and Apply / Cancel
- Apply creates the checked groups and closes the checked duplicate/stale tabs (closed tabs can be reopened with ⇧⌘T); pinned tabs are never moved or closed
- Cap the model input at 60 tabs and say so when truncated; show a progress state while the model runs off the main actor
- Explain when the model is unavailable (Apple Intelligence off, device not eligible, model not ready); duplicates and stale tabs still work
- Everything is gated to macOS 26+; on older macOS the menu item is disabled

## Capabilities

### New Capabilities
- `tab-triage`: Model-suggested tab groups, duplicate and stale tab detection, and the review sheet that applies them

### Modified Capabilities
- `tab-group-ui`: Groups can be created in bulk from the triage sheet

## Impact

- **TabTriage.swift** (new): Duplicate/stale detection, `@Generable` output types, model call, availability and error messages
- **TabTriageSheet.swift** (new): The review sheet and the modifier that presents it
- **BrowserTab.swift**: `lastActiveAt: Date` property, persisted (older sessions decode it as now)
- **AppFeature** (TCA reducer): `showTabTriage` and `applyTriage(TabTriagePlan)` actions, `showTabTriageTrigger`, `selectTab` updates `lastActiveAt`
- **BrowserApp.swift**: "Organize Tabs…" menu item
- **ContentView.swift**: Attaches the triage sheet modifier
- **Project.swift**: Optional (weak-linked) `FoundationModels` SDK dependency so the app still launches on macOS 14

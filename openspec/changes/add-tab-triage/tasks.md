## 1. Tab Activity Tracking

- [x] 1.1 Add `lastActiveAt: Date` to `BrowserTab`, defaulting to the creation time
- [x] 1.2 Update `lastActiveAt` when a tab is selected
- [x] 1.3 Persist `lastActiveAt` with the session, decoding older sessions without it as now

## 2. Deterministic Triage

- [x] 2.1 Detect duplicate tabs by normalized URL, keeping the selected, pinned or most recently active copy
- [x] 2.2 Detect stale tabs (not selected for 3+ days), excluding the selected tab and pinned tabs

## 3. Model Suggestions

- [x] 3.1 Weak-link `FoundationModels` and gate all model code to macOS 26+
- [x] 3.2 Define `@Generable` output types: groups with a name, a color from `GroupColor`, and tab numbers
- [x] 3.3 Prompt with a numbered list of tab titles and hosts, capped at 60 tabs
- [x] 3.4 Validate the output: drop unknown or repeated tab numbers and groups with fewer than two tabs
- [x] 3.5 Show clear messages for unavailable model states and generation errors

## 4. Triage Sheet

- [x] 4.1 Add "Organize Tabs…" (⌥⌘O) to the Tab menu, disabled before macOS 26
- [x] 4.2 Present the sheet through a trigger counter, like the other ContentView panels
- [x] 4.3 Show suggested groups, duplicates and stale tabs with checkboxes, a progress state and a truncation note
- [x] 4.4 Add an option to include tabs that are already grouped
- [x] 4.5 Add an `applyTriage` action that creates groups and closes the checked tabs, never touching pinned tabs

## 5. Verification

- [x] 5.1 Build the app (Debug)
- [ ] 5.2 Manually try the sheet on a Mac with Apple Intelligence enabled

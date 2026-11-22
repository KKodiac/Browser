## 1. Snapshot Store

- [x] 1.1 Create `TimelineSnapshot` (id, date, one `SessionData` per normal window)
- [x] 1.2 Create `TimelineStore` that loads and saves `Application Support/Browser/timeline.json` on a background queue
- [x] 1.3 Skip snapshots identical to the last one (tab URLs/titles, groups) or without any loaded page
- [x] 1.4 Prune on save: drop snapshots older than 7 days, keep at most 500
- [x] 1.5 Keep snapshots taken before the file finishes loading, and don't write until it has loaded

## 2. When to Snapshot

- [x] 2.1 Snapshot every 5 minutes while the app runs
- [x] 2.2 Snapshot right before a normal window closes
- [x] 2.3 Snapshot right before Close Group
- [ ] 2.4 Snapshot before closing several tabs at once (no such action exists yet)
- [x] 2.5 Read only normal windows from `WindowRegistry`; private windows are never included

## 3. Restoring

- [x] 3.1 Add a timeline restore queue to `WindowRegistry`, claimed by new normal windows on appear via `.restoreSession`
- [x] 3.2 Chain window opening: each window that claims a queued entry opens the next
- [x] 3.3 Give restored tabs and groups new IDs so they don't clash with open tabs
- [x] 3.4 Keep launch-time session restore working (timeline queue is empty at launch)

## 4. Timeline UI

- [x] 4.1 Add History > Session Timeline… (⌥⌘Y) opening a sheet on the focused window
- [x] 4.2 List snapshots newest first, grouped by day, with time, window/tab counts and top tab favicons/titles
- [x] 4.3 Show the selected snapshot's windows, groups and tabs
- [x] 4.4 "Restore" opens each snapshot window as a new window
- [x] 4.5 "Restore Tab" opens one tab in the focused window
- [x] 4.6 Delete a snapshot from its context menu
- [ ] 4.7 Try the timeline in the running app (only build-checked)

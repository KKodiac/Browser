## Why

Users often juggle several contexts (a project, a trip, a research topic), each spread over a window of tabs and groups. Today the only way to keep such a window is to leave it open: closing it loses the tabs (unless it happens to be the last window at quit). Workspaces let users put a window away and bring it back later, exactly as it was.

## What Changes

- Add a `Workspace` model: an id, a name, an updated date and one window's contents, reusing `SessionData` (ungrouped tabs, tab groups, selected tab, accent color)
- Add `WorkspaceStore`, which persists workspaces as JSON in Application Support/Browser/workspaces.json and remembers which open window each workspace belongs to
- Add a Workspaces menu: "Save Window as Workspace…" (⌥⌘S, asks for a name defaulting to the largest group's name or the selected tab's host), "Put Away Window" (⌥⌘W, saves then closes), one item per saved workspace (opens it in a new window), and "Manage Workspaces…"
- Add a "Workspaces" window listing saved workspaces with rename, open and delete
- Extend `WindowRegistry` with a queue of window contents for the next normal window that opens; `BrowserWindow` claims it on appear and sends `.restoreSession(data)`
- Disable workspace saving in private windows so private tabs never reach disk

## Capabilities

### New Capabilities
- `workspaces`: Save, put away, reopen, rename and delete named snapshots of a window's tabs and groups

### Modified Capabilities

_(none -- launch-time session restore is unchanged)_

## Impact

- **New file**: `WorkspaceStore.swift` (model, persistence, menu commands, manage window, name prompt)
- **WindowRegistry.swift**: pending "open these contents" queue (`enqueueOpen` / `claimPendingOpen`)
- **BrowserWindow.swift**: claims queued contents on appear; exposes whether the window is private as a focused value
- **BrowserApp.swift**: adds the Workspaces commands and the "Workspaces" manage window
- No new dependencies

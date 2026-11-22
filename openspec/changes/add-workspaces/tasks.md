## 1. Model and Persistence

- [x] 1.1 Add `Workspace` (id, name, updatedAt, `SessionData` window contents)
- [x] 1.2 Add `WorkspaceStore` that loads and saves `workspaces.json` in Application Support/Browser
- [x] 1.3 Track which workspace each open window belongs to (weak map from window store to workspace id)
- [x] 1.4 Saving a window that belongs to a workspace updates it; otherwise creates a new workspace

## 2. Opening Workspaces

- [x] 2.1 Add a pending-open queue to `WindowRegistry` (`enqueueOpen` / `claimPendingOpen`)
- [x] 2.2 `BrowserWindow` claims queued contents on appear and sends `.restoreSession(data)`, before falling back to launch-time restore
- [x] 2.3 Opening a workspace opens a new normal window that remembers the workspace

## 3. Menu Commands

- [x] 3.1 "Save Window as Workspace…" (⌥⌘S) with a name prompt (default: largest group's name, else selected tab's host)
- [x] 3.2 "Put Away Window" (⌥⌘W): save (updating the window's workspace if any) and close the window
- [x] 3.3 List saved workspaces in the Workspaces menu; choosing one opens it
- [x] 3.4 Disable saving and putting away in private windows (focused `windowIsPrivate` value)

## 4. Manage

- [x] 4.1 "Manage Workspaces…" window listing workspaces with tab count and date
- [x] 4.2 Rename (edit the name, press Return) and delete (button or context menu)

## 5. Verification

- [x] 5.1 Debug build passes
- [ ] 5.2 Manual check: save, put away, reopen, rename, delete; private window items disabled; launch restore unaffected

# Features

Feature inventory and roadmap for Browser. Status as of 2026-11-22.

Legend: ✅ shipped (committed) · 🚧 in progress (uncommitted, needs fixes) · ⬜ planned / idea

---

## 1. Shipped

| Feature | Notes |
|---|---|
| ✅ URL bar | URL or search query; focus with ⌘L |
| ✅ Navigation | Back, Forward, Reload |
| ✅ Tabs | Add, close, switch; drag-and-drop reorder |
| ✅ Tab groups | Create, rename, color, collapse (`openspec/specs/tab-grouping`, `tab-group-ui`) |
| ✅ Accent color theming | 8 accent colors |
| ✅ JavaScript dialogs | `alert`, `confirm`, `prompt` |

## 2. In progress (uncommitted)

Each has an OpenSpec change in `openspec/changes/`. All tasks are ticked, but review found the issues listed.

| Feature | Status / known issues |
|---|---|
| 🚧 Bookmarks | Add/remove, sidebar, folders. Editing from ⌘D doesn't enter edit mode (state not shared with sidebar) |
| 🚧 History | Panel, recording on URL change |
| 🚧 Downloads | Popover, active badge. Progress never updates (`didReceiveData` is not a `WKDownloadDelegate` method) |
| 🚧 Find in page | Find bar, ⌘F. Next/Previous don't move in the page; match count is only 0 or 1 |
| 🚧 Session persistence | Save on `onDisappear` is unreliable on app quit |
| 🚧 Content blocker | Static ad/tracker list. Rules compile async, so tabs created at launch aren't blocked; toggle doesn't affect existing tabs |
| 🚧 Favicons | Shown in tabs via `AsyncImage`; `FaviconCache` unused |
| 🚧 New tab page | Shown when tab has no URL |
| 🚧 Settings | Search engine, content blocking |
| 🚧 Tab pinning | Pinned tabs shown first as icons |
| 🚧 Zoom controls | ⌘+ / ⌘- / ⌘0, per-tab zoom indicator |
| 🚧 Split view | ⌘\\; find/zoom don't target the split pane |
| ⬜ Private browsing | Spec exists, no code |
| ⬜ Multiple windows | Spec exists, no code (all windows share one store) |
| ⬜ URL autocomplete | Spec exists, no code |

**Blocker:** the build currently fails inside ComposableArchitecture (`NavigationStack+Observation.swift`, main-actor key path error). Bump TCA to a version compatible with the installed toolchain.

## 3. Essential gaps

Baseline behavior users expect. Ordered by impact.

### Web compatibility
- ⬜ `target="_blank"` / `window.open` → new tab (`createWebViewWith` not implemented; such links do nothing today)
- ⬜ File upload (`runOpenPanelWith`)
- ⬜ HTTP auth and certificate challenges
- ⬜ Error pages (offline, DNS failure, bad certificate)
- ⬜ Camera / microphone / location permission prompts
- ⬜ Element fullscreen and Picture-in-Picture

### Tabs & navigation
- ⬜ ⌘W close tab, ⇧⌘T reopen closed tab
- ⬜ ⌘1–9 and ⌃Tab / ⌃⇧Tab tab switching
- ⬜ Link context menu: Open in New Tab, Copy Link, Download Linked File
- ⬜ ⌘-click / middle-click opens in background tab
- ⬜ Loading progress bar (`estimatedProgress`)
- ⬜ Audio indicator and per-tab mute
- ⬜ Tab sleeping (unload inactive web views to save memory)

### Security & privacy
- ⬜ HTTPS lock indicator with certificate details
- ⬜ HTTPS-only mode
- ⬜ Clear browsing data (cookies, cache, website data)
- ⬜ Per-site permissions
- ⬜ Password / passkey autofill (AuthenticationServices already linked)

### Power-user
- ⬜ Web Inspector (`isInspectable = true`)
- ⬜ Reader mode
- ⬜ Print / Save as PDF
- ⬜ Set as default browser (handle `http`/`https` URLs from other apps)
- ⬜ Import bookmarks/history from Safari and Chrome
- ⬜ Command palette (⌘K) across tabs, bookmarks, history

### Engineering
- ⬜ Fix TCA build error
- ⬜ Test target with `TestStore` coverage for `AppFeature`
- ⬜ Update README feature list

## 4. Standout ideas

Features that would differentiate this browser rather than reach parity.
Proposed positioning: **"a browser for people with too many tabs."**

### On-device AI (Foundation Models, macOS 26+, private, no server cost)
- ⬜ **Ask this page:** summarize, answer questions, extract tables or steps
- ⬜ **Tab triage:** cluster open tabs into suggested groups, name them, flag duplicates and stale tabs
- ⬜ **Semantic history search:** find pages by meaning, not title
- ⬜ **Smart new tab page:** suggest the next task from time of day and recent groups

### Workspaces
- ⬜ **Workspaces:** a tab group becomes a saved workspace (tabs, split layout, notes) you can put away and restore
- ⬜ **Ephemeral tabs:** auto-close after a set time unless pinned
- ⬜ **Linked split view:** links clicked in one pane open in the other

### Built on the TCA design
- ⬜ **Browsing timeline / undo:** scrub back through a session, undo closing a group
- ⬜ **Shareable sessions:** export a workspace as a file or link
- ⬜ **Automation:** record and replay actions as macros

### Native macOS
- ⬜ **Shortcuts & Spotlight:** expose tabs, groups and workspaces
- ⬜ **Quick-look peek:** preview a link in a floating panel without opening a tab
- ⬜ **Menu bar mini-browser:** pin a site (chat, music) to the menu bar
- ⬜ **Focus modes:** tie workspaces to macOS Focus

### Reading & research
- ⬜ **Highlights & notes:** persist per page; searchable; export to Markdown / Obsidian
- ⬜ **Collect mode:** drag text, images and links into a side panel that builds a document
- ⬜ **Themed reader mode:** reader view styled with the accent color system

### Recommended signature set
1. AI tab triage
2. Workspaces you can put away
3. Browsing timeline

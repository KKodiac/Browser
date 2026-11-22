# Features

Feature inventory and roadmap for Browser. Status as of 2026-11-22.

Legend: ✅ shipped (on master) · 🚧 shipped with known issues · ⬜ planned / idea

Note: there is no test target yet. Everything below was checked by a passing build and code review only, not by using the app.

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

## 2. Recently added

Each has an OpenSpec change in `openspec/changes/`. Bugs from the first review were fixed in PRs #1, #2, #5 and #6.

| Feature | Status / known issues |
|---|---|
| ✅ Bookmarks | Add/remove, sidebar, folders; ⌘D on a bookmarked page opens it for editing |
| ✅ History | Panel, recording on URL change |
| ✅ Downloads | Popover, active badge, live progress |
| ✅ Find in page | Find bar, ⌘F, Next/Previous, "N of M" count, Esc to close |
| ✅ Session persistence | Saved on app quit |
| 🚧 Content blocker | Static ad/tracker list; applies to all tabs and follows the setting. Changes take effect on the next page load |
| 🚧 Favicons | Shown in tabs via `AsyncImage`; `FaviconCache` is still unused |
| ✅ New tab page | Shown when tab has no URL |
| ✅ Settings | Search engine, content blocking |
| ✅ Tab pinning | Pinned tabs shown first as icons |
| ✅ Zoom controls | ⌘+ / ⌘- / ⌘0, per-tab zoom indicator |
| 🚧 Split view | ⌘\\; find and zoom commands only act on the main pane |
| ✅ Private browsing | ⇧⌘N; temporary cookies and site data, no history, Private badge, asks before bookmarking (#11) |
| ✅ Multiple windows | ⌘N; each window has its own tabs; all windows restored on launch; drag tabs between windows (#11) |
| 🚧 URL autocomplete | History, bookmarks and popular sites, arrow keys and Enter (#10). No inline completion |

## 3. Essential gaps

Baseline behavior users expect. Ordered by impact.

### Web compatibility
- ✅ `target="_blank"` / `window.open` → new tab (#9)
- ✅ File upload (#7)
- ⬜ HTTP auth and certificate challenges
- ✅ Error pages (offline, DNS failure, bad certificate) (#8)
- ⬜ Camera / microphone / location permission prompts
- ⬜ Element fullscreen and Picture-in-Picture

### Tabs & navigation
- ✅ ⌘W close tab, ⇧⌘T reopen closed tab (#4)
- ✅ ⌘1–9 and ⌃Tab / ⌃⇧Tab tab switching (#4)
- ✅ Link context menu: Open Link in New Tab (#9)
- ✅ ⌘-click / middle-click opens in background tab (#9)
- ✅ Loading progress bar (#3)
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
- ✅ Fix TCA build error (TCA 1.26.2)
- ⬜ Test target with `TestStore` coverage for `AppFeature`
- ⬜ Update README feature list

## 4. Standout ideas

Features that would differentiate this browser rather than reach parity.
Proposed positioning: **"a browser for people with too many tabs."**

### On-device AI (Foundation Models, macOS 26+, private, no server cost)
The ✅ AI features need macOS 26 and Apple Intelligence turned on; on older macOS their menu items are disabled.
- ✅ **Ask this page:** ⇧⌘A side panel; summarize, key points, explain selection (#16)
- ✅ **Tab triage:** ⌥⌘O Organize Tabs suggests groups and flags duplicate and stale tabs (#15)
- ⬜ **Semantic history search:** find pages by meaning, not title
- ⬜ **Smart new tab page:** suggest the next task from time of day and recent groups

### Workspaces
- ✅ **Workspaces:** save (⌥⌘S), put away (⌥⌘W) and reopen a window's tabs and groups (#12). Split layout and notes not included yet
- ⬜ **Ephemeral tabs:** auto-close after a set time unless pinned
- ⬜ **Linked split view:** links clicked in one pane open in the other

### Built on the TCA design
- 🚧 **Browsing timeline / undo:** ⌥⌘Y Session Timeline restores snapshots taken every 5 minutes and before closing a window or group (#14). No scrubbing or undo yet
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

## 5. Ideas from Dia

Feature ideas taken from what's inside the Dia 1.58.1 app bundle (looked at on 2026-11-23). They're adapted for this browser, which uses WebKit and aims to keep AI on the device. Items already listed in section 4 aren't repeated.

Fit: 🟢 works with WebKit and on-device AI · 🟡 needs extra platform work · 🔴 needs a cloud service or account

### Engine & platform
Dia embeds Chromium. These are things it gets from Chromium or adds around it that we'd build on WebKit.
- ⬜ 🟡 **Web extensions:** support Safari-style web extensions through WebKit's extension API (macOS 15.4+)
- ⬜ 🟢 **Picture-in-Picture** for web video
- ⬜ 🟡 **Cast to TV** (Chromecast/AirPlay device picker)
- ⬜ 🟢 **Import from other browsers:** profiles, bookmarks, history, logins from Safari and Chrome
- ⬜ 🟢 **Open local files:** HTML, PDF and text files open in a tab
- ⬜ 🟢 **AppleScript support:** a scripting dictionary for tabs and windows
- ⬜ 🟢 **Sign-in sheets for other apps:** be the browser macOS uses when other apps open login windows
- ⬜ 🟡 **Auto-update** (Sparkle) and **crash reporting**
- ⬜ 🟢 **Dock icon badge**, e.g. active downloads

### Browser UI
Dia has about 60 UI modules. These are the ones worth copying.
- ✅ 🟢 **Command bar:** one ⌘K bar for URLs, tabs, history, bookmarks and commands (#13)
- ⬜ 🟢 **Shareable tab bundles:** save a set of tabs as a file (`.browsertabs`) that opens as a group
- ⬜ 🟢 **Clean up tabs:** one action that closes or archives stale and duplicate tabs
- ⬜ 🟢 **Recent tabs** list, including closed ones (builds on ⇧⌘T)
- ⬜ 🟢 **Custom tab icons:** pick an emoji or symbol for a tab or group
- ⬜ 🟢 **Window themes:** per-window tint and theme beyond accent color
- ⬜ 🟢 **Swipe navigation:** trackpad swipes between tabs, with visual feedback
- ⬜ 🟢 **Calendar preview:** show the next meeting from the system calendar (EventKit) on the new tab page
- ⬜ 🟢 **First-run onboarding** and a short tour of shortcuts
- ⬜ 🟢 **Privacy control for history search:** exclude sites or clear by range

### On-device ML
Dia ships Apple's MLX framework, transformer models and a local classifier.
- ⬜ 🟢 **Page classifier:** tag pages by topic or type (docs, shopping, video) to drive tab grouping and clean-up
- ⬜ 🟢 **Page embeddings** stored locally, powering semantic history and "related tabs"
- ⬜ 🟢 **Dictation** into the assistant (Speech framework)

### Assistant panel
Dia's chat is a bundled web app shown in a side panel.
- ⬜ 🟢 **Side panel chat** with the current page (or several selected tabs) as context
- ⬜ 🟢 **Chat history** saved per workspace
- ⬜ 🔴 **Model choice:** on-device by default, with an optional cloud model the user brings
- ⬜ 🟢 **"Ask on page" quick action:** select text, then ask

### Agent and tools
Dia runs a separate agent process that is sandboxed with a deny-by-default profile and has about 110 browser and app tools.
- ⬜ 🟢 **Browser tools for the assistant:** read, open, close and group tabs; read the page; save as PDF; export a file
- ⬜ 🟡 **Browse for me:** the assistant clicks and fills in forms on a page step by step, with the user approving each action
- ⬜ 🟢 **Scheduled prompts:** run a saved prompt daily, e.g. "summarize these 5 sites every morning"
- ⬜ 🟢 **Task notes:** a scratch note attached to a task or workspace that the assistant can write to
- ⬜ 🟢 **Generated documents:** the assistant writes a doc or slides and saves it as a file you can reopen
- ⬜ 🟡 **Sandboxed agent process:** run the agent outside the app process under a deny-by-default macOS sandbox

### Skills & proactive agents
Dia has about 45 agents and 10 skills (morning brief, meeting prep, task lists).
- ⬜ 🟢 **Skills:** reusable saved prompts with names, shared across workspaces
- ⬜ 🟢 **Morning brief:** a summary of pinned sites and calendar on the first new tab of the day
- ⬜ 🟢 **Meeting prep:** before a calendar event, gather the tabs, history and notes related to it
- ⬜ 🟢 **Suggested next tasks** from open tabs and recent activity, all on device

### Integrations
Dia's agent connects to Slack, Notion, Linear, Figma, Google, Salesforce and others.
- ⬜ 🟡 **MCP client:** let the assistant use MCP servers the user configures, instead of building each integration
- ⬜ 🔴 **Built-in connectors** for Slack, Notion and Linear, only if MCP isn't enough

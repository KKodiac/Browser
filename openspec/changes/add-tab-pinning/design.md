## Context

The browser manages tabs as `BrowserTab` structs stored in `IdentifiedArrayOf<BrowserTab>` collections — `ungroupedTabs` for tabs outside groups and `tabs` within each `TabGroup`. The tab bar is a horizontal `ScrollView` rendering ungrouped tabs first, then group sections. `BrowserTab` is a value type conforming to `Equatable` and `Identifiable` with properties for `id`, `url`, `title`, loading states, and navigation state. Tab groups are managed via a separate `TabGroup` model. The app uses The Composable Architecture (TCA) with an `AppFeature` reducer.

## Goals / Non-Goals

**Goals:**
- Users can pin any tab to lock it at the left edge of the tab bar
- Pinned tabs render as compact, narrow items (favicon or truncated title)
- Pinned tabs cannot be accidentally closed (no close button)
- Pinned tabs are excluded from tab groups
- Users can unpin a tab to return it to normal behavior
- Pin/unpin is accessible via right-click context menu

**Non-Goals:**
- Cross-session pin persistence (that is the `add-session-persistence` change)
- Pinned tab favicon display (that is the `add-favicon-display` change)
- Drag-and-drop reordering of pinned tabs among themselves (future enhancement)
- Limiting the number of pinned tabs

## Decisions

### 1. Add `isPinned: Bool` to `BrowserTab`

**Decision**: Add an `isPinned` property (default `false`) directly to the `BrowserTab` struct rather than maintaining a separate pinned tab collection.

**Rationale**: Pin state is an intrinsic property of a tab, not a relationship like grouping. A boolean flag is the simplest representation and avoids duplicating tab storage. The tab bar can derive the pinned/unpinned split with a simple filter on the existing `ungroupedTabs` collection.

**Alternatives considered**:
- *Separate `pinnedTabs` array*: Would require moving tabs between collections on pin/unpin, adding complexity to tab lookup and selection. Since pinned tabs are always ungrouped, filtering `ungroupedTabs` by `isPinned` is equivalent and simpler.

### 2. Pinned tabs rendered as narrow fixed-width items at the leading edge

**Decision**: Pinned tabs SHALL appear in a visually distinct fixed section at the far left of the tab bar, before ungrouped and grouped tabs. They render at a narrow fixed width (e.g., ~40pt) showing only a truncated title or favicon placeholder, with no close button.

**Rationale**: This matches the convention established by Safari and Chrome. Compact rendering saves tab bar space, which is the primary reason users pin tabs. The leading position ensures pinned tabs are always visible without scrolling.

### 3. Pinned tabs excluded from tab groups

**Decision**: A pinned tab SHALL NOT belong to any tab group. Pinning a grouped tab removes it from its group first. Attempting to add a pinned tab to a group is not allowed (context menu omits group options for pinned tabs).

**Rationale**: Pinned tabs occupy a separate fixed section of the tab bar, outside the group layout. Allowing pinned tabs inside groups would create conflicting layout requirements (pinned = left edge vs. grouped = inside group section). This matches browser conventions.

### 4. Pinned tabs cannot be closed via close button

**Decision**: Pinned tabs SHALL NOT display a close button. The only way to close a pinned tab is to first unpin it, then close it normally. The "Close Tab" context menu item is hidden for pinned tabs; "Unpin Tab" is shown instead.

**Rationale**: The purpose of pinning is to prevent accidental closure. Requiring an explicit unpin step creates a deliberate two-step process that protects the tab.

## Risks / Trade-offs

- **Tab bar layout complexity** -> The tab bar now has three sections (pinned, ungrouped, groups) instead of two. Mitigation: Pinned tabs are just a filtered subset of ungrouped tabs rendered differently, so the structural change is minimal.
- **No favicon yet** -> Without the `add-favicon-display` capability, pinned tabs will show a truncated title rather than a favicon, which is less compact than ideal. Mitigation: A short truncated title still communicates identity; favicon support can enhance this later.
- **No persistence** -> Pinned state is lost on quit, same as groups. Mitigation: Explicitly a non-goal; the `add-session-persistence` change will handle this.

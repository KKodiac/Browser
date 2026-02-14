## Context

The browser currently manages tabs as a flat `[BrowserTab]` array in `ContentView`, with a horizontal `ScrollView` tab bar. There is no grouping, labeling, or color-coding. All state lives in `ContentView` as `@State` properties. `BrowserTab` is an `@Observable` model with `Identifiable` conformance.

The tab bar renders each tab via `tabButton(_:)` and supports adding/closing tabs. Tabs are selected by UUID. The WebView layer is tab-agnostic — it just takes a `BrowserTab` and renders it.

## Goals / Non-Goals

**Goals:**
- Users can create named, color-coded tab groups
- Tabs can be moved into and out of groups
- Groups are visually distinct in the tab bar with colored headers
- Groups can be collapsed to save space
- Closing a group closes all its tabs
- Ungrouped tabs continue to work exactly as they do today

**Non-Goals:**
- Persisting groups across app launches (no persistence layer yet)
- Drag-and-drop reordering of tabs between groups (future enhancement)
- Nested groups (groups within groups)
- Tab group syncing across windows

## Decisions

### 1. New `TabGroup` model as a separate `@Observable` class

**Decision**: Introduce a `TabGroup` model that holds an id, label, color, collapsed state, and an ordered array of `BrowserTab` references. Tabs that aren't in any group remain in a top-level ungrouped list.

**Rationale**: Keeping `TabGroup` as a standalone `@Observable` class mirrors `BrowserTab`'s pattern and lets SwiftUI observe group-level changes (rename, recolor, collapse) independently. Embedding group info inside `BrowserTab` would scatter group state across all tabs and make group-level operations (collapse, close all) awkward.

**Alternatives considered**:
- *Optional `groupId` on `BrowserTab`*: Simpler but requires scanning all tabs to find group members, and group metadata (label, color) has no natural home.
- *Dictionary `[UUID: [BrowserTab]]`*: Loses ordering and makes the relationship less explicit.

### 2. State structure in ContentView

**Decision**: Replace the flat `tabs` array with two collections:
- `ungroupedTabs: [BrowserTab]` — tabs not in any group
- `tabGroups: [TabGroup]` — ordered groups, each containing its own tabs

`selectedTabId` remains a single `UUID?` that works across both collections.

**Rationale**: This makes the tab bar rendering straightforward — iterate ungrouped tabs, then iterate groups. A single flat array with optional group references would require filtering/sorting on every render.

### 3. Group colors from a fixed palette

**Decision**: Offer a fixed set of 8 colors (red, orange, yellow, green, blue, purple, pink, gray) rather than a custom color picker. Store as an enum.

**Rationale**: Matches Safari/Chrome behavior. A fixed palette keeps the UI simple and ensures colors are visually distinct. Custom colors add complexity with no clear user need at this stage.

### 4. Context menus for group management

**Decision**: Use SwiftUI `.contextMenu` on tab buttons for group operations:
- On an ungrouped tab: "Add to New Group", "Add to [existing group]"
- On a grouped tab: "Remove from Group", "Close Group", "Rename Group", "Change Group Color"
- On a group header: "Rename", "Change Color", "Ungroup All", "Close Group"

**Rationale**: Context menus are the standard macOS pattern for secondary actions. No additional toolbar chrome needed.

### 5. Collapsible groups via a chevron toggle

**Decision**: Each group header shows a disclosure chevron. When collapsed, the group's tabs are hidden but remain in memory (WebViews stay alive). If the selected tab is in a collapsed group, it remains visible in the content area.

**Rationale**: Collapsing is purely a tab bar space optimization. Destroying WebViews on collapse would lose page state and cause reloads on expand.

## Risks / Trade-offs

- **State migration complexity** → The shift from a single `tabs` array to `ungroupedTabs` + `tabGroups` touches most of `ContentView`'s logic. Mitigation: Keep `selectedTabId` as-is, add a computed helper `allTabs` that flattens both collections for operations that need all tabs.
- **WebView lifecycle unchanged** → All tabs (grouped or not) keep their WebViews alive, same as today. This means grouping many tabs still consumes memory. Mitigation: Acceptable for now; tab suspension is a separate future concern.
- **No persistence** → Groups are lost on quit. Mitigation: Explicitly a non-goal; persistence can be layered on later with Codable conformance on the models.

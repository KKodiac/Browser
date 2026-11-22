import ComposableArchitecture
import SwiftUI

/// Presents the "Organize Tabs…" sheet when `showTabTriageTrigger` changes.
struct TabTriageModifier: ViewModifier {
    let store: StoreOf<AppFeature>
    @State private var isPresented = false

    func body(content: Content) -> some View {
        content
            .onChange(of: store.showTabTriageTrigger) { _, _ in
                isPresented = true
            }
            .sheet(isPresented: $isPresented) {
                if #available(macOS 26.0, *) {
                    TabTriageSheet(store: store)
                }
            }
    }
}

@available(macOS 26.0, *)
struct TabTriageSheet: View {
    let store: StoreOf<AppFeature>
    @Environment(\.dismiss) private var dismiss

    // Snapshot of the window's tabs when the sheet opened.
    @State private var tabs: [UUID: BrowserTab] = [:]
    @State private var duplicateIds: [UUID] = []
    @State private var staleIds: [UUID] = []
    @State private var groups: [TabTriageGroup] = []
    @State private var checked: Set<UUID> = []
    @State private var checkedGroupTabs: [UUID: Set<UUID>] = [:]
    @State private var includeGrouped = false
    @State private var isLoading = false
    @State private var modelMessage: String?
    @State private var truncatedCount = 0

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Organize Tabs")
                .font(.headline)
                .padding()
            Divider()
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    groupsSection
                    if !duplicateIds.isEmpty {
                        tabSection("Duplicates", subtitle: "Same page open more than once; the most recent copy is kept.", ids: duplicateIds)
                    }
                    if !staleIds.isEmpty {
                        tabSection("Not used in 3+ days", subtitle: nil, ids: staleIds)
                    }
                }
                .padding()
            }
            Divider()
            HStack {
                Text("Pinned tabs are never moved or closed.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
                Button("Cancel") { dismiss() }
                    .keyboardShortcut(.cancelAction)
                Button("Apply") {
                    store.send(.applyTriage(plan))
                    dismiss()
                }
                .keyboardShortcut(.defaultAction)
                .disabled(isLoading || (plan.groups.isEmpty && plan.closeTabIds.isEmpty))
            }
            .padding()
        }
        .frame(width: 520, height: 560)
        .onAppear(perform: takeSnapshot)
        .task(id: includeGrouped) { await suggestGroups() }
    }

    // MARK: - Sections

    private var groupsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Suggested Groups").font(.subheadline.bold())
                Spacer()
                Toggle("Include grouped tabs", isOn: $includeGrouped)
                    .toggleStyle(.checkbox)
                    .disabled(isLoading)
            }
            if isLoading {
                HStack(spacing: 8) {
                    ProgressView().controlSize(.small)
                    Text("Asking the on-device model…").foregroundStyle(.secondary)
                }
            } else if let modelMessage {
                Text(modelMessage).foregroundStyle(.secondary)
            } else if groups.isEmpty {
                Text("No groups to suggest.").foregroundStyle(.secondary)
            }
            if truncatedCount > 0 {
                Text("Only the first \(TabTriage.maxModelTabs) tabs were considered; \(truncatedCount) more were left out.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            if !isLoading {
                ForEach($groups) { $group in
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 6) {
                            Circle().fill(group.color.color).frame(width: 10, height: 10)
                            TextField("Group name", text: $group.name)
                                .textFieldStyle(.plain)
                                .font(.body.bold())
                        }
                        ForEach(group.tabIds, id: \.self) { id in
                            tabCheckbox(id, isOn: Binding(
                                get: { checkedGroupTabs[group.id, default: []].contains(id) },
                                set: { on in
                                    if on { checkedGroupTabs[group.id, default: []].insert(id) }
                                    else { checkedGroupTabs[group.id]?.remove(id) }
                                }
                            ))
                        }
                    }
                }
            }
        }
    }

    private func tabSection(_ title: String, subtitle: String?, ids: [UUID]) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("\(title) — close checked tabs").font(.subheadline.bold())
            if let subtitle {
                Text(subtitle).font(.caption).foregroundStyle(.secondary)
            }
            ForEach(ids, id: \.self) { id in
                tabCheckbox(id, isOn: Binding(
                    get: { checked.contains(id) },
                    set: { on in
                        if on { checked.insert(id) } else { checked.remove(id) }
                    }
                ))
            }
        }
    }

    private func tabCheckbox(_ id: UUID, isOn: Binding<Bool>) -> some View {
        Toggle(isOn: isOn) {
            HStack(spacing: 4) {
                Text(tabs[id]?.displayTitle ?? "Tab").lineLimit(1)
                if let host = tabs[id]?.url?.host {
                    Text(host).foregroundStyle(.secondary).lineLimit(1)
                }
            }
        }
        .toggleStyle(.checkbox)
    }

    // MARK: - Logic

    private var plan: TabTriagePlan {
        let accepted = groups.compactMap { group -> TabTriageGroup? in
            var g = group
            g.tabIds = group.tabIds.filter { checkedGroupTabs[group.id, default: []].contains($0) }
            return g.tabIds.isEmpty ? nil : g
        }
        let close = (duplicateIds + staleIds).filter { checked.contains($0) }
        return TabTriagePlan(groups: accepted, closeTabIds: close)
    }

    private func takeSnapshot() {
        let all = Array(store.allTabs)
        tabs = Dictionary(uniqueKeysWithValues: all.map { ($0.id, $0) })
        let selectedId = store.selectedId
        duplicateIds = TabTriage.duplicateTabIds(in: all, selectedId: selectedId)
        let duplicates = Set(duplicateIds)
        staleIds = TabTriage.staleTabIds(in: all, selectedId: selectedId).filter { !duplicates.contains($0) }
        // Duplicates are checked by default; stale tabs are opt-in.
        checked = duplicates
    }

    private func suggestGroups() async {
        groups = []
        checkedGroupTabs = [:]
        if let message = TabTriage.unavailableMessage {
            modelMessage = message
            return
        }
        // Duplicates are offered for closing, so they aren't sent to the model.
        let duplicates = Set(duplicateIds)
        let isCandidate = { (tab: BrowserTab) in !tab.isPinned && tab.url != nil && !duplicates.contains(tab.id) }
        var candidates = store.ungroupedTabs.filter(isCandidate)
        if includeGrouped {
            candidates += store.tabGroups.flatMap { $0.tabs.filter(isCandidate) }
        }
        truncatedCount = max(0, candidates.count - TabTriage.maxModelTabs)
        let considered = Array(candidates.prefix(TabTriage.maxModelTabs))
        guard considered.count >= 2 else {
            modelMessage = "Not enough tabs to group."
            return
        }
        let inputs = considered.enumerated().map { offset, tab in
            TabTriageInput(index: offset + 1, title: String(tab.displayTitle.prefix(80)), host: tab.url?.host ?? "")
        }

        isLoading = true
        modelMessage = nil
        defer { isLoading = false }
        do {
            let result = try await TabTriage.suggestGroups(for: inputs)
            guard !Task.isCancelled else { return }
            groups = result.map { suggestion in
                TabTriageGroup(name: suggestion.name, color: suggestion.color, tabIds: suggestion.indices.map { considered[$0 - 1].id })
            }
            checkedGroupTabs = Dictionary(uniqueKeysWithValues: groups.map { ($0.id, Set($0.tabIds)) })
        } catch {
            guard !Task.isCancelled else { return }
            modelMessage = TabTriage.message(for: error)
        }
    }
}

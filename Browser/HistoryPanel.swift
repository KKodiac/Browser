import SwiftUI

struct HistoryPanel: View {
    @Environment(HistoryStore.self) private var store
    var onSelectEntry: (URL) -> Void
    var onDismiss: () -> Void
    @State private var searchText = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            header
            Divider()
            searchField
            Divider()
            if filteredEntries.isEmpty {
                emptyState
            } else {
                entryList
            }
        }
        .frame(width: 320)
        .background(.ultraThinMaterial)
    }

    private var filteredEntries: [HistoryEntry] {
        store.search(query: searchText)
    }

    private var header: some View {
        HStack {
            Text("History")
                .font(.system(size: 13, weight: .semibold))
            Spacer()
            Menu("Clear") {
                Button("Last Hour") { store.clearHistory(range: .lastHour) }
                Button("Today") { store.clearHistory(range: .today) }
                Divider()
                Button("All History", role: .destructive) { store.clearHistory(range: .all) }
            }
            .menuStyle(.borderlessButton)
            .fixedSize()
            .font(.system(size: 12))
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
    }

    private var searchField: some View {
        TextField("Search history", text: $searchText)
            .textFieldStyle(.plain)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color.white.opacity(0.05))
    }

    private var emptyState: some View {
        Text("No history")
            .font(.system(size: 12))
            .foregroundStyle(.tertiary)
            .frame(maxWidth: .infinity, minHeight: 60)
    }

    private var entryList: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 2) {
                let grouped = groupedFilteredEntries()
                ForEach(grouped, id: \.0) { section, entries in
                    Text(section)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(.tertiary)
                        .padding(.horizontal, 8)
                        .padding(.top, 8)
                    ForEach(entries) { entry in
                        entryRow(entry)
                    }
                }
            }
            .padding(8)
        }
    }

    private func groupedFilteredEntries() -> [(String, [HistoryEntry])] {
        let entries = filteredEntries
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: entries) { entry -> String in
            if calendar.isDateInToday(entry.visitedAt) { return "Today" }
            if calendar.isDateInYesterday(entry.visitedAt) { return "Yesterday" }
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            return formatter.string(from: entry.visitedAt)
        }
        return grouped.sorted { lhs, rhs in
            let lDate = lhs.value.first?.visitedAt ?? .distantPast
            let rDate = rhs.value.first?.visitedAt ?? .distantPast
            return lDate > rDate
        }
    }

    private func entryRow(_ entry: HistoryEntry) -> some View {
        Button {
            onSelectEntry(entry.url)
            onDismiss()
        } label: {
            VStack(alignment: .leading, spacing: 2) {
                Text(entry.displayTitle)
                    .font(.system(size: 12))
                    .lineLimit(1)
                Text(entry.url.absoluteString)
                    .font(.system(size: 10))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .truncationMode(.middle)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .frame(maxWidth: .infinity, alignment: .leading)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .clipShape(.rect(cornerRadius: 6))
        .contextMenu {
            Button("Delete", role: .destructive) {
                store.deleteEntry(id: entry.id)
            }
        }
    }
}

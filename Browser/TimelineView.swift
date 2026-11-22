import ComposableArchitecture
import SwiftUI

/// Sheet listing session timeline snapshots, newest first and grouped by day. Restores a whole
/// snapshot as new windows, or a single tab into the window the sheet belongs to.
struct TimelineView: View {
    let windowStore: StoreOf<AppFeature>
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openWindow) private var openWindow
    @State private var selectedId: UUID?

    private var timeline: TimelineStore { .shared }

    private var selectedSnapshot: TimelineSnapshot? {
        timeline.snapshots.first { $0.id == selectedId }
    }

    var body: some View {
        VStack(spacing: 0) {
            if timeline.snapshots.isEmpty {
                ContentUnavailableView(
                    "No Snapshots Yet",
                    systemImage: "clock.arrow.circlepath",
                    description: Text("Your open windows are saved here every 5 minutes and before windows or tab groups close.")
                )
            } else {
                HStack(spacing: 0) {
                    snapshotList
                        .frame(width: 300)
                    Divider()
                    detail
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            Divider()
            footer
        }
        .frame(width: 760, height: 520)
        .onAppear {
            if selectedId == nil { selectedId = timeline.snapshots.first?.id }
        }
    }

    // MARK: - Snapshot list

    private var snapshotList: some View {
        List(selection: $selectedId) {
            ForEach(days, id: \.day) { day, snapshots in
                Section(dayTitle(day)) {
                    ForEach(snapshots) { snapshot in
                        snapshotRow(snapshot)
                            .tag(snapshot.id)
                            .contextMenu {
                                Button("Delete Snapshot", role: .destructive) {
                                    timeline.delete(snapshot.id)
                                }
                            }
                    }
                }
            }
        }
        .listStyle(.sidebar)
    }

    private var days: [(day: Date, snapshots: [TimelineSnapshot])] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: timeline.snapshots) { calendar.startOfDay(for: $0.date) }
        return grouped
            .map { (day: $0.key, snapshots: $0.value.sorted { $0.date > $1.date }) }
            .sorted { $0.day > $1.day }
    }

    private func dayTitle(_ day: Date) -> String {
        let calendar = Calendar.current
        if calendar.isDateInToday(day) { return "Today" }
        if calendar.isDateInYesterday(day) { return "Yesterday" }
        return day.formatted(date: .complete, time: .omitted)
    }

    private func summary(_ snapshot: TimelineSnapshot) -> String {
        let windows = snapshot.windows.count
        let tabs = snapshot.tabs.count
        return "\(windows) \(windows == 1 ? "window" : "windows") · \(tabs) \(tabs == 1 ? "tab" : "tabs")"
    }

    private func snapshotRow(_ snapshot: TimelineSnapshot) -> some View {
        let topTabs = Array(snapshot.tabs.prefix(4))
        return VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(snapshot.date, format: .dateTime.hour().minute())
                    .font(.system(size: 12, weight: .semibold))
                Spacer()
                Text(summary(snapshot))
                    .font(.system(size: 11))
                    .foregroundStyle(.secondary)
            }
            HStack(spacing: 4) {
                ForEach(Array(topTabs.enumerated()), id: \.offset) { _, tab in
                    favicon(for: tab)
                }
                Text(topTabs.map(\.displayTitle).joined(separator: ", "))
                    .font(.system(size: 11))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
        }
        .padding(.vertical, 2)
    }

    // MARK: - Detail

    @ViewBuilder
    private var detail: some View {
        if let snapshot = selectedSnapshot {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    ForEach(Array(snapshot.windows.enumerated()), id: \.offset) { index, window in
                        windowSection(window, index: index)
                    }
                }
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        } else {
            Text("Select a snapshot")
                .foregroundStyle(.tertiary)
        }
    }

    private func windowSection(_ window: SessionData, index: Int) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 6) {
                Circle()
                    .fill(window.accentColor.color)
                    .frame(width: 8, height: 8)
                Text("Window \(index + 1)")
                    .font(.system(size: 13, weight: .semibold))
            }
            ForEach(window.ungroupedTabs) { tab in
                tabRow(tab)
            }
            ForEach(window.tabGroups) { group in
                HStack(spacing: 6) {
                    Circle()
                        .fill(group.color.color)
                        .frame(width: 6, height: 6)
                    Text(group.label)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(.secondary)
                }
                .padding(.top, 4)
                ForEach(group.tabs) { tab in
                    tabRow(tab)
                        .padding(.leading, 12)
                }
            }
        }
    }

    private func tabRow(_ tab: BrowserTab) -> some View {
        HStack(spacing: 8) {
            favicon(for: tab)
            VStack(alignment: .leading, spacing: 1) {
                Text(tab.displayTitle)
                    .font(.system(size: 12))
                    .lineLimit(1)
                Text(tab.urlString)
                    .font(.system(size: 10))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .truncationMode(.middle)
            }
            Spacer()
            Button("Restore Tab") {
                restoreTab(tab)
            }
            .font(.system(size: 11))
            .disabled(tab.url == nil)
        }
        .padding(.vertical, 2)
    }

    @ViewBuilder
    private func favicon(for tab: BrowserTab) -> some View {
        if let faviconURL = tab.faviconURL {
            AsyncImage(url: faviconURL) { image in
                image.resizable().aspectRatio(contentMode: .fit)
            } placeholder: {
                Image(systemName: "globe")
                    .font(.system(size: 11))
                    .foregroundStyle(.secondary)
            }
            .frame(width: 14, height: 14)
        } else {
            Image(systemName: "globe")
                .font(.system(size: 11))
                .foregroundStyle(.secondary)
                .frame(width: 14, height: 14)
        }
    }

    // MARK: - Footer

    private var footer: some View {
        HStack {
            Text("Snapshots are kept for 7 days.")
                .font(.system(size: 11))
                .foregroundStyle(.tertiary)
            Spacer()
            Button("Close") { dismiss() }
                .keyboardShortcut(.cancelAction)
            Button("Restore") {
                if let snapshot = selectedSnapshot { restore(snapshot) }
            }
            .keyboardShortcut(.defaultAction)
            .disabled(selectedSnapshot == nil)
        }
        .padding(12)
    }

    // MARK: - Actions

    /// Opens every window of the snapshot as a new window; current windows stay as they are.
    private func restore(_ snapshot: TimelineSnapshot) {
        WindowRegistry.shared.queueTimelineRestore(snapshot.windows.map { $0.withFreshIDs() })
        openWindow(id: BrowserWindow.mainID)
        dismiss()
    }

    /// Opens one tab from the snapshot in this window.
    private func restoreTab(_ tab: BrowserTab) {
        guard let url = tab.url else { return }
        windowStore.send(.openURLInNewTab(url, select: true))
        dismiss()
    }
}

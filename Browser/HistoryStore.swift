import Foundation
import Observation

@Observable
final class HistoryStore {
    var entries: [HistoryEntry] = []

    private let fileURL: URL

    init() {
        let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let dir = appSupport.appendingPathComponent("Browser", isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        self.fileURL = dir.appendingPathComponent("history.json")
        load()
    }

    func addEntry(url: URL, title: String = "") {
        let entry = HistoryEntry(url: url, title: title)
        entries.insert(entry, at: 0)
        save()
    }

    func updateLatestTitle(for url: URL, title: String) {
        guard let index = entries.firstIndex(where: { $0.url == url }) else { return }
        entries[index].title = title
        save()
    }

    func deleteEntry(id: UUID) {
        entries.removeAll { $0.id == id }
        save()
    }

    func clearHistory(range: ClearRange) {
        let now = Date()
        switch range {
        case .lastHour:
            entries.removeAll { now.timeIntervalSince($0.visitedAt) < 3600 }
        case .today:
            entries.removeAll { Calendar.current.isDateInToday($0.visitedAt) }
        case .all:
            entries.removeAll()
        }
        save()
    }

    func search(query: String) -> [HistoryEntry] {
        guard !query.isEmpty else { return entries }
        let q = query.lowercased()
        return entries.filter {
            $0.title.lowercased().contains(q) || $0.url.absoluteString.lowercased().contains(q)
        }
    }

    func entriesGroupedByDate() -> [(String, [HistoryEntry])] {
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

    enum ClearRange {
        case lastHour, today, all
    }

    private func save() {
        guard let data = try? JSONEncoder().encode(entries) else { return }
        try? data.write(to: fileURL, options: .atomic)
    }

    private func load() {
        guard let data = try? Data(contentsOf: fileURL),
              let decoded = try? JSONDecoder().decode([HistoryEntry].self, from: data) else { return }
        entries = decoded
    }
}

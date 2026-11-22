import Foundation

struct HistoryEntry: Codable, Identifiable, Equatable {
    let id: UUID
    var url: URL
    var title: String
    var visitedAt: Date

    init(id: UUID = UUID(), url: URL, title: String = "", visitedAt: Date = Date()) {
        self.id = id
        self.url = url
        self.title = title
        self.visitedAt = visitedAt
    }

    var displayTitle: String {
        if !title.isEmpty { return title }
        return url.host ?? url.absoluteString
    }
}

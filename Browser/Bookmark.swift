import Foundation

struct Bookmark: Codable, Identifiable, Equatable {
    let id: UUID
    var title: String
    var url: URL
    var folderId: UUID?
    var createdAt: Date

    init(
        id: UUID = UUID(),
        title: String,
        url: URL,
        folderId: UUID? = nil,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.url = url
        self.folderId = folderId
        self.createdAt = createdAt
    }
}

struct BookmarkFolder: Codable, Identifiable, Equatable {
    let id: UUID
    var name: String
    var sortOrder: Int

    init(
        id: UUID = UUID(),
        name: String,
        sortOrder: Int = 0
    ) {
        self.id = id
        self.name = name
        self.sortOrder = sortOrder
    }
}

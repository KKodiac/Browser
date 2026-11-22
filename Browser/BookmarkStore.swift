import Foundation
import Observation

@Observable
final class BookmarkStore {
    var bookmarks: [Bookmark] = []
    var folders: [BookmarkFolder] = []

    private let fileURL: URL

    init() {
        let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let dir = appSupport.appendingPathComponent("Browser", isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        self.fileURL = dir.appendingPathComponent("bookmarks.json")
        load()
    }

    // MARK: - Bookmark CRUD

    func addBookmark(title: String, url: URL, folderId: UUID? = nil) {
        let bookmark = Bookmark(title: title, url: url, folderId: folderId)
        bookmarks.append(bookmark)
        save()
    }

    func removeBookmark(id: UUID) {
        bookmarks.removeAll { $0.id == id }
        save()
    }

    func updateBookmark(id: UUID, title: String? = nil, url: URL? = nil, folderId: UUID?? = nil) {
        guard let index = bookmarks.firstIndex(where: { $0.id == id }) else { return }
        if let title { bookmarks[index].title = title }
        if let url { bookmarks[index].url = url }
        if let folderId { bookmarks[index].folderId = folderId }
        save()
    }

    func bookmark(for url: URL) -> Bookmark? {
        bookmarks.first { $0.url == url }
    }

    func isBookmarked(url: URL?) -> Bool {
        guard let url else { return false }
        return bookmarks.contains { $0.url == url }
    }

    func bookmarks(in folderId: UUID?) -> [Bookmark] {
        bookmarks.filter { $0.folderId == folderId }
    }

    // MARK: - Folder CRUD

    func addFolder(name: String) -> BookmarkFolder {
        let maxOrder = folders.map(\.sortOrder).max() ?? -1
        let folder = BookmarkFolder(name: name, sortOrder: maxOrder + 1)
        folders.append(folder)
        save()
        return folder
    }

    func removeFolder(id: UUID) {
        folders.removeAll { $0.id == id }
        for index in bookmarks.indices where bookmarks[index].folderId == id {
            bookmarks[index].folderId = nil
        }
        save()
    }

    func renameFolder(id: UUID, name: String) {
        guard let index = folders.firstIndex(where: { $0.id == id }) else { return }
        folders[index].name = name
        save()
    }

    // MARK: - Persistence

    private struct StorageData: Codable {
        var bookmarks: [Bookmark]
        var folders: [BookmarkFolder]
    }

    private func save() {
        let data = StorageData(bookmarks: bookmarks, folders: folders)
        guard let encoded = try? JSONEncoder().encode(data) else { return }
        try? encoded.write(to: fileURL, options: .atomic)
    }

    private func load() {
        guard let data = try? Data(contentsOf: fileURL),
              let decoded = try? JSONDecoder().decode(StorageData.self, from: data) else { return }
        bookmarks = decoded.bookmarks
        folders = decoded.folders
    }
}

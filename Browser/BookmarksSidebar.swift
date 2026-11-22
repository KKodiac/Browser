import SwiftUI

struct BookmarksSidebar: View {
    @Environment(BookmarkStore.self) private var store
    var onSelectBookmark: (URL) -> Void
    @Binding var editingBookmarkId: UUID?
    @State private var editingFolderId: UUID?
    @State private var editText: String = ""
    @State private var creatingFolder = false
    @State private var newFolderName: String = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            header
            Divider()
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 2) {
                    ForEach(store.folders.sorted(by: { $0.sortOrder < $1.sortOrder })) { folder in
                        folderSection(folder)
                    }
                    unfiledSection
                }
                .padding(8)
            }
        }
        .frame(width: 240)
        .background(.ultraThinMaterial)
        .onAppear { syncEditText() }
        .onChange(of: editingBookmarkId) { _, _ in syncEditText() }
    }

    /// Loads the bookmark's title into the edit field when editing is started externally (e.g. Cmd+D).
    private func syncEditText() {
        guard let id = editingBookmarkId, let bookmark = store.bookmarks.first(where: { $0.id == id }) else { return }
        editText = bookmark.title
        editingFolderId = nil
    }

    // MARK: - Header

    private var header: some View {
        HStack {
            Text("Bookmarks")
                .font(.system(size: 13, weight: .semibold))
            Spacer()
            Button(action: startCreatingFolder) {
                Image(systemName: "folder.badge.plus")
                    .font(.system(size: 12))
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
    }

    // MARK: - Folder Section

    private func folderSection(_ folder: BookmarkFolder) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            folderHeader(folder)
            ForEach(store.bookmarks(in: folder.id)) { bookmark in
                bookmarkRow(bookmark)
            }
        }
    }

    private func folderHeader(_ folder: BookmarkFolder) -> some View {
        HStack(spacing: 6) {
            Image(systemName: "folder.fill")
                .font(.system(size: 12))
                .foregroundStyle(.secondary)
            if editingFolderId == folder.id {
                TextField("Folder name", text: $editText)
                    .textFieldStyle(.plain)
                    .font(.system(size: 12, weight: .medium))
                    .onSubmit { commitFolderRename(folder.id) }
            } else if creatingFolder && folder.id == store.folders.last?.id {
                TextField("New folder", text: $newFolderName)
                    .textFieldStyle(.plain)
                    .font(.system(size: 12, weight: .medium))
                    .onSubmit { commitNewFolder() }
            } else {
                Text(folder.name)
                    .font(.system(size: 12, weight: .medium))
                    .lineLimit(1)
            }
            Spacer()
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .contextMenu {
            Button("Rename") { startRenamingFolder(folder) }
            Divider()
            Button("Delete", role: .destructive) { store.removeFolder(id: folder.id) }
        }
    }

    // MARK: - Unfiled Section

    private var unfiledSection: some View {
        let unfiled = store.bookmarks(in: nil)
        return Group {
            if !unfiled.isEmpty {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Unfiled")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(.tertiary)
                        .padding(.horizontal, 8)
                        .padding(.top, 8)
                    ForEach(unfiled) { bookmark in
                        bookmarkRow(bookmark)
                    }
                }
            }
        }
    }

    // MARK: - Bookmark Row

    private func bookmarkRow(_ bookmark: Bookmark) -> some View {
        Button {
            onSelectBookmark(bookmark.url)
        } label: {
            HStack(spacing: 6) {
                Image(systemName: "globe")
                    .font(.system(size: 11))
                    .foregroundStyle(.secondary)
                if editingBookmarkId == bookmark.id {
                    TextField("Title", text: $editText)
                        .textFieldStyle(.plain)
                        .font(.system(size: 12))
                        .onSubmit { commitBookmarkRename(bookmark.id) }
                } else {
                    Text(bookmark.title)
                        .font(.system(size: 12))
                        .lineLimit(1)
                        .truncationMode(.tail)
                }
                Spacer()
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .background(Color.white.opacity(0.001))
        .clipShape(.rect(cornerRadius: 6))
        .contextMenu {
            Button("Edit") { startEditingBookmark(bookmark) }
            if !store.folders.isEmpty {
                Menu("Move to Folder") {
                    Button("Unfiled") {
                        store.updateBookmark(id: bookmark.id, folderId: .some(nil))
                    }
                    Divider()
                    ForEach(store.folders.sorted(by: { $0.sortOrder < $1.sortOrder })) { folder in
                        Button(folder.name) {
                            store.updateBookmark(id: bookmark.id, folderId: .some(folder.id))
                        }
                    }
                }
            }
            Divider()
            Button("Delete", role: .destructive) { store.removeBookmark(id: bookmark.id) }
        }
    }

    // MARK: - Editing Actions

    private func startEditingBookmark(_ bookmark: Bookmark) {
        editText = bookmark.title
        editingBookmarkId = bookmark.id
        editingFolderId = nil
    }

    private func commitBookmarkRename(_ id: UUID) {
        let trimmed = editText.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmed.isEmpty {
            store.updateBookmark(id: id, title: trimmed)
        }
        editingBookmarkId = nil
    }

    private func startRenamingFolder(_ folder: BookmarkFolder) {
        editText = folder.name
        editingFolderId = folder.id
        editingBookmarkId = nil
    }

    private func commitFolderRename(_ id: UUID) {
        let trimmed = editText.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmed.isEmpty {
            store.renameFolder(id: id, name: trimmed)
        }
        editingFolderId = nil
    }

    private func startCreatingFolder() {
        newFolderName = ""
        creatingFolder = true
        _ = store.addFolder(name: "New Folder")
    }

    private func commitNewFolder() {
        let trimmed = newFolderName.trimmingCharacters(in: .whitespacesAndNewlines)
        if let last = store.folders.last {
            if trimmed.isEmpty {
                store.removeFolder(id: last.id)
            } else {
                store.renameFolder(id: last.id, name: trimmed)
            }
        }
        creatingFolder = false
    }
}

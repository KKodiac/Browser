import AppKit
import ComposableArchitecture
import Foundation
import Observation
import SwiftUI

/// A saved, named snapshot of one window's tabs and groups.
struct Workspace: Codable, Identifiable {
    let id: UUID
    var name: String
    var window: SessionData
    var updatedAt: Date
}

/// Saved workspaces, persisted to Application Support/Browser/workspaces.json.
/// Only normal windows are saved; private tabs never reach disk.
@MainActor
@Observable
final class WorkspaceStore {
    static let shared = WorkspaceStore()

    private(set) var workspaces: [Workspace] = []

    /// Which workspace each open window came from, so saving again updates it.
    @ObservationIgnored
    private let windowWorkspaces = NSMapTable<StoreOf<AppFeature>, NSUUID>.weakToStrongObjects()

    private static var fileURL: URL {
        let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let dir = appSupport.appendingPathComponent("Browser", isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir.appendingPathComponent("workspaces.json")
    }

    private init() {
        if let data = try? Data(contentsOf: Self.fileURL),
           let saved = try? JSONDecoder().decode([Workspace].self, from: data) {
            workspaces = saved
        }
    }

    private func persist() {
        guard let encoded = try? JSONEncoder().encode(workspaces) else { return }
        try? encoded.write(to: Self.fileURL, options: .atomic)
    }

    // MARK: - Windows

    /// The workspace a window was opened from (or last saved as), if it still exists.
    func workspace(for store: StoreOf<AppFeature>) -> Workspace? {
        guard let id = windowWorkspaces.object(forKey: store).map({ $0 as UUID }) else { return nil }
        return workspaces.first { $0.id == id }
    }

    /// A default name: the largest group's label, else the selected tab's host.
    func suggestedName(for store: StoreOf<AppFeature>) -> String {
        if let group = store.tabGroups.max(by: { $0.tabs.count < $1.tabs.count }) {
            return group.label
        }
        return store.selectedTab?.url?.host() ?? "Workspace"
    }

    /// Saves the window's tabs, updating its workspace if it has one, else creating a new one.
    @discardableResult
    func save(_ store: StoreOf<AppFeature>, name: String) -> Workspace {
        let window = SessionData(
            ungroupedTabs: Array(store.ungroupedTabs),
            tabGroups: Array(store.tabGroups),
            selectedTabId: store.selectedTabId,
            accentColor: store.accentColor
        )
        let workspace: Workspace
        if let existing = self.workspace(for: store),
           let index = workspaces.firstIndex(where: { $0.id == existing.id }) {
            workspaces[index].name = name
            workspaces[index].window = window
            workspaces[index].updatedAt = Date()
            workspace = workspaces[index]
        } else {
            workspace = Workspace(id: UUID(), name: name, window: window, updatedAt: Date())
            workspaces.append(workspace)
        }
        windowWorkspaces.setObject(workspace.id as NSUUID, forKey: store)
        persist()
        return workspace
    }

    /// Opens the workspace in a new normal window, which remembers the workspace.
    func open(_ workspace: Workspace, openWindow: OpenWindowAction) {
        WindowRegistry.shared.enqueueOpen(workspace.window) { [weak self] store in
            self?.windowWorkspaces.setObject(workspace.id as NSUUID, forKey: store)
        }
        openWindow(id: BrowserWindow.mainID)
    }

    // MARK: - Manage

    func rename(_ id: UUID, to name: String) {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, let index = workspaces.firstIndex(where: { $0.id == id }) else { return }
        workspaces[index].name = trimmed
        persist()
    }

    func delete(_ id: UUID) {
        workspaces.removeAll { $0.id == id }
        persist()
    }
}

// MARK: - Naming prompt

enum WorkspaceNamePrompt {
    /// Asks for a workspace name; returns nil if cancelled.
    @MainActor
    static func run(title: String, defaultName: String) -> String? {
        let alert = NSAlert()
        alert.messageText = title
        alert.informativeText = "Name this workspace."
        alert.addButton(withTitle: "Save")
        alert.addButton(withTitle: "Cancel")
        let field = NSTextField(frame: NSRect(x: 0, y: 0, width: 260, height: 24))
        field.stringValue = defaultName
        alert.accessoryView = field
        alert.window.initialFirstResponder = field
        guard alert.runModal() == .alertFirstButtonReturn else { return nil }
        let name = field.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
        return name.isEmpty ? defaultName : name
    }
}

// MARK: - Focused window kind

struct WindowIsPrivateKey: FocusedValueKey {
    typealias Value = Bool
}

extension FocusedValues {
    /// Whether the focused browser window is private; workspace commands are disabled for private windows.
    var windowIsPrivate: Bool? {
        get { self[WindowIsPrivateKey.self] }
        set { self[WindowIsPrivateKey.self] = newValue }
    }
}

// MARK: - Menu

struct WorkspaceCommands: Commands {
    var workspaceStore: WorkspaceStore
    @FocusedValue(\.windowStore) private var store
    @FocusedValue(\.windowIsPrivate) private var isPrivate
    @Environment(\.openWindow) private var openWindow

    private var canSave: Bool { store != nil && isPrivate == false }

    var body: some Commands {
        CommandMenu("Workspaces") {
            Button("Save Window as Workspace…") {
                guard let store, isPrivate == false else { return }
                let current = workspaceStore.workspace(for: store)
                let defaultName = current?.name ?? workspaceStore.suggestedName(for: store)
                guard let name = WorkspaceNamePrompt.run(title: "Save Window as Workspace", defaultName: defaultName)
                else { return }
                workspaceStore.save(store, name: name)
            }
            .keyboardShortcut("s", modifiers: [.command, .option])
            .disabled(!canSave)
            Button("Put Away Window") {
                guard let store, isPrivate == false else { return }
                let name: String
                if let current = workspaceStore.workspace(for: store) {
                    name = current.name
                } else {
                    guard let entered = WorkspaceNamePrompt.run(
                        title: "Put Away Window", defaultName: workspaceStore.suggestedName(for: store)
                    ) else { return }
                    name = entered
                }
                workspaceStore.save(store, name: name)
                NSApp.keyWindow?.performClose(nil)
            }
            .keyboardShortcut("w", modifiers: [.command, .option])
            .disabled(!canSave)
            Divider()
            if workspaceStore.workspaces.isEmpty {
                Button("No Saved Workspaces") {}
                    .disabled(true)
            } else {
                ForEach(workspaceStore.workspaces) { workspace in
                    Button(workspace.name) {
                        workspaceStore.open(workspace, openWindow: openWindow)
                    }
                }
            }
            Divider()
            Button("Manage Workspaces…") {
                openWindow(id: ManageWorkspacesView.windowID)
            }
        }
    }
}

// MARK: - Manage window

struct ManageWorkspacesView: View {
    static let windowID = "workspaces"

    var workspaceStore: WorkspaceStore
    @Environment(\.openWindow) private var openWindow

    var body: some View {
        Group {
            if workspaceStore.workspaces.isEmpty {
                Text("No saved workspaces. Use Workspaces › Save Window as Workspace… (⌥⌘S).")
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List(workspaceStore.workspaces) { workspace in
                    WorkspaceRow(workspace: workspace, workspaceStore: workspaceStore) {
                        workspaceStore.open(workspace, openWindow: openWindow)
                    }
                }
            }
        }
        .frame(minWidth: 380, minHeight: 240)
    }
}

private struct WorkspaceRow: View {
    let workspace: Workspace
    var workspaceStore: WorkspaceStore
    let onOpen: () -> Void
    @State private var name = ""

    private var tabCount: Int {
        workspace.window.ungroupedTabs.count + workspace.window.tabGroups.reduce(0) { $0 + $1.tabs.count }
    }

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                TextField("Name", text: $name)
                    .textFieldStyle(.plain)
                    .onSubmit { workspaceStore.rename(workspace.id, to: name) }
                Text("\(tabCount) tab\(tabCount == 1 ? "" : "s") · \(workspace.updatedAt.formatted(date: .abbreviated, time: .shortened))")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Button("Open", action: onOpen)
            Button(role: .destructive) {
                workspaceStore.delete(workspace.id)
            } label: {
                Image(systemName: "trash")
            }
            .buttonStyle(.borderless)
            .help("Delete Workspace")
        }
        .onAppear { name = workspace.name }
        .onChange(of: workspace.name) { _, newValue in name = newValue }
        .contextMenu {
            Button("Open", action: onOpen)
            Button("Delete", role: .destructive) { workspaceStore.delete(workspace.id) }
        }
    }
}

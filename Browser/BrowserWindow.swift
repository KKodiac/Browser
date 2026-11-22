import ComposableArchitecture
import SwiftUI
import WebKit

/// One browser window. Each window owns its own store (tabs, groups, selection);
/// private windows also own an ephemeral website data store shared by their tabs.
struct BrowserWindow: View {
    static let mainID = "main"
    static let privateID = "private"

    let isPrivate: Bool
    @State private var store: StoreOf<AppFeature>
    @State private var dataStore: WKWebsiteDataStore?
    @Environment(\.openWindow) private var openWindow

    init(isPrivate: Bool) {
        self.isPrivate = isPrivate
        var state = AppFeature.State()
        state.accentColor = .saved
        _store = State(initialValue: Store(initialState: state) { AppFeature() })
        _dataStore = State(initialValue: isPrivate ? .nonPersistent() : nil)
    }

    var body: some View {
        ContentView(store: store, isPrivate: isPrivate, dataStore: dataStore)
            .frame(minWidth: 800, minHeight: 600)
            .focusedSceneValue(\.windowStore, store)
            .onAppear {
                let registry = WindowRegistry.shared
                registry.register(store, isPrivate: isPrivate)
                guard !isPrivate, let data = registry.nextPendingRestore() else { return }
                store.send(.restoreSession(data))
                // Each restored window opens the next one until every saved window is back.
                if registry.hasPendingRestore {
                    openWindow(id: Self.mainID)
                }
            }
            .onDisappear {
                WindowRegistry.shared.unregister(store)
            }
    }
}

struct WindowStoreKey: FocusedValueKey {
    typealias Value = StoreOf<AppFeature>
}

extension FocusedValues {
    /// The store of the focused browser window; menu commands act on it.
    var windowStore: StoreOf<AppFeature>? {
        get { self[WindowStoreKey.self] }
        set { self[WindowStoreKey.self] = newValue }
    }
}

extension AccentColor {
    /// The last accent color picked, used for new windows.
    static var saved: AccentColor {
        UserDefaults.standard.string(forKey: "accentColor").flatMap(AccentColor.init(rawValue:)) ?? .blue
    }
}

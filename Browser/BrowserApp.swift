import ComposableArchitecture
import SwiftUI

@main
struct BrowserApp: App {
    @State private var store = Store(initialState: AppFeature.State()) {
        AppFeature()
    }

    var body: some Scene {
        WindowGroup {
            ContentView(store: store)
                .frame(minWidth: 800, minHeight: 600)
        }
        .windowStyle(.automatic)
        .commands {
            CommandGroup(replacing: .newItem) {}
            CommandMenu("Navigation") {
                Button("Back") {
                    store.send(.goBack)
                }
                .keyboardShortcut("[", modifiers: .command)
                Button("Forward") {
                    store.send(.goForward)
                }
                .keyboardShortcut("]", modifiers: .command)
                Button("Reload") {
                    store.send(.reload)
                }
                .keyboardShortcut("r", modifiers: .command)
                Divider()
                Button("Focus URL Bar") {
                    store.send(.focusURLBar)
                }
                .keyboardShortcut("l", modifiers: .command)
            }
        }
    }
}

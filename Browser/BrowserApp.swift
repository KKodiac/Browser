import SwiftUI

@main
struct BrowserApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(minWidth: 800, minHeight: 600)
        }
        .windowStyle(.automatic)
        .commands {
            CommandGroup(replacing: .newItem) {}
            CommandMenu("Navigation") {
                Button("Back") {}
                    .keyboardShortcut("[", modifiers: .command)
                Button("Forward") {}
                    .keyboardShortcut("]", modifiers: .command)
                Button("Reload") {}
                    .keyboardShortcut("r", modifiers: .command)
            }
        }
    }
}

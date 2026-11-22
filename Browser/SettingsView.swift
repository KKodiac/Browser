import SwiftUI

enum SearchEngine: String, CaseIterable, Identifiable {
    case google, duckduckgo, bing

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .google: "Google"
        case .duckduckgo: "DuckDuckGo"
        case .bing: "Bing"
        }
    }

    var searchURLPrefix: String {
        switch self {
        case .google: "https://www.google.com/search?q="
        case .duckduckgo: "https://duckduckgo.com/?q="
        case .bing: "https://www.bing.com/search?q="
        }
    }
}

struct SettingsView: View {
    var body: some View {
        TabView {
            GeneralSettingsTab()
                .tabItem {
                    Label("General", systemImage: "gear")
                }
            AppearanceSettingsTab()
                .tabItem {
                    Label("Appearance", systemImage: "paintbrush")
                }
            PrivacySettingsTab()
                .tabItem {
                    Label("Privacy", systemImage: "lock.shield")
                }
        }
        .frame(width: 450, height: 250)
    }
}

struct GeneralSettingsTab: View {
    @AppStorage("searchEngine") private var searchEngine: String = SearchEngine.google.rawValue
    @AppStorage("homePageURL") private var homePageURL: String = ""

    var body: some View {
        Form {
            Picker("Search Engine", selection: $searchEngine) {
                ForEach(SearchEngine.allCases) { engine in
                    Text(engine.displayName).tag(engine.rawValue)
                }
            }
            TextField("Home Page URL", text: $homePageURL, prompt: Text("Leave empty for blank tab"))
        }
        .padding()
    }
}

struct AppearanceSettingsTab: View {
    @AppStorage("accentColor") private var accentColor: String = AccentColor.blue.rawValue

    var body: some View {
        Form {
            Picker("Accent Color", selection: $accentColor) {
                ForEach(AccentColor.allCases, id: \.self) { ac in
                    HStack {
                        Circle().fill(ac.color).frame(width: 12, height: 12)
                        Text(ac.rawValue.capitalized)
                    }
                    .tag(ac.rawValue)
                }
            }
        }
        .padding()
    }
}

struct PrivacySettingsTab: View {
    @AppStorage("contentBlockingEnabled") private var contentBlockingEnabled: Bool = true
    @AppStorage("clearDataOnQuit") private var clearDataOnQuit: Bool = false

    var body: some View {
        Form {
            Toggle("Block Trackers & Ads", isOn: $contentBlockingEnabled)
            Toggle("Clear Browsing Data on Quit", isOn: $clearDataOnQuit)
        }
        .padding()
    }
}

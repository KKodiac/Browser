import Foundation
import IdentifiedCollections
import SwiftUI

enum AccentColor: String, CaseIterable, Equatable {
    case blue, purple, pink, orange, teal, green, red, white

    var color: Color {
        switch self {
        case .blue: .blue
        case .purple: .purple
        case .pink: .pink
        case .orange: .orange
        case .teal: .teal
        case .green: .green
        case .red: .red
        case .white: .white
        }
    }
}

enum GroupColor: String, CaseIterable, Equatable {
    case red, orange, yellow, green, blue, purple, pink, gray

    var color: Color {
        switch self {
        case .red: .red
        case .orange: .orange
        case .yellow: .yellow
        case .green: .green
        case .blue: .blue
        case .purple: .purple
        case .pink: .pink
        case .gray: .gray
        }
    }
}

struct TabGroup: Equatable, Identifiable {
    let id: UUID
    var label: String
    var color: GroupColor
    var isCollapsed: Bool
    var tabs: IdentifiedArrayOf<BrowserTab>

    init(
        id: UUID = UUID(),
        label: String = "New Group",
        color: GroupColor = .blue,
        isCollapsed: Bool = false,
        tabs: IdentifiedArrayOf<BrowserTab> = []
    ) {
        self.id = id
        self.label = label
        self.color = color
        self.isCollapsed = isCollapsed
        self.tabs = tabs
    }
}

import SwiftUI

/// Shared sizes and helpers. Colors live in the asset catalog (`LearnedOrange`, `FreezeBlue`)
/// with light and dark variants, so the app follows the system appearance.
enum Theme {
    static let screenPadding: CGFloat = 16
    static let logButtonSize: CGFloat = 274
    static let wideButtonWidth: CGFloat = 274
    static let dayCircleSize: CGFloat = 44
    static let cardCornerRadius: CGFloat = 34
}

extension DayStatus {
    var tint: Color {
        switch self {
        case .learned: .learnedOrange
        case .freezed: .freezeBlue
        }
    }
}

extension Int {
    /// "1 day", "2 days" — the design asks for the singular when the count is one.
    var daysText: String {
        self == 1 ? "1 day" : "\(self) days"
    }
}

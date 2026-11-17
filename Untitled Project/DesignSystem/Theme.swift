import SwiftUI

/// Sizes taken from the Sketch Hi-Fi screens (iPhone 393 × 852 pt).
/// Colors live in the asset catalog (`LearnedOrange`, `FreezeBlue`) with light and dark
/// variants, so the app follows the system appearance.
enum Theme {
    static let screenPadding: CGFloat = 16
    static let contentPadding: CGFloat = 14

    static let logButtonSize: CGFloat = 272
    static let wideButtonWidth: CGFloat = 272
    static let buttonHeight: CGFloat = 46
    static let toolbarButtonSize: CGFloat = 44

    static let dayCircleSize: CGFloat = 44
    static let dayTintOpacity: Double = 0.12

    static let cardHeight: CGFloat = 102
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

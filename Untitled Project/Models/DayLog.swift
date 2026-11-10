import Foundation

/// How a single day was logged.
enum DayStatus: String, Codable {
    case learned
    case freezed
}

/// One logged day. A day can only be logged once.
struct DayLog: Codable, Hashable, Identifiable {
    /// Start of the logged calendar day.
    var day: Date
    var status: DayStatus
    /// The exact moment the learner tapped the button (used by the 32-hour streak rule).
    var loggedAt: Date

    var id: Date { day }
}

/// Everything the app persists.
struct LearningData: Codable, Equatable {
    var goal: LearningGoal?
    var logs: [DayLog] = []
}

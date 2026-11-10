import Foundation

/// What the learner wants to learn and for how long.
struct LearningGoal: Codable, Equatable {
    var subject: String
    var period: GoalPeriod
    /// The moment the goal was created. Its calendar day is the goal's first day.
    var startDate: Date

    func firstDay(in calendar: Calendar) -> Date {
        calendar.startOfDay(for: startDate)
    }

    /// Midnight right after the goal's last day (exclusive end).
    func endDate(in calendar: Calendar) -> Date {
        let start = firstDay(in: calendar)
        return calendar.date(byAdding: period.calendarComponent, value: 1, to: start) ?? start
    }

    /// Total number of days the learner needs to log to complete the goal.
    func lengthInDays(in calendar: Calendar) -> Int {
        calendar.dateComponents([.day], from: firstDay(in: calendar), to: endDate(in: calendar)).day ?? 0
    }

    func hasSameTarget(as other: LearningGoal) -> Bool {
        subject == other.subject && period == other.period
    }
}

import Foundation

/// Dummy data used in DEBUG builds and SwiftUI previews.
/// Kept apart from the app logic so it can be removed without touching anything else.
enum MockData {

    /// Learned/freezed days from January of the previous months up to a few days before `date`.
    /// The pattern is deterministic, so the calendar looks the same on every run.
    static func previousMonthsHistory(before date: Date, calendar: Calendar) -> [DayLog] {
        let today = calendar.startOfDay(for: date)
        guard
            let lastDay = calendar.date(byAdding: .day, value: -2, to: today),
            let tenMonthsAgo = calendar.date(byAdding: .month, value: -10, to: today),
            let firstDay = calendar.dateInterval(of: .month, for: tenMonthsAgo)?.start
        else { return [] }

        var logs: [DayLog] = []
        var day = firstDay
        var index = 0

        while day <= lastDay {
            if let status = status(forDayIndex: index) {
                let loggedAt = calendar.date(byAdding: .hour, value: 20, to: day) ?? day
                logs.append(DayLog(day: day, status: status, loggedAt: loggedAt))
            }
            index += 1
            guard let next = calendar.date(byAdding: .day, value: 1, to: day) else { break }
            day = next
        }
        return logs
    }

    /// A repeating 23-day pattern: mostly learned, a couple of freezes and a short break.
    private static func status(forDayIndex index: Int) -> DayStatus? {
        switch index % 23 {
        case 6, 15: .freezed
        case 19, 20: nil
        default: .learned
        }
    }

    // MARK: - Previews

    static func previewStore(
        subject: String = "Swift",
        period: GoalPeriod = .month,
        goalStartedDaysAgo: Int = 4,
        today todayStatus: DayStatus? = nil
    ) -> LearningStore {
        let calendar = Calendar.current
        let now = Date()
        let today = calendar.startOfDay(for: now)
        let goalStart = calendar.date(byAdding: .day, value: -goalStartedDaysAgo, to: now) ?? now

        var logs = previousMonthsHistory(before: goalStart, calendar: calendar)
        for offset in stride(from: goalStartedDaysAgo, through: 1, by: -1) {
            guard let day = calendar.date(byAdding: .day, value: -offset, to: today) else { continue }
            let loggedAt = calendar.date(byAdding: .hour, value: 19, to: day) ?? day
            logs.append(DayLog(day: day, status: offset == 2 ? .freezed : .learned, loggedAt: loggedAt))
        }
        if let todayStatus {
            logs.append(DayLog(day: today, status: todayStatus, loggedAt: now))
        }

        let data = LearningData(
            goal: LearningGoal(subject: subject, period: period, startDate: goalStart),
            logs: logs
        )
        return LearningStore(persistence: InMemoryPersistence(data), calendar: calendar)
    }
}

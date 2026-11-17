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

    /// Back-to-back past goals from `start` until `date`, so every mock day belongs to a goal.
    static func previousGoals(from start: Date, before date: Date, calendar: Calendar) -> [LearningGoal] {
        let plan: [(String, GoalPeriod)] = [
            ("Swift", .month), ("SwiftUI", .week), ("UI Design", .week), ("Arabic", .month), ("Figma", .week),
        ]
        let end = calendar.startOfDay(for: date)
        var goals: [LearningGoal] = []
        var goalStart = calendar.startOfDay(for: start)

        while goalStart < end {
            let (subject, period) = plan[goals.count % plan.count]
            let goal = LearningGoal(subject: subject, period: period, startDate: goalStart)
            goals.append(goal)
            goalStart = goal.endDate(in: calendar)
        }
        return goals
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

    static func previewStore() -> LearningStore {
        let goalStartedDaysAgo = 4
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

        let installDate = logs.first?.day ?? today
        let data = LearningData(
            installDate: installDate,
            goal: LearningGoal(subject: "Swift", period: .month, startDate: goalStart),
            pastGoals: previousGoals(from: installDate, before: goalStart, calendar: calendar),
            logs: logs
        )
        return LearningStore(persistence: InMemoryPersistence(data), calendar: calendar)
    }
}

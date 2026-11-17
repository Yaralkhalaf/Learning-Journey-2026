import Foundation

/// The state of the current goal.
enum GoalState: Equatable {
    case inProgress
    case completed
    case notMet
}

/// A read-only summary of the learner's progress at a given moment.
struct ProgressSnapshot {
    /// Learned days in the current streak.
    var learnedCount: Int
    /// Freezed days in the current streak.
    var freezedCount: Int
    /// Freezes spent during the whole goal period (does not reset with the streak).
    var freezesUsed: Int
    var freezeLimit: Int
    var todayStatus: DayStatus?
    var goalState: GoalState
    var daysLeft: Int

    var hasFreezesLeft: Bool { freezesUsed < freezeLimit }
    var isTodayLogged: Bool { todayStatus != nil }

    /// Today can be logged as learned, or switched from freezed to learned (fixes a wrong tap).
    var canLogLearned: Bool { goalState == .inProgress && todayStatus != .learned }
    /// Today can be freezed, or switched from learned to freezed, while a freeze is left.
    /// (A freezed today is already counted in `freezesUsed`, so switching back gives it back.)
    var canFreeze: Bool { goalState == .inProgress && todayStatus != .freezed && hasFreezesLeft }
}

/// Pure business rules. No storage, no UI — easy to reason about and to test.
///
/// Rules (from the design notes):
/// - Freezes: 2 per week, 8 per month, 96 per year.
/// - The streak ends when more than 32 hours pass without logging (learned or freezed),
///   counted from the moment of the last tap — even if the learner logged "yesterday".
///   It also resets when the learning goal is updated.
/// - Today is logged once, as learned or freezed. A wrong tap can be fixed by tapping the
///   other button (switching to freezed needs a freeze left). The chosen button is disabled,
///   and Freeze is disabled when all freezes are used. Both are fresh again at midnight.
/// - A goal is completed when every day of its period is logged.
struct ProgressCalculator {
    /// The longest time allowed between two logs (or since the last log) before the streak ends.
    static let streakGraceInterval: TimeInterval = 32 * 60 * 60

    let calendar: Calendar

    func snapshot(goal: LearningGoal, logs: [DayLog], now: Date) -> ProgressSnapshot {
        let firstDay = goal.firstDay(in: calendar)
        let endDate = goal.endDate(in: calendar)
        let hasEnded = now >= endDate
        // Once the goal ends, freeze the numbers as they were on its last day.
        let referenceDate = hasEnded ? endDate : now

        // Every log on a day inside the goal's period: used for "already logged today" and completion.
        let daysInPeriod = logs
            .filter { $0.day >= firstDay && $0.day < endDate }
            .sorted { $0.day < $1.day }
        // Only logs made after the goal was set: the streak and freezes start over with a new goal,
        // even when today was already logged under the previous goal.
        let goalLogs = daysInPeriod.filter { $0.loggedAt >= goal.startDate }

        let streak = currentStreak(in: goalLogs, asOf: referenceDate)
        let today = calendar.startOfDay(for: now)

        return ProgressSnapshot(
            learnedCount: streak.count { $0.status == .learned },
            freezedCount: streak.count { $0.status == .freezed },
            freezesUsed: goalLogs.count { $0.status == .freezed },
            freezeLimit: goal.period.freezeLimit,
            todayStatus: daysInPeriod.first { $0.day == today }?.status,
            goalState: goalState(hasEnded: hasEnded, loggedDays: daysInPeriod.count, goal: goal),
            daysLeft: max(0, dayDistance(from: today, to: endDate))
        )
    }

    // MARK: - Streak

    /// The unbroken run of logs that ends at `date`, or an empty array if the streak was lost.
    func currentStreak(in sortedLogs: [DayLog], asOf date: Date) -> [DayLog] {
        // 1. Is the streak still alive right now? (last log no more than 32 hours ago)
        guard let last = sortedLogs.last, isContinuous(from: last, to: date) else { return [] }

        // 2. Walk back from the newest log while each gap is 32 hours or less.
        var startIndex = sortedLogs.count - 1
        while startIndex > 0 {
            let previous = sortedLogs[startIndex - 1]
            let current = sortedLogs[startIndex]
            guard isContinuous(from: previous, to: current.loggedAt) else { break }
            startIndex -= 1
        }
        return Array(sortedLogs[startIndex...])
    }

    /// The streak continues only if no more than 32 hours passed since `log` was tapped.
    private func isContinuous(from log: DayLog, to moment: Date) -> Bool {
        moment.timeIntervalSince(log.loggedAt) <= Self.streakGraceInterval
    }

    // MARK: - Goal

    private func goalState(hasEnded: Bool, loggedDays: Int, goal: LearningGoal) -> GoalState {
        guard hasEnded else { return .inProgress }
        return loggedDays >= goal.lengthInDays(in: calendar) ? .completed : .notMet
    }

    private func dayDistance(from start: Date, to end: Date) -> Int {
        calendar.dateComponents([.day], from: calendar.startOfDay(for: start), to: calendar.startOfDay(for: end)).day ?? 0
    }
}

import Foundation

/// The state of the current goal.
enum GoalState: Equatable {
    case inProgress
    case completed
    case notMet
}

/// A read-only summary of the learner's progress at a given moment.
struct ProgressSnapshot: Equatable {
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
    var canLogLearned: Bool { goalState == .inProgress && !isTodayLogged }
    var canFreeze: Bool { canLogLearned && hasFreezesLeft }
}

/// Pure business rules. No storage, no UI — easy to reason about and to test.
///
/// Rules (from the design notes):
/// - Freezes: 2 per week, 8 per month, 96 per year.
/// - The streak resets when more than 32 hours pass without logging a day
///   (learned or freezed), or when the learning goal is updated.
/// - Logging buttons are disabled once today is logged or when all freezes are used.
///   They are enabled again at midnight.
/// - A goal is completed when every day of its period is logged.
struct ProgressCalculator {
    static let streakGraceInterval: TimeInterval = 32 * 60 * 60

    let calendar: Calendar

    func snapshot(goal: LearningGoal, logs: [DayLog], now: Date) -> ProgressSnapshot {
        let firstDay = goal.firstDay(in: calendar)
        let endDate = goal.endDate(in: calendar)
        let hasEnded = now >= endDate
        // Once the goal ends, freeze the numbers as they were on its last day.
        let referenceDate = hasEnded ? endDate : now

        let goalLogs = logs
            .filter { $0.day >= firstDay && $0.day < endDate }
            .sorted { $0.day < $1.day }

        let streak = currentStreak(in: goalLogs, asOf: referenceDate)
        let today = calendar.startOfDay(for: now)

        return ProgressSnapshot(
            learnedCount: streak.count { $0.status == .learned },
            freezedCount: streak.count { $0.status == .freezed },
            freezesUsed: goalLogs.count { $0.status == .freezed },
            freezeLimit: goal.period.freezeLimit,
            todayStatus: goalLogs.first { $0.day == today }?.status,
            goalState: goalState(hasEnded: hasEnded, loggedDays: goalLogs.count, goal: goal),
            daysLeft: max(0, dayDistance(from: today, to: endDate))
        )
    }

    // MARK: - Streak

    /// The unbroken run of logs that ends at `date`, or an empty array if the streak was lost.
    func currentStreak(in sortedLogs: [DayLog], asOf date: Date) -> [DayLog] {
        guard let last = sortedLogs.last,
              isContinuous(previous: last, nextDay: calendar.startOfDay(for: date), nextMoment: date)
        else { return [] }

        var startIndex = sortedLogs.count - 1
        while startIndex > 0 {
            let previous = sortedLogs[startIndex - 1]
            let current = sortedLogs[startIndex]
            guard isContinuous(previous: previous, nextDay: current.day, nextMoment: current.loggedAt) else { break }
            startIndex -= 1
        }
        return Array(sortedLogs[startIndex...])
    }

    /// Two moments keep the streak alive when they are on consecutive days,
    /// or when no more than 32 hours separate them.
    private func isContinuous(previous: DayLog, nextDay: Date, nextMoment: Date) -> Bool {
        dayDistance(from: previous.day, to: nextDay) <= 1
            || nextMoment.timeIntervalSince(previous.loggedAt) <= Self.streakGraceInterval
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

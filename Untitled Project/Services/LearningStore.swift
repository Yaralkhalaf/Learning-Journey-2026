import Foundation
import Observation

/// The single source of truth for the app. ViewModels read from it and call its intents.
@Observable
final class LearningStore {
    private(set) var goal: LearningGoal?
    private(set) var now: Date
    /// The day the app was first opened. Nothing before it is counted or shown.
    private(set) var installDate: Date
    /// Goals that were replaced, oldest first. Used to show which goal a past day belonged to.
    private(set) var pastGoals: [LearningGoal]

    /// Logs keyed by the start of their day, for quick lookups.
    private var logsByDay: [Date: DayLog]

    let calendar: Calendar
    private let persistence: LearningPersistence
    private let seedsMockHistory: Bool
    private let clock: () -> Date

    init(
        persistence: LearningPersistence,
        calendar: Calendar = .current,
        seedsMockHistory: Bool = false,
        clock: @escaping () -> Date = Date.init
    ) {
        let data = persistence.load()
        let now = clock()
        self.persistence = persistence
        self.calendar = calendar
        self.seedsMockHistory = seedsMockHistory
        self.clock = clock
        self.now = now
        self.goal = data.goal
        self.installDate = data.installDate ?? calendar.startOfDay(for: now)
        self.pastGoals = data.pastGoals ?? []
        self.logsByDay = Dictionary(data.logs.map { ($0.day, $0) }, uniquingKeysWith: { first, _ in first })

        if data.installDate == nil { save() }
    }

    // MARK: - Derived state

    /// Onboarding is shown only until the first goal is created.
    var hasOnboarded: Bool { goal != nil }

    /// Logs from the install day onwards, oldest first.
    var logs: [DayLog] {
        logsByDay.values
            .filter { $0.day >= installDate }
            .sorted { $0.day < $1.day }
    }

    var snapshot: ProgressSnapshot? {
        guard let goal else { return nil }
        return ProgressCalculator(calendar: calendar).snapshot(goal: goal, logs: logs, now: now)
    }

    var today: Date { calendar.startOfDay(for: now) }

    func status(on day: Date) -> DayStatus? {
        let day = calendar.startOfDay(for: day)
        guard day >= installDate else { return nil }
        return logsByDay[day]?.status
    }

    /// Every goal ever set: the old ones plus the current one, oldest first.
    var allGoals: [LearningGoal] {
        pastGoals + (goal.map { [$0] } ?? [])
    }

    /// The last day `goal` really ran: the end of its period,
    /// or the day before a newer goal replaced it, whichever comes first.
    func lastDay(of goal: LearningGoal) -> Date? {
        let firstDay = goal.firstDay(in: calendar)
        // The first day of the next goal set after this one, if any.
        let nextStart = allGoals
            .map { $0.firstDay(in: calendar) }
            .filter { $0 > firstDay }
            .min()
        let end = min(goal.endDate(in: calendar), nextStart ?? .distantFuture)
        // `end` is the first day the goal no longer runs, so step back one day.
        return calendar.date(byAdding: .day, value: -1, to: end)
    }

    /// The goal that was running on `day`, if any.
    /// A newer goal replaces an older one from its first day, so the latest goal that had
    /// started by `day` wins, as long as its period had not ended yet.
    /// Used by the calendar's day popover.
    func goal(on day: Date) -> LearningGoal? {
        let day = calendar.startOfDay(for: day)
        // The newest goal that had already started on that day.
        guard let candidate = allGoals.last(where: { $0.firstDay(in: calendar) <= day }) else { return nil }
        // Only if that goal hadn't ended yet on that day.
        return day < candidate.endDate(in: calendar) ? candidate : nil
    }

    // MARK: - Intents

    /// Called once from onboarding.
    func startJourney(subject: String, period: GoalPeriod) {
        refreshDate()
        if seedsMockHistory && logsByDay.isEmpty {
            // Demo only: pretend the app was installed months ago and fill that history.
            let history = MockData.previousMonthsHistory(before: today, calendar: calendar)
            for log in history { logsByDay[log.day] = log }
            if let first = history.first {
                installDate = first.day
                pastGoals = MockData.previousGoals(from: first.day, before: today, calendar: calendar)
            }
        }
        setGoal(subject: subject, period: period)
    }

    /// Replaces the current goal. The streak starts over from today.
    func setGoal(subject: String, period: GoalPeriod) {
        refreshDate()
        // Keep the old goal in the history, so the calendar can still show it for its days.
        if let goal { pastGoals.append(goal) }
        goal = LearningGoal(
            subject: subject.trimmingCharacters(in: .whitespacesAndNewlines),
            period: period,
            startDate: now
        )
        save()
    }

    /// Logs today as learned or freezed. If today is already logged the other way,
    /// it is switched (to fix a wrong tap).
    func logToday(as status: DayStatus) {
        refreshDate()
        guard let snapshot else { return }
        let isAllowed = status == .learned ? snapshot.canLogLearned : snapshot.canFreeze
        guard isAllowed else { return }

        // When switching, keep the first tap's time so the 32-hour streak rule doesn't change.
        let loggedAt = logsByDay[today]?.loggedAt ?? now
        logsByDay[today] = DayLog(day: today, status: status, loggedAt: loggedAt)
        save()
    }

    /// Re-reads the clock, e.g. when the app becomes active or the day changes at midnight.
    func refreshDate() {
        now = clock()
    }

    private func save() {
        persistence.save(LearningData(
            installDate: installDate,
            goal: goal,
            pastGoals: pastGoals,
            logs: logsByDay.values.sorted { $0.day < $1.day }
        ))
    }
}

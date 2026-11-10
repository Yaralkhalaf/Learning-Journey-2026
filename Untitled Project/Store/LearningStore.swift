import Foundation
import Observation

/// The single source of truth for the app. Views read from it and call its intents.
@Observable
final class LearningStore {
    private(set) var goal: LearningGoal?
    private(set) var now: Date

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
        self.persistence = persistence
        self.calendar = calendar
        self.seedsMockHistory = seedsMockHistory
        self.clock = clock
        self.goal = data.goal
        self.now = clock()
        self.logsByDay = Dictionary(data.logs.map { ($0.day, $0) }, uniquingKeysWith: { first, _ in first })
    }

    // MARK: - Derived state

    /// Onboarding is shown only until the first goal is created.
    var hasOnboarded: Bool { goal != nil }

    var logs: [DayLog] {
        logsByDay.values.sorted { $0.day < $1.day }
    }

    var snapshot: ProgressSnapshot? {
        guard let goal else { return nil }
        return ProgressCalculator(calendar: calendar).snapshot(goal: goal, logs: logs, now: now)
    }

    var today: Date { calendar.startOfDay(for: now) }

    func status(on day: Date) -> DayStatus? {
        logsByDay[calendar.startOfDay(for: day)]?.status
    }

    // MARK: - Intents

    /// Called once from onboarding.
    func startJourney(subject: String, period: GoalPeriod) {
        refreshDate()
        if seedsMockHistory && logsByDay.isEmpty {
            for log in MockData.previousMonthsHistory(before: today, calendar: calendar) {
                logsByDay[log.day] = log
            }
        }
        setGoal(subject: subject, period: period)
    }

    /// Replaces the current goal. The streak starts over from today.
    func setGoal(subject: String, period: GoalPeriod) {
        refreshDate()
        goal = LearningGoal(
            subject: subject.trimmingCharacters(in: .whitespacesAndNewlines),
            period: period,
            startDate: now
        )
        save()
    }

    func logToday(as status: DayStatus) {
        refreshDate()
        guard let snapshot else { return }
        let isAllowed = status == .learned ? snapshot.canLogLearned : snapshot.canFreeze
        guard isAllowed else { return }

        logsByDay[today] = DayLog(day: today, status: status, loggedAt: now)
        save()
    }

    /// Re-reads the clock, e.g. when the app becomes active or the day changes at midnight.
    func refreshDate() {
        now = clock()
    }

    private func save() {
        persistence.save(LearningData(goal: goal, logs: logs))
    }
}

import Foundation
import Observation

/// Destinations reachable from the Activity page.
enum ActivityRoute: Hashable {
    case calendar
    case editGoal
    case newGoal
}

/// Task 2 — the main screen: this week, streak counters and today's logging actions.
@Observable
final class ActivityViewModel {
    var path: [ActivityRoute] = []

    private let store: LearningStore

    init(store: LearningStore) {
        self.store = store
    }

    private var snapshot: ProgressSnapshot? { store.snapshot }
    private var calendar: Calendar { store.calendar }

    // MARK: - Header

    var hasGoal: Bool { snapshot != nil }
    var today: Date { store.now }

    // MARK: - This week

    var weekDays: [CalendarDay] {
        guard let week = calendar.dateInterval(of: .weekOfYear, for: store.now) else { return [] }
        return (0..<7).compactMap { offset in
            guard let date = calendar.date(byAdding: .day, value: offset, to: week.start) else { return nil }
            return CalendarDay(
                date: date,
                status: store.status(on: date),
                isToday: calendar.isDate(date, inSameDayAs: store.now)
            )
        }
    }

    // MARK: - Streak

    var learnedCount: Int { snapshot?.learnedCount ?? 0 }
    var freezedCount: Int { snapshot?.freezedCount ?? 0 }

    // MARK: - Today's actions

    var goalState: GoalState { snapshot?.goalState ?? .inProgress }
    var todayStatus: DayStatus? { snapshot?.todayStatus }
    var canLogLearned: Bool { snapshot?.canLogLearned ?? false }
    var canFreeze: Bool { snapshot?.canFreeze ?? false }

    var learnedButtonTitle: String {
        todayStatus == .learned ? "Logged as Learned" : "Log as Learned"
    }

    var freezeButtonTitle: String {
        todayStatus == .freezed ? "Freezed for a day" : "Freeze for a day"
    }

    var freezesUsedText: String {
        guard let snapshot else { return "" }
        return "\(snapshot.freezesUsed) out of \(snapshot.freezeLimit) Freezes used"
    }

    func logLearned() {
        store.logToday(as: .learned)
    }

    func freezeToday() {
        store.logToday(as: .freezed)
    }

    // MARK: - Navigation

    func showCalendar() { path.append(.calendar) }
    func editGoal() { path.append(.editGoal) }
    func setNewGoal() { path.append(.newGoal) }

    /// "Set same learning goal and duration" — starts the same goal again from today.
    func repeatGoal() {
        guard let goal = store.goal else { return }
        store.setGoal(subject: goal.subject, period: goal.period)
    }

    func makeGoalEditorViewModel(for route: ActivityRoute) -> GoalEditorViewModel {
        // Editing a running goal resets the streak, so it needs confirmation.
        let requiresConfirmation = route == .editGoal && goalState == .inProgress
        return GoalEditorViewModel(store: store, requiresConfirmation: requiresConfirmation)
    }

    func makeCalendarViewModel() -> CalendarViewModel {
        CalendarViewModel(store: store)
    }
}

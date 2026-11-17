import Foundation

/// One day as shown on screen: its date, how it was logged, and whether it is today.
struct CalendarDay: Identifiable, Hashable {
    let date: Date
    let status: DayStatus?
    var isToday = false
    /// True when the day can be tapped to show its details (it was logged or had a goal).
    var isSelectable = false

    var id: Date { date }
}

/// What the calendar shows when a day is tapped.
struct DayDetails {
    let date: Date
    let status: DayStatus?
    /// The goal that was running that day, if any.
    let goal: LearningGoal?
    /// First and last day the goal actually ran (it ends early if it was replaced).
    let goalFirstDay: Date?
    let goalLastDay: Date?
}

import Foundation

/// One day as shown on screen: its date, how it was logged, and whether it is today.
struct CalendarDay: Identifiable, Hashable {
    let date: Date
    let status: DayStatus?
    var isToday = false

    var id: Date { date }
}

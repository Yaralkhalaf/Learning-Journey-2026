import Foundation
import Observation

/// One month of the calendar, ready to draw as a 7-column grid.
struct CalendarMonth: Identifiable {
    let start: Date
    /// Empty cells before day 1, so day 1 sits under the right weekday.
    let leadingBlanks: Int
    let days: [CalendarDay]

    var id: Date { start }
}

/// Task 5 — every month since the app was installed.
/// Tapping a logged day shows which goal it belonged to and how long that goal was.
@Observable
final class CalendarViewModel {
    /// The day whose details are showing, if any.
    var selectedDate: Date?

    private let store: LearningStore

    init(store: LearningStore) {
        self.store = store
    }

    private var calendar: Calendar { store.calendar }

    // MARK: - Day details

    func details(for date: Date) -> DayDetails {
        let goal = store.goal(on: date)
        let firstDay = goal?.firstDay(in: calendar)
        var lastDay: Date?

        if let goal, let firstDay {
            // A goal ends at its period's end, or earlier if the learner set a new goal.
            let allGoals = store.pastGoals + (store.goal.map { [$0] } ?? [])
            let nextStart = allGoals
                .map { $0.firstDay(in: calendar) }
                .filter { $0 > firstDay }
                .min()
            let end = min(goal.endDate(in: calendar), nextStart ?? .distantFuture)
            lastDay = calendar.date(byAdding: .day, value: -1, to: end)
        }

        return DayDetails(
            date: date,
            status: store.status(on: date),
            goal: goal,
            goalFirstDay: firstDay,
            goalLastDay: lastDay
        )
    }

    /// "SUN MON …" rotated to match the calendar's first weekday.
    var weekdaySymbols: [String] {
        let symbols = calendar.shortWeekdaySymbols.map { $0.uppercased() }
        let shift = calendar.firstWeekday - 1
        return Array(symbols[shift...] + symbols[..<shift])
    }

    /// From the month the app was installed up to the current month.
    var months: [CalendarMonth] {
        guard let current = calendar.dateInterval(of: .month, for: store.now)?.start else { return [] }
        let installMonth = calendar.dateInterval(of: .month, for: store.installDate)?.start ?? current
        var month = min(installMonth, current)

        var result: [CalendarMonth] = []
        while month <= current {
            result.append(makeMonth(startingAt: month))
            guard let next = calendar.date(byAdding: .month, value: 1, to: month) else { break }
            month = next
        }
        return result
    }

    private func makeMonth(startingAt start: Date) -> CalendarMonth {
        let range = calendar.range(of: .day, in: .month, for: start) ?? 1..<1
        let days = range.compactMap { number -> CalendarDay? in
            guard let date = calendar.date(byAdding: .day, value: number - 1, to: start) else { return nil }
            let status = store.status(on: date)
            let isPast = date <= store.today
            return CalendarDay(
                date: date,
                status: status,
                isSelectable: isPast && (status != nil || store.goal(on: date) != nil)
            )
        }
        let weekday = calendar.component(.weekday, from: start)
        let leadingBlanks = (weekday - calendar.firstWeekday + 7) % 7
        return CalendarMonth(start: start, leadingBlanks: leadingBlanks, days: days)
    }
}

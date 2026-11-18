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

    /// Calendar step 8: builds what the popover shows for a tapped day —
    /// how it was logged, which goal was running, and the dates that goal ran.
    func details(for date: Date) -> DayDetails {
        // Ask the store which goal was running on this day.
        let goal = store.goal(on: date)

        return DayDetails(
            date: date,
            status: store.status(on: date),
            goal: goal,
            goalFirstDay: goal?.firstDay(in: calendar),
            // The store knows when a goal ended (its period's end, or earlier if a new goal replaced it).
            goalLastDay: goal.flatMap(store.lastDay(of:))
        )
    }

    /// "SUN MON …" rotated to match the calendar's first weekday.
    var weekdaySymbols: [String] {
        let symbols = calendar.shortWeekdaySymbols.map { $0.uppercased() }
        let shift = calendar.firstWeekday - 1
        return Array(symbols[shift...] + symbols[..<shift])
    }

    /// The months the calendar shows: from the month the app was installed up to the current month.
    var months: [CalendarMonth] {
        // The first day of this month, and of the month the app was installed.
        guard let current = calendar.dateInterval(of: .month, for: store.now)?.start else { return [] }
        let installMonth = calendar.dateInterval(of: .month, for: store.installDate)?.start ?? current
        var month = min(installMonth, current)

        // Add one month at a time until we reach the current month.
        var result: [CalendarMonth] = []
        while month <= current {
            result.append(makeMonth(startingAt: month))
            guard let next = calendar.date(byAdding: .month, value: 1, to: month) else { break }
            month = next
        }
        return result
    }

    /// Builds one month: every day with its color (learned / freezed / none) and whether it can be tapped.
    private func makeMonth(startingAt start: Date) -> CalendarMonth {
        // How many days this month has (28–31).
        let range = calendar.range(of: .day, in: .month, for: start) ?? 1..<1
        let days = range.compactMap { number -> CalendarDay? in
            guard let date = calendar.date(byAdding: .day, value: number - 1, to: start) else { return nil }
            let status = store.status(on: date)
            let isPast = date <= store.today
            return CalendarDay(
                date: date,
                status: status,
                // Only past days that were logged or had a goal can be tapped.
                isSelectable: isPast && (status != nil || store.goal(on: date) != nil)
            )
        }
        // How many empty cells go before day 1 (e.g. a month starting on Wednesday needs 3).
        let weekday = calendar.component(.weekday, from: start)
        let leadingBlanks = (weekday - calendar.firstWeekday + 7) % 7
        return CalendarMonth(start: start, leadingBlanks: leadingBlanks, days: days)
    }
}

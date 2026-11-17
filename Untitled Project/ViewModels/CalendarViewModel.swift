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

/// Task 5 — every month since the app was installed. View only.
@Observable
final class CalendarViewModel {
    private let store: LearningStore

    init(store: LearningStore) {
        self.store = store
    }

    private var calendar: Calendar { store.calendar }

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
            return CalendarDay(date: date, status: store.status(on: date))
        }
        let weekday = calendar.component(.weekday, from: start)
        let leadingBlanks = (weekday - calendar.firstWeekday + 7) % 7
        return CalendarMonth(start: start, leadingBlanks: leadingBlanks, days: days)
    }
}

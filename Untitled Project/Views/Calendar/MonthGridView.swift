import SwiftUI

/// One month laid out as a 7-column grid, starting on the calendar's first weekday.
struct MonthGridView: View {
    @Environment(LearningStore.self) private var store
    let month: Date

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 0), count: 7)

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(month, format: .dateTime.month(.wide).year())
                .font(.title3.weight(.semibold))
                .padding(.horizontal, 8)

            LazyVGrid(columns: columns, spacing: 8) {
                ForEach(weekdaySymbols, id: \.self) { symbol in
                    Text(symbol)
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(.secondary)
                }
                ForEach(0..<leadingBlanks, id: \.self) { _ in
                    Color.clear.frame(height: Theme.dayCircleSize)
                }
                ForEach(days, id: \.self) { day in
                    DayCircle(day: day, status: store.status(on: day))
                }
            }
        }
        .padding(.vertical, 16)
    }

    private var calendar: Calendar { store.calendar }

    private var days: [Date] {
        guard let range = calendar.range(of: .day, in: .month, for: month) else { return [] }
        return range.compactMap { calendar.date(byAdding: .day, value: $0 - 1, to: month) }
    }

    private var leadingBlanks: Int {
        let weekday = calendar.component(.weekday, from: month)
        return (weekday - calendar.firstWeekday + 7) % 7
    }

    /// "SUN MON …" rotated to match the calendar's first weekday.
    private var weekdaySymbols: [String] {
        let symbols = calendar.shortWeekdaySymbols.map { $0.uppercased() }
        let shift = calendar.firstWeekday - 1
        return Array(symbols[shift...] + symbols[..<shift])
    }
}

#Preview {
    MonthGridView(month: Calendar.current.dateInterval(of: .month, for: .now)!.start)
        .environment(MockData.previewStore())
}

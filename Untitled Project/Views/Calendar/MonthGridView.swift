import SwiftUI

/// One month laid out as a 7-column grid, starting on the calendar's first weekday.
struct MonthGridView: View {
    let month: CalendarMonth
    let weekdaySymbols: [String]

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 0), count: 7)

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(month.start, format: .dateTime.month(.wide).year())
                .font(.body.weight(.semibold))
                .frame(height: 22)
                .padding(.horizontal, 8)

            LazyVGrid(columns: columns, spacing: 7) {
                ForEach(weekdaySymbols, id: \.self) { symbol in
                    Text(symbol)
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(.secondary)
                        .frame(height: 18)
                }
                ForEach(0..<month.leadingBlanks, id: \.self) { _ in
                    Color.clear.frame(height: Theme.dayCircleSize)
                }
                ForEach(month.days) { day in
                    DayCircle(day: day)
                }
            }
        }
        .padding(.vertical, 16)
    }
}

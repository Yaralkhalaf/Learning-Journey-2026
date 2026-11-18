import SwiftUI

/// One month laid out as a 7-column grid, starting on the calendar's first weekday.
/// Logged days can be tapped to see their goal.
struct MonthGridView: View {
    let month: CalendarMonth
    let weekdaySymbols: [String]
    @Binding var selectedDate: Date?
    let details: (Date) -> DayDetails

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 0), count: 7)

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(month.start, format: .dateTime.month(.wide).year())
                .font(.body.weight(.semibold))
                .frame(height: 22)
                .padding(.horizontal, 8)

            LazyVGrid(columns: columns, spacing: 7) {
                // The first row: SUN MON TUE …
                ForEach(weekdaySymbols, id: \.self) { symbol in
                    Text(symbol)
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(.secondary)
                        .frame(height: 18)
                }
                // Empty cells, so day 1 lands under the right weekday.
                ForEach(0..<month.leadingBlanks, id: \.self) { _ in
                    Color.clear.frame(height: Theme.dayCircleSize)
                }
                // Calendar step 6: one circle per day of the month.
                ForEach(month.days) { day in
                    if day.isSelectable {
                        // A past day that was logged or had a goal: tapping it remembers the day…
                        Button { selectedDate = day.date } label: { DayCircle(day: day) }
                            .buttonStyle(.plain)
                            // Calendar step 7: …and opens a popover above it with the day's details.
                            .popover(isPresented: isShowing(day)) {
                                DayDetailsView(details: details(day.date))
                                    .presentationCompactAdaptation(.popover) // stay a small bubble on iPhone
                            }
                            .accessibilityHint("Shows the goal for this day")
                    } else {
                        // Future days and days with nothing: just the number, not tappable.
                        DayCircle(day: day)
                    }
                }
            }
        }
        .padding(.vertical, 16)
    }

    /// True while this day's popover is open; closing it clears the selection.
    private func isShowing(_ day: CalendarDay) -> Binding<Bool> {
        Binding(
            get: { selectedDate == day.date },
            set: { if !$0 { selectedDate = nil } }
        )
    }
}

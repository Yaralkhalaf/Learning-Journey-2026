import SwiftUI

/// The current week (Sun…Sat), with each day colored by its log.
struct WeekStripView: View {
    let days: [CalendarDay]

    var body: some View {
        HStack(spacing: 0) {
            ForEach(days) { day in
                VStack(spacing: 4) {
                    Text(day.date, format: .dateTime.weekday(.narrow))
                        .font(.footnote.weight(.semibold))
                        .frame(height: 18)
                    DayCircle(day: day)
                }
                .frame(maxWidth: .infinity)
            }
        }
    }
}

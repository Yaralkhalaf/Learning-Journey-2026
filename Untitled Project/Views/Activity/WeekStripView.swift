import SwiftUI

/// The current week (Sun…Sat), with each day colored by its log.
struct WeekStripView: View {
    @Environment(LearningStore.self) private var store

    var body: some View {
        HStack(spacing: 0) {
            ForEach(weekDays, id: \.self) { day in
                VStack(spacing: 6) {
                    Text(day, format: .dateTime.weekday(.narrow))
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.secondary)
                    DayCircle(
                        day: day,
                        status: store.status(on: day),
                        isToday: store.calendar.isDate(day, inSameDayAs: store.now)
                    )
                }
                .frame(maxWidth: .infinity)
            }
        }
    }

    private var weekDays: [Date] {
        let calendar = store.calendar
        guard let week = calendar.dateInterval(of: .weekOfYear, for: store.now) else { return [] }
        return (0..<7).compactMap { calendar.date(byAdding: .day, value: $0, to: week.start) }
    }
}

#Preview {
    WeekStripView()
        .padding()
        .environment(MockData.previewStore())
}

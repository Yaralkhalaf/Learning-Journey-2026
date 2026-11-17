import SwiftUI

/// A day number inside a circle, colored by how the day was logged.
/// Matches the design's date states: Default, Current (logged) and Current and Selected (today).
struct DayCircle: View {
    let day: CalendarDay

    var body: some View {
        Text(day.date, format: .dateTime.day())
            .font(.title3.weight(weight))
            .monospacedDigit()
            .foregroundStyle(foreground)
            .frame(width: Theme.dayCircleSize, height: Theme.dayCircleSize)
            .background(background, in: .circle)
            .accessibilityLabel(accessibilityText)
    }

    private var weight: Font.Weight {
        if day.status != nil { return .medium }
        return day.isToday ? .bold : .regular
    }

    private var foreground: Color {
        if let status = day.status { return status.tint }
        return day.isToday ? .white : .primary
    }

    private var background: Color {
        if let status = day.status { return status.tint.opacity(Theme.dayTintOpacity) }
        return day.isToday ? .learnedOrange : .clear
    }

    private var accessibilityText: String {
        let date = day.date.formatted(.dateTime.weekday(.wide).day().month(.wide))
        switch day.status {
        case .learned: return "\(date), learned"
        case .freezed: return "\(date), freezed"
        case nil: return date
        }
    }
}

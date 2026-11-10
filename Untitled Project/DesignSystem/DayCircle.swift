import SwiftUI

/// A day number inside a circle, colored by how the day was logged.
struct DayCircle: View {
    let day: Date
    let status: DayStatus?
    var isToday = false

    var body: some View {
        Text(day, format: .dateTime.day())
            .font(.title3.weight(isToday ? .semibold : .regular))
            .monospacedDigit()
            .foregroundStyle(foreground)
            .frame(width: Theme.dayCircleSize, height: Theme.dayCircleSize)
            .background(background, in: .circle)
            .accessibilityLabel(accessibilityText)
    }

    private var foreground: Color {
        if let status { return status.tint }
        return isToday ? .white : .primary
    }

    private var background: Color {
        if let status { return status.tint.opacity(0.2) }
        return isToday ? .learnedOrange : .clear
    }

    private var accessibilityText: String {
        let date = day.formatted(.dateTime.weekday(.wide).day().month(.wide))
        switch status {
        case .learned: return "\(date), learned"
        case .freezed: return "\(date), freezed"
        case nil: return date
        }
    }
}

#Preview {
    HStack {
        DayCircle(day: .now, status: .learned)
        DayCircle(day: .now, status: .freezed)
        DayCircle(day: .now, status: nil, isToday: true)
        DayCircle(day: .now, status: nil)
    }
}

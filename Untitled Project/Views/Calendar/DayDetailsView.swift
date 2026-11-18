import SwiftUI

/// The small popover shown when a calendar day is tapped:
/// how the day was logged, the goal's name, and how long that goal was.
struct DayDetailsView: View {
    let details: DayDetails

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // The tapped day, e.g. "Wednesday, 14 October".
            Text(details.date, format: .dateTime.weekday(.wide).day().month(.wide))
                .font(.subheadline)
                .foregroundStyle(.secondary)

            // How the day was logged: 🔥 Learned (orange) or ❄️ Freezed (blue). Hidden if not logged.
            if let status = details.status {
                Label(status == .learned ? "Learned" : "Freezed",
                      systemImage: status == .learned ? "flame.fill" : "snowflake")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(status.tint)
            }

            Divider()

            if let goal = details.goal {
                VStack(alignment: .leading, spacing: 4) {
                    // The goal's name the learner typed, e.g. "Swift".
                    Text(goal.subject)
                        .font(.title3.bold())
                    // How long the goal was: "Week goal", "Month goal" or "Year goal".
                    Text("\(goal.period.title) goal")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.learnedOrange)
                    // The dates the goal really ran, e.g. "10 Oct – 16 Oct 2026".
                    if let first = details.goalFirstDay, let last = details.goalLastDay {
                        Text("\(first.formatted(.dateTime.day().month())) – \(last.formatted(.dateTime.day().month().year()))")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }
            } else {
                // A logged day with no goal running (rare, e.g. very old data).
                Text("No goal on this day")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(20)
        .frame(minWidth: 220, alignment: .leading)
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    DayDetailsView(details: DayDetails(
        date: .now,
        status: .learned,
        goal: LearningGoal(subject: "Swift", period: .month, startDate: .now),
        goalFirstDay: .now,
        goalLastDay: .now.addingTimeInterval(29 * 86_400)
    ))
}

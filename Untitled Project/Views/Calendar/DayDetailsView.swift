import SwiftUI

/// The small popover shown when a calendar day is tapped:
/// how the day was logged, the goal's name, and how long that goal was.
struct DayDetailsView: View {
    let details: DayDetails

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(details.date, format: .dateTime.weekday(.wide).day().month(.wide))
                .font(.subheadline)
                .foregroundStyle(.secondary)

            if let status = details.status {
                Label(status == .learned ? "Learned" : "Freezed",
                      systemImage: status == .learned ? "flame.fill" : "snowflake")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(status.tint)
            }

            Divider()

            if let goal = details.goal {
                VStack(alignment: .leading, spacing: 4) {
                    Text(goal.subject)
                        .font(.title3.bold())
                    Text("\(goal.period.title) goal")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.learnedOrange)
                    if let first = details.goalFirstDay, let last = details.goalLastDay {
                        Text("\(first.formatted(.dateTime.day().month())) – \(last.formatted(.dateTime.day().month().year()))")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }
            } else {
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

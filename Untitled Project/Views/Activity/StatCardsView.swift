import SwiftUI

/// "4 days Learned" and "1 day Freezed" — counts for the current streak.
struct StatCardsView: View {
    let snapshot: ProgressSnapshot

    var body: some View {
        GlassEffectContainer {
            HStack(spacing: 14) {
                StatCard(icon: "flame.fill", tint: .learnedOrange, count: snapshot.learnedCount, label: "Learned")
                StatCard(icon: "snowflake", tint: .freezeBlue, count: snapshot.freezedCount, label: "Freezed")
            }
        }
    }
}

private struct StatCard: View {
    let icon: String
    let tint: Color
    let count: Int
    let label: String

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(tint)
                .accessibilityHidden(true)
            Text(count.daysText)
                .font(.title3.weight(.semibold))
                .contentTransition(.numericText())
            Text(label)
                .font(.footnote)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 18)
        .glassEffect(.regular, in: .rect(cornerRadius: Theme.cardCornerRadius))
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    StatCardsView(snapshot: ProgressSnapshot(
        learnedCount: 4, freezedCount: 1, freezesUsed: 1, freezeLimit: 2,
        todayStatus: nil, goalState: .inProgress, daysLeft: 3
    ))
    .padding()
}

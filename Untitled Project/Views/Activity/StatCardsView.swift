import SwiftUI

/// "4 days Learned" and "1 day Freezed" — counts for the current streak.
struct StatCardsView: View {
    let learnedCount: Int
    let freezedCount: Int

    var body: some View {
        GlassEffectContainer {
            HStack(spacing: 12) {
                StatCard(icon: "flame.fill", tint: .learnedOrange, count: learnedCount, label: "Learned")
                StatCard(icon: "snowflake", tint: .freezeBlue, count: freezedCount, label: "Freezed")
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
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 15, weight: .bold))
                .foregroundStyle(tint)
                .frame(height: 25)
                .accessibilityHidden(true)
            VStack(spacing: 4) {
                Text(count.daysText)
                    .font(.callout.weight(.semibold))
                    .contentTransition(.numericText())
                Text(label)
                    .font(.caption)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: Theme.cardHeight)
        .glassEffect(.regular, in: .rect(cornerRadius: Theme.cardCornerRadius))
        .accessibilityElement(children: .combine)
    }
}

import SwiftUI

/// Task 3 — shown when the goal period ends: completed or not met.
struct GoalOutcomeView: View {
    let state: GoalState
    let onNewGoal: () -> Void
    let onRepeat: () -> Void

    var body: some View {
        VStack(spacing: 40) {
            VStack(spacing: 8) {
                Image(systemName: isCompleted ? "hands.clap.fill" : "xmark.seal")
                    .font(.system(size: 44))
                    .foregroundStyle(.learnedOrange)
                    .symbolEffect(.bounce, value: state)
                    .padding(.bottom, 8)
                    .accessibilityHidden(true)

                Text(isCompleted ? "Well done!" : "You didn't reach your goal this time.")
                    .font(.headline)
                Text(isCompleted ? "Ready for your next goal?" : "Want to set another goal?")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .multilineTextAlignment(.center)

            VStack(spacing: 16) {
                Button("Set a goal", systemImage: "pencil.and.outline", action: onNewGoal)
                    .font(.title3.weight(.medium))
                    .buttonStyle(.glassProminent)
                    .controlSize(.large)
                    .tint(.learnedOrange)

                Button("Set same learning goal and duration", action: onRepeat)
                    .font(.subheadline)
                    .tint(.learnedOrange)
            }
        }
        .padding(.top, 48)
    }

    private var isCompleted: Bool { state == .completed }
}

#Preview("Completed") {
    GoalOutcomeView(state: .completed, onNewGoal: {}, onRepeat: {})
}

#Preview("Not met") {
    GoalOutcomeView(state: .notMet, onNewGoal: {}, onRepeat: {})
}

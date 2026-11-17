import SwiftUI

/// Task 3 — shown when the goal period ends: completed or not met.
struct GoalOutcomeView: View {
    let state: GoalState
    let onNewGoal: () -> Void
    let onRepeat: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            Image(systemName: isCompleted ? "hands.clap.fill" : "xmark.seal")
                .font(.system(size: 40))
                .foregroundStyle(.learnedOrange)
                .symbolEffect(.bounce, value: state)
                .frame(height: 51)
                .accessibilityHidden(true)

            VStack(spacing: 0) {
                Text(isCompleted ? "Well done!" : "You didn't reach your goal this time.")
                    .font(.callout.bold())
                Text(isCompleted ? "Ready for your next goal?" : "Want to set another goal?")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(.secondary)
                    .frame(minHeight: 28)
            }
            .multilineTextAlignment(.center)
            .padding(.top, 20)

            GlassCapsuleButton(title: "Set a goal", systemImage: "pencil.and.outline", height: 50, action: onNewGoal)
                .padding(.top, 64)

            // Task 3 in the design notes: "Set new/same task when the goal gets completed".
            Button("Set same learning goal and duration", action: onRepeat)
                .font(.subheadline)
                .tint(.learnedOrange)
                .padding(.top, 16)
        }
    }

    private var isCompleted: Bool { state == .completed }
}

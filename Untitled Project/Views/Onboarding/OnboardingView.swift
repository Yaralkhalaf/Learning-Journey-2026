import SwiftUI

/// Task 1 — the first screen. Shown only once, until the first goal is set.
struct OnboardingView: View {
    @Environment(LearningStore.self) private var store

    @State private var subject = ""
    @State private var period: GoalPeriod = .week

    private var canStart: Bool {
        !subject.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 32) {
                Image(systemName: "flame.fill")
                    .font(.system(size: 36))
                    .foregroundStyle(.learnedOrange)
                    .frame(width: 109, height: 109)
                    .glassEffect(.regular.tint(.learnedOrange.opacity(0.15)), in: .circle)
                    .frame(maxWidth: .infinity)
                    .padding(.top, 32)
                    .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: 4) {
                    Text("Hello **Learner**")
                        .font(.largeTitle)
                    Text("This app will help you learn everyday!")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                }

                GoalFormFields(subject: $subject, period: $period)
            }
            .padding(.horizontal, Theme.screenPadding)
        }
        .scrollDismissesKeyboard(.interactively)
        .safeAreaInset(edge: .bottom) {
            VStack(spacing: 12) {
                Button("Start Learning") {
                    store.startJourney(subject: subject, period: period)
                }
                .font(.title3.weight(.medium))
                .buttonStyle(.glassProminent)
                .controlSize(.large)
                .tint(.learnedOrange)
                .disabled(!canStart)

                Text("You can edit your desire later")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            .padding(.bottom, 8)
        }
    }
}

#Preview {
    OnboardingView()
        .environment(LearningStore(persistence: InMemoryPersistence()))
}

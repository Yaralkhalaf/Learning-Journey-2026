import SwiftUI

/// Task 1 — the first screen. Shown only once, until the first goal is set.
struct OnboardingView: View {
    @State private var viewModel: OnboardingViewModel

    init(viewModel: OnboardingViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                Image(systemName: "flame.fill")
                    .font(.system(size: 36, weight: .bold))
                    .foregroundStyle(.learnedOrange)
                    .frame(maxWidth: .infinity)
                    .padding(.top, 57)
                    .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: 4) {
                    Text("Hello **Learner**")
                        .font(.largeTitle)
                    Text("This app will help you learn everyday!")
                        .font(.body)
                        .foregroundStyle(.secondary)
                }
                .padding(.top, 80)

                GoalFormFields(subject: $viewModel.subject, period: $viewModel.period)
                    .padding(.top, 28)
            }
            .padding(.horizontal, Theme.screenPadding)
        }
        .scrollDismissesKeyboard(.interactively)
        .safeAreaInset(edge: .bottom) {
            VStack(spacing: 12) {
                // Always orange, as in the design; `start()` ignores taps until a subject is typed.
                GlassCapsuleButton(title: "Start Learning", action: viewModel.start)

                Text("You can edit your desire later")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(.bottom, 13)
        }
        // The keyboard covers the button instead of pushing it over the chips.
        .ignoresSafeArea(.keyboard, edges: .bottom)
    }
}

#Preview {
    OnboardingView(viewModel: OnboardingViewModel(store: LearningStore(persistence: InMemoryPersistence())))
}

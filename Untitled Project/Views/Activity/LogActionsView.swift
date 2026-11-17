import SwiftUI

/// Task 2 — log today as learned or freezed.
/// Both buttons are disabled once today is logged; Freeze is also disabled when no freezes are left.
struct LogActionsView: View {
    let viewModel: ActivityViewModel

    var body: some View {
        VStack(spacing: 0) {
            Button {
                withAnimation { viewModel.logLearned() }
            } label: {
                Text(viewModel.learnedButtonTitle)
                    .font(.body.bold())
                    .multilineTextAlignment(.center)
                    .foregroundStyle(isLearnedToday ? AnyShapeStyle(.secondary) : AnyShapeStyle(.white))
                    .frame(width: Theme.logButtonSize, height: Theme.logButtonSize)
                    .contentShape(.circle)
            }
            .buttonStyle(.plain)
            // Orange until today is logged as learned (a freezed day keeps the orange look, as in the design).
            .glassEffect(isLearnedToday ? .regular : .regular.tint(.learnedOrange).interactive(), in: .circle)
            // Block taps without the system's faded look, so a freezed day keeps the design's white label.
            .allowsHitTesting(viewModel.canLogLearned)
            .accessibilityAddTraits(viewModel.canLogLearned ? [] : .isStaticText)
            .sensoryFeedback(.success, trigger: viewModel.todayStatus)

            GlassCapsuleButton(
                title: viewModel.freezeButtonTitle,
                tint: .freezeBlue,
                width: Theme.wideButtonWidth,
                isEnabled: viewModel.canFreeze
            ) {
                withAnimation { viewModel.freezeToday() }
            }
            .padding(.top, 48)

            Text(viewModel.freezesUsedText)
                .font(.system(size: 14))
                .foregroundStyle(.secondary)
                .contentTransition(.numericText())
                .padding(.top, 16)
        }
    }

    private var isLearnedToday: Bool { viewModel.todayStatus == .learned }
}

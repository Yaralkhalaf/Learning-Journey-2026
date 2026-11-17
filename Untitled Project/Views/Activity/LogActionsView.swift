import SwiftUI

/// Task 2 — log today as learned or freezed.
/// The chosen button is disabled; tapping the other one switches today's log (to fix a wrong tap).
/// Freeze is also disabled when no freezes are left.
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
            // Orange until today is logged as learned. A freezed day stays orange (as in the design)
            // because tapping it switches the day to learned.
            .glassEffect(isLearnedToday ? .regular : .regular.tint(.learnedOrange).interactive(), in: .circle)
            // Block taps once today is learned, without the system's faded look on the label.
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

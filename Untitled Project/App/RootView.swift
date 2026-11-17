import SwiftUI

/// Shows onboarding the first time, then the Activity page forever after.
/// Keeps the clock fresh so buttons re-enable at midnight.
struct RootView: View {
    @State private var viewModel: RootViewModel
    @Environment(\.scenePhase) private var scenePhase

    init(viewModel: RootViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        Group {
            if viewModel.hasOnboarded {
                ActivityView(viewModel: viewModel.makeActivityViewModel())
            } else {
                OnboardingView(viewModel: viewModel.makeOnboardingViewModel())
            }
        }
        .animation(.default, value: viewModel.hasOnboarded)
        .onChange(of: scenePhase) { _, phase in
            if phase == .active { viewModel.refreshDate() }
        }
        .onReceive(NotificationCenter.default.publisher(for: .NSCalendarDayChanged)) { _ in
            viewModel.refreshDate()
        }
        .task {
            // Also tick every minute while open, so the 32-hour rule is applied on time.
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(60))
                viewModel.refreshDate()
            }
        }
    }
}

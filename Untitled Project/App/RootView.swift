import SwiftUI

/// Shows onboarding the first time, then the Activity page forever after.
/// Keeps the store's clock fresh so buttons re-enable at midnight.
struct RootView: View {
    @Environment(LearningStore.self) private var store
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        Group {
            if store.hasOnboarded {
                ActivityView()
            } else {
                OnboardingView()
            }
        }
        .animation(.default, value: store.hasOnboarded)
        .onChange(of: scenePhase) { _, phase in
            if phase == .active { store.refreshDate() }
        }
        .onReceive(NotificationCenter.default.publisher(for: .NSCalendarDayChanged)) { _ in
            store.refreshDate()
        }
        .task {
            // Also tick every minute while open, so the 32-hour rule is applied on time.
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(60))
                store.refreshDate()
            }
        }
    }
}

#Preview("Onboarding") {
    RootView().environment(LearningStore(persistence: InMemoryPersistence()))
}

#Preview("Activity") {
    RootView().environment(MockData.previewStore())
}

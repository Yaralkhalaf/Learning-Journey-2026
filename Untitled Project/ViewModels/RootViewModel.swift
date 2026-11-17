import Foundation
import Observation

/// Decides which screen the app starts on and keeps the clock fresh.
@Observable
final class RootViewModel {
    private let store: LearningStore

    init(store: LearningStore) {
        self.store = store
    }

    /// Onboarding is shown only until the first goal is created.
    var hasOnboarded: Bool { store.hasOnboarded }

    /// Called when the app becomes active, at midnight, and every minute while open.
    func refreshDate() {
        store.refreshDate()
    }

    func makeOnboardingViewModel() -> OnboardingViewModel {
        OnboardingViewModel(store: store)
    }

    func makeActivityViewModel() -> ActivityViewModel {
        ActivityViewModel(store: store)
    }
}

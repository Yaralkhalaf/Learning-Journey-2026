import Foundation
import Observation

/// Task 1 — holds what the learner types on the first screen.
@Observable
final class OnboardingViewModel {
    var subject = ""
    var period: GoalPeriod = .week

    private let store: LearningStore

    init(store: LearningStore) {
        self.store = store
    }

    var canStart: Bool {
        !subject.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    func start() {
        guard canStart else { return }
        store.startJourney(subject: subject, period: period)
    }
}

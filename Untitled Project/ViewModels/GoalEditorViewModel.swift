import Foundation
import Observation

/// Tasks 3 & 4 — change the learning goal, or set a new one after the previous goal ended.
@Observable
final class GoalEditorViewModel {
    var subject: String
    var period: GoalPeriod
    var isConfirmingUpdate = false
    /// Becomes true after saving, so the view knows to close.
    private(set) var isFinished = false

    /// While a goal is in progress, changing it resets the streak and needs confirmation.
    let requiresConfirmation: Bool

    private let originalGoal: LearningGoal?
    private let store: LearningStore

    init(store: LearningStore, requiresConfirmation: Bool) {
        self.store = store
        self.requiresConfirmation = requiresConfirmation
        originalGoal = store.goal
        subject = store.goal?.subject ?? ""
        period = store.goal?.period ?? .week
    }

    private var trimmedSubject: String {
        subject.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var hasChanges: Bool {
        guard let originalGoal else { return true }
        return trimmedSubject != originalGoal.subject || period != originalGoal.period
    }

    var canSave: Bool { !trimmedSubject.isEmpty }

    /// The checkmark button (always orange, as in the design).
    /// - Nothing changed on a running goal: just close, the streak is kept.
    /// - Something changed on a running goal: ask first, because the streak starts over.
    /// - The goal has ended: save straight away (this also allows "same goal again").
    func saveTapped() {
        guard canSave else { return }
        if requiresConfirmation && !hasChanges {
            isFinished = true
        } else if requiresConfirmation {
            isConfirmingUpdate = true
        } else {
            save()
        }
    }

    func save() {
        guard canSave else { return }
        store.setGoal(subject: trimmedSubject, period: period)
        isFinished = true
    }
}

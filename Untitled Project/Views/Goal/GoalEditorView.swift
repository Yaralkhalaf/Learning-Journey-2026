import SwiftUI

/// Tasks 3 & 4 — change the learning goal, or set a new one after the previous goal ended.
struct GoalEditorView: View {
    @Environment(LearningStore.self) private var store
    @Environment(\.dismiss) private var dismiss

    @State private var subject: String
    @State private var period: GoalPeriod
    @State private var isConfirmingUpdate = false

    private let originalGoal: LearningGoal?
    /// While a goal is in progress, changing it resets the streak and needs confirmation.
    private let requiresConfirmation: Bool

    init(goal: LearningGoal?, requiresConfirmation: Bool) {
        originalGoal = goal
        self.requiresConfirmation = requiresConfirmation
        _subject = State(initialValue: goal?.subject ?? "")
        _period = State(initialValue: goal?.period ?? .week)
    }

    private var trimmedSubject: String {
        subject.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var hasChanges: Bool {
        guard let originalGoal else { return true }
        return trimmedSubject != originalGoal.subject || period != originalGoal.period
    }

    /// After a goal ends the learner may also restart the same goal, so "no changes" is fine there.
    private var canSave: Bool {
        !trimmedSubject.isEmpty && (hasChanges || !requiresConfirmation)
    }

    var body: some View {
        ScrollView {
            GoalFormFields(subject: $subject, period: $period)
                .padding(.horizontal, Theme.screenPadding)
                .padding(.top, 24)
        }
        .scrollDismissesKeyboard(.interactively)
        .navigationTitle("Learning Goal")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Save", systemImage: "checkmark", action: confirm)
                    .buttonStyle(.glassProminent)
                    .tint(.learnedOrange)
                    .disabled(!canSave)
            }
        }
        .alert("Update goal", isPresented: $isConfirmingUpdate) {
            Button("Dismiss", role: .cancel) {}
            Button("Update", action: save)
        } message: {
            Text("If you update now, your streak will start over.")
        }
    }

    private func confirm() {
        if requiresConfirmation {
            isConfirmingUpdate = true
        } else {
            save()
        }
    }

    private func save() {
        store.setGoal(subject: trimmedSubject, period: period)
        dismiss()
    }
}

#Preview {
    NavigationStack {
        GoalEditorView(goal: LearningGoal(subject: "Swift", period: .week, startDate: .now), requiresConfirmation: true)
    }
    .environment(MockData.previewStore())
}

import SwiftUI

/// Tasks 3 & 4 — change the learning goal, or set a new one after the previous goal ended.
struct GoalEditorView: View {
    @State private var viewModel: GoalEditorViewModel
    @Environment(\.dismiss) private var dismiss

    init(viewModel: GoalEditorViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        ScrollView {
            GoalFormFields(subject: $viewModel.subject, period: $viewModel.period)
                .padding(.horizontal, Theme.screenPadding)
                .padding(.top, 24)
        }
        .scrollDismissesKeyboard(.interactively)
        .navigationTitle("Learning Goal")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Save", systemImage: "checkmark", action: viewModel.saveTapped)
                    .buttonStyle(.glassProminent)
                    .tint(.learnedOrange)
                    .disabled(!viewModel.canSave)
            }
        }
        .alert("Update goal", isPresented: $viewModel.isConfirmingUpdate) {
            Button("Dismiss", role: .cancel) {}
            // The default button is drawn in the accent color (orange), as in the design.
            Button("Update", action: viewModel.save)
                .keyboardShortcut(.defaultAction)
        } message: {
            Text("If you update now, your streak will start over.")
        }
        .onChange(of: viewModel.isFinished) { _, isFinished in
            if isFinished { dismiss() }
        }
    }
}

#Preview {
    NavigationStack {
        GoalEditorView(viewModel: GoalEditorViewModel(store: MockData.previewStore(), requiresConfirmation: true))
    }
}

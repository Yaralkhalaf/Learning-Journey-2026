import SwiftUI

/// Task 2 — log today as learned or freezed.
/// Both buttons are disabled once today is logged; Freeze is also disabled when no freezes are left.
struct LogActionsView: View {
    @Environment(LearningStore.self) private var store
    let snapshot: ProgressSnapshot

    var body: some View {
        VStack(spacing: 32) {
            Button {
                withAnimation { store.logToday(as: .learned) }
            } label: {
                Text(learnedTitle)
                    .font(.title2.weight(.bold))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(learnedForeground)
                    .frame(width: Theme.logButtonSize, height: Theme.logButtonSize)
                    .contentShape(.circle)
            }
            .buttonStyle(.plain)
            .glassEffect(learnedGlass, in: .circle)
            .disabled(!snapshot.canLogLearned)
            .sensoryFeedback(.success, trigger: snapshot.todayStatus)

            VStack(spacing: 12) {
                Button {
                    withAnimation { store.logToday(as: .freezed) }
                } label: {
                    Text(snapshot.todayStatus == .freezed ? "Freezed for a day" : "Freeze for a day")
                        .font(.title3.weight(.medium))
                        .frame(width: Theme.wideButtonWidth - 32, height: 32)
                }
                .buttonStyle(.glassProminent)
                .controlSize(.large)
                .tint(snapshot.canFreeze ? .freezeBlue : .secondary.opacity(0.3))
                .disabled(!snapshot.canFreeze)

                Text("\(snapshot.freezesUsed) out of \(snapshot.freezeLimit) Freezes used")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .contentTransition(.numericText())
            }
        }
        .padding(.top, 8)
    }

    private var learnedTitle: String {
        switch snapshot.todayStatus {
        case .learned: "Logged as Learned"
        case .freezed: "Day Freezed"
        case nil: "Log as Learned"
        }
    }

    private var learnedForeground: Color {
        switch snapshot.todayStatus {
        case .learned: .secondary
        case .freezed: .freezeBlue
        case nil: .white
        }
    }

    private var learnedGlass: Glass {
        switch snapshot.todayStatus {
        case .learned: .regular
        case .freezed: .regular.tint(.freezeBlue.opacity(0.2))
        case nil: .regular.tint(.learnedOrange).interactive()
        }
    }
}

#Preview("Not logged") {
    let store = MockData.previewStore()
    LogActionsView(snapshot: store.snapshot!).environment(store)
}

#Preview("Freezed") {
    let store = MockData.previewStore(today: .freezed)
    LogActionsView(snapshot: store.snapshot!).environment(store)
}

import SwiftUI

/// Destinations reachable from the Activity page.
enum ActivityRoute: Hashable {
    case calendar
    case editGoal
    case newGoal
}

/// The main screen: this week, streak counters and today's logging actions.
struct ActivityView: View {
    @Environment(LearningStore.self) private var store
    @State private var path: [ActivityRoute] = []

    var body: some View {
        NavigationStack(path: $path) {
            ScrollView {
                if let goal = store.goal, let snapshot = store.snapshot {
                    VStack(spacing: 24) {
                        GoalHeader(goal: goal, snapshot: snapshot)
                        WeekStripView()
                        StatCardsView(snapshot: snapshot)

                        if snapshot.goalState == .inProgress {
                            LogActionsView(snapshot: snapshot)
                        } else {
                            GoalOutcomeView(state: snapshot.goalState) {
                                path.append(.newGoal)
                            } onRepeat: {
                                store.setGoal(subject: goal.subject, period: goal.period)
                            }
                        }
                    }
                    .padding(.horizontal, Theme.screenPadding)
                    .padding(.bottom, 24)
                }
            }
            .navigationTitle("Activity")
            .navigationSubtitle(Text(store.now, format: .dateTime.weekday(.wide).day().month(.wide)))
            .toolbar {
                ToolbarItemGroup(placement: .primaryAction) {
                    Button("Activities calendar", systemImage: "calendar") {
                        path.append(.calendar)
                    }
                    Button("Learning goal", systemImage: "pencil.and.outline") {
                        path.append(.editGoal)
                    }
                }
            }
            .navigationDestination(for: ActivityRoute.self) { route in
                switch route {
                case .calendar:
                    ActivitiesCalendarView()
                case .editGoal:
                    GoalEditorView(goal: store.goal, requiresConfirmation: store.snapshot?.goalState == .inProgress)
                case .newGoal:
                    GoalEditorView(goal: store.goal, requiresConfirmation: false)
                }
            }
        }
    }
}

/// Shows which goal the learner is working on (the name they typed in onboarding).
private struct GoalHeader: View {
    let goal: LearningGoal
    let snapshot: ProgressSnapshot

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: "target")
            Text("Learning **\(goal.subject)**")
            Spacer()
            Text(detail)
                .foregroundStyle(Color.secondary)
        }
        .font(.subheadline)
        .foregroundStyle(.learnedOrange)
        .accessibilityElement(children: .combine)
    }

    private var detail: String {
        switch snapshot.goalState {
        case .inProgress: "\(snapshot.daysLeft.daysText) left this \(goal.period.title.lowercased())"
        case .completed, .notMet: "\(goal.period.title) ended"
        }
    }
}

#Preview("In progress") {
    ActivityView().environment(MockData.previewStore())
}

#Preview("Learned today") {
    ActivityView().environment(MockData.previewStore(today: .learned))
}

#Preview("Goal ended") {
    ActivityView().environment(MockData.previewStore(period: .week, goalStartedDaysAgo: 7))
}

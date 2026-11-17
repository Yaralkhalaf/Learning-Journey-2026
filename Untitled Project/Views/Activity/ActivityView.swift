import SwiftUI

/// Task 2 — the main screen: this week, streak counters and today's logging actions.
struct ActivityView: View {
    @State private var viewModel: ActivityViewModel

    init(viewModel: ActivityViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        NavigationStack(path: $viewModel.path) {
            ScrollView {
                VStack(spacing: 0) {
                    ActivityHeader(
                        date: viewModel.today,
                        onCalendar: viewModel.showCalendar,
                        onEditGoal: viewModel.editGoal
                    )

                    if viewModel.hasGoal {
                        WeekStripView(days: viewModel.weekDays)
                            .padding(.top, 15)

                        StatCardsView(learnedCount: viewModel.learnedCount, freezedCount: viewModel.freezedCount)
                            .padding(.top, 12)

                        if viewModel.goalState == .inProgress {
                            LogActionsView(viewModel: viewModel)
                                .padding(.top, 48)
                        } else {
                            GoalOutcomeView(
                                state: viewModel.goalState,
                                onNewGoal: viewModel.setNewGoal,
                                onRepeat: viewModel.repeatGoal
                            )
                            .padding(.top, 64)
                        }
                    }
                }
                .padding(.horizontal, Theme.contentPadding)
                .padding(.bottom, 24)
            }
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(for: ActivityRoute.self) { route in
                switch route {
                case .calendar:
                    ActivitiesCalendarView(viewModel: viewModel.makeCalendarViewModel())
                case .editGoal, .newGoal:
                    GoalEditorView(viewModel: viewModel.makeGoalEditorViewModel(for: route))
                }
            }
        }
    }
}

/// "Activity" + today's date on the left, calendar and goal buttons on the right.
private struct ActivityHeader: View {
    let date: Date
    let onCalendar: () -> Void
    let onEditGoal: () -> Void

    var body: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 2) {
                Text("Activity")
                    .font(.largeTitle.bold())
                    .accessibilityAddTraits(.isHeader)
                Text(date, format: .dateTime.weekday(.wide).day().month(.wide))
                    .font(.body)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            HStack(spacing: 12) {
                GlassCircleButton(title: "Activities calendar", systemImage: "calendar", action: onCalendar)
                GlassCircleButton(title: "Learning goal", systemImage: "pencil.and.outline", action: onEditGoal)
            }
        }
        .padding(.leading, 2)
    }
}

#Preview {
    ActivityView(viewModel: ActivityViewModel(store: MockData.previewStore()))
}

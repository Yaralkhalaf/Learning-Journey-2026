import SwiftUI

/// Task 5 — every month since the app was installed. Tap a logged day to see its goal.
struct ActivitiesCalendarView: View {
    @State private var viewModel: CalendarViewModel

    init(viewModel: CalendarViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 0) {
                ForEach(viewModel.months) { month in
                    MonthGridView(
                        month: month,
                        weekdaySymbols: viewModel.weekdaySymbols,
                        selectedDate: $viewModel.selectedDate,
                        details: viewModel.details(for:)
                    )
                    Divider()
                }
            }
            .padding(.horizontal, 12)
        }
        // Open on the current month (older months are above it), but keep short content at the top.
        .defaultScrollAnchor(.bottom, for: .initialOffset)
        .defaultScrollAnchor(.top, for: .alignment)
        .navigationTitle("Activities")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        ActivitiesCalendarView(viewModel: CalendarViewModel(store: MockData.previewStore()))
    }
}

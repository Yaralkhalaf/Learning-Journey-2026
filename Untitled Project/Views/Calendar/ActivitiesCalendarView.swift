import SwiftUI

/// Task 5 — every month with logged days. View only: no interaction with the days.
struct ActivitiesCalendarView: View {
    @Environment(LearningStore.self) private var store

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 0) {
                ForEach(months, id: \.self) { month in
                    MonthGridView(month: month)
                    Divider()
                }
            }
            .padding(.horizontal, 12)
        }
        // Open on the current month; older months are above it.
        .defaultScrollAnchor(.bottom)
        .safeAreaInset(edge: .top) {
            YearSummaryView()
        }
        .navigationTitle("Activities")
        .navigationBarTitleDisplayMode(.inline)
    }

    /// From the first logged month (or the current one) up to the current month.
    private var months: [Date] {
        let calendar = store.calendar
        guard let current = calendar.dateInterval(of: .month, for: store.now)?.start else { return [] }
        let firstLogged = store.logs.first.flatMap { calendar.dateInterval(of: .month, for: $0.day)?.start }
        var month = min(firstLogged ?? current, current)

        var result: [Date] = []
        while month <= current {
            result.append(month)
            guard let next = calendar.date(byAdding: .month, value: 1, to: month) else { break }
            month = next
        }
        return result
    }
}

/// Totals for the current year, across all goals (the streak resets, these don't).
private struct YearSummaryView: View {
    @Environment(LearningStore.self) private var store

    var body: some View {
        let yearLogs = store.logs.filter { store.calendar.isDate($0.day, equalTo: store.now, toGranularity: .year) }
        let learned = yearLogs.count { $0.status == .learned }
        let freezed = yearLogs.count { $0.status == .freezed }

        HStack(spacing: 16) {
            Text(store.now, format: .dateTime.year())
                .font(.headline)
            Spacer()
            Label(learned.daysText, systemImage: "flame.fill")
                .foregroundStyle(.learnedOrange)
            Label(freezed.daysText, systemImage: "snowflake")
                .foregroundStyle(.freezeBlue)
        }
        .font(.subheadline.weight(.semibold))
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .glassEffect(.regular, in: .capsule)
        .padding(.horizontal, Theme.screenPadding)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("This year: \(learned.daysText) learned, \(freezed.daysText) freezed")
    }
}

#Preview {
    NavigationStack {
        ActivitiesCalendarView()
    }
    .environment(MockData.previewStore())
}

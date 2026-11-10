import SwiftUI

/// "I want to learn …" + "I want to learn it in a …". Shared by onboarding and the goal editor.
struct GoalFormFields: View {
    @Binding var subject: String
    @Binding var period: GoalPeriod

    @FocusState private var isSubjectFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 32) {
            VStack(alignment: .leading, spacing: 12) {
                Text("I want to learn")
                    .font(.title3)

                TextField("Swift", text: $subject)
                    .font(.title3)
                    .focused($isSubjectFocused)
                    .submitLabel(.done)
                    .autocorrectionDisabled()

                Divider()
            }

            VStack(alignment: .leading, spacing: 12) {
                Text("I want to learn it in a")
                    .font(.title3)

                GlassEffectContainer {
                    HStack(spacing: 8) {
                        ForEach(GoalPeriod.allCases) { option in
                            PeriodChip(title: option.title, isSelected: option == period) {
                                period = option
                                isSubjectFocused = false
                            }
                        }
                    }
                }
            }
        }
    }
}

private struct PeriodChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.headline.weight(isSelected ? .semibold : .regular))
                .foregroundStyle(isSelected ? .white : .secondary)
                .frame(width: 70, height: 32)
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .glassEffect(isSelected ? .regular.tint(.learnedOrange).interactive() : .regular.interactive(), in: .capsule)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

#Preview {
    @Previewable @State var subject = ""
    @Previewable @State var period = GoalPeriod.week
    GoalFormFields(subject: $subject, period: $period)
        .padding()
}

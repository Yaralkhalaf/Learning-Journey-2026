import SwiftUI

/// "I want to learn …" + "I want to learn it in a …". Shared by onboarding and the goal editor.
struct GoalFormFields: View {
    @Binding var subject: String
    @Binding var period: GoalPeriod

    @FocusState private var isSubjectFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("I want to learn")
                .font(.callout)

            TextField("Swift", text: $subject)
                .font(.body.weight(.medium))
                .focused($isSubjectFocused)
                .submitLabel(.done)
                .autocorrectionDisabled()
                .frame(height: 47)
                .padding(.top, 5)

            Divider()

            Text("I want to learn it in a")
                .font(.callout)
                .padding(.top, 30)

            GlassEffectContainer {
                HStack(spacing: 12) {
                    ForEach(GoalPeriod.allCases) { option in
                        PeriodChip(title: option.title, isSelected: option == period) {
                            period = option
                            isSubjectFocused = false
                        }
                    }
                }
            }
            .padding(.top, 13)
        }
    }
}

/// Week / Month / Year. The selected one is orange glass; the others are plain glass.
private struct PeriodChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.body.weight(.medium))
                .foregroundStyle(isSelected ? AnyShapeStyle(.white) : AnyShapeStyle(.tertiary))
                .padding(.horizontal, 20)
                .frame(height: Theme.buttonHeight)
                .contentShape(.capsule)
        }
        .buttonStyle(.plain)
        .glassEffect(isSelected ? .regular.tint(.learnedOrange).interactive() : .regular.interactive(), in: .capsule)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

import SwiftUI

/// The capsule "Glass Prominent" button from the design: tinted when enabled,
/// plain glass with a faded label when disabled.
struct GlassCapsuleButton: View {
    let title: String
    var systemImage: String?
    var tint: Color = .learnedOrange
    var width: CGFloat?
    var height: CGFloat = Theme.buttonHeight
    var isEnabled = true
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                if let systemImage {
                    Image(systemName: systemImage)
                }
                Text(title)
            }
            .font(.body.weight(.medium))
            .foregroundStyle(isEnabled ? AnyShapeStyle(.white) : AnyShapeStyle(.tertiary))
            .padding(.horizontal, 20)
            .frame(width: width, height: height)
            .contentShape(.capsule)
        }
        .buttonStyle(.plain)
        .glassEffect(isEnabled ? .regular.tint(tint).interactive() : .regular, in: .capsule)
        .disabled(!isEnabled)
    }
}

/// The round glass toolbar button from the design (calendar, pencil, back).
struct GlassCircleButton: View {
    let title: String
    let systemImage: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.system(size: 19, weight: .medium))
                .foregroundStyle(.primary)
                .frame(width: Theme.toolbarButtonSize, height: Theme.toolbarButtonSize)
                .contentShape(.circle)
        }
        .buttonStyle(.plain)
        .glassEffect(.regular.interactive(), in: .circle)
        .accessibilityLabel(title)
    }
}

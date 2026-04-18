import SwiftUI

struct CardView<Content: View>: View {
    @ViewBuilder let content: Content

    private static let cornerRadius: CGFloat = 14
    private static let shadowRadius: CGFloat = 8
    private static let shadowOpacity: Double = 0.08
    private static let shadowYOffset: CGFloat = 3
    private static let backgroundOpacity: Double = 0.68

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.medium) {
            content
        }
        .padding(Spacing.medium)
        .background(AppDesign.card.opacity(Self.backgroundOpacity))
        .clipShape(RoundedRectangle(cornerRadius: Self.cornerRadius, style: .continuous))
        .shadow(
            color: .black.opacity(Self.shadowOpacity),
            radius: Self.shadowRadius,
            x: 0,
            y: Self.shadowYOffset
        )
    }
}

#Preview {
    AppBackground {
        CardView {
            Text("Sample Card")
                .font(TextStyles.subtitle)
                .foregroundStyle(AppDesign.text)

            Text("Reusable shared surface style")
                .font(TextStyles.body)
                .foregroundStyle(AppDesign.muted)
        }
        .padding(Spacing.large)
    }
}

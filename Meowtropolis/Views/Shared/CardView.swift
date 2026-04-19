import SwiftUI
import Combine

struct CardView<Content: View>: View {
    @ViewBuilder let content: Content

    private static var cornerRadius: CGFloat { 14 }
    private static var shadowRadius: CGFloat { 8 }
    private static var shadowOpacity: Double { 0.08 }
    private static var shadowYOffset: CGFloat { 3 }
    private static var backgroundOpacity: Double { 0.68 }

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

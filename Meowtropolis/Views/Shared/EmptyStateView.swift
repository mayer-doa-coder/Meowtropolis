import SwiftUI

struct EmptyStateView: View {
    var icon: String? = "tray"
    var title: String = "No data available"
    var message: String? = nil

    var body: some View {
        CardView {
            VStack(spacing: Spacing.small) {
                if let icon {
                    Image(systemName: icon)
                        .font(.system(size: 28, weight: .semibold))
                        .foregroundStyle(AppDesign.muted)
                }

                Text(title)
                    .accessibilityIdentifier("emptyStateTitle")
                    .font(TextStyles.subtitle)
                    .foregroundStyle(AppDesign.text)
                    .multilineTextAlignment(.center)

                if let message, !message.isEmpty {
                    Text(message)
                        .accessibilityIdentifier("emptyStateMessage")
                        .font(TextStyles.body)
                        .foregroundStyle(AppDesign.muted)
                        .multilineTextAlignment(.center)
                }
            }
            .frame(maxWidth: .infinity, alignment: .center)
        }
        .accessibilityIdentifier("emptyStateView")
    }
}

#Preview {
    AppBackground {
        EmptyStateView(
            icon: "pawprint",
            title: "No pets found",
            message: "Add your first pet to continue."
        )
        .padding(Spacing.large)
    }
}

import SwiftUI

struct ErrorStateView: View {
    var title: String = "Something went wrong"
    var message: String
    var retryTitle: String = "Retry"
    var retryAccessibilityIdentifier: String? = nil
    var onRetry: (() -> Void)? = nil

    var body: some View {
        CardView {
            VStack(spacing: Spacing.small) {
                Image(systemName: "exclamationmark.triangle")
                    .font(.system(size: 26, weight: .semibold))
                    .foregroundStyle(.red)

                Text(title)
                    .font(TextStyles.subtitle)
                    .foregroundStyle(AppDesign.text)
                    .multilineTextAlignment(.center)

                Text(message)
                    .font(TextStyles.body)
                    .foregroundStyle(AppDesign.muted)
                    .multilineTextAlignment(.center)

                if let onRetry {
                    Button(retryTitle) {
                        print("[UI] Error block triggered")
                        onRetry()
                    }
                    .accessibilityIdentifier(retryAccessibilityIdentifier ?? "errorStateRetryButton")
                    .buttonStyle(FilledPrimaryButtonStyle())
                    .padding(.top, Spacing.small)
                }
            }
            .frame(maxWidth: .infinity, alignment: .center)
        }
        .accessibilityIdentifier("errorStateView")
    }
}

#Preview {
    AppBackground {
        ErrorStateView(
            message: "We could not load your data right now.",
            onRetry: {}
        )
        .padding(Spacing.large)
    }
}

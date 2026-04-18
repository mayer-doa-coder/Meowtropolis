import SwiftUI

struct LoadingBlockView: View {
    var message: String = "Loading..."

    var body: some View {
        CardView {
            VStack(spacing: Spacing.small) {
                ProgressView()

                if !message.isEmpty {
                    Text(message)
                        .font(TextStyles.body)
                        .foregroundStyle(AppDesign.muted)
                        .multilineTextAlignment(.center)
                }
            }
            .frame(maxWidth: .infinity, alignment: .center)
        }
        .accessibilityIdentifier("loadingBlockView")
    }
}

#Preview {
    AppBackground {
        LoadingBlockView(message: "Loading nearby places...")
            .padding(Spacing.large)
    }
}

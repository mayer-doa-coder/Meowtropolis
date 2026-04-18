import SwiftUI

struct DividerWithText: View {
    var text: String

    var body: some View {
        HStack(spacing: Spacing.small) {
            line
            Text(text)
                .font(TextStyles.caption)
                .foregroundStyle(AppDesign.muted)
            line
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Spacing.small)
    }

    private var line: some View {
        Rectangle()
            .fill(AppDesign.line)
            .frame(height: 1)
    }
}

#Preview {
    AppBackground {
        DividerWithText(text: "OR")
            .padding(Spacing.large)
    }
}

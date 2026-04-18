import SwiftUI

struct AppPlaceholderImageView: View {
    var cornerRadius: CGFloat = 12
    var iconSize: CGFloat = 28
    var tint: Color = AppDesign.muted

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(Color.gray.opacity(0.18))

            Image(systemName: "photo.fill")
                .font(.system(size: iconSize, weight: .semibold))
                .foregroundStyle(tint)
        }
    }
}

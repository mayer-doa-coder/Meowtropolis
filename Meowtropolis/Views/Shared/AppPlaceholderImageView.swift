import SwiftUI

struct AppPlaceholderImageView: View {
    var assetName: String? = nil
    var cornerRadius: CGFloat = 12
    var iconSize: CGFloat = 28
    var tint: Color = AppDesign.muted

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(Color.gray.opacity(0.18))

            if let assetName, !assetName.isEmpty {
                Image(assetName)
                    .resizable()
                    .scaledToFit()
                    .clipped()
                    .padding(4)
            } else {
                Image(systemName: "photo.fill")
                    .font(.system(size: iconSize, weight: .semibold))
                    .foregroundStyle(tint)
            }
        }
    }
}

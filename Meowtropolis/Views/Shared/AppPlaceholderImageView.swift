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

            if let resolvedAssetName = AppImageLibrary.resolveExistingAssetName(from: assetName) {
                Image(resolvedAssetName)
                    .resizable()
                    .scaledToFit()
                    .clipped()
                    .padding(4)
            } else {
                Image(AppImageLibrary.userAvatarAssetName)
                    .resizable()
                    .scaledToFit()
                    .clipped()
                    .padding(4)
            }
        }
    }
}

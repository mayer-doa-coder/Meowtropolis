import SwiftUI

struct RelatedProductsView: View {
    @EnvironmentObject private var cartState: CartState

    let products: [Product]
    let language: AppLanguage
    let onTapProduct: (Product) -> Void

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 10) {
                ForEach(products, id: \.id) { product in
                    NavigationLink(destination: ProductDetailView(product: product)) {
                        RelatedProductCard(product: product, language: language)
                    }
                    .buttonStyle(.plain)
                    .simultaneousGesture(
                        TapGesture().onEnded {
                            onTapProduct(product)
                        }
                    )
                }
            }
            .padding(.vertical, 4)
        }
    }
}

private struct RelatedProductCard: View {
    let product: Product
    let language: AppLanguage

    var body: some View {
        CardView {
            VStack(alignment: .leading, spacing: 8) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.gray.opacity(0.4))

                    AppPlaceholderImageView(
                        assetName: AppImageLibrary.productImageAssetName(for: product),
                        cornerRadius: 10,
                        iconSize: 20
                    )
                }
                .frame(width: 140, height: 92)
                .clipShape(RoundedRectangle(cornerRadius: 10))

                Text(product.name)
                    .font(TextStyles.caption)
                    .foregroundStyle(AppDesign.text)
                    .lineLimit(2)

                Text(language.formatMoney(product.price))
                    .font(TextStyles.body)
                    .foregroundStyle(AppDesign.primary)
            }
            .frame(width: 140, alignment: .leading)
        }
    }
}

#Preview {
    NavigationStack {
        RelatedProductsView(
            products: [
                Product(id: "preview_related_001", name: "Related Cat Food", price: 320, category: "cat", imageURL: "")
            ],
            language: .englishUS,
            onTapProduct: { _ in }
        )
        .environmentObject(CartState())
    }
}

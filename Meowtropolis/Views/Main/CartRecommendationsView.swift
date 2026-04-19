import SwiftUI

struct CartRecommendationsView: View {
    @EnvironmentObject private var cartState: CartState

    let products: [Product]
    let language: AppLanguage
    let onTapProduct: (Product) -> Void

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 10) {
                ForEach(products, id: \.id) { product in
                    VStack(spacing: 8) {
                        NavigationLink(destination: ProductDetailView(product: product)) {
                            CartRecommendationCard(product: product, language: language)
                        }
                        .buttonStyle(.plain)
                        .simultaneousGesture(
                            TapGesture().onEnded {
                                onTapProduct(product)
                            }
                        )

                        Button(product.stock > 0 ? localizedAddLabel : localizedOutOfStockLabel) {
                            cartState.addToCart(product: product)
                        }
                        .font(TextStyles.caption)
                        .buttonStyle(FilledPrimaryButtonStyle(disabled: product.stock <= 0))
                        .disabled(product.stock <= 0)
                        .frame(width: 132)
                    }
                }
            }
            .padding(.vertical, 4)
        }
    }

    private var localizedAddLabel: String {
        language.text(english: "Quick Add", bangla: "দ্রুত যোগ করুন")
    }

    private var localizedOutOfStockLabel: String {
        language.text(english: "Out of Stock", bangla: "স্টক শেষ")
    }
}

private struct CartRecommendationCard: View {
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
                .frame(width: 132, height: 88)
                .clipShape(RoundedRectangle(cornerRadius: 10))

                Text(product.name)
                    .font(TextStyles.caption)
                    .foregroundStyle(AppDesign.text)
                    .lineLimit(2)

                Text(language.formatMoney(product.price))
                    .font(TextStyles.body)
                    .foregroundStyle(AppDesign.primary)
            }
            .frame(width: 132, alignment: .leading)
        }
    }
}

#Preview {
    NavigationStack {
        CartRecommendationsView(
            products: [
                Product(id: "preview_reco_001", name: "Related Cat Treat", price: 220, category: "cat", imageURL: "", animalType: "cat", brand: "Preview", isFeatured: false)
            ],
            language: .englishUS,
            onTapProduct: { _ in }
        )
        .environmentObject(CartState())
    }
}

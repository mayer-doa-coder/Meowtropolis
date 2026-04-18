import SwiftUI

struct ProductDetailView: View {
    @EnvironmentObject private var cartState: CartState
    @AppStorage(AppLanguage.storageKey) private var appLanguageCode: String = AppLanguage.englishUS.rawValue

    let product: Product
    @State private var quantity: Int = 1
    @State private var successMessage: String?

    var body: some View {
        AppBackground {
            ScrollView {
                VStack(spacing: Spacing.medium) {
                    RoundedRectangle(cornerRadius: 28)
                        .fill(Color.gray.opacity(0.45))
                        .frame(height: 280)
                        .padding(.horizontal, 20)
                        .padding(.top, 12)
                        .overlay {
                            AppPlaceholderImageView(cornerRadius: 28, iconSize: 40)
                                .clipShape(RoundedRectangle(cornerRadius: 28))
                                .padding(.horizontal, 20)
                                .padding(.top, 12)
                        }

                    CardView {
                        Text(product.name)
                            .font(TextStyles.title)
                            .foregroundStyle(AppDesign.text)

                        Text(text("Category:", "ক্যাটাগরি:") + " \(product.category.capitalized)")
                            .font(TextStyles.body)
                            .foregroundStyle(AppDesign.muted)

                        Text(currentLanguage.formatMoney(prefixEnglish: "Price:", prefixBangla: "দাম:", value: product.price))
                            .font(TextStyles.subtitle)
                            .foregroundStyle(AppDesign.primary)

                        DividerWithText(text: text("Product Details", "পণ্যের তথ্য"))

                        Text(text("Check product details and choose quantity before adding to cart.", "কার্টে যোগ করার আগে পণ্যের তথ্য দেখে পরিমাণ বেছে নিন।"))
                            .font(TextStyles.body)
                            .foregroundStyle(AppDesign.muted)
                    }
                    .padding(.horizontal, 20)

                    CardView {
                        HStack {
                            Text(text("Quantity", "পরিমাণ"))
                                .font(TextStyles.subtitle)
                                .foregroundStyle(AppDesign.text)

                            Spacer()

                            Button {
                                quantity = max(1, quantity - 1)
                                UserHistoryService.shared.recordCurrentUser(
                                    category: .shop,
                                    action: "Decreased product quantity",
                                    details: product.name
                                )
                            } label: {
                                Image(systemName: "minus")
                                    .frame(width: 28, height: 28)
                            }

                            Text(String(format: "%02d", quantity))
                                .font(.system(size: 24, weight: .medium, design: .rounded))
                                .frame(minWidth: 40)

                            Button {
                                quantity += 1
                                UserHistoryService.shared.recordCurrentUser(
                                    category: .shop,
                                    action: "Increased product quantity",
                                    details: product.name
                                )
                            } label: {
                                Image(systemName: "plus")
                                    .frame(width: 28, height: 28)
                                    .foregroundStyle(.white)
                                    .background(AppDesign.primary)
                                    .clipShape(RoundedRectangle(cornerRadius: 6))
                            }
                        }

                        if let successMessage {
                            Text(successMessage)
                                .font(TextStyles.caption)
                                .foregroundStyle(.green)
                                .accessibilityIdentifier("productDetailAddToCartSuccessMessage")
                        }

                        Button(text("Add to Cart", "কার্টে যোগ করুন")) {
                            cartState.addToCart(product: product, quantity: quantity)
                            successMessage = text("Added to cart successfully.", "কার্টে সফলভাবে যোগ করা হয়েছে।")
                            UserHistoryService.shared.recordCurrentUser(
                                category: .shop,
                                action: "Tapped add to cart",
                                details: "\(product.name) x\(quantity)"
                            )
                        }
                        .buttonStyle(FilledPrimaryButtonStyle())
                        .accessibilityIdentifier("productDetailAddToCartButton")

                        Text(text("Demo note: Checkout does not process real payments yet.", "ডেমো নোট: চেকআউট এখনো বাস্তব পেমেন্ট প্রক্রিয়া করে না।"))
                            .font(TextStyles.caption)
                            .foregroundStyle(AppDesign.muted)
                    }
                    .padding(.horizontal, 20)
                }
                .padding(.bottom, 20)
            }
        }
        .navigationTitle(text("Product", "পণ্য"))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                NavigationLink(destination: CartView()) {
                    HStack(spacing: 4) {
                        Image(systemName: "cart")
                        if cartState.totalItemCount > 0 {
                            Text("\(cartState.totalItemCount)")
                                .font(.caption)
                        }
                    }
                }
                .accessibilityIdentifier("productDetailCartButton")
                .simultaneousGesture(
                    TapGesture().onEnded {
                        UserHistoryService.shared.recordCurrentUser(
                            category: .shop,
                            action: "Opened cart from product details",
                            details: product.name
                        )
                    }
                )
            }
        }
        .onAppear {
            UserHistoryService.shared.recordCurrentUser(
                category: .shop,
                action: "Viewed product details",
                details: product.name
            )
        }
    }

    private var currentLanguage: AppLanguage {
        AppLanguage.from(code: appLanguageCode)
    }

    private func text(_ english: String, _ bangla: String) -> String {
        currentLanguage.text(english: english, bangla: bangla)
    }
}

#Preview {
    NavigationStack {
        ProductDetailView(
            product: Product(
                id: "preview_001",
                name: "Preview Cat Food",
                price: 12.99,
                category: "food",
                imageURL: ""
            )
        )
        .environmentObject(CartState())
    }
}

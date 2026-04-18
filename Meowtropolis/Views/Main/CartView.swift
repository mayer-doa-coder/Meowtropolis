import SwiftUI

struct CartView: View {
    @EnvironmentObject private var cartState: CartState
    @AppStorage(AppLanguage.storageKey) private var appLanguageCode: String = AppLanguage.englishUS.rawValue

    var body: some View {
        AppBackground {
            ScrollView {
                VStack(spacing: 12) {
                    if cartState.items.isEmpty {
                        VStack(spacing: 10) {
                            Text(text("Cart is empty", "কার্ট খালি"))
                                .font(.system(size: 24, weight: .bold, design: .rounded))
                                .foregroundStyle(AppDesign.text)
                                .accessibilityIdentifier("cartEmptyText")

                            Text(text("Add products from the store to continue.", "চালিয়ে যেতে স্টোর থেকে পণ্য যোগ করুন।"))
                                .font(.system(size: 16, weight: .regular, design: .rounded))
                                .foregroundStyle(AppDesign.muted)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.top, 30)
                    } else {
                        LazyVStack(spacing: 10) {
                            ForEach(cartState.items) { item in
                                cartRow(item)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .background(Color.white.opacity(0.65))
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                        }
                        .accessibilityIdentifier("cartItemsList")

                        summaryCard
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 16)
            }
        }
        .navigationTitle(text("My Cart", "আমার কার্ট"))
        .navigationBarTitleDisplayMode(.inline)
        .accessibilityIdentifier("cartView")
        .onAppear {
            UserHistoryService.shared.recordCurrentUser(
                category: .shop,
                action: "Opened cart"
            )
        }
    }

    private func cartRow(_ item: CartItem) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(item.name)
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .foregroundStyle(AppDesign.text)

            Text(currentLanguage.formatMoney(item.price))
                .font(.system(size: 16, weight: .regular, design: .rounded))
                .foregroundStyle(AppDesign.muted)

            Text(stockText(for: item.availableStock))
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundStyle(item.availableStock > 0 ? AppDesign.muted : .red)

            HStack {
                Stepper(
                    text("Qty:", "পরিমাণ:") + " \(item.quantity)",
                    value: bindingForQuantity(item),
                    in: 1...max(1, item.availableStock)
                )

                Spacer()

                Button(text("Remove", "অপসারণ"), role: .destructive) {
                    cartState.removeFromCart(productId: item.productId)
                }
                .font(.system(size: 14, weight: .medium, design: .rounded))
            }
        }
        .padding(.vertical, 4)
    }

    private var summaryCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(text("Cart Summary", "কার্ট সারাংশ"))
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundStyle(AppDesign.text)

            Text(text("Items:", "আইটেম:") + " \(cartState.totalItemCount)")
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundStyle(AppDesign.muted)

            Text(currentLanguage.formatMoney(prefixEnglish: "Total:", prefixBangla: "মোট:", value: cartState.totalPrice))
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundStyle(AppDesign.primary)

            NavigationLink(destination: CheckoutView()) {
                Text(text("Checkout", "চেকআউট"))
            }
            .buttonStyle(FilledPrimaryButtonStyle(disabled: cartState.items.isEmpty))
            .disabled(cartState.items.isEmpty)
            .simultaneousGesture(
                TapGesture().onEnded {
                    UserHistoryService.shared.recordCurrentUser(
                        category: .shop,
                        action: "Opened checkout"
                    )
                }
            )
        }
        .padding(14)
        .background(Color.white.opacity(0.7))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .padding(.bottom, 16)
    }

    private func bindingForQuantity(_ item: CartItem) -> Binding<Int> {
        Binding(
            get: { item.quantity },
            set: { newValue in
                cartState.updateQuantity(productId: item.productId, quantity: newValue)
            }
        )
    }

    private func stockText(for stock: Int) -> String {
        if stock <= 0 {
            return text("Out of stock", "স্টক শেষ")
        }
        return text("Stock: \(stock)", "স্টক: \(stock)")
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
        CartView()
            .environmentObject(CartState())
    }
}

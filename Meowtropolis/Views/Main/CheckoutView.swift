import SwiftUI

struct CheckoutView: View {
    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var cartState: CartState
    @Environment(\.dismiss) private var dismiss
    @AppStorage(AppLanguage.storageKey) private var appLanguageCode: String = AppLanguage.englishUS.rawValue

    @State private var showConfirmation: Bool = false
    @State private var isPlacingOrder: Bool = false
    @State private var checkoutErrorMessage: String?

    private let orderService = OrderService()

    var body: some View {
        AppBackground {
            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    Text(text("Checkout", "চেকআউট"))
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundStyle(AppDesign.text)

                    if cartState.items.isEmpty {
                        Text(text("Cart is empty", "কার্ট খালি"))
                            .font(.system(size: 18, weight: .medium, design: .rounded))
                            .foregroundStyle(AppDesign.muted)

                        Button(text("Back to Store", "স্টোরে ফিরে যান")) {
                            UserHistoryService.shared.recordCurrentUser(
                                category: .shop,
                                action: "Returned to store from checkout"
                            )
                            dismiss()
                        }
                        .buttonStyle(OutlinedPrimaryButtonStyle())
                    } else {
                        if let checkoutErrorMessage {
                            ErrorStateView(
                                title: text("Order failed.", "অর্ডার সম্পন্ন হয়নি।"),
                                message: checkoutErrorMessage,
                                messageAccessibilityIdentifier: "checkoutErrorMessage",
                                retryTitle: text("Retry", "আবার চেষ্টা করুন"),
                                retryAccessibilityIdentifier: "checkoutRetryButton",
                                onRetry: placeOrder
                            )
                        }

                        LazyVStack(spacing: 10) {
                            ForEach(cartState.items) { item in
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(item.name)
                                            .font(.system(size: 17, weight: .semibold, design: .rounded))
                                            .foregroundStyle(AppDesign.text)

                                        Text(text("Qty:", "পরিমাণ:") + " \(item.quantity)")
                                            .font(.system(size: 14, weight: .regular, design: .rounded))
                                            .foregroundStyle(AppDesign.muted)
                                    }

                                    Spacer()

                                    Text(currentLanguage.formatMoney(Double(item.quantity) * item.price))
                                        .font(.system(size: 16, weight: .bold, design: .rounded))
                                        .foregroundStyle(AppDesign.primary)
                                }
                                .padding(.vertical, 8)
                                .padding(.horizontal, 12)
                                .background(Color.white.opacity(0.65))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                        }

                        VStack(alignment: .leading, spacing: 8) {
                            Text(text("Items:", "আইটেম:") + " \(cartState.totalItemCount)")
                                .font(.system(size: 16, weight: .medium, design: .rounded))
                                .foregroundStyle(AppDesign.muted)

                            Text(currentLanguage.formatMoney(prefixEnglish: "Total:", prefixBangla: "মোট:", value: cartState.totalPrice))
                                .font(.system(size: 22, weight: .bold, design: .rounded))
                                .foregroundStyle(AppDesign.primary)

                            Button(text("Place Order", "অর্ডার দিন")) {
                                placeOrder()
                            }
                            .buttonStyle(FilledPrimaryButtonStyle(disabled: isPlacingOrder))
                            .disabled(isPlacingOrder)

                            if isPlacingOrder {
                                Text(text("Placing order...", "অর্ডার দেওয়া হচ্ছে..."))
                                    .font(TextStyles.caption)
                                    .foregroundStyle(AppDesign.muted)
                            }
                        }
                        .padding(14)
                        .background(Color.white.opacity(0.7))
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 16)
            }
        }
        .navigationTitle(text("Checkout", "চেকআউট"))
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            checkoutErrorMessage = nil
            UserHistoryService.shared.recordCurrentUser(
                category: .shop,
                action: "Opened checkout screen"
            )
        }
        .alert(text("Order Confirmation", "অর্ডার নিশ্চিতকরণ"), isPresented: $showConfirmation) {
            Button(text("Back to Store", "স্টোরে ফিরে যান")) {
                UserHistoryService.shared.recordCurrentUser(
                    category: .shop,
                    action: "Closed order confirmation"
                )
                dismiss()
            }
        } message: {
            Text(text("Order placed successfully.", "অর্ডার সফলভাবে সম্পন্ন হয়েছে।"))
        }
    }

    private func placeOrder() {
        guard !isPlacingOrder else {
            return
        }

        guard let userId = appState.currentUserId else {
            checkoutErrorMessage = text("Please log in to place your order.", "অর্ডার দিতে লগইন করুন।")
            return
        }

        let items = cartState.items
        guard !items.isEmpty else {
            checkoutErrorMessage = text("Your cart is empty.", "আপনার কার্ট খালি।")
            return
        }

        isPlacingOrder = true
        checkoutErrorMessage = nil

        orderService.placeOrder(
            userId: userId,
            cartItems: items,
            totalAmount: cartState.totalPrice,
            currencyCode: "BDT"
        ) { result in
            DispatchQueue.main.async {
                isPlacingOrder = false

                switch result {
                case let .success(order):
                    let totalItems = items.reduce(0) { $0 + $1.quantity }
                    let details: String
                    if currentLanguage == .bangla {
                        details = "\(totalItems)টি পণ্য, মোট \(String(format: "%.2f", order.totalAmount))"
                    } else {
                        details = "\(totalItems) item(s), total \(String(format: "%.2f", order.totalAmount))"
                    }
                    cartState.clearCart()
                    UserHistoryService.shared.recordCurrentUser(
                        category: .shop,
                        action: "Placed order",
                        details: details
                    )
                    showConfirmation = true
                case let .failure(error):
                    checkoutErrorMessage = localizedCheckoutError(error)
                    UserHistoryService.shared.recordCurrentUser(
                        category: .shop,
                        action: "Order placement failed",
                        details: error.localizedDescription
                    )
                }
            }
        }
    }

    private func localizedCheckoutError(_ error: Error) -> String {
        let errorDescription = error.localizedDescription.lowercased()
        if errorDescription.contains("stock") || errorDescription.contains("insufficient") {
            return text("Some items are out of stock. Please adjust your cart and try again.", "কিছু পণ্যের স্টক নেই। কার্ট ঠিক করে আবার চেষ্টা করুন।")
        }

        return text("Could not place the order right now. Please try again.", "এই মুহূর্তে অর্ডার দেওয়া যাচ্ছে না। আবার চেষ্টা করুন।")
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
        CheckoutView()
            .environmentObject(CartState())
    }
}

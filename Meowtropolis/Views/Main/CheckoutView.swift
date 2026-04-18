import SwiftUI

struct CheckoutView: View {
    @EnvironmentObject private var cartState: CartState
    @Environment(\.dismiss) private var dismiss
    @AppStorage(AppLanguage.storageKey) private var appLanguageCode: String = AppLanguage.englishUS.rawValue

    @State private var showConfirmation: Bool = false

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
                            dismiss()
                        }
                        .buttonStyle(OutlinedPrimaryButtonStyle())
                    } else {
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
                                cartState.clearCart()
                                showConfirmation = true
                            }
                            .buttonStyle(FilledPrimaryButtonStyle())
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
        .alert(text("Order Confirmation", "অর্ডার নিশ্চিতকরণ"), isPresented: $showConfirmation) {
            Button(text("Back to Store", "স্টোরে ফিরে যান")) {
                dismiss()
            }
        } message: {
            Text(text("Order placed. This is a demo confirmation.", "অর্ডার সম্পন্ন হয়েছে। এটি একটি ডেমো নিশ্চিতকরণ।"))
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
        CheckoutView()
            .environmentObject(CartState())
    }
}

import SwiftUI

struct CheckoutView: View {
    @EnvironmentObject private var cartState: CartState
    @Environment(\.dismiss) private var dismiss

    @State private var showConfirmation: Bool = false

    var body: some View {
        AppBackground {
            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    Text("Checkout (Demo)")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundStyle(AppDesign.text)

                    if cartState.items.isEmpty {
                        Text("Cart is empty")
                            .font(.system(size: 18, weight: .medium, design: .rounded))
                            .foregroundStyle(AppDesign.muted)

                        Button("Back to Store") {
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

                                        Text("Qty: \(item.quantity)")
                                            .font(.system(size: 14, weight: .regular, design: .rounded))
                                            .foregroundStyle(AppDesign.muted)
                                    }

                                    Spacer()

                                    Text(String(format: "$%.2f", Double(item.quantity) * item.price))
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
                            Text("Items: \(cartState.totalItemCount)")
                                .font(.system(size: 16, weight: .medium, design: .rounded))
                                .foregroundStyle(AppDesign.muted)

                            Text(String(format: "Total: $%.2f", cartState.totalPrice))
                                .font(.system(size: 22, weight: .bold, design: .rounded))
                                .foregroundStyle(AppDesign.primary)

                            Button("Confirm") {
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
        .navigationTitle("Checkout")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Order Confirmation", isPresented: $showConfirmation) {
            Button("Back to Store") {
                dismiss()
            }
        } message: {
            Text("Order placed successfully (demo only)")
        }
    }
}

#Preview {
    NavigationStack {
        CheckoutView()
            .environmentObject(CartState())
    }
}

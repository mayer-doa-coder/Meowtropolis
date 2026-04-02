import SwiftUI

struct CartView: View {
    @EnvironmentObject private var cartState: CartState

    var body: some View {
        AppBackground {
            VStack(spacing: 12) {
                if cartState.items.isEmpty {
                    VStack(spacing: 10) {
                        Text("Cart is empty")
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundStyle(AppDesign.text)

                        Text("Add products from the store to continue.")
                            .font(.system(size: 16, weight: .regular, design: .rounded))
                            .foregroundStyle(AppDesign.muted)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        ForEach(cartState.items) { item in
                            cartRow(item)
                        }
                    }
                    .scrollContentBackground(.hidden)
                    .background(Color.clear)

                    summaryCard
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
        }
        .navigationTitle("My Cart")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func cartRow(_ item: CartItem) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(item.name)
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .foregroundStyle(AppDesign.text)

            Text(String(format: "$%.2f", item.price))
                .font(.system(size: 16, weight: .regular, design: .rounded))
                .foregroundStyle(AppDesign.muted)

            HStack {
                Stepper("Qty: \(item.quantity)", value: bindingForQuantity(item), in: 1...99)

                Spacer()

                Button("Remove", role: .destructive) {
                    cartState.removeFromCart(productId: item.productId)
                }
                .font(.system(size: 14, weight: .medium, design: .rounded))
            }
        }
        .padding(.vertical, 4)
    }

    private var summaryCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Cart Summary")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundStyle(AppDesign.text)

            Text("Items: \(cartState.totalItemCount)")
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundStyle(AppDesign.muted)

            Text(String(format: "Total: $%.2f", cartState.totalPrice))
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundStyle(AppDesign.primary)

            NavigationLink(destination: CheckoutView()) {
                Text("Proceed to Checkout")
            }
            .buttonStyle(FilledPrimaryButtonStyle(disabled: cartState.items.isEmpty))
            .disabled(cartState.items.isEmpty)
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
}

#Preview {
    NavigationStack {
        CartView()
            .environmentObject(CartState())
    }
}

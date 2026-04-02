import SwiftUI

struct ProductDetailView: View {
    @EnvironmentObject private var cartState: CartState

    let product: Product
    @State private var quantity: Int = 1
    @State private var successMessage: String?

    var body: some View {
        AppBackground {
            VStack(spacing: 0) {
                RoundedRectangle(cornerRadius: 28)
                    .fill(Color.gray.opacity(0.45))
                    .frame(height: 280)
                    .padding(.horizontal, 20)
                    .padding(.top, 12)
                    .overlay {
                        if let url = URL(string: product.imageURL), !product.imageURL.isEmpty {
                            AsyncImage(url: url) { phase in
                                switch phase {
                                case let .success(image):
                                    image
                                        .resizable()
                                        .scaledToFill()
                                        .clipShape(RoundedRectangle(cornerRadius: 28))
                                        .padding(.horizontal, 20)
                                        .padding(.top, 12)
                                case .failure:
                                    Image(systemName: "photo")
                                        .font(.system(size: 40))
                                        .foregroundStyle(AppDesign.muted)
                                case .empty:
                                    ProgressView()
                                @unknown default:
                                    EmptyView()
                                }
                            }
                        }
                    }

                VStack(alignment: .leading, spacing: 14) {
                    Text(product.name)
                        .font(.system(size: 34, weight: .bold, design: .rounded))
                        .foregroundStyle(AppDesign.text)

                    Text("Category: \(product.category.capitalized)")
                        .font(.system(size: 17, weight: .regular, design: .rounded))
                        .foregroundStyle(AppDesign.muted)

                    Text(String(format: "Price: $%.2f", product.price))
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundStyle(AppDesign.primary)

                    Text("About")
                        .font(.system(size: 30, weight: .bold, design: .rounded))
                        .foregroundStyle(AppDesign.text)
                        .padding(.top, 8)

                    Text("This product is available in the marketplace and loaded from Firestore or local fallback data.")
                        .font(.system(size: 17, weight: .regular, design: .rounded))
                        .foregroundStyle(AppDesign.muted)

                    HStack {
                        Text("Quantity")
                            .font(.system(size: 30, weight: .bold, design: .rounded))
                            .foregroundStyle(AppDesign.text)

                        Spacer()

                        Button {
                            quantity = max(1, quantity - 1)
                        } label: {
                            Image(systemName: "minus")
                                .frame(width: 28, height: 28)
                        }

                        Text(String(format: "%02d", quantity))
                            .font(.system(size: 24, weight: .medium, design: .rounded))
                            .frame(minWidth: 40)

                        Button {
                            quantity += 1
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
                            .font(.footnote)
                            .foregroundStyle(.green)
                    }

                    Button("Add to Cart") {
                        cartState.addToCart(product: product, quantity: quantity)
                        successMessage = "Added to cart"
                    }
                    .buttonStyle(FilledPrimaryButtonStyle())

                    Text("MVP mode: checkout is demo-only and does not process real payment.")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundStyle(AppDesign.muted)
                        .padding(.top, 8)
                }
                .padding(20)

                Spacer()
            }
        }
        .navigationTitle("Product")
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
            }
        }
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

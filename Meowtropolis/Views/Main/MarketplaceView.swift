import SwiftUI

struct MarketplaceView: View {
    @EnvironmentObject private var cartState: CartState

    private let productService: ProductService

    @State private var query: String = ""
    @State private var products: [Product] = []
    @State private var isLoading: Bool = false
    @State private var errorMessage: String?

    init(productService: ProductService = ProductService()) {
        self.productService = productService
    }

    var body: some View {
        AppBackground {
            VStack(spacing: 14) {
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(AppDesign.muted)
                    TextField("Search products", text: $query)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                }
                .padding(.horizontal, 14)
                .frame(height: 44)
                .background(Color.white.opacity(0.5))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding(.horizontal, 20)

                if isLoading {
                    ProgressView("Loading products...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let errorMessage {
                    VStack(spacing: 10) {
                        Text("Could not load products")
                            .font(.system(size: 22, weight: .bold, design: .rounded))
                            .foregroundStyle(AppDesign.text)

                        Text(errorMessage)
                            .font(.system(size: 15, weight: .regular, design: .rounded))
                            .foregroundStyle(.red)
                            .multilineTextAlignment(.center)

                        Button("Try Again") {
                            loadProducts()
                        }
                        .buttonStyle(FilledPrimaryButtonStyle())
                    }
                    .padding(20)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if filteredProducts.isEmpty {
                    Text("No products available")
                        .font(.system(size: 17, weight: .medium, design: .rounded))
                        .foregroundStyle(AppDesign.muted)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        ForEach(filteredProducts, id: \.id) { product in
                            NavigationLink(destination: ProductDetailView(product: product)) {
                                productRow(product)
                            }
                            .accessibilityIdentifier("marketplaceProductRow_\(product.id)")
                        }
                    }
                    .accessibilityIdentifier("marketplaceProductList")
                    .scrollContentBackground(.hidden)
                    .background(Color.clear)
                }
            }
        }
        .navigationTitle("Store")
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
                    .foregroundStyle(AppDesign.text)
                }
                .accessibilityIdentifier("marketplaceCartButton")
            }
        }
        .task {
            loadProducts()
        }
    }

    private var filteredProducts: [Product] {
        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedQuery.isEmpty else {
            return products
        }

        return products.filter { product in
            product.name.localizedCaseInsensitiveContains(trimmedQuery)
                || product.category.localizedCaseInsensitiveContains(trimmedQuery)
        }
    }

    private func loadProducts() {
        isLoading = true
        errorMessage = nil

        productService.fetchProducts { result in
            DispatchQueue.main.async {
                isLoading = false

                switch result {
                case let .success(loadedProducts):
                    products = loadedProducts.sorted { $0.name.lowercased() < $1.name.lowercased() }
                case let .failure(error):
                    products = []
                    errorMessage = error.localizedDescription
                }
            }
        }
    }

    private func productRow(_ product: Product) -> some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.gray.opacity(0.4))

                if let imageURL = AppImageLibrary.productImageURL(for: product) {
                    AsyncImage(url: imageURL) { phase in
                        switch phase {
                        case let .success(image):
                            image
                                .resizable()
                                .scaledToFill()
                        default:
                            Image(systemName: "photo")
                                .foregroundStyle(AppDesign.muted)
                        }
                    }
                } else {
                    Image(systemName: "photo")
                        .foregroundStyle(AppDesign.muted)
                }
            }
            .frame(width: 72, height: 72)
            .clipShape(RoundedRectangle(cornerRadius: 10))

            VStack(alignment: .leading, spacing: 5) {
                Text(product.name)
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundStyle(AppDesign.text)

                Text("Category: \(product.category.capitalized)")
                    .font(.system(size: 14, weight: .regular, design: .rounded))
                    .foregroundStyle(AppDesign.muted)

                Text(String(format: "$%.2f", product.price))
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundStyle(AppDesign.primary)
            }

            Spacer()
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    NavigationStack {
        MarketplaceView()
            .environmentObject(CartState())
    }
}

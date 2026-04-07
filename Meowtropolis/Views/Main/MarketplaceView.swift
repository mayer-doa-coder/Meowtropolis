import SwiftUI

struct MarketplaceView: View {
    @EnvironmentObject private var cartState: CartState
    @AppStorage(AppLanguage.storageKey) private var appLanguageCode: String = AppLanguage.englishUS.rawValue

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
                    TextField(text("Search products", "পণ্য খুঁজুন"), text: $query)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                }
                .padding(.horizontal, 14)
                .frame(height: 44)
                .background(Color.white.opacity(0.5))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding(.horizontal, 20)

                if isLoading {
                    ProgressView(text("Loading products...", "পণ্য লোড হচ্ছে..."))
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let errorMessage {
                    VStack(spacing: 10) {
                        Text(text("Could not load products", "পণ্য লোড করা যায়নি"))
                            .font(.system(size: 22, weight: .bold, design: .rounded))
                            .foregroundStyle(AppDesign.text)

                        Text(errorMessage)
                            .font(.system(size: 15, weight: .regular, design: .rounded))
                            .foregroundStyle(.red)
                            .multilineTextAlignment(.center)

                        Button(text("Try Again", "আবার চেষ্টা করুন")) {
                            loadProducts()
                        }
                        .buttonStyle(FilledPrimaryButtonStyle())
                    }
                    .padding(20)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if filteredProducts.isEmpty {
                    Text(text("No products available", "কোনো পণ্য পাওয়া যায়নি"))
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
        .navigationTitle(text("Store", "স্টোর"))
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

                Text(text("Category:", "ক্যাটাগরি:") + " \(product.category.capitalized)")
                    .font(.system(size: 14, weight: .regular, design: .rounded))
                    .foregroundStyle(AppDesign.muted)

                Text(currentLanguage.formatMoney(product.price))
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundStyle(AppDesign.primary)
            }

            Spacer()
        }
        .padding(.vertical, 4)
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
        MarketplaceView()
            .environmentObject(CartState())
    }
}

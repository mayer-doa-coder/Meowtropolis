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
            VStack(spacing: Spacing.small) {
                CardView {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundStyle(AppDesign.muted)
                        TextField(text("Search products", "পণ্য খুঁজুন"), text: $query)
                            .accessibilityIdentifier("marketplaceSearchField")
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                    }
                    .padding(.horizontal, 4)
                    .frame(height: 44)
                }
                .padding(.horizontal, Spacing.medium)

                if isLoading {
                    LoadingBlockView(message: text("Loading products...", "পণ্যগুলো লোড হচ্ছে..."))
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let errorMessage {
                    ErrorStateView(
                        title: text("Couldn't load products.", "পণ্য লোড করা যায়নি।"),
                        message: text(
                            "Please check your internet connection. Tap Retry to try again.",
                            "দয়া করে ইন্টারনেট সংযোগ যাচাই করুন। আবার চেষ্টা করতে Retry চাপুন।"
                        ) + "\n\n" + errorMessage,
                        messageAccessibilityIdentifier: "marketplaceErrorMessage",
                        retryTitle: text("Retry", "আবার চেষ্টা করুন"),
                        retryAccessibilityIdentifier: "marketplaceRetryButton",
                        onRetry: loadProducts
                    )
                    .padding(20)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if filteredProducts.isEmpty {
                    EmptyStateView(
                        icon: "bag",
                        title: text("No products found.", "কোনো পণ্য পাওয়া যায়নি।"),
                        message: text("Try another search keyword to see available products.", "উপলব্ধ পণ্য দেখতে অন্য একটি খোঁজার শব্দ ব্যবহার করুন।")
                    )
                    .padding(.horizontal, Spacing.medium)
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
        CardView {
            HStack(spacing: Spacing.small) {
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
                        .font(TextStyles.body)
                        .foregroundStyle(AppDesign.text)

                    Text(text("Category:", "ক্যাটাগরি:") + " \(product.category.capitalized)")
                        .font(TextStyles.caption)
                        .foregroundStyle(AppDesign.muted)

                    Text(currentLanguage.formatMoney(product.price))
                        .font(TextStyles.subtitle)
                        .foregroundStyle(AppDesign.primary)
                }

                Spacer()
            }
        }
        .padding(.vertical, 2)
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

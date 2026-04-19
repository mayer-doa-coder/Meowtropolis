import SwiftUI

private enum MarketplaceSortOption: String, CaseIterable, Identifiable {
    case lowToHigh
    case highToLow

    var id: String { rawValue }
}

private enum MarketplaceAnimalFilter: String, CaseIterable, Identifiable {
    case all
    case cat
    case dog

    var id: String { rawValue }
}

struct MarketplaceView: View {
    @EnvironmentObject private var cartState: CartState
    @AppStorage(AppLanguage.storageKey) private var appLanguageCode: String = AppLanguage.englishUS.rawValue

    private let productService: ProductService

    @State private var query: String = ""
    @State private var products: [Product] = []
    @State private var isLoading: Bool = false
    @State private var errorMessage: String?
    @State private var selectedSortOption: MarketplaceSortOption = .lowToHigh
    @State private var selectedAnimalFilter: MarketplaceAnimalFilter = .all
    @State private var showInStockOnly: Bool = false
    @State private var selectedProduct: Product?

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
                            .onSubmit {
                                let cleanedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
                                guard !cleanedQuery.isEmpty else {
                                    return
                                }
                                UserHistoryService.shared.recordCurrentUser(
                                    category: .shop,
                                    action: "Submitted store search",
                                    details: cleanedQuery
                                )
                            }
                    }
                    .padding(.horizontal, 4)
                    .frame(height: 44)
                }
                .padding(.horizontal, Spacing.medium)

                CardView {
                    HStack(spacing: 12) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text(text("Sort", "সাজান"))
                                .font(TextStyles.caption)
                                .foregroundStyle(AppDesign.muted)

                            Picker("Sort", selection: $selectedSortOption) {
                                Text(text("Price: Low to High", "দাম: কম থেকে বেশি")).tag(MarketplaceSortOption.lowToHigh)
                                Text(text("Price: High to Low", "দাম: বেশি থেকে কম")).tag(MarketplaceSortOption.highToLow)
                            }
                            .pickerStyle(.menu)
                            .onChange(of: selectedSortOption) { _, option in
                                UserHistoryService.shared.recordCurrentUser(
                                    category: .shop,
                                    action: "Changed marketplace sort",
                                    details: option.rawValue
                                )
                            }
                        }

                        VStack(alignment: .leading, spacing: 6) {
                            Text(text("Pet Type", "পোষা প্রাণীর ধরন"))
                                .font(TextStyles.caption)
                                .foregroundStyle(AppDesign.muted)

                            Picker("Animal", selection: $selectedAnimalFilter) {
                                Text(text("All", "সব")).tag(MarketplaceAnimalFilter.all)
                                Text(text("Only Cat", "শুধু বিড়াল")).tag(MarketplaceAnimalFilter.cat)
                                Text(text("Only Dog", "শুধু কুকুর")).tag(MarketplaceAnimalFilter.dog)
                            }
                            .pickerStyle(.menu)
                            .onChange(of: selectedAnimalFilter) { _, filter in
                                UserHistoryService.shared.recordCurrentUser(
                                    category: .shop,
                                    action: "Changed marketplace animal filter",
                                    details: filter.rawValue
                                )
                            }
                        }

                        Toggle(isOn: $showInStockOnly) {
                            Text(text("In Stock Only", "শুধু স্টকে আছে"))
                                .font(TextStyles.caption)
                                .foregroundStyle(AppDesign.muted)
                        }
                        .toggleStyle(.switch)
                        .onChange(of: showInStockOnly) { _, enabled in
                            UserHistoryService.shared.recordCurrentUser(
                                category: .shop,
                                action: "Changed stock filter",
                                details: enabled ? "enabled" : "disabled"
                            )
                        }
                    }
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
                            "দয়া করে ইন্টারনেট সংযোগ যাচাই করুন। আবার চেষ্টা করতে পুনরায় চেষ্টা বোতাম চাপুন।"
                        ) + "\n\n" + errorMessage,
                        messageAccessibilityIdentifier: "marketplaceErrorMessage",
                        retryTitle: text("Retry", "আবার চেষ্টা করুন"),
                        retryAccessibilityIdentifier: "marketplaceRetryButton",
                        onRetry: {
                            UserHistoryService.shared.recordCurrentUser(
                                category: .shop,
                                action: "Tapped retry in marketplace"
                            )
                            loadProducts()
                        }
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
                            Button {
                                selectedProduct = product
                                UserHistoryService.shared.recordCurrentUser(
                                    category: .shop,
                                    action: "Opened product from list",
                                    details: product.name
                                )
                            } label: {
                                productRow(product)
                            }
                            .buttonStyle(.plain)
                            .accessibilityIdentifier("marketplaceProductRow_\(product.id)")
                        }
                    }
                    .accessibilityIdentifier("marketplaceProductList")
                    .scrollContentBackground(.hidden)
                    .background(Color.clear)
                }
            }
        }
        .navigationDestination(item: $selectedProduct) { product in
            ProductDetailView(product: product)
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
                .simultaneousGesture(
                    TapGesture().onEnded {
                        UserHistoryService.shared.recordCurrentUser(
                            category: .shop,
                            action: "Opened cart from marketplace"
                        )
                    }
                )
            }
        }
        .task {
            loadProducts()
        }
        .onAppear {
            UserHistoryService.shared.recordCurrentUser(
                category: .shop,
                action: "Opened marketplace"
            )
        }
    }

    private var filteredProducts: [Product] {
        let animalFilteredProducts = products.filter { product in
            matchesAnimalFilter(product)
        }

        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        let queryFilteredProducts: [Product]

        if trimmedQuery.isEmpty {
            queryFilteredProducts = animalFilteredProducts
        } else {
            queryFilteredProducts = animalFilteredProducts.filter { product in
                product.name.localizedCaseInsensitiveContains(trimmedQuery)
                    || product.category.localizedCaseInsensitiveContains(trimmedQuery)
            }
        }

        let stockFilteredProducts: [Product]
        if showInStockOnly {
            stockFilteredProducts = queryFilteredProducts.filter { $0.stock > 0 }
        } else {
            stockFilteredProducts = queryFilteredProducts
        }

        switch selectedSortOption {
        case .lowToHigh:
            return stockFilteredProducts.sorted { $0.price < $1.price }
        case .highToLow:
            return stockFilteredProducts.sorted { $0.price > $1.price }
        }
    }

    private func matchesAnimalFilter(_ product: Product) -> Bool {
        switch selectedAnimalFilter {
        case .all:
            return true
        case .cat:
            return inferredAnimalType(for: product) == .cat
        case .dog:
            return inferredAnimalType(for: product) == .dog
        }
    }

    private func inferredAnimalType(for product: Product) -> MarketplaceAnimalFilter {
        let key = "\(product.name) \(product.category) \(product.imageURL)".lowercased()
        if key.contains("dog") || key.contains("puppy") || key.contains("canine") || key.contains("pedigree") || key.contains("wanpy") {
            return .dog
        }
        return .cat
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
                    cartState.syncStock(with: products)
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

                    AppPlaceholderImageView(assetName: AppImageLibrary.productImageAssetName(for: product), cornerRadius: 10, iconSize: 24)
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

                    Text(stockLabel(for: product.stock))
                        .font(TextStyles.caption)
                        .foregroundStyle(product.stock > 0 ? AppDesign.muted : .red)
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

    private func stockLabel(for stock: Int) -> String {
        if stock <= 0 {
            return text("Out of stock", "স্টক শেষ")
        }
        return text("Stock: \(stock)", "স্টক: \(stock)")
    }
}

#Preview {
    NavigationStack {
        MarketplaceView()
            .environmentObject(CartState())
    }
}
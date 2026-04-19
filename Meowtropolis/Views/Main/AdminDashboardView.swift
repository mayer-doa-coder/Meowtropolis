import SwiftUI

private enum AdminDashboardSection: String, CaseIterable, Identifiable {
    case products
    case vetRequests
    case orders

    var id: String { rawValue }

    func title(language: AppLanguage) -> String {
        switch self {
        case .products:
            return language.text(english: "Products", bangla: "পণ্য")
        case .vetRequests:
            return language.text(english: "Vet Requests", bangla: "ভেট অনুরোধ")
        case .orders:
            return language.text(english: "Orders", bangla: "অর্ডার")
        }
    }
}

struct AdminDashboardView: View {
    @EnvironmentObject private var appState: AppState
    @AppStorage(AppLanguage.storageKey) private var appLanguageCode: String = AppLanguage.englishUS.rawValue

    @State private var selectedSection: AdminDashboardSection = .products

    @State private var products: [Product] = []
    @State private var vetRequests: [VetRequest] = []
    @State private var orders: [Order] = []

    @State private var isLoading: Bool = false
    @State private var errorMessage: String?
    @State private var infoMessage: String?

    @State private var selectedProductForEdit: Product?
    @State private var showProductEditor: Bool = false

    private let productService = FirestoreProductService()
    private let vetService = VetService()
    private let orderService = OrderService()

    var body: some View {
        AppBackground {
            if appState.isAdmin {
                VStack(spacing: Spacing.medium) {
                    Picker("AdminSection", selection: $selectedSection) {
                        ForEach(AdminDashboardSection.allCases) { section in
                            Text(section.title(language: currentLanguage)).tag(section)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal, 20)

                    if let infoMessage {
                        Text(infoMessage)
                            .font(TextStyles.caption)
                            .foregroundStyle(.green)
                            .padding(.horizontal, 20)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    if let errorMessage {
                        Text(errorMessage)
                            .font(TextStyles.caption)
                            .foregroundStyle(.red)
                            .padding(.horizontal, 20)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    contentSection
                }
                .padding(.top, 16)
            } else {
                ErrorStateView(
                    title: text("Admin access required.", "অ্যাডমিন অ্যাক্সেস প্রয়োজন।"),
                    message: text("You do not have permission to open this dashboard.", "এই ড্যাশবোর্ড খোলার অনুমতি আপনার নেই।"),
                    retryTitle: text("OK", "ঠিক আছে"),
                    onRetry: {}
                )
                .padding(20)
            }
        }
        .navigationTitle(text("Admin Dashboard", "অ্যাডমিন ড্যাশবোর্ড"))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                if selectedSection == .products {
                    Button {
                        selectedProductForEdit = nil
                        showProductEditor = true
                    } label: {
                        Image(systemName: "plus")
                    }
                    .accessibilityIdentifier("adminAddProductButton")
                }
            }
        }
        .sheet(isPresented: $showProductEditor) {
            NavigationStack {
                AdminProductEditorView(
                    product: selectedProductForEdit,
                    onSave: { product in
                        saveProduct(product)
                    }
                )
            }
        }
        .task {
            if appState.isAdmin {
                refreshAllData()
            }
        }
        .onChange(of: selectedSection) { _ in
            infoMessage = nil
            errorMessage = nil
        }
        .onAppear {
            UserHistoryService.shared.recordCurrentUser(
                category: .account,
                action: "Opened admin dashboard"
            )
        }
    }

    @ViewBuilder
    private var contentSection: some View {
        if isLoading {
            LoadingBlockView(message: text("Loading dashboard data...", "ড্যাশবোর্ড ডেটা লোড হচ্ছে..."))
                .padding(20)
        } else {
            switch selectedSection {
            case .products:
                productsSection
            case .vetRequests:
                vetRequestsSection
            case .orders:
                ordersSection
            }
        }
    }

    private var productsSection: some View {
        List {
            ForEach(products, id: \.id) { product in
                CardView {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(product.name)
                            .font(TextStyles.subtitle)
                            .foregroundStyle(AppDesign.text)

                        Text("ID: \(product.id)")
                            .font(TextStyles.caption)
                            .foregroundStyle(AppDesign.muted)

                        Text(text("Category", "ক্যাটাগরি") + ": \(product.category)")
                            .font(TextStyles.caption)
                            .foregroundStyle(AppDesign.muted)

                        Text(currentLanguage.formatMoney(product.price))
                            .font(TextStyles.body)
                            .foregroundStyle(AppDesign.primary)

                        Text(text("Stock", "স্টক") + ": \(product.stock)")
                            .font(TextStyles.caption)
                            .foregroundStyle(AppDesign.muted)

                        HStack(spacing: 12) {
                            Button(text("Edit", "এডিট")) {
                                selectedProductForEdit = product
                                showProductEditor = true
                            }
                            .font(TextStyles.caption)

                            Button(text("Delete", "মুছুন"), role: .destructive) {
                                deleteProduct(product)
                            }
                            .font(TextStyles.caption)
                        }
                    }
                }
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .background(Color.clear)
    }

    private var vetRequestsSection: some View {
        List {
            ForEach(vetRequests, id: \.id) { request in
                CardView {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(request.issueDescription)
                            .font(TextStyles.body)
                            .foregroundStyle(AppDesign.text)

                        Text("User: \(request.userId)")
                            .font(TextStyles.caption)
                            .foregroundStyle(AppDesign.muted)

                        Text(text("Status", "স্ট্যাটাস") + ": \(request.status.rawValue)")
                            .font(TextStyles.caption)
                            .foregroundStyle(AppDesign.primary)

                        Menu(text("Change Status", "স্ট্যাটাস পরিবর্তন")) {
                            Button(text("Pending", "অপেক্ষমাণ")) {
                                updateVetStatus(requestId: request.id, status: .pending)
                            }
                            Button(text("Resolved", "সমাধান হয়েছে")) {
                                updateVetStatus(requestId: request.id, status: .resolved)
                            }
                        }
                        .font(TextStyles.caption)
                    }
                }
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .background(Color.clear)
    }

    private var ordersSection: some View {
        List {
            ForEach(orders, id: \.id) { order in
                CardView {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Order: \(order.id)")
                            .font(TextStyles.subtitle)
                            .foregroundStyle(AppDesign.text)

                        Text("User: \(order.userId)")
                            .font(TextStyles.caption)
                            .foregroundStyle(AppDesign.muted)

                        Text(text("Items", "পণ্য") + ": \(order.items.count)")
                            .font(TextStyles.caption)
                            .foregroundStyle(AppDesign.muted)

                        Text(currentLanguage.formatMoney(order.totalAmount))
                            .font(TextStyles.body)
                            .foregroundStyle(AppDesign.primary)

                        Text(text("Status", "স্ট্যাটাস") + ": \(order.status)")
                            .font(TextStyles.caption)
                            .foregroundStyle(AppDesign.muted)

                        Menu(text("Update Status", "স্ট্যাটাস আপডেট")) {
                            Button("placed") {
                                updateOrderStatus(orderId: order.id, status: "placed")
                            }
                            Button("processing") {
                                updateOrderStatus(orderId: order.id, status: "processing")
                            }
                            Button("completed") {
                                updateOrderStatus(orderId: order.id, status: "completed")
                            }
                            Button("cancelled") {
                                updateOrderStatus(orderId: order.id, status: "cancelled")
                            }
                        }
                        .font(TextStyles.caption)
                    }
                }
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .background(Color.clear)
    }

    private func refreshAllData() {
        isLoading = true
        errorMessage = nil

        let group = DispatchGroup()
        var productsResult: Result<[Product], Error>?
        var vetsResult: Result<[VetRequest], Error>?
        var ordersResult: Result<[Order], Error>?

        group.enter()
        productService.fetchProducts { result in
            productsResult = result
            group.leave()
        }

        group.enter()
        vetService.listAllRequests { result in
            vetsResult = result
            group.leave()
        }

        group.enter()
        orderService.listAllOrders { result in
            ordersResult = result
            group.leave()
        }

        group.notify(queue: .main) {
            isLoading = false

            if case let .failure(error) = productsResult {
                errorMessage = error.localizedDescription
                return
            }
            if case let .failure(error) = vetsResult {
                errorMessage = error.localizedDescription
                return
            }
            if case let .failure(error) = ordersResult {
                errorMessage = error.localizedDescription
                return
            }

            products = (try? productsResult?.get())?.sorted(by: { $0.name < $1.name }) ?? []
            vetRequests = (try? vetsResult?.get()) ?? []
            orders = (try? ordersResult?.get()) ?? []
        }
    }

    private func saveProduct(_ product: Product) {
        productService.upsertProduct(product) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    infoMessage = text("Product saved.", "পণ্য সেভ হয়েছে।")
                    errorMessage = nil
                    showProductEditor = false
                    refreshAllData()
                case let .failure(error):
                    errorMessage = error.localizedDescription
                }
            }
        }
    }

    private func deleteProduct(_ product: Product) {
        productService.deleteProduct(productId: product.id) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    infoMessage = text("Product deleted.", "পণ্য মুছে ফেলা হয়েছে।")
                    errorMessage = nil
                    refreshAllData()
                case let .failure(error):
                    errorMessage = error.localizedDescription
                }
            }
        }
    }

    private func updateVetStatus(requestId: String, status: VetRequestStatus) {
        vetService.updateRequestStatus(requestId: requestId, status: status) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    infoMessage = text("Vet request updated.", "ভেট অনুরোধ আপডেট হয়েছে।")
                    errorMessage = nil
                    refreshAllData()
                case let .failure(error):
                    errorMessage = error.localizedDescription
                }
            }
        }
    }

    private func updateOrderStatus(orderId: String, status: String) {
        orderService.updateOrderStatus(orderId: orderId, status: status) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    infoMessage = text("Order updated.", "অর্ডার আপডেট হয়েছে।")
                    errorMessage = nil
                    refreshAllData()
                case let .failure(error):
                    errorMessage = error.localizedDescription
                }
            }
        }
    }

    private var currentLanguage: AppLanguage {
        AppLanguage.from(code: appLanguageCode)
    }

    private func text(_ english: String, _ bangla: String) -> String {
        currentLanguage.text(english: english, bangla: bangla)
    }
}

private struct AdminProductEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage(AppLanguage.storageKey) private var appLanguageCode: String = AppLanguage.englishUS.rawValue

    let product: Product?
    let onSave: (Product) -> Void

    @State private var id: String = ""
    @State private var name: String = ""
    @State private var category: String = ""
    @State private var imageURL: String = ""
    @State private var priceText: String = ""
    @State private var stockText: String = ""
    @State private var formError: String?

    var body: some View {
        AppBackground {
            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    AppInputField(title: text("Product ID", "পণ্যের আইডি"), text: $id)
                        .disabled(product != nil)
                    AppInputField(title: text("Name", "নাম"), text: $name)
                    AppInputField(title: text("Category", "ক্যাটাগরি"), text: $category)
                    AppInputField(title: text("Image Key", "ইমেজ কী"), text: $imageURL)
                    AppInputField(title: text("Price", "দাম"), text: $priceText)
                    AppInputField(title: text("Stock", "স্টক"), text: $stockText)

                    if let formError {
                        Text(formError)
                            .font(TextStyles.caption)
                            .foregroundStyle(.red)
                    }

                    Button(text("Save", "সেভ")) {
                        handleSave()
                    }
                    .buttonStyle(FilledPrimaryButtonStyle())

                    Button(text("Cancel", "বাতিল")) {
                        dismiss()
                    }
                    .buttonStyle(OutlinedPrimaryButtonStyle())
                }
                .padding(20)
            }
        }
        .navigationTitle(text(product == nil ? "Add Product" : "Edit Product", product == nil ? "পণ্য যোগ করুন" : "পণ্য এডিট করুন"))
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            guard let product else {
                return
            }
            id = product.id
            name = product.name
            category = product.category
            imageURL = product.imageURL
            priceText = String(product.price)
            stockText = String(product.stock)
        }
    }

    private func handleSave() {
        let cleanId = id.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanCategory = category.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanImageURL = imageURL.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !cleanId.isEmpty, !cleanName.isEmpty, !cleanCategory.isEmpty, !cleanImageURL.isEmpty else {
            formError = text("Please fill all fields.", "সব ঘর পূরণ করুন।")
            return
        }

        guard let price = Double(priceText), price >= 0 else {
            formError = text("Enter a valid price.", "সঠিক দাম লিখুন।")
            return
        }

        guard let stock = Int(stockText), stock >= 0 else {
            formError = text("Enter a valid stock number.", "সঠিক স্টক সংখ্যা লিখুন।")
            return
        }

        formError = nil
        onSave(
            Product(
                id: cleanId,
                name: cleanName,
                price: price,
                category: cleanCategory,
                imageURL: cleanImageURL,
                stock: stock
            )
        )
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
        AdminDashboardView()
            .environmentObject(AppState())
    }
}

import Foundation
import Combine 

/// Shared in-memory cart for MVP flows.
final class CartState: ObservableObject {
    @Published private(set) var items: [CartItem] = []

    var totalItemCount: Int {
        items.reduce(0) { $0 + $1.quantity }
    }

    var totalPrice: Double {
        items.reduce(0) { $0 + (Double($1.quantity) * $1.price) }
    }

    /// Adds one quantity of a product by default.
    func addToCart(product: Product, quantity: Int = 1) {
        let safeQuantity = max(1, quantity)
        let safeStock = max(0, product.stock)

        guard safeStock > 0 else {
            UserHistoryService.shared.recordCurrentUser(
                category: .shop,
                action: "Attempted add on out-of-stock product",
                details: product.name
            )
            return
        }

        if let index = items.firstIndex(where: { $0.productId == product.id }) {
            let maxAllowed = max(0, items[index].availableStock)
            items[index].quantity = min(maxAllowed, items[index].quantity + safeQuantity)
            items[index].availableStock = safeStock
            UserHistoryService.shared.recordCurrentUser(
                category: .shop,
                action: "Updated cart quantity",
                details: "\(product.name): +\(safeQuantity)"
            )
            return
        }

        let newItem = CartItem(
            id: UUID().uuidString,
            productId: product.id,
            name: product.name,
            price: product.price,
            category: product.category,
            imageURL: product.imageURL,
            availableStock: safeStock,
            quantity: min(safeQuantity, safeStock)
        )

        items.append(newItem)
        UserHistoryService.shared.recordCurrentUser(
            category: .shop,
            action: "Added item to cart",
            details: "\(product.name) x\(safeQuantity)"
        )
    }

    func removeFromCart(productId: String) {
        let itemName = items.first(where: { $0.productId == productId })?.name ?? productId
        items.removeAll { $0.productId == productId }
        UserHistoryService.shared.recordCurrentUser(
            category: .shop,
            action: "Removed item from cart",
            details: itemName
        )
    }

    func updateQuantity(productId: String, quantity: Int) {
        guard let index = items.firstIndex(where: { $0.productId == productId }) else {
            return
        }

        if quantity <= 0 {
            removeFromCart(productId: productId)
        } else {
            items[index].quantity = min(quantity, max(1, items[index].availableStock))
            UserHistoryService.shared.recordCurrentUser(
                category: .shop,
                action: "Changed cart quantity",
                details: "\(items[index].name): \(quantity)"
            )
        }
    }

    func syncStock(with products: [Product]) {
        let stockById = Dictionary(uniqueKeysWithValues: products.map { ($0.id, max(0, $0.stock)) })

        items = items.compactMap { item in
            guard let updatedStock = stockById[item.productId], updatedStock > 0 else {
                return nil
            }

            var updatedItem = item
            updatedItem.availableStock = updatedStock
            updatedItem.quantity = min(item.quantity, updatedStock)
            return updatedItem
        }
    }

    func clearCart() {
        items = []
        UserHistoryService.shared.recordCurrentUser(
            category: .shop,
            action: "Cleared cart"
        )
    }
}

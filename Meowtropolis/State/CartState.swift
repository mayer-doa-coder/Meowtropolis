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

        if let index = items.firstIndex(where: { $0.productId == product.id }) {
            items[index].quantity += safeQuantity
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
            quantity: safeQuantity
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
            items[index].quantity = quantity
            UserHistoryService.shared.recordCurrentUser(
                category: .shop,
                action: "Changed cart quantity",
                details: "\(items[index].name): \(quantity)"
            )
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

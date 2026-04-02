import Foundation

/// Minimal cart row used for session-level shopping cart state.
struct CartItem: Identifiable, Codable {
    let id: String
    let productId: String
    let name: String
    let price: Double
    var quantity: Int
}

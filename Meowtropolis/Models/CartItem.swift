import Foundation

/// Minimal cart row used for session-level shopping cart state.
struct CartItem: Identifiable, Codable {
    let id: String
    let productId: String
    let name: String
    let price: Double
    let category: String
    let imageURL: String
    var availableStock: Int
    var quantity: Int

    init(
        id: String,
        productId: String,
        name: String,
        price: Double,
        category: String,
        imageURL: String,
        availableStock: Int,
        quantity: Int
    ) {
        self.id = id
        self.productId = productId
        self.name = name
        self.price = price
        self.category = category
        self.imageURL = imageURL
        self.availableStock = availableStock
        self.quantity = quantity
    }

    private enum CodingKeys: String, CodingKey {
        case id
        case productId
        case name
        case price
        case category
        case imageURL
        case availableStock
        case quantity
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        productId = try container.decode(String.self, forKey: .productId)
        name = try container.decode(String.self, forKey: .name)
        price = try container.decode(Double.self, forKey: .price)
        category = try container.decodeIfPresent(String.self, forKey: .category) ?? "cat"
        imageURL = try container.decodeIfPresent(String.self, forKey: .imageURL) ?? ""
        availableStock = try container.decodeIfPresent(Int.self, forKey: .availableStock) ?? 50
        quantity = try container.decode(Int.self, forKey: .quantity)
    }
}

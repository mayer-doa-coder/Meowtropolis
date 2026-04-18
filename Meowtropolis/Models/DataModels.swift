import Foundation

/// Fixed booking states used across app and Firestore.
enum BookingStatus: String, Codable {
    case pending
    case confirmed
    case completed
    case cancelled
}

/// Basic account information for an app user.
struct User: Codable {
    /// Unique identifier for the user.
    let id: String
    /// Full name displayed in the app.
    let name: String
    /// Email used for login and communication.
    let email: String
    /// Optional language code preference for UI.
    let preferredLanguageCode: String?
    /// Optional base64 image data used as profile avatar.
    let profileImageBase64: String?

    init(
        id: String,
        name: String,
        email: String,
        preferredLanguageCode: String? = nil,
        profileImageBase64: String? = nil
    ) {
        self.id = id
        self.name = name
        self.email = email
        self.preferredLanguageCode = preferredLanguageCode
        self.profileImageBase64 = profileImageBase64
    }
}

/// Basic pet profile linked to a user.
struct Pet: Codable {
    /// Unique identifier for the pet.
    let id: String
    /// Identifier of the user who owns this pet.
    let userId: String
    /// Pet name shown in profile and bookings.
    let name: String
    /// Pet age in years.
    let age: Int?
    /// Pet breed information.
    let breed: String

    init(id: String, userId: String, name: String, breed: String, age: Int? = nil) {
        self.id = id
        self.userId = userId
        self.name = name
        self.age = age
        self.breed = breed
    }
}

/// Service appointment made for a pet.
struct Booking: Codable {
    /// Unique identifier for the booking.
    let id: String
    /// Identifier of the user who created the booking.
    let userId: String
    /// Identifier of the booked pet.
    let petId: String
    /// Type of service requested (for example: grooming).
    let serviceType: String
    /// Booking date in ISO-8601 string format.
    let date: String
    /// Current booking status.
    let status: BookingStatus
}

/// Item available in the marketplace.
struct Product: Codable {
    /// Unique identifier for the product.
    let id: String
    /// Product name shown in listings.
    let name: String
    /// Product price value.
    let price: Double
    /// Product category used for filtering.
    let category: String
    /// Local asset key for product thumbnail or preview.
    let imageURL: String
    /// Available stock quantity for ordering.
    let stock: Int

    init(
        id: String,
        name: String,
        price: Double,
        category: String,
        imageURL: String,
        stock: Int = 50
    ) {
        self.id = id
        self.name = name
        self.price = price
        self.category = category
        self.imageURL = imageURL
        self.stock = stock
    }

    private enum CodingKeys: String, CodingKey {
        case id
        case name
        case price
        case category
        case imageURL
        case stock
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        price = try container.decode(Double.self, forKey: .price)
        category = try container.decode(String.self, forKey: .category)
        imageURL = try container.decode(String.self, forKey: .imageURL)
        stock = try container.decodeIfPresent(Int.self, forKey: .stock) ?? 50
    }
}

/// One item in an order snapshot.
struct OrderItem: Codable {
    let productId: String
    let name: String
    let category: String
    let imageURL: String
    let unitPrice: Double
    let quantity: Int
    let lineTotal: Double
}

/// Order saved to Firestore after checkout.
struct Order: Codable {
    let id: String
    let userId: String
    let items: [OrderItem]
    let totalAmount: Double
    let currencyCode: String
    let status: String
    let createdAt: String
}
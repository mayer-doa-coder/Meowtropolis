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
    /// Public image URL for product thumbnail or preview.
    let imageURL: String
}
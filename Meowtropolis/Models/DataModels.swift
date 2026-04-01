import Foundation

/// Basic account information for an app user.
struct User: Codable {
    /// Unique identifier for the user.
    let id: String
    /// Full name displayed in the app.
    let name: String
    /// Email used for login and communication.
    let email: String
}

/// Basic pet profile linked to a user.
struct Pet: Codable {
    /// Unique identifier for the pet.
    let id: String
    /// Identifier of the user who owns this pet.
    let userId: String
    /// Pet name shown in profile and bookings.
    let name: String
    /// Pet breed information.
    let breed: String
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
    /// Current booking status (for example: pending).
    let status: String
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
}
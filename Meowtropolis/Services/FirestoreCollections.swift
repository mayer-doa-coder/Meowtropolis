import Foundation

/// Central place for Firestore collection names.
/// Use these constants everywhere instead of hardcoded strings.
enum FirestoreCollections {
    static let users = "users"
    static let pets = "pets"
    static let bookings = "bookings"
    static let products = "products"
    static let orders = "orders"
    static let vetRequests = "vetRequests"
}

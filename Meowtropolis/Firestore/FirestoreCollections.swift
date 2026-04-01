import Foundation

/// Locked Firestore collection names used by the app.
///
/// Important: These raw values are part of the database contract.
/// Do not rename them after data is created in Firestore.
enum FirestoreCollection: String {
    /// Collection for app users.
    case users = "users"
    /// Collection for pet profiles.
    case pets = "pets"
    /// Collection for service bookings.
    case bookings = "bookings"
    /// Collection for marketplace products.
    case products = "products"
}

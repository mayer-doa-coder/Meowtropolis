import Foundation

/// Backward-compatible shim for older test/code paths.
///
/// Source of truth is `FirestoreCollections` in Services.
/// This type should not define literal collection names.
enum FirestoreCollection {
    case users
    case pets
    case bookings
    case products
    case orders

    var rawValue: String {
        switch self {
        case .users:
            return FirestoreCollections.users
        case .pets:
            return FirestoreCollections.pets
        case .bookings:
            return FirestoreCollections.bookings
        case .products:
            return FirestoreCollections.products
        case .orders:
            return FirestoreCollections.orders
        }
    }
}

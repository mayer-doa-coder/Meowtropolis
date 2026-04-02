import Foundation

/// Minimal status flow for MVP-level vet requests.
enum VetRequestStatus: String, Codable {
    case pending
    case resolved
}

/// Basic vet request submitted by a logged-in user.
struct VetRequest: Codable {
    /// Unique identifier for the request document.
    let id: String
    /// User who created this request.
    let userId: String
    /// Optional pet id when request is tied to a specific pet.
    let petId: String?
    /// Simple text description of the health issue.
    let issueDescription: String
    /// Current request state.
    let status: VetRequestStatus
    /// ISO-8601 creation timestamp string.
    let createdAt: String
}

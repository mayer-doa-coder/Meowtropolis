import Foundation
import FirebaseFirestore

// GUARDRAIL:
// Do not modify Firestore wiring or booking service contracts in this phase.
// Required for MVP stability and demo consistency.
// If a requested change risks backend connectivity, stop and log it in docs/issue_inventory.md.

/// Handles Firestore operations for booking data.
final class BookingService {
    private let db: Firestore

    init(db: Firestore = Firestore.firestore()) {
        self.db = db
    }

    /// Creates a booking document.
    func createBooking(_ booking: Booking, completion: @escaping (Result<Void, Error>) -> Void) {
        do {
            let payload = try FirestoreModelCoder.encode(booking)
            db.collection(FirestoreCollections.bookings)
                .document(booking.id)
                .setData(payload) { error in
                    if let error {
                        completion(.failure(error))
                        return
                    }
                    completion(.success(()))
                }
        } catch {
            completion(.failure(error))
        }
    }

    /// Lists all bookings for a specific user.
    func listBookingsByUser(userId: String, completion: @escaping (Result<[Booking], Error>) -> Void) {
        db.collection(FirestoreCollections.bookings)
            .whereField("userId", isEqualTo: userId)
            .getDocuments { snapshot, error in
                if let error {
                    completion(.failure(error))
                    return
                }

                guard let documents = snapshot?.documents else {
                    completion(.success([]))
                    return
                }

                do {
                    let bookings = try documents.map { document in
                        try self.decodeBooking(document)
                    }
                    completion(.success(bookings))
                } catch {
                    completion(.failure(error))
                }
            }
    }

    /// Lists all bookings for a specific pet.
    func listBookingsByPet(petId: String, completion: @escaping (Result<[Booking], Error>) -> Void) {
        db.collection(FirestoreCollections.bookings)
            .whereField("petId", isEqualTo: petId)
            .getDocuments { snapshot, error in
                if let error {
                    completion(.failure(error))
                    return
                }

                guard let documents = snapshot?.documents else {
                    completion(.success([]))
                    return
                }

                do {
                    let bookings = try documents.map { document in
                        try self.decodeBooking(document)
                    }
                    completion(.success(bookings))
                } catch {
                    completion(.failure(error))
                }
            }
    }

    /// Updates only the status field of a booking document.
    func updateBookingStatus(bookingId: String, status: BookingStatus, completion: @escaping (Result<Void, Error>) -> Void) {
        db.collection(FirestoreCollections.bookings)
            .document(bookingId)
            .updateData(["status": status.rawValue]) { error in
                if let error {
                    completion(.failure(error))
                    return
                }
                completion(.success(()))
            }
    }

    /// Decodes booking safely and supports legacy docs where id may be missing from the payload.
    private func decodeBooking(_ document: QueryDocumentSnapshot) throws -> Booking {
        let data = document.data()

        let id = (data["id"] as? String)?.trimmingCharacters(in: .whitespacesAndNewlines)
        let userId = (data["userId"] as? String)?.trimmingCharacters(in: .whitespacesAndNewlines)
        let petId = (data["petId"] as? String)?.trimmingCharacters(in: .whitespacesAndNewlines)
        let serviceType = (data["serviceType"] as? String)?.trimmingCharacters(in: .whitespacesAndNewlines)
        let date = (data["date"] as? String)?.trimmingCharacters(in: .whitespacesAndNewlines)
        let statusRaw = (data["status"] as? String)?.trimmingCharacters(in: .whitespacesAndNewlines)

        let resolvedId = (id?.isEmpty == false ? id! : document.documentID)

        guard let resolvedUserId = userId, !resolvedUserId.isEmpty,
              let resolvedPetId = petId, !resolvedPetId.isEmpty,
              let resolvedServiceType = serviceType, !resolvedServiceType.isEmpty,
              let resolvedDate = date, !resolvedDate.isEmpty,
              let statusRaw, let resolvedStatus = BookingStatus(rawValue: statusRaw) else {
            throw NSError(
                domain: "BookingService",
                code: 422,
                userInfo: [NSLocalizedDescriptionKey: "Invalid booking data found in database."]
            )
        }

        return Booking(
            id: resolvedId,
            userId: resolvedUserId,
            petId: resolvedPetId,
            serviceType: resolvedServiceType,
            date: resolvedDate,
            status: resolvedStatus
        )
    }
}

/// Simple smoke test helper for manual verification.
enum BookingServiceSmokeTest {
    static func run(bookingService: BookingService = BookingService()) {
        let sample = Booking(
            id: "booking_smoke_001",
            userId: "user_smoke_001",
            petId: "pet_smoke_001",
            serviceType: "grooming",
            date: "2026-04-01T10:00:00Z",
            status: .pending
        )

        bookingService.createBooking(sample) { createResult in
            switch createResult {
            case .success:
                print("Smoke test: booking create success")

                bookingService.listBookingsByUser(userId: sample.userId) { fetchResult in
                    switch fetchResult {
                    case let .success(bookings):
                        print("Smoke test: fetched bookings for user =>", bookings)
                    case let .failure(error):
                        print("Smoke test: fetch failed =>", error.localizedDescription)
                    }
                }

            case let .failure(error):
                print("Smoke test: create failed =>", error.localizedDescription)
            }
        }
    }
}

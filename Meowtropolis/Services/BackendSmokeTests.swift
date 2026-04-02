import Foundation

/// Simple manual smoke tests for backend services.
/// These tests are intentionally straightforward for beginner debugging.
enum BackendSmokeTests {
    private enum SmokeLogger {
        static var totalChecks: Int = 0
        static var passedChecks: Int = 0

        static func start() {
            totalChecks = 0
            passedChecks = 0
            print("=== Backend Smoke Tests: Start ===")
        }

        static func pass(_ message: String) {
            totalChecks += 1
            passedChecks += 1
            print("[PASS] \(message)")
        }

        static func fail(_ message: String, error: Error) {
            totalChecks += 1
            print("[FAIL] \(message) => \(error.localizedDescription)")
        }

        static func end() {
            let failedChecks = totalChecks - passedChecks
            print("=== Backend Smoke Tests: End ===")
            print("Summary: \(passedChecks)/\(totalChecks) checks passed, \(failedChecks) failed")
        }
    }

    /// One-call entry point for manual checks.
    /// Uses a unique test email each run to avoid duplicate-account errors.
    static func runAll() {
        let unique = UUID().uuidString.prefix(8)
        let email = "smoke_\(unique)@meowtropolis.app"
        let password = "Meow123!"
        runAll(testEmail: email, testPassword: password, fullName: "Smoke User")
    }

    /// Runs all service smoke tests in sequence.
    /// Note: Auth smoke test may fail if test email already exists.
    static func runAll(testEmail: String, testPassword: String, fullName: String = "Smoke User") {
        let authService = FirebaseAuthService()
        let userService = UserService()
        let petService = PetService()
        let bookingService = BookingService()
        let productService = ProductService()
        let localProductService = LocalProductService()

        SmokeLogger.start()

        runAuthSmokeTest(authService: authService, email: testEmail, password: testPassword) { authResult in
            switch authResult {
            case let .success(userId):
                SmokeLogger.pass("Auth flow completed, userId => \(userId)")

                let user = User(id: userId, name: fullName, email: testEmail)
                runUserSmokeTest(userService: userService, user: user) {
                    runPetSmokeTest(petService: petService, userId: userId) {
                        runBookingSmokeTest(bookingService: bookingService, userId: userId) {
                            runProductSmokeTest(productService: productService) {
                                runLocalProductSmokeTest(localProductService: localProductService) {
                                    SmokeLogger.end()
                                }
                            }
                        }
                    }
                }

            case let .failure(error):
                SmokeLogger.fail("Auth flow", error: error)
                // Continue to product checks at least.
                runProductSmokeTest(productService: productService) {
                    runLocalProductSmokeTest(localProductService: localProductService) {
                        SmokeLogger.end()
                    }
                }
            }
        }
    }

    /// Signup -> Login -> Logout -> Login flow smoke test.
    /// Final login keeps session active for Firestore service tests.
    static func runAuthSmokeTest(
        authService: AuthService,
        email: String,
        password: String,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        authService.signUp(email: email, password: password) { signUpResult in
            switch signUpResult {
            case let .success(uid):
                SmokeLogger.pass("Auth signUp")
                authService.signOut { _ in
                    authService.signIn(email: email, password: password) { signInResult in
                        switch signInResult {
                        case .success:
                            SmokeLogger.pass("Auth signIn")
                            authService.signOut { signOutResult in
                                switch signOutResult {
                                case .success:
                                    SmokeLogger.pass("Auth signOut")
                                case let .failure(error):
                                    SmokeLogger.fail("Auth signOut", error: error)
                                }

                                authService.signIn(email: email, password: password) { finalSignInResult in
                                    switch finalSignInResult {
                                    case .success:
                                        SmokeLogger.pass("Auth signIn (session restore)")
                                        completion(.success(uid))
                                    case let .failure(error):
                                        SmokeLogger.fail("Auth signIn (session restore)", error: error)
                                        completion(.failure(error))
                                    }
                                }
                            }
                        case let .failure(error):
                            SmokeLogger.fail("Auth signIn", error: error)
                            completion(.failure(error))
                        }
                    }
                }
            case let .failure(error):
                SmokeLogger.fail("Auth signUp", error: error)
                completion(.failure(error))
            }
        }
    }

    /// User profile create and fetch smoke test.
    static func runUserSmokeTest(
        userService: UserService,
        user: User,
        completion: @escaping () -> Void
    ) {
        userService.createUserProfile(user: user) { createResult in
            switch createResult {
            case .success:
                SmokeLogger.pass("User create profile")
                userService.fetchCurrentUser(userId: user.id) { fetchResult in
                    switch fetchResult {
                    case let .success(fetched):
                        SmokeLogger.pass("User fetch profile => \(fetched.id)")
                    case let .failure(error):
                        SmokeLogger.fail("User fetch profile", error: error)
                    }
                    completion()
                }
            case let .failure(error):
                SmokeLogger.fail("User create profile", error: error)
                completion()
            }
        }
    }

    /// Pet add, list, update, delete smoke test.
    static func runPetSmokeTest(
        petService: PetService,
        userId: String,
        completion: @escaping () -> Void
    ) {
        let petId = "pet_smoke_\(UUID().uuidString)"
        let pet = Pet(id: petId, userId: userId, name: "Milo", breed: "Persian", age: 2)

        petService.addPet(pet) { addResult in
            switch addResult {
            case .success:
                SmokeLogger.pass("Pet add")
                petService.listPets(userId: userId) { listResult in
                    switch listResult {
                    case let .success(pets):
                        SmokeLogger.pass("Pet list count => \(pets.count)")
                    case let .failure(error):
                        SmokeLogger.fail("Pet list", error: error)
                    }

                    let updatedPet = Pet(id: pet.id, userId: pet.userId, name: "Milo Updated", breed: pet.breed, age: 3)
                    petService.updatePet(updatedPet) { updateResult in
                        switch updateResult {
                        case .success:
                            SmokeLogger.pass("Pet update")
                        case let .failure(error):
                            SmokeLogger.fail("Pet update", error: error)
                        }

                        petService.deletePet(petId: pet.id) { deleteResult in
                            switch deleteResult {
                            case .success:
                                SmokeLogger.pass("Pet delete")
                            case let .failure(error):
                                SmokeLogger.fail("Pet delete", error: error)
                            }
                            completion()
                        }
                    }
                }
            case let .failure(error):
                SmokeLogger.fail("Pet add", error: error)
                completion()
            }
        }
    }

    /// Booking create, list, update status smoke test.
    static func runBookingSmokeTest(
        bookingService: BookingService,
        userId: String,
        completion: @escaping () -> Void
    ) {
        let bookingId = "booking_smoke_\(UUID().uuidString)"
        let petId = "pet_smoke_for_booking"
        let booking = Booking(
            id: bookingId,
            userId: userId,
            petId: petId,
            serviceType: "grooming",
            date: ISO8601DateFormatter().string(from: Date()),
            status: .pending
        )

        bookingService.createBooking(booking) { createResult in
            switch createResult {
            case .success:
                SmokeLogger.pass("Booking create")

                bookingService.listBookingsByUser(userId: userId) { listResult in
                    switch listResult {
                    case let .success(bookings):
                        SmokeLogger.pass("Booking list by user count => \(bookings.count)")
                    case let .failure(error):
                        SmokeLogger.fail("Booking list by user", error: error)
                    }

                    bookingService.updateBookingStatus(bookingId: bookingId, status: .confirmed) { updateResult in
                        switch updateResult {
                        case .success:
                            SmokeLogger.pass("Booking update status")
                        case let .failure(error):
                            SmokeLogger.fail("Booking update status", error: error)
                        }
                        completion()
                    }
                }
            case let .failure(error):
                SmokeLogger.fail("Booking create", error: error)
                completion()
            }
        }
    }

    /// Product fetch smoke test (Firestore first, local fallback).
    static func runProductSmokeTest(productService: ProductService, completion: @escaping () -> Void) {
        productService.fetchProducts { result in
            switch result {
            case let .success(products):
                SmokeLogger.pass("Product fetch count => \(products.count)")
                print("[INFO] Product list => \(products)")
            case let .failure(error):
                SmokeLogger.fail("Product fetch", error: error)
            }
            completion()
        }
    }

    /// Local JSON product loading smoke test.
    static func runLocalProductSmokeTest(localProductService: LocalProductService, completion: @escaping () -> Void) {
        localProductService.loadProducts { result in
            switch result {
            case let .success(products):
                SmokeLogger.pass("Local product load count => \(products.count)")
                print("[INFO] Local products => \(products)")
            case let .failure(error):
                SmokeLogger.fail("Local product load", error: error)
            }
            completion()
        }
    }
}

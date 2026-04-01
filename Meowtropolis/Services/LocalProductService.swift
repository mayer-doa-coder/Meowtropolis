import Foundation

/// Loads product data from local JSON in app bundle.
final class LocalProductService {
    enum LocalProductServiceError: Error {
        case fileNotFound
        case invalidData
    }

    private let bundle: Bundle

    init(bundle: Bundle = .main) {
        self.bundle = bundle
    }

    /// Reads products.json and decodes it into [Product].
    func loadProducts(completion: @escaping (Result<[Product], Error>) -> Void) {
        let url = bundle.url(forResource: "products", withExtension: "json")
            ?? bundle.url(forResource: "products", withExtension: "json", subdirectory: "SampleData")

        guard let url else {
            completion(.failure(LocalProductServiceError.fileNotFound))
            return
        }

        do {
            let data = try Data(contentsOf: url)
            let products = try JSONDecoder().decode([Product].self, from: data)
            completion(.success(products))
        } catch {
            completion(.failure(error))
        }
    }
}

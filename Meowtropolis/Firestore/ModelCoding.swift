import Foundation

/// Errors that can occur when converting between models and Firestore dictionaries.
enum ModelCodingError: Error {
    case invalidDictionaryFormat
}

/// Small helper for encoding/decoding Codable models with Firestore-style dictionaries.
enum FirestoreModelCoder {
    /// Converts any Encodable model into a [String: Any] dictionary.
    static func encode<T: Encodable>(_ model: T) throws -> [String: Any] {
        let data = try JSONEncoder().encode(model)
        let object = try JSONSerialization.jsonObject(with: data, options: [])

        guard let dictionary = object as? [String: Any] else {
            throw ModelCodingError.invalidDictionaryFormat
        }

        return dictionary
    }

    /// Converts a [String: Any] dictionary into a Decodable model.
    static func decode<T: Decodable>(_ type: T.Type, from dictionary: [String: Any]) throws -> T {
        let data = try JSONSerialization.data(withJSONObject: dictionary, options: [])
        return try JSONDecoder().decode(type, from: data)
    }
}

extension Product {
    /// Encodes Product into Firestore dictionary data.
    func toFirestoreData() throws -> [String: Any] {
        try FirestoreModelCoder.encode(self)
    }

    /// Decodes Product from Firestore dictionary data.
    static func fromFirestoreData(_ data: [String: Any]) throws -> Product {
        try FirestoreModelCoder.decode(Product.self, from: data)
    }
}

/// Example usage for testing and learning.
enum ProductCodingExample {
    static func run() throws {
        // Swift model -> Dictionary
        let product = Product(
            id: "product_001",
            name: "Premium Salmon Cat Food",
            price: 18.99,
            category: "food",
            imageURL: "https://loremflickr.com/900/700/cat,food"
        )

        let firestoreData = try product.toFirestoreData()
        print("Encoded dictionary:", firestoreData)

        // Dictionary -> Swift model
        let decodedProduct = try Product.fromFirestoreData(firestoreData)
        print("Decoded product:", decodedProduct)
    }
}

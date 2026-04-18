import Foundation

struct UserHistoryEntry: Codable, Identifiable {
    let id: String
    let userId: String
    let category: UserHistoryCategory
    let action: String
    let details: String?
    let timestamp: Date
}

enum UserHistoryCategory: String, CaseIterable, Codable {
    case auth
    case pets
    case grooming
    case vet
    case shop
    case map
    case account
    case system

    var displayTitle: String {
        switch self {
        case .auth:
            return "Auth"
        case .pets:
            return "Pets"
        case .grooming:
            return "Grooming"
        case .vet:
            return "Vet"
        case .shop:
            return "Shop"
        case .map:
            return "Map"
        case .account:
            return "Account"
        case .system:
            return "System"
        }
    }
}

final class UserHistoryService {
    static let shared = UserHistoryService()

    private let defaults: UserDefaults
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    private let activeUserDefaultsKey = "activeUserIdForHistory"
    private let storageKeyPrefix = "userHistoryEntries."
    private let maxEntriesPerUser = 200

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func setActiveUserId(_ userId: String?) {
        defaults.set(userId, forKey: activeUserDefaultsKey)
    }

    func recordCurrentUser(
        category: UserHistoryCategory,
        action: String,
        details: String? = nil,
        timestamp: Date = Date()
    ) {
        guard let userId = defaults.string(forKey: activeUserDefaultsKey), !userId.isEmpty else {
            return
        }

        record(userId: userId, category: category, action: action, details: details, timestamp: timestamp)
    }

    func record(
        userId: String,
        category: UserHistoryCategory,
        action: String,
        details: String? = nil,
        timestamp: Date = Date()
    ) {
        let cleanedAction = action.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanedAction.isEmpty else {
            return
        }

        var entries = entriesForUser(userId)
        let entry = UserHistoryEntry(
            id: UUID().uuidString,
            userId: userId,
            category: category,
            action: cleanedAction,
            details: details?.trimmingCharacters(in: .whitespacesAndNewlines),
            timestamp: timestamp
        )

        entries.insert(entry, at: 0)

        if entries.count > maxEntriesPerUser {
            entries = Array(entries.prefix(maxEntriesPerUser))
        }

        save(entries: entries, userId: userId)
    }

    func entries(for userId: String?) -> [UserHistoryEntry] {
        guard let userId, !userId.isEmpty else {
            return []
        }
        return entriesForUser(userId)
    }

    func clear(for userId: String?) {
        guard let userId, !userId.isEmpty else {
            return
        }

        defaults.removeObject(forKey: storageKey(for: userId))
    }

    private func entriesForUser(_ userId: String) -> [UserHistoryEntry] {
        let key = storageKey(for: userId)
        guard let data = defaults.data(forKey: key) else {
            return []
        }

        do {
            return try decoder.decode([UserHistoryEntry].self, from: data)
        } catch {
            defaults.removeObject(forKey: key)
            return []
        }
    }

    private func save(entries: [UserHistoryEntry], userId: String) {
        do {
            let data = try encoder.encode(entries)
            defaults.set(data, forKey: storageKey(for: userId))
        } catch {
            return
        }
    }

    private func storageKey(for userId: String) -> String {
        storageKeyPrefix + userId
    }
}

import Foundation

final class UserDefaultsStorage {
    let defaults: UserDefaults = .standard
}

extension UserDefaultsStorage: WritableStorage {
    func save<T: Codable>(value: T, for key: StorageKey) throws {
        defaults.set(value.encode, forKey: key.key)
    }
    
    func remove<T: Codable>(type _: T.Type, for key: StorageKey) throws {
        defaults.removeObject(forKey: key.key)
    }
}

extension UserDefaultsStorage: ReadableStorage {

    func fetchValue<T: Codable>(for key: StorageKey) throws -> T? {
        guard let value = defaults.data(forKey: key.key)?.decode(T.self) else {
            throw StorageError.notFound
        }
        return value
    }
}

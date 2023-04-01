import Foundation

public final class CacheManager {
    
    public enum SupportedStorage {
        case userDefaults
        case keychain
        case sqlLite
    }
    
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder
    private lazy var userDefaultsStorage = UserDefaultsStorage()
    private lazy var encryptedStorage = EncryptedStorage()
    private lazy var sqlLiteStorage = SqlLiteStorage()
    
    public init(
        decoder: JSONDecoder = .init(),
        encoder: JSONEncoder = .init()
    ) {
        self.decoder = decoder
        self.encoder = encoder
    }
    
    public func fetch<T: Codable>(_: T.Type, for key: StorageKey) throws -> T? {
        try getSuitableStorage(from: key.suitableStorage).fetchValue(for: key)
    }
    
    public func save<T: Codable>(_ value: T, for key: StorageKey) throws {
        try getSuitableStorage(from: key.suitableStorage).save(value: value, for: key)
    }
    
    public func remove<T: Codable>(type: T.Type, for key: StorageKey) throws {
        try getSuitableStorage(from: key.suitableStorage).remove(type: type, for: key)
    }
}

private extension CacheManager {
    func getSuitableStorage(from choice: SupportedStorage) -> Storage {
        switch choice {
        case .userDefaults:
            return userDefaultsStorage
        case .keychain:
            return encryptedStorage
        case .sqlLite:
            return sqlLiteStorage
        }
    }
}

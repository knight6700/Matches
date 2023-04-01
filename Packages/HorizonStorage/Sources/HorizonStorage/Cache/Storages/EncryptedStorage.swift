import KeychainSwift

final class EncryptedStorage {
    private let keychain = KeychainSwift()
}

extension EncryptedStorage: WritableStorage {
    func remove<T>(type _: T.Type, for key: StorageKey) throws where T: Codable {
        keychain.delete(key.key)
    }
    
    func save<T: Codable>(value: T, for key: StorageKey) throws {
        keychain.set(value.encode, forKey: key.key)
    }
}

extension EncryptedStorage: ReadableStorage {
    func fetchValue<T: Codable>(for key: StorageKey) throws -> T? {
        guard let value = keychain.getData(key.key)?.decode(T.self) else {
            throw StorageError.notFound
        }
        
        return value
    }
}

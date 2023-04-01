import Foundation

public struct StorageKey {
    public let key: String
    public let suitableStorage: CacheManager.SupportedStorage
    
    public init(key: String, suitableStorage: CacheManager.SupportedStorage) {
        self.key = key
        self.suitableStorage = suitableStorage
    }
}

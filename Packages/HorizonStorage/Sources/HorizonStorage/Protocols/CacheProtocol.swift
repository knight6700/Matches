import Foundation

public protocol ReadableStorage {
    func fetchValue<T: Codable>(for key: StorageKey) throws -> T?
}

public protocol WritableStorage {
    func save<T: Codable>(value: T, for key: StorageKey) throws
    func remove<T: Codable>(type: T.Type, for key: StorageKey) throws
    
}

public typealias Storage = ReadableStorage & WritableStorage

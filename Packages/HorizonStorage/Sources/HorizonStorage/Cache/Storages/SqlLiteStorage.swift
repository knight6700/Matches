import GRDB
import Foundation

final class SqlLiteStorage {
    private let dbQueue: DatabaseQueue
    
    init() {
        do {
            let databaseURL = try FileManager.default
                .url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
                .appendingPathComponent("cache.sqlite")
            dbQueue = try DatabaseQueue(path: databaseURL.path)
            try setupDatabase(dbQueue)
        } catch {
            fatalError("Could not setup cache database: \(error)")
        }
    }
    
    private func setupDatabase(_ dbQueue: DatabaseQueue) throws {
        do {
            try dbQueue.write { db in
                try db.create(table: "cache") { t in
                    t.column("key", .text).notNull().primaryKey()
                    t.column("value", .blob).notNull()
                }
            }
        } catch {
            dbQueue.inDatabase { db in
                try? db.execute(literal: "CREATE TEMPORARY TABLE cache_backup AS SELECT * FROM cache")
            }
        }
    }
}

extension SqlLiteStorage: WritableStorage {
    
    func save<T: Codable>(value: T, for key: StorageKey) throws {
        try dbQueue.write { db in
            try db.execute(
                sql: "INSERT OR REPLACE INTO cache (key, value) VALUES (:key, :value)",
                arguments: ["key": key.key, "value": value.encode]
            )
        }
    }
    
    func remove<T: Codable>(type _: T.Type, for key: StorageKey) throws {
        try dbQueue.write { db in
            try db.execute(sql: "DELETE FROM cache WHERE key = ?", arguments: [key.key])
        }
    }
}

extension SqlLiteStorage: ReadableStorage {

    func fetchValue<T: Codable>(for key: StorageKey) throws -> T? {
        var object: T?
        try dbQueue.read { db in
            let row = try Row.fetchOne(db, sql: "SELECT * FROM cache WHERE key = ?", arguments: [key.key])
            if let value = row?["value"] as? Data {
                object = value.decode(T.self)
            }
        }
        return object
    }
}

import Dependencies
import HorizonStorage

struct MatchesRepository  {
    var favoriteMatches: @Sendable () async throws -> [MatchDomain]
    var add: @Sendable (_ match: MatchDomain) async throws -> ()
    var remove: @Sendable (_ id: Int) async throws -> ()
    var fetchMatches: @Sendable () async throws -> [MatchDomain]
}


extension MatchesRepository: DependencyKey {
    static var liveValue: MatchesRepository {
        @Dependency(\.cacheManager) var cache
        @Dependency(\.matchesNetwork) var network
        return .init {
            try cache.fetch([MatchDomain].self, for: CacheKey.matches.key) ?? []
        } add: { match in
            var matches = try cache.fetch([MatchDomain].self, for: CacheKey.matches.key) ?? []
            matches.append(match)
            try cache.save(matches, for: CacheKey.matches.key)
        } remove: { id in
            var matches = try cache.fetch([MatchDomain].self, for: CacheKey.matches.key) ?? []
            matches.removeAll(where: { $0.id == id })
            try cache.save(matches, for: CacheKey.matches.key)
        } fetchMatches: {
            let favoriteMatch = try cache.fetch([MatchDomain].self, for: CacheKey.matches.key) ?? []
            var remoteMatches = try await network.loadMatches().matches.map{ $0.toDomain }
            // Use indices to loop through the remoteMatches array and modify the non-nil matches in-place
            for i in remoteMatches.indices {
                guard favoriteMatch.first(where: { $0.id == remoteMatches[i].id }) != nil else {
                    continue // If the match is not in the favoriteMatch array, continue to the next match
                }
                remoteMatches[i].isFavorite = true // Modify the isFavorite property as needed
            }
            return remoteMatches
        }
    }
}
extension MatchesRepository {
    static var testValue: MatchesRepository {
        .init {
            Competitions.testValue.matches.map{$0.toDomain}
        } add: { match in
            
        } remove: { id in
            
        } fetchMatches: {
            Competitions.testValue.matches.map{$0.toDomain}
        }

    }
}
extension DependencyValues {
    var matchRepository: MatchesRepository {
        get { self[MatchesRepository.self] }
        set { self[MatchesRepository.self] = newValue }
    }
}



enum CacheKey: String {
    case matches
    
    var key: StorageKey {
        switch self {
        case .matches:
            return .init(key: rawValue, suitableStorage: .sqlLite)
        }
    }
}


extension DependencyValues {
    var cacheManager: CacheManager {
        get { self[CacheManager.self] }
        set { self[CacheManager.self] = newValue }
    }
}
extension CacheManager: DependencyKey {
    static public var liveValue: CacheManager = CacheManager()
    public static var testValue: CacheManager {
        .liveValue
    }
}

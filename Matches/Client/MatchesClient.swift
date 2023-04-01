
import Foundation
import NetworkHerizon
import ComposableArchitecture
struct Crest: Codable, Equatable {
    let crestURL: String
    enum CodingKeys: String, CodingKey {
        case crestURL = "crestUrl"
    }

}

struct MatchesNetwork {
    var loadMatches: () async throws -> Competitions
    var loadCrests: (_ id: Int) async throws -> Crest
}

extension MatchesNetwork: DependencyKey {
    static var liveValue: MatchesNetwork {
        .init {
            let data = try await NetworkService().fetch(
                type: Competitions.self,
                with: .init(endpoint: "competitions/2021/matches",
                            method: .get
                           ),
                body: nil
            )
            return data

        } loadCrests: { id in
            let data = try await NetworkService().fetch(
                type: Crest.self,
                with: .init(endpoint: "teams/\(id)",
                            method: .get
                           ),
                body: nil
            )
            return data

        }

    }
    
    static var testValue: MatchesNetwork {
        .init {
            .testValue
        } loadCrests: { id in
                .init(crestURL: "")
        }
    }
    
    static var previewValue: MatchesNetwork {
        .testValue
    }
}

extension DependencyValues {
  var matchesNetwork: MatchesNetwork {
    get { self[MatchesNetwork.self] }
    set { self[MatchesNetwork.self] = newValue }
  }
}

struct MatchesFiler {
    var sortMatches: ([MatchDomain]) -> [Date : [MatchDomain]]
}

extension MatchesFiler: DependencyKey {
    static var liveValue: MatchesFiler {
        @Dependency(\.dateFormatter) var dateFormatter
        return .init { matches in
            let cal = Calendar.current
            return Dictionary(
                grouping: matches,
                by: {
                    cal.startOfDay(
                        for: dateFormatter.convertStringToDate(
                            $0.utcDate
                        )
                    )
                }
            )
        }
    }
}
extension MatchesFiler: TestDependencyKey {
    static var testValue: MatchesFiler {
        .liveValue
    }
}
extension DependencyValues {
    var matchesFiler: MatchesFiler {
        get { self[MatchesFiler.self] }
        set { self[MatchesFiler.self] = newValue }
    }
}



import Foundation
struct MatchDomain: Equatable, Codable {
    let id: Int
    let utcDate: String
    let status: Status
    let matchday: Int
    let score: Score
    let homeTeam, awayTeam: Team
    var isFavorite: Bool
    init(
        match: Match,
        isFavorite: Bool
    ) {
        self.id = match.id
        self.utcDate = match.utcDate
        self.status = match.status
        self.matchday = match.matchday
        self.score = match.score
        self.homeTeam = match.homeTeam
        self.awayTeam = match.awayTeam
        self.isFavorite = isFavorite
    }
}
extension Team {
    var crestUrl: URL? {
        CrestBuilder(id: id).crestUrl
    }
}

extension MatchDomain {
    static let testValue: Self = Self(match: .init(id: 1, season: .init(id: 0, startDate: "28/08", endDate: "26/9", currentMatchday: 1), utcDate: "2255", status: .postponed, matchday: 1, stage: .regularSeason, group: nil, lastUpdated:"wswsw", odds: .init(msg: "swsws"), score: .init(winner: .homeTeam, duration: .regular, fullTime: .init(homeTeam: 2, awayTeam: 0), halfTime: .init(homeTeam: 1, awayTeam: 0), extraTime: .init(homeTeam: 0, awayTeam: 0), penalties: .init(homeTeam: 0, awayTeam: 0)), homeTeam: .init(id: 57, name: "Arsenal"), awayTeam: .init(id: 66, name: "Manchester United FC"), referees: []), isFavorite: true)
}

extension Match {
    var toDomain: MatchDomain {
        .init(
            match: .init(
                id: id,
                season: season,
                utcDate: utcDate,
                status: status,
                matchday: matchday,
                stage: stage,
                group: group,
                lastUpdated: lastUpdated,
                odds: odds,
                score: score,
                homeTeam: homeTeam,
                awayTeam: awayTeam,
                referees: referees
            ),
            isFavorite: false
        )
    }
}

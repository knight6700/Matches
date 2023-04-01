

import Foundation

struct Competitions: Codable {
    let count: Int
    let competition: Competition
    let matches: [Match]
}

// MARK: - Competition
struct Competition: Codable {
    let id: Int
    let area: Area
    let name, code, plan: String
    let lastUpdated: String
}

// MARK: - Area
struct Area: Codable {
    let id: Int
    let name: String
}

struct Team: Codable, Equatable {
    let id: Int
    let name: String
}
// MARK: - Match
struct Match: Codable {
    let id: Int
    let season: Season
    let utcDate: String
    let status: Status
    let matchday: Int
    let stage: Stage
    let group: String?
    let lastUpdated: String
    let odds: Odds
    let score: Score
    let homeTeam, awayTeam: Team
    let referees: [Referee]
}

// MARK: - Odds
struct Odds: Codable {
    let msg: String
}

// MARK: - Referee
struct Referee: Codable {
    let id: Int
    let name: String
    let role: Role
    let nationality: String
}


enum Role: String, Codable {
    case referee = "REFEREE"
}

// MARK: - Score
struct Score: Codable, Equatable {
    let winner: Winner?
    let duration: Duration
    let fullTime, halfTime, extraTime, penalties: Scores
}

enum Duration: String, Codable, Equatable {
    case regular = "REGULAR"
}

// MARK: - ExtraTime
struct Scores: Codable, Equatable {
    let homeTeam, awayTeam: Int?
}

enum Winner: String, Codable, Equatable {
    case awayTeam = "AWAY_TEAM"
    case draw = "DRAW"
    case homeTeam = "HOME_TEAM"
}

// MARK: - Season
struct Season: Codable {
    let id: Int
    let startDate, endDate: String
    let currentMatchday: Int
}

enum Stage: String, Codable {
    case regularSeason = "REGULAR_SEASON"
}

enum Status: String, Codable, Equatable {
    case finished = "FINISHED"
    case postponed = "POSTPONED"
    case scheduled = "SCHEDULED"
    case pause = "PAUSED"
    case inPlay = "IN_PLAY"
}




struct CrestBuilder {
    var id: Int
    var crestUrl: URL? {
        return URL(string: "https://crests.football-data.org/\(id).png")
    }
}


#if DEBUG
extension Competitions {
    static let testValue: Self = Self(count: 1, competition: .testValue, matches: Match.testValue)
}

extension Competition {
    static let testValue: Self = Self(id: 0, area: .init(id: 0, name: "England"), name: "Premiere League", code: "02", plan: "Squads", lastUpdated: Data().description)
}
extension Season {
    static let testValue: Self = Self(id: 0, startDate: Data().description, endDate: Data().description, currentMatchday: 1)
}
extension Match {
    static let testValue: [Self] = [
        Self(id: 0,
             season: .testValue, utcDate: Date.randomBetween(start: "2019-01-01", end: "2020-01-01"),
             status: .finished, matchday: 1, stage: .regularSeason, group: "", lastUpdated: Data().description, odds: .init(msg: "Message"),
             score: .init(winner: .homeTeam, duration: .regular, fullTime: .init(homeTeam: 2, awayTeam: 0), halfTime: .init(homeTeam: 2, awayTeam: 0), extraTime: .init(homeTeam: 2, awayTeam: 0), penalties: .init(homeTeam: 2, awayTeam: 0)),
             homeTeam: .init(id: 57, name: "Arsenal"),
             awayTeam: .init(id: 25, name: "Man"),
             referees: []
            ),
        
        Self(id: 1,
             season: .testValue,
             utcDate: Date.randomBetween(start: "2018-01-01", end: "2019-01-01"),
             status: .finished,
             matchday: 1,
             stage: .regularSeason,
             group: "", lastUpdated: Data().description, odds: .init(msg: "Message"),
             score: .init(winner: .homeTeam, duration: .regular, fullTime: .init(homeTeam: 2, awayTeam: 0), halfTime: .init(homeTeam: 2, awayTeam: 0), extraTime: .init(homeTeam: 2, awayTeam: 0), penalties: .init(homeTeam: 2, awayTeam: 0))
             , homeTeam: .init(id: 57, name: "Arsenal"),
             awayTeam: .init(id: 25, name: "Man"), referees: [])
    ]
}
extension Date {
    
    static func randomBetween(start: String, end: String, format: String = "yyyy-MM-dd") -> String {
        let date1 = Date.parse(start, format: format)
        let date2 = Date.parse(end, format: format)
        return Date.randomBetween(start: date1, end: date2).dateString(format)
    }
    
    static func randomBetween(start: Date, end: Date) -> Date {
        var date1 = start
        var date2 = end
        if date2 < date1 {
            let temp = date1
            date1 = date2
            date2 = temp
        }
        let span = TimeInterval.random(in: date1.timeIntervalSinceNow...date2.timeIntervalSinceNow)
        return Date(timeIntervalSinceNow: span)
    }

    func dateString(_ format: String = "yyyy-MM-dd") -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: self)
    }

    static func parse(_ string: String, format: String = "yyyy-MM-dd") -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = NSTimeZone.default
        dateFormatter.dateFormat = format

        let date = dateFormatter.date(from: string)!
        return date
    }

}
#endif

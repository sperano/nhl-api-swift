import Foundation

/// Schedule game information
public struct ScheduleGame: Sendable, Hashable, Codable, Identifiable {
    public var id: GameID { gameId }

    public let gameId: GameID
    public let gameType: GameType
    public let gameDate: String?
    public let startTimeUTC: String
    public let awayTeam: ScheduleTeam
    public let homeTeam: ScheduleTeam
    public let gameState: GameState

    private enum CodingKeys: String, CodingKey {
        case gameId = "id"
        case gameType, gameDate, startTimeUTC, awayTeam, homeTeam, gameState
    }
}

extension ScheduleGame: CustomStringConvertible {
    public var description: String {
        if let date = gameDate {
            return "\(awayTeam.abbrev) @ \(homeTeam.abbrev) on \(date) [\(gameState)]"
        }
        return "\(awayTeam.abbrev) @ \(homeTeam.abbrev) [\(gameState)]"
    }
}

/// Team information in schedule
public struct ScheduleTeam: Sendable, Hashable, Codable, Identifiable {
    public let id: TeamID
    public let abbrev: String
    public let placeName: LocalizedString?
    public let logo: String
    public let score: Int?
}

/// Daily schedule
public struct DailySchedule: Sendable, Hashable, Codable {
    public let nextStartDate: String?
    public let previousStartDate: String?
    public let date: String
    public let games: [ScheduleGame]
    public let numberOfGames: Int
}

/// Weekly schedule response
public struct WeeklyScheduleResponse: Sendable, Hashable, Codable {
    public let nextStartDate: String
    public let previousStartDate: String
    public let gameWeek: [GameDay]
}

/// A day of games
public struct GameDay: Sendable, Hashable, Codable {
    public let date: String
    public let games: [ScheduleGame]
}

/// Team schedule response
public struct TeamScheduleResponse: Sendable, Hashable, Codable {
    public let games: [ScheduleGame]
}

/// Game scores for a day
public struct DailyScores: Sendable, Hashable, Codable {
    public let prevDate: String
    public let currentDate: String
    public let nextDate: String
    public let games: [GameScore]
}

/// Individual game score
public struct GameScore: Sendable, Hashable, Codable, Identifiable {
    public var id: GameID { gameId }

    public let gameId: GameID
    public let gameType: GameType
    public let gameState: GameState
    public let awayTeam: ScheduleTeam
    public let homeTeam: ScheduleTeam

    private enum CodingKeys: String, CodingKey {
        case gameId = "id"
        case gameType, gameState, awayTeam, homeTeam
    }
}

extension GameScore: CustomStringConvertible {
    public var description: String {
        let awayScore = awayTeam.score.map(String.init) ?? "-"
        let homeScore = homeTeam.score.map(String.init) ?? "-"
        return "\(awayTeam.abbrev) \(awayScore) @ \(homeTeam.abbrev) \(homeScore) [\(gameState)]"
    }
}

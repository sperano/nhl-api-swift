import Foundation

/// Skater season statistics for a team
public struct ClubSkaterStats: Sendable, Hashable, Codable, Identifiable {
    public var id: PlayerID { playerId }

    public let playerId: PlayerID
    public let headshot: String
    public let firstName: LocalizedString
    public let lastName: LocalizedString
    public let positionCode: Position
    public let gamesPlayed: Int
    public let goals: Int
    public let assists: Int
    public let points: Int
    public let plusMinus: Int
    public let penaltyMinutes: Int
    public let powerPlayGoals: Int
    public let shorthandedGoals: Int
    public let gameWinningGoals: Int
    public let overtimeGoals: Int
    public let shots: Int
    public let shootingPctg: Double
    public let avgTimeOnIcePerGame: Double
    public let avgShiftsPerGame: Double
    public let faceoffWinPctg: Double

    public var fullName: String {
        "\(firstName.default) \(lastName.default)"
    }
}

extension ClubSkaterStats: CustomStringConvertible {
    public var description: String {
        "\(fullName) - \(gamesPlayed) GP, \(goals) G, \(assists) A, \(points) PTS"
    }
}

/// Goalie season statistics for a team
public struct ClubGoalieStats: Sendable, Hashable, Codable, Identifiable {
    public var id: PlayerID { playerId }

    public let playerId: PlayerID
    public let headshot: String
    public let firstName: LocalizedString
    public let lastName: LocalizedString
    public let gamesPlayed: Int
    public let gamesStarted: Int
    public let wins: Int
    public let losses: Int
    public let overtimeLosses: Int
    public let goalsAgainstAverage: Double
    public let savePercentage: Double
    public let shotsAgainst: Int
    public let saves: Int
    public let goalsAgainst: Int
    public let shutouts: Int
    public let goals: Int
    public let assists: Int
    public let points: Int
    public let penaltyMinutes: Int
    public let timeOnIce: Int

    public var fullName: String {
        "\(firstName.default) \(lastName.default)"
    }

    public var record: String {
        "\(wins)-\(losses)-\(overtimeLosses)"
    }
}

extension ClubGoalieStats: CustomStringConvertible {
    public var description: String {
        String(
            format: "%@ - %d GP, %@, %.3f GAA, %.3f SV%%",
            fullName, gamesPlayed, record,
            goalsAgainstAverage, savePercentage
        )
    }
}

/// Club statistics response
public struct ClubStats: Sendable, Hashable, Codable {
    public let season: String
    public let gameType: GameType
    public let skaters: [ClubSkaterStats]
    public let goalies: [ClubGoalieStats]
}

/// Season game type availability for a team
public struct SeasonGameTypes: Sendable, Hashable, Codable {
    public let season: Int
    public let gameTypes: [GameType]

    private enum CodingKeys: String, CodingKey {
        case season, gameTypes
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.season = try container.decode(Int.self, forKey: .season)
        let rawValues = try container.decode([Int].self, forKey: .gameTypes)
        self.gameTypes = rawValues.compactMap { GameType(rawValue: $0) }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(season, forKey: .season)
        try container.encode(gameTypes.map(\.rawValue), forKey: .gameTypes)
    }
}

extension SeasonGameTypes: CustomStringConvertible {
    public var description: String {
        "\(season): \(gameTypes.map(\.displayName).joined(separator: ", "))"
    }
}

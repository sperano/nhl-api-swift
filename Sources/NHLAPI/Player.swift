import Foundation

// MARK: - Player Landing

/// Player landing page data - comprehensive player profile
public struct PlayerLanding: Sendable, Hashable, Codable, Identifiable {
    public var id: PlayerID { playerId }

    public let playerId: PlayerID
    public let isActive: Bool
    public let currentTeamId: TeamID?
    public let currentTeamAbbrev: String?
    public let firstName: LocalizedString
    public let lastName: LocalizedString
    public let sweaterNumber: Int?
    public let position: Position
    public let headshot: String
    public let heroImage: String?
    public let heightInInches: Int
    public let weightInPounds: Int
    public let birthDate: String
    public let birthCity: LocalizedString?
    public let birthStateProvince: LocalizedString?
    public let birthCountry: String?
    public let shootsCatches: Handedness
    public let draftDetails: DraftDetails?
    public let playerSlug: String?
    public let featuredStats: FeaturedStats?
    public let careerTotals: CareerTotals?
    public let seasonTotals: [SeasonTotal]?
    public let awards: [Award]?
    public let lastFiveGames: [GameLog]?

    /// Full name (first + last)
    public var fullName: String {
        "\(firstName.default) \(lastName.default)"
    }

    /// Player's age in years, calculated from birthDate
    public var age: Int? {
        guard let birthDate = NHLDateFormatter.date(from: birthDate) else { return nil }
        let calendar = Calendar(identifier: .gregorian)
        let components = calendar.dateComponents([.year], from: birthDate, to: Date())
        return components.year
    }

    /// Height formatted as feet and inches (e.g., "6'1\"")
    public var heightFormatted: String {
        let feet = heightInInches / 12
        let inches = heightInInches % 12
        return "\(feet)'\(inches)\""
    }

    /// Height in centimeters
    public var heightInCentimeters: Int {
        Int((Double(heightInInches) * 2.54).rounded())
    }

    /// Weight in kilograms
    public var weightInKilograms: Int {
        Int((Double(weightInPounds) * 0.453592).rounded())
    }
}

// MARK: - Draft Details

/// Draft details for a player
public struct DraftDetails: Sendable, Hashable, Codable {
    public let year: Int
    public let teamAbbrev: String
    public let round: Int
    public let pickInRound: Int
    public let overallPick: Int
}

// MARK: - Stats

/// Featured stats shown prominently on player page
public struct FeaturedStats: Sendable, Hashable, Codable {
    public let season: Int
    public let regularSeason: PlayerStats
    public let playoffs: PlayerStats?
}

/// Career totals for regular season and playoffs
public struct CareerTotals: Sendable, Hashable, Codable {
    public let regularSeason: PlayerStats
    public let playoffs: PlayerStats?
}

/// Player statistics (skater or goalie)
public struct PlayerStats: Sendable, Hashable, Codable {
    public let gamesPlayed: Int?

    // Skater stats
    public let goals: Int?
    public let assists: Int?
    public let points: Int?
    public let plusMinus: Int?
    public let pim: Int?
    public let powerPlayGoals: Int?
    public let powerPlayPoints: Int?
    public let shortHandedGoals: Int?
    public let shortHandedPoints: Int?
    public let shots: Int?
    public let shootingPctg: Double?
    public let faceoffWinPctg: Double?
    public let avgToi: String?

    // Goalie stats
    public let wins: Int?
    public let losses: Int?
    public let otLosses: Int?
    public let shutouts: Int?
    public let goalsAgainstAvg: Double?
    public let savePctg: Double?
}

// MARK: - Season Total

/// Season-by-season statistics
public struct SeasonTotal: Sendable, Hashable, Codable {
    public let season: Int
    public let gameType: GameType
    public let leagueAbbrev: String
    public let teamName: LocalizedString
    public let teamCommonName: LocalizedString?
    public let sequence: Int?
    public let gamesPlayed: Int
    public let goals: Int?
    public let assists: Int?
    public let points: Int?
    public let plusMinus: Int?
    public let pim: Int?

    private enum CodingKeys: String, CodingKey {
        case season
        case gameType = "gameTypeId"
        case leagueAbbrev, teamName, teamCommonName, sequence
        case gamesPlayed, goals, assists, points, plusMinus, pim
    }
}

// MARK: - Awards

/// Award won by player
public struct Award: Sendable, Hashable, Codable {
    public let trophy: LocalizedString
    public let seasons: [AwardSeason]
}

/// Season when award was won
public struct AwardSeason: Sendable, Hashable, Codable {
    public let seasonId: Int
}

// MARK: - Game Log

/// Game log entry for a single game
public struct GameLog: Sendable, Hashable, Codable, Identifiable {
    public var id: GameID { gameId }

    public let gameId: GameID
    public let gameDate: String
    public let teamAbbrev: String
    public let homeRoadFlag: HomeRoad
    public let opponentAbbrev: String
    public let goals: Int
    public let assists: Int
    public let points: Int
    public let plusMinus: Int
    public let powerPlayGoals: Int
    public let powerPlayPoints: Int
    public let shots: Int
    public let shifts: Int
    public let toi: String
    public let gameWinningGoals: Int?
    public let otGoals: Int?
    public let pim: Int?
}

/// Player game log response
public struct PlayerGameLog: Sendable, Hashable, Codable {
    /// The player ID (set by client after API call)
    public var playerId: PlayerID

    public let season: Int
    public let gameType: GameType
    public let gameLog: [GameLog]

    private enum CodingKeys: String, CodingKey {
        case season = "seasonId"
        case gameType = "gameTypeId"
        case gameLog
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.playerId = PlayerID(rawValue: 0)
        self.season = try container.decode(Int.self, forKey: .season)
        self.gameType = try container.decode(GameType.self, forKey: .gameType)
        self.gameLog = try container.decode([GameLog].self, forKey: .gameLog)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(season, forKey: .season)
        try container.encode(gameType, forKey: .gameType)
        try container.encode(gameLog, forKey: .gameLog)
    }
}

// MARK: - Player Search

/// Player search result
public struct PlayerSearchResult: Sendable, Hashable, Codable, Identifiable {
    public var id: String { playerId }

    public let playerId: String
    public let name: String
    public let position: Position
    public let teamId: String?
    public let teamAbbrev: String?
    public let sweaterNumber: Int?
    public let active: Bool
    public let height: String?
    public let birthCity: String?
    public let birthStateProvince: String?
    public let birthCountry: String?

    private enum CodingKeys: String, CodingKey {
        case playerId, name
        case position = "positionCode"
        case teamId, teamAbbrev, sweaterNumber, active
        case height, birthCity, birthStateProvince, birthCountry
    }
}

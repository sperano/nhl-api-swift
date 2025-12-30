import Foundation

/// Boxscore response with detailed game and player statistics
public struct Boxscore: Sendable, Codable, Identifiable {
    public let id: GameID
    public let season: Int
    public let gameType: GameType
    public let limitedScoring: Bool
    public let gameDate: String
    public let venue: LocalizedString
    public let venueLocation: LocalizedString
    public let startTimeUTC: String
    public let easternUTCOffset: String
    public let venueUTCOffset: String
    public let tvBroadcasts: [TvBroadcast]
    public let gameState: GameState
    public let gameScheduleState: String
    public let periodDescriptor: PeriodDescriptor
    public let specialEvent: SpecialEvent?
    public let awayTeam: BoxscoreTeam
    public let homeTeam: BoxscoreTeam
    public let clock: GameClock
    public let playerByGameStats: PlayerByGameStats
}

/// TV broadcast information
public struct TvBroadcast: Sendable, Hashable, Codable, Identifiable {
    public let id: Int
    public let market: String
    public let countryCode: String
    public let network: String
    public let sequenceNumber: Int
}

/// Special event information
public struct SpecialEvent: Sendable, Hashable, Codable {
    public let parentId: Int
    public let name: LocalizedString
    public let lightLogoUrl: LocalizedString
}

/// Period descriptor with game period information
public struct PeriodDescriptor: Sendable, Hashable, Codable {
    public let number: Int
    public let periodType: PeriodType
    public let maxRegulationPeriods: Int
}

/// Team information in boxscore
public struct BoxscoreTeam: Sendable, Hashable, Codable, Identifiable {
    public let id: TeamID
    public let commonName: LocalizedString
    public let abbrev: String
    public let score: Int
    public let sog: Int
    public let logo: String
    public let darkLogo: String
    public let placeName: LocalizedString
    public let placeNameWithPreposition: LocalizedString
}

/// Game clock information
public struct GameClock: Sendable, Hashable, Codable {
    public let timeRemaining: String
    public let secondsRemaining: Int
    public let running: Bool
    public let inIntermission: Bool
}

/// Player statistics organized by team
public struct PlayerByGameStats: Sendable, Codable {
    public let awayTeam: TeamPlayerStats
    public let homeTeam: TeamPlayerStats
}

/// Team's player statistics grouped by position
public struct TeamPlayerStats: Sendable, Codable {
    public let forwards: [SkaterStats]
    public let defense: [SkaterStats]
    public let goalies: [GoalieStats]

    private enum CodingKeys: String, CodingKey {
        case forwards, defense, goalies
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.forwards = try container.decodeIfPresent([SkaterStats].self, forKey: .forwards) ?? []
        self.defense = try container.decodeIfPresent([SkaterStats].self, forKey: .defense) ?? []
        self.goalies = try container.decodeIfPresent([GoalieStats].self, forKey: .goalies) ?? []
    }
}

/// Aggregated team statistics for game comparison
public struct TeamGameStats: Sendable, Hashable {
    public var shotsOnGoal: Int = 0
    public var faceoffWins: Int = 0
    public var faceoffTotal: Int = 0
    public var powerPlayGoals: Int = 0
    public var powerPlayOpportunities: Int = 0
    public var penaltyMinutes: Int = 0
    public var hits: Int = 0
    public var blockedShots: Int = 0
    public var giveaways: Int = 0
    public var takeaways: Int = 0

    public init() {}

    /// Calculate aggregated team statistics from individual player stats
    public static func from(teamPlayerStats stats: TeamPlayerStats) -> TeamGameStats {
        var teamStats = TeamGameStats()

        for skater in stats.forwards + stats.defense {
            teamStats.shotsOnGoal += skater.sog
            teamStats.powerPlayGoals += skater.powerPlayGoals
            teamStats.penaltyMinutes += skater.pim
            teamStats.hits += skater.hits
            teamStats.blockedShots += skater.blockedShots
            teamStats.giveaways += skater.giveaways
            teamStats.takeaways += skater.takeaways

            if skater.position == .center && skater.faceoffWinningPctg > 0.0 {
                let estimatedFaceoffs = skater.shifts
                teamStats.faceoffTotal += estimatedFaceoffs
                teamStats.faceoffWins += Int((Double(estimatedFaceoffs) * skater.faceoffWinningPctg).rounded())
            }
        }

        for goalie in stats.goalies {
            if let pim = goalie.pim {
                teamStats.penaltyMinutes += pim
            }
            teamStats.powerPlayOpportunities += goalie.powerPlayGoalsAgainst
        }

        return teamStats
    }

    public var faceoffPercentage: Double {
        guard faceoffTotal > 0 else { return 0.0 }
        return (Double(faceoffWins) / Double(faceoffTotal)) * 100.0
    }

    public var powerPlayPercentage: Double {
        guard powerPlayOpportunities > 0 else { return 0.0 }
        return (Double(powerPlayGoals) / Double(powerPlayOpportunities)) * 100.0
    }
}

/// Skater (forward/defense) statistics
public struct SkaterStats: Sendable, Hashable, Codable, Identifiable {
    public var id: PlayerID { playerId }

    public let playerId: PlayerID
    public let sweaterNumber: Int
    public let name: LocalizedString
    public let position: Position
    public let goals: Int
    public let assists: Int
    public let points: Int
    public let plusMinus: Int
    public let pim: Int
    public let hits: Int
    public let powerPlayGoals: Int
    public let sog: Int
    public let faceoffWinningPctg: Double
    public let toi: String
    public let blockedShots: Int
    public let shifts: Int
    public let giveaways: Int
    public let takeaways: Int
}

/// Goalie statistics
public struct GoalieStats: Sendable, Hashable, Codable, Identifiable {
    public var id: PlayerID { playerId }

    public let playerId: PlayerID
    public let sweaterNumber: Int
    public let name: LocalizedString
    public let position: Position
    public let evenStrengthShotsAgainst: String
    public let powerPlayShotsAgainst: String
    public let shorthandedShotsAgainst: String
    public let saveShotsAgainst: String
    public let savePctg: Double?
    public let evenStrengthGoalsAgainst: Int
    public let powerPlayGoalsAgainst: Int
    public let shorthandedGoalsAgainst: Int
    public let pim: Int?
    public let goalsAgainst: Int
    public let toi: String
    public let starter: Bool?
    public let decision: GoalieDecision?
    public let shotsAgainst: Int
    public let saves: Int
}

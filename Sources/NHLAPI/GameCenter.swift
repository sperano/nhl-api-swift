import Foundation

// MARK: - Game Situation

/// Parsed game situation from situation code
public struct GameSituation: Sendable, Hashable {
    public let awaySkaters: UInt8
    public let awayGoalieIn: Bool
    public let homeSkaters: UInt8
    public let homeGoalieIn: Bool

    /// Parse a situation code string (e.g., "1551")
    public init?(code: String) {
        guard code.count == 4 else { return nil }
        let chars = Array(code)
        guard let away = chars[1].wholeNumberValue,
              let home = chars[2].wholeNumberValue else { return nil }

        self.awaySkaters = UInt8(away)
        self.awayGoalieIn = chars[0] == "1"
        self.homeSkaters = UInt8(home)
        self.homeGoalieIn = chars[3] == "1"
    }

    public var isEvenStrength: Bool { awaySkaters == homeSkaters }
    public var isAwayPowerPlay: Bool { awaySkaters > homeSkaters }
    public var isHomePowerPlay: Bool { homeSkaters > awaySkaters }
    public var isEmptyNet: Bool { !awayGoalieIn || !homeGoalieIn }

    public var strengthDescription: String {
        let base = "\(awaySkaters)v\(homeSkaters)"
        if isEmptyNet { return "\(base) EN" }
        if awaySkaters != homeSkaters { return "\(base) PP" }
        return base
    }
}

extension GameSituation: CustomStringConvertible {
    public var description: String { strengthDescription }
}

// MARK: - Play By Play

/// Play by play response with all game events
public struct PlayByPlay: Sendable, Codable, Identifiable {
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
    public let gameScheduleState: GameScheduleState
    public let periodDescriptor: PeriodDescriptor
    public let specialEvent: SpecialEvent?
    public let awayTeam: BoxscoreTeam
    public let homeTeam: BoxscoreTeam
    public let shootoutInUse: Bool
    public let otInUse: Bool
    public let clock: GameClock
    public let displayPeriod: Int
    public let maxPeriods: Int
    public let gameOutcome: GameOutcome?
    public let plays: [PlayEvent]
    public let rosterSpots: [RosterSpot]
    public let regPeriods: Int?
    public let summary: GameSummary?

    public var goals: [PlayEvent] { plays.filter { $0.typeDescKey == .goal } }
    public var penalties: [PlayEvent] { plays.filter { $0.typeDescKey == .penalty } }
    public var shots: [PlayEvent] { plays.filter { $0.typeDescKey.isScoringEvent } }

    public func recentPlays(_ count: Int) -> [PlayEvent] {
        Array(plays.suffix(count).reversed())
    }

    public func plays(inPeriod period: Int) -> [PlayEvent] {
        plays.filter { $0.periodDescriptor.number == period }
    }

    public func player(withId playerId: PlayerID) -> RosterSpot? {
        rosterSpots.first { $0.playerId == playerId }
    }

    public func roster(forTeam teamId: TeamID) -> [RosterSpot] {
        rosterSpots.filter { $0.teamId == teamId }
    }

    public var currentSituation: GameSituation? {
        plays.last?.situation
    }

    /// Filter goals by team
    public func goalsBy(team teamId: TeamID) -> [PlayEvent] {
        goals.filter { $0.details?.eventOwnerTeamId == teamId }
    }

    /// Filter penalties by team
    public func penaltiesBy(team teamId: TeamID) -> [PlayEvent] {
        penalties.filter { $0.details?.eventOwnerTeamId == teamId }
    }

    /// Filter all plays by team
    public func playsBy(team teamId: TeamID) -> [PlayEvent] {
        plays.filter { $0.details?.eventOwnerTeamId == teamId }
    }
}

/// Game outcome information
public struct GameOutcome: Sendable, Hashable, Codable {
    public let lastPeriodType: PeriodType
}

/// Individual play event in the game
public struct PlayEvent: Sendable, Codable, Identifiable {
    public var id: EventID { eventId }

    public let eventId: EventID
    public let periodDescriptor: PeriodDescriptor
    public let timeInPeriod: String
    public let timeRemaining: String
    public let situationCode: String
    public let homeTeamDefendingSide: DefendingSide
    public let typeCode: Int
    public let typeDescKey: PlayEventType
    public let sortOrder: Int
    public let details: PlayEventDetails?
    public let pptReplayUrl: String?

    public var situation: GameSituation? {
        GameSituation(code: situationCode)
    }
}

/// Details for a play event
public struct PlayEventDetails: Sendable, Hashable, Codable {
    public let xCoord: Int?
    public let yCoord: Int?
    public let zoneCode: ZoneCode?
    public let eventOwnerTeamId: TeamID?
    public let shotType: String?
    public let shootingPlayerId: PlayerID?
    public let goalieInNetId: PlayerID?
    public let blockingPlayerId: PlayerID?
    public let scoringPlayerId: PlayerID?
    public let scoringPlayerTotal: Int?
    public let assist1PlayerId: PlayerID?
    public let assist1PlayerTotal: Int?
    public let assist2PlayerId: PlayerID?
    public let assist2PlayerTotal: Int?
    public let awayScore: Int?
    public let homeScore: Int?
    public let highlightClip: Int?
    public let highlightClipSharingUrl: String?
    public let discreteClip: Int?
    public let typeCode: String?
    public let descKey: String?
    public let duration: Int?
    public let committedByPlayerId: PlayerID?
    public let drawnByPlayerId: PlayerID?
    public let hittingPlayerId: PlayerID?
    public let hitteePlayerId: PlayerID?
    public let winningPlayerId: PlayerID?
    public let losingPlayerId: PlayerID?
    public let playerId: PlayerID?
    public let reason: String?
    public let awaySOG: Int?
    public let homeSOG: Int?
}

/// Roster spot with player information
public struct RosterSpot: Sendable, Hashable, Codable, Identifiable {
    public var id: PlayerID { playerId }

    public let teamId: TeamID
    public let playerId: PlayerID
    public let firstName: LocalizedString
    public let lastName: LocalizedString
    public let sweaterNumber: Int
    public let positionCode: Position
    public let headshot: String

    public var fullName: String {
        "\(firstName.default) \(lastName.default)"
    }
}

// MARK: - Game Matchup

/// Game matchup/landing response
public struct GameMatchup: Sendable, Codable, Identifiable {
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
    public let venueTimezone: String
    public let periodDescriptor: PeriodDescriptor
    public let tvBroadcasts: [TvBroadcast]
    public let gameState: GameState
    public let gameScheduleState: GameScheduleState
    public let specialEvent: SpecialEvent?
    public let awayTeam: MatchupTeam
    public let homeTeam: MatchupTeam
    public let shootoutInUse: Bool
    public let maxPeriods: Int
    public let regPeriods: Int
    public let otInUse: Bool
    public let tiesInUse: Bool
    public let summary: GameSummary?
    public let clock: GameClock?
}

/// Team information in game matchup
public struct MatchupTeam: Sendable, Hashable, Codable, Identifiable {
    public let id: TeamID
    public let commonName: LocalizedString
    public let abbrev: String
    public let placeName: LocalizedString
    public let placeNameWithPreposition: LocalizedString
    public let score: Int
    public let sog: Int
    public let logo: String
    public let darkLogo: String
}

// MARK: - Game Summary

/// Game summary with scoring and penalties
public struct GameSummary: Sendable, Hashable, Codable {
    public let scoring: [PeriodScoring]?
    public let shootout: [ShootoutAttempt]?
    public let threeStars: [ThreeStar]?
    public let penalties: [PeriodPenalties]?
}

/// Scoring summary for a period
public struct PeriodScoring: Sendable, Hashable, Codable {
    public let periodDescriptor: PeriodDescriptor
    public let goals: [GoalSummary]
}

/// Goal summary information
public struct GoalSummary: Sendable, Hashable, Codable, Identifiable {
    public var id: EventID { eventId }

    public let situationCode: String
    public let eventId: EventID
    public let strength: String
    public let playerId: PlayerID
    public let firstName: LocalizedString
    public let lastName: LocalizedString
    public let name: LocalizedString
    public let teamAbbrev: LocalizedString
    public let headshot: String
    public let highlightClipSharingUrl: String?
    public let highlightClip: Int?
    public let discreteClip: Int?
    public let goalsToDate: Int?
    public let awayScore: Int
    public let homeScore: Int
    public let leadingTeamAbbrev: LocalizedString?
    public let timeInPeriod: String
    public let shotType: String
    public let goalModifier: String
    public let assists: [AssistSummary]
    public let homeTeamDefendingSide: DefendingSide
    public let isHome: Bool
}

/// Assist summary information
public struct AssistSummary: Sendable, Hashable, Codable, Identifiable {
    public var id: PlayerID { playerId }

    public let playerId: PlayerID
    public let firstName: LocalizedString
    public let lastName: LocalizedString
    public let name: LocalizedString
    public let assistsToDate: Int
    public let sweaterNumber: Int
}

/// Shootout attempt information
public struct ShootoutAttempt: Sendable, Hashable, Codable, Identifiable {
    public var id: PlayerID { playerId }

    public let sequence: Int
    public let playerId: PlayerID
    public let teamAbbrev: LocalizedString
    public let firstName: LocalizedString
    public let lastName: LocalizedString
    public let shotType: String
    public let result: String
    public let headshot: String
    public let gameWinner: Bool
}

/// Three stars selection
public struct ThreeStar: Sendable, Hashable, Codable, Identifiable {
    public var id: PlayerID { playerId }

    public let star: Int
    public let playerId: PlayerID
    public let teamAbbrev: String
    public let headshot: String
    public let name: String
    public let sweaterNo: Int
    public let position: Position
    public let goals: Int?
    public let assists: Int?
    public let points: Int?
    public let goalsAgainstAverage: Double?
    public let savePctg: Double?

    private enum CodingKeys: String, CodingKey {
        case star, playerId, teamAbbrev, headshot, name, sweaterNo, position
        case goals, assists, points, goalsAgainstAverage, savePctg
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        star = try container.decode(Int.self, forKey: .star)
        playerId = try container.decode(PlayerID.self, forKey: .playerId)
        teamAbbrev = try container.decode(String.self, forKey: .teamAbbrev)
        headshot = try container.decode(String.self, forKey: .headshot)
        sweaterNo = try container.decode(Int.self, forKey: .sweaterNo)
        position = try container.decode(Position.self, forKey: .position)
        goals = try container.decodeIfPresent(Int.self, forKey: .goals)
        assists = try container.decodeIfPresent(Int.self, forKey: .assists)
        points = try container.decodeIfPresent(Int.self, forKey: .points)
        goalsAgainstAverage = try container.decodeIfPresent(Double.self, forKey: .goalsAgainstAverage)
        savePctg = try container.decodeIfPresent(Double.self, forKey: .savePctg)

        // Handle name as either String or LocalizedString
        if let stringName = try? container.decode(String.self, forKey: .name) {
            name = stringName
        } else if let localizedName = try? container.decode(LocalizedString.self, forKey: .name) {
            name = localizedName.default
        } else {
            throw DecodingError.typeMismatch(
                String.self,
                DecodingError.Context(
                    codingPath: container.codingPath + [CodingKeys.name],
                    debugDescription: "Expected String or LocalizedString for name"
                )
            )
        }
    }
}

/// Penalty summary for a period
public struct PeriodPenalties: Sendable, Hashable, Codable {
    public let periodDescriptor: PeriodDescriptor
    public let penalties: [PenaltySummary]
}

/// Penalty summary information
public struct PenaltySummary: Sendable, Hashable, Codable, Identifiable {
    public var id: EventID? { eventId }

    public let timeInPeriod: String
    public let type: String
    public let duration: Int
    public let committedByPlayer: PenaltyPlayer?
    public let teamAbbrev: LocalizedString
    public let drawnBy: PenaltyPlayer?
    public let descKey: String
    public let servedBy: LocalizedString?
    public let eventId: EventID?
}

/// Player information in penalty summary
public struct PenaltyPlayer: Sendable, Hashable, Codable {
    public let firstName: LocalizedString
    public let lastName: LocalizedString
    public let sweaterNumber: Int
}

// MARK: - Shift Chart

/// Shift chart data
public struct ShiftChart: Sendable, Codable {
    public let data: [ShiftEntry]
}

/// Individual shift entry for a player
public struct ShiftEntry: Sendable, Hashable, Codable, Identifiable {
    public let id: Int
    public let detailCode: Int
    public let duration: String?
    public let endTime: String
    public let eventDescription: String?
    public let eventNumber: Int
    public let firstName: String
    public let gameId: GameID
    public let hexValue: String
    public let lastName: String
    public let period: Int
    public let playerId: PlayerID
    public let shiftNumber: Int
    public let startTime: String
    public let teamAbbrev: String
    public let teamId: TeamID
    public let teamName: String
    public let typeCode: Int
}

// MARK: - Season Series

/// Season series matchup
public struct SeasonSeriesMatchup: Sendable, Codable {
    public let seasonSeries: [SeriesGame]
    public let seasonSeriesWins: SeriesWins
    public let gameInfo: SeriesGameInfo
}

/// Individual game in the season series
public struct SeriesGame: Sendable, Hashable, Codable, Identifiable {
    public let id: GameID
    public let season: Int
    public let gameType: GameType
    public let gameDate: String
    public let startTimeUTC: String
    public let easternUTCOffset: String
    public let venueUTCOffset: String
    public let gameState: GameState
    public let gameScheduleState: GameScheduleState
    public let awayTeam: SeriesTeam
    public let homeTeam: SeriesTeam
    public let periodDescriptor: PeriodDescriptor
    public let gameCenterLink: String
    public let gameOutcome: GameOutcome
}

/// Team information in season series
public struct SeriesTeam: Sendable, Hashable, Codable, Identifiable {
    public let id: TeamID
    public let abbrev: String
    public let logo: String
    public let score: Int
}

/// Season series win counts
public struct SeriesWins: Sendable, Hashable, Codable {
    public let awayTeamWins: Int
    public let homeTeamWins: Int
}

/// Game information including officials and scratches
public struct SeriesGameInfo: Sendable, Hashable, Codable {
    public let referees: [LocalizedString]
    public let linesmen: [LocalizedString]
    public let awayTeam: TeamGameInfo
    public let homeTeam: TeamGameInfo
}

/// Team-specific game information
public struct TeamGameInfo: Sendable, Hashable, Codable {
    public let headCoach: LocalizedString
    public let scratches: [ScratchedPlayer]
}

/// Scratched player information
public struct ScratchedPlayer: Sendable, Hashable, Codable, Identifiable {
    public let id: PlayerID
    public let firstName: LocalizedString
    public let lastName: LocalizedString
}

// MARK: - Game Story

/// Game story
public struct GameStory: Sendable, Codable, Identifiable {
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
    public let venueTimezone: String
    public let tvBroadcasts: [TvBroadcast]
    public let gameState: GameState
    public let gameScheduleState: GameScheduleState
    public let awayTeam: StoryTeam
    public let homeTeam: StoryTeam
    public let shootoutInUse: Bool
    public let maxPeriods: Int
    public let regPeriods: Int
    public let otInUse: Bool
    public let tiesInUse: Bool
    public let summary: GameSummary?
}

/// Team information in game story
public struct StoryTeam: Sendable, Hashable, Codable, Identifiable {
    public let id: TeamID
    public let name: LocalizedString
    public let abbrev: String
    public let placeName: LocalizedString
    public let score: Int
    public let sog: Int
    public let logo: String
}

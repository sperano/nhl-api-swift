import Foundation

// MARK: - Player Enums

/// Player position
public enum Position: String, Sendable, Hashable, Codable, CaseIterable {
    case center = "C"
    case leftWing = "L"
    case rightWing = "R"
    case defenseman = "D"
    case goalie = "G"

    /// Whether this position is a forward
    public var isForward: Bool {
        switch self {
        case .center, .leftWing, .rightWing:
            return true
        case .defenseman, .goalie:
            return false
        }
    }

    /// Whether this position is a skater (not a goalie)
    public var isSkater: Bool {
        self != .goalie
    }

    /// Human-readable name for the position
    public var displayName: String {
        switch self {
        case .center:
            return "Center"
        case .leftWing:
            return "Left Wing"
        case .rightWing:
            return "Right Wing"
        case .defenseman:
            return "Defenseman"
        case .goalie:
            return "Goalie"
        }
    }
}

/// Player handedness (shoots/catches)
public enum Handedness: String, Sendable, Hashable, Codable, CaseIterable {
    case left = "L"
    case right = "R"

    public var displayName: String {
        switch self {
        case .left:
            return "Left"
        case .right:
            return "Right"
        }
    }
}

/// Decision credited to a goalie for a game
public enum GoalieDecision: String, Sendable, Hashable, Codable, CaseIterable {
    case win = "W"
    case loss = "L"
    case overtimeLoss = "O"
}

// MARK: - Game Enums

/// Type of period (regulation, overtime, shootout)
public enum PeriodType: String, Sendable, Hashable, Codable, CaseIterable {
    case regulation = "REG"
    case overtime = "OT"
    case shootout = "SO"

    public var displayName: String {
        switch self {
        case .regulation:
            return "Regulation"
        case .overtime:
            return "Overtime"
        case .shootout:
            return "Shootout"
        }
    }
}

/// Whether a team is home or away
public enum HomeRoad: String, Sendable, Hashable, Codable, CaseIterable {
    case home = "H"
    case road = "R"

    public var displayName: String {
        switch self {
        case .home:
            return "Home"
        case .road:
            return "Road"
        }
    }
}

/// Zone on the ice where a play occurred
public enum ZoneCode: String, Sendable, Hashable, Codable, CaseIterable {
    case offensive = "O"
    case defensive = "D"
    case neutral = "N"

    public var displayName: String {
        switch self {
        case .offensive:
            return "Offensive Zone"
        case .defensive:
            return "Defensive Zone"
        case .neutral:
            return "Neutral Zone"
        }
    }
}

/// Which side of the ice a team is defending
public enum DefendingSide: String, Sendable, Hashable, Codable, CaseIterable {
    case left = "left"
    case right = "right"
}

/// Schedule state for a game
public enum GameScheduleState: String, Sendable, Hashable, Codable, CaseIterable {
    case ok = "OK"
    case postponed = "PPD"
    case suspended = "SUSP"
    case cancelled = "CNCL"
}

// MARK: - Play Event Types

/// Type of play event in play-by-play data
public enum PlayEventType: String, Sendable, Hashable, Codable, CaseIterable {
    // Game flow events
    case gameStart = "game-start"
    case periodStart = "period-start"
    case periodEnd = "period-end"
    case gameEnd = "game-end"
    case stoppage = "stoppage"

    // Scoring events
    case goal = "goal"
    case shot = "shot-on-goal"
    case missedShot = "missed-shot"
    case blockedShot = "blocked-shot"

    // Penalties
    case penalty = "penalty"

    // Face-offs
    case faceoff = "faceoff"

    // Physical play
    case hit = "hit"
    case giveaway = "giveaway"
    case takeaway = "takeaway"

    // Goalie events
    case shootoutComplete = "shootout-complete"

    // Other
    case delayedPenalty = "delayed-penalty"
    case failedShotAttempt = "failed-shot-attempt"

    /// Whether this event type is a scoring-related event
    public var isScoringEvent: Bool {
        switch self {
        case .goal, .shot, .missedShot, .blockedShot:
            return true
        default:
            return false
        }
    }

    /// Whether this event type marks a period/game boundary
    public var isPeriodBoundary: Bool {
        switch self {
        case .periodStart, .periodEnd, .gameStart, .gameEnd:
            return true
        default:
            return false
        }
    }
}

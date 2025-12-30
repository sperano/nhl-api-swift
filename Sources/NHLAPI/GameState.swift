import Foundation

/// Current state of a game
public enum GameState: String, Sendable, Hashable, Codable, CaseIterable {
    /// Game is scheduled for the future
    case future = "FUT"

    /// Pre-game warmups
    case preGame = "PRE"

    /// Game is currently in progress
    case live = "LIVE"

    /// Game has ended (regulation, OT, or shootout)
    case final = "FINAL"

    /// Game is not currently active (off day)
    case off = "OFF"

    /// Game has been postponed
    case postponed = "PPD"

    /// Game has been suspended
    case suspended = "SUSP"

    /// Game is in a critical state (overtime, late in close game)
    case critical = "CRIT"

    /// Whether the game has started (pre-game or later)
    public var hasStarted: Bool {
        switch self {
        case .future, .off, .postponed:
            return false
        case .preGame, .live, .final, .suspended, .critical:
            return true
        }
    }

    /// Whether the game is currently being played
    public var isLive: Bool {
        switch self {
        case .live, .critical:
            return true
        case .future, .preGame, .final, .off, .postponed, .suspended:
            return false
        }
    }

    /// Whether the game has finished
    public var isFinal: Bool {
        self == .final
    }

    /// Whether the game can still be played (not postponed/cancelled)
    public var isPlayable: Bool {
        switch self {
        case .future, .preGame, .live, .final, .critical:
            return true
        case .off, .postponed, .suspended:
            return false
        }
    }
}

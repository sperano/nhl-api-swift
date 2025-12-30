import Foundation

/// Type of NHL game
public enum GameType: Int, Sendable, Hashable, Codable, CaseIterable {
    case preseason = 1
    case regularSeason = 2
    case playoffs = 3
    case allStar = 4

    /// Human-readable name for the game type
    public var displayName: String {
        switch self {
        case .preseason:
            return "Preseason"
        case .regularSeason:
            return "Regular Season"
        case .playoffs:
            return "Playoffs"
        case .allStar:
            return "All-Star"
        }
    }

    /// Short code used in game IDs (e.g., "02" for regular season)
    public var gameIDCode: String {
        String(format: "%02d", rawValue)
    }
}

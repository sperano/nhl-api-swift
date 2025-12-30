import Foundation

/// Standing entry for a team
public struct Standing: Sendable, Hashable, Codable {
    public let conferenceAbbrev: String?
    public let conferenceName: String?
    public let divisionAbbrev: String
    public let divisionName: String
    public let teamName: LocalizedString
    public let teamCommonName: LocalizedString
    public let teamAbbrev: LocalizedString
    public let teamLogo: String
    public let wins: Int
    public let losses: Int
    public let otLosses: Int
    public let points: Int

    /// Total games played
    public var gamesPlayed: Int {
        wins + losses + otLosses
    }

    /// Record string (e.g., "15-10-2")
    public var record: String {
        "\(wins)-\(losses)-\(otLosses)"
    }

    /// Win percentage (wins / games played)
    public var winPercentage: Double {
        guard gamesPlayed > 0 else { return 0.0 }
        return Double(wins) / Double(gamesPlayed)
    }

    /// Points percentage (points / possible points)
    public var pointsPercentage: Double {
        guard gamesPlayed > 0 else { return 0.0 }
        return Double(points) / Double(gamesPlayed * 2)
    }
}

extension Standing: CustomStringConvertible {
    public var description: String {
        "\(teamAbbrev.default): \(points) pts (\(record))"
    }
}

/// Standings response from the API
struct StandingsResponse: Sendable, Hashable, Codable {
    let standings: [Standing]
}

/// Season information from the seasons manifest
public struct SeasonInfo: Sendable, Hashable, Codable, Identifiable {
    public let id: Int
    public let standingsStart: String
    public let standingsEnd: String
}

/// Seasons manifest response
struct SeasonsResponse: Sendable, Hashable, Codable {
    let seasons: [SeasonInfo]
}

import Foundation

/// NHL API client for fetching hockey data
public actor NHLClient {
    private let httpClient: HTTPClient

    /// Create a new NHL client with default configuration
    public init() {
        self.httpClient = HTTPClient(config: .default)
    }

    /// Create a new NHL client with custom configuration
    public init(config: ClientConfig) {
        self.httpClient = HTTPClient(config: config)
    }

    /// Create a new NHL client with a custom HTTP client (useful for testing)
    public init(httpClient: HTTPClient) {
        self.httpClient = httpClient
    }

    // MARK: - Standings

    /// Gets current league standings
    public func standings() async throws -> [Standing] {
        try await standings(for: nil)
    }

    /// Gets league standings for a specific date
    /// - Parameter date: The date to get standings for, or nil for current
    public func standings(for date: Date?) async throws -> [Standing] {
        let dateString = NHLDateFormatter.apiString(from: date ?? Date())
        let response: StandingsResponse = try await httpClient.getJSON(
            endpoint: .apiWebV1,
            resource: "standings/\(dateString)"
        )
        return response.standings
    }

    /// Gets league standings for a specific season
    /// - Parameter season: Season to get standings for
    public func standings(for season: Season) async throws -> [Standing] {
        let seasons = try await seasonManifest()
        guard let seasonData = seasons.first(where: { $0.id == season.startYear * 10000 + season.endYear }) else {
            throw NHLAPIError.other(message: "Invalid season: \(season)")
        }
        let response: StandingsResponse = try await httpClient.getJSON(
            endpoint: .apiWebV1,
            resource: "standings/\(seasonData.standingsEnd)"
        )
        return response.standings
    }

    /// Gets metadata for all NHL seasons
    public func seasonManifest() async throws -> [SeasonInfo] {
        let response: SeasonsResponse = try await httpClient.getJSON(
            endpoint: .apiWebV1,
            resource: "standings-season"
        )
        return response.seasons
    }

    // MARK: - Game Center

    /// Gets boxscore data for a game
    public func boxscore(gameId: GameID) async throws -> Boxscore {
        try await httpClient.getJSON(
            endpoint: .apiWebV1,
            resource: "gamecenter/\(gameId)/boxscore"
        )
    }

    /// Gets play-by-play data for a game
    public func playByPlay(gameId: GameID) async throws -> PlayByPlay {
        try await httpClient.getJSON(
            endpoint: .apiWebV1,
            resource: "gamecenter/\(gameId)/play-by-play"
        )
    }

    /// Gets game landing/matchup data (lighter than play-by-play)
    public func landing(gameId: GameID) async throws -> GameMatchup {
        try await httpClient.getJSON(
            endpoint: .apiWebV1,
            resource: "gamecenter/\(gameId)/landing"
        )
    }

    /// Gets season series matchup data including head-to-head records
    public func seasonSeries(gameId: GameID) async throws -> SeasonSeriesMatchup {
        try await httpClient.getJSON(
            endpoint: .apiWebV1,
            resource: "gamecenter/\(gameId)/right-rail"
        )
    }

    /// Gets game story narrative content
    public func gameStory(gameId: GameID) async throws -> GameStory {
        try await httpClient.getJSON(
            endpoint: .apiWebV1,
            resource: "wsc/game-story/\(gameId)"
        )
    }

    /// Gets shift chart data for a game
    public func shiftChart(gameId: GameID) async throws -> ShiftChart {
        let cayenneExpr = "gameId=\(gameId) and ((duration != '00:00' and typeCode = 517) or typeCode != 517 )"
        return try await httpClient.getJSON(
            endpoint: .apiStats,
            resource: "en/shiftcharts",
            queryParams: [
                "cayenneExp": cayenneExpr,
                "exclude": "eventDetails"
            ]
        )
    }

    // MARK: - Schedule

    /// Gets daily schedule for a specific date
    /// - Parameter date: The date to get schedule for, or nil for today
    public func dailySchedule(date: Date? = nil) async throws -> DailySchedule {
        let dateString = NHLDateFormatter.apiString(from: date ?? Date())
        let response: WeeklyScheduleResponse = try await httpClient.getJSON(
            endpoint: .apiWebV1,
            resource: "schedule/\(dateString)"
        )
        return extractDailySchedule(from: response, date: dateString)
    }

    /// Gets weekly schedule starting from a specific date
    /// - Parameter date: The starting date, or nil for today
    public func weeklySchedule(date: Date? = nil) async throws -> WeeklyScheduleResponse {
        let dateString = NHLDateFormatter.apiString(from: date ?? Date())
        return try await httpClient.getJSON(
            endpoint: .apiWebV1,
            resource: "schedule/\(dateString)"
        )
    }

    /// Gets daily game scores for a specific date
    /// - Parameter date: The date to get scores for, or nil for today
    public func dailyScores(date: Date? = nil) async throws -> DailyScores {
        let dateString = NHLDateFormatter.apiString(from: date ?? Date())
        return try await httpClient.getJSON(
            endpoint: .apiWebV1,
            resource: "score/\(dateString)"
        )
    }

    /// Gets weekly schedule for a specific team
    /// - Parameters:
    ///   - teamAbbrev: Team abbreviation (e.g., "MTL", "TOR", "BUF")
    ///   - date: The starting date, or nil for today
    public func teamWeeklySchedule(teamAbbrev: String, date: Date? = nil) async throws -> TeamScheduleResponse {
        let dateString = NHLDateFormatter.apiString(from: date ?? Date())
        return try await httpClient.getJSON(
            endpoint: .apiWebV1,
            resource: "club-schedule/\(teamAbbrev)/week/\(dateString)"
        )
    }

    private func extractDailySchedule(from weeklyResponse: WeeklyScheduleResponse, date dateString: String) -> DailySchedule {
        let games = weeklyResponse.gameWeek.first { $0.date == dateString }?.games ?? []
        return DailySchedule(
            nextStartDate: weeklyResponse.nextStartDate,
            previousStartDate: weeklyResponse.previousStartDate,
            date: dateString,
            games: games,
            numberOfGames: games.count
        )
    }

    // MARK: - Players

    /// Gets comprehensive player profile data
    /// - Parameter playerId: NHL player ID
    public func player(_ playerId: PlayerID) async throws -> PlayerLanding {
        try await httpClient.getJSON(
            endpoint: .apiWebV1,
            resource: "player/\(playerId)/landing"
        )
    }

    /// Gets game-by-game log for a player's season
    /// - Parameters:
    ///   - playerId: NHL player ID
    ///   - season: Season in YYYYYYYY format (e.g., 20232024)
    ///   - gameType: Game type (regular season, playoffs, etc.)
    public func playerGameLog(
        _ playerId: PlayerID,
        season: Int,
        gameType: GameType
    ) async throws -> PlayerGameLog {
        var gameLog: PlayerGameLog = try await httpClient.getJSON(
            endpoint: .apiWebV1,
            resource: "player/\(playerId)/game-log/\(season)/\(gameType.rawValue)"
        )
        gameLog.playerId = playerId
        return gameLog
    }

    /// Search for players by name
    /// - Parameters:
    ///   - query: Search query (player name or partial name)
    ///   - limit: Maximum number of results to return (default 20)
    public func searchPlayers(query: String, limit: Int = 20) async throws -> [PlayerSearchResult] {
        try await httpClient.getJSON(
            endpoint: .searchV1,
            resource: "search/player",
            queryParams: [
                "culture": "en-us",
                "q": query,
                "limit": String(limit)
            ]
        )
    }

    // MARK: - Teams

    /// Gets the current roster for a team
    /// - Parameter teamAbbrev: Team abbreviation (e.g., "MTL", "TOR", "BUF")
    public func roster(teamAbbrev: String) async throws -> Roster {
        try await httpClient.getJSON(
            endpoint: .apiWebV1,
            resource: "roster/\(teamAbbrev)/current"
        )
    }

    /// Gets the roster for a team in a specific season
    /// - Parameters:
    ///   - teamAbbrev: Team abbreviation (e.g., "MTL", "TOR", "BUF")
    ///   - season: Season in YYYYYYYY format (e.g., 20242025)
    public func roster(teamAbbrev: String, season: Int) async throws -> Roster {
        try await httpClient.getJSON(
            endpoint: .apiWebV1,
            resource: "roster/\(teamAbbrev)/\(season)"
        )
    }

    /// Gets player statistics for a team in a specific season
    /// - Parameters:
    ///   - teamAbbrev: Team abbreviation (e.g., "MTL", "TOR", "BUF")
    ///   - season: Season in YYYYYYYY format (e.g., 20242025)
    ///   - gameType: Game type (regular season, playoffs, etc.)
    public func clubStats(teamAbbrev: String, season: Int, gameType: GameType) async throws -> ClubStats {
        try await httpClient.getJSON(
            endpoint: .apiWebV1,
            resource: "club-stats/\(teamAbbrev)/\(season)/\(gameType.rawValue)"
        )
    }

    /// Gets available seasons and game types for a team
    /// - Parameter teamAbbrev: Team abbreviation (e.g., "MTL", "TOR", "BUF")
    public func clubStatsSeasons(teamAbbrev: String) async throws -> [SeasonGameTypes] {
        try await httpClient.getJSON(
            endpoint: .apiWebV1,
            resource: "club-stats-season/\(teamAbbrev)"
        )
    }

    // MARK: - Franchises

    /// Gets a list of all NHL franchises (past and current)
    public func franchises() async throws -> [Franchise] {
        let response: FranchisesResponse = try await httpClient.getJSON(
            endpoint: .apiStats,
            resource: "en/franchise"
        )
        return response.data
    }
}

// MARK: - Supporting Response Types

struct FranchisesResponse: Sendable, Codable {
    let data: [Franchise]
}

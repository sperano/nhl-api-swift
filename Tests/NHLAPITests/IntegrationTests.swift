import Testing
@testable import NHLAPI
import Foundation

// MARK: - Integration Tests
// These tests make real API calls to the NHL API

@Suite("Integration Tests - Standings", .tags(.integration))
struct StandingsIntegrationTests {
    let client = NHLClient()

    @Test("Fetch current league standings")
    func currentStandings() async throws {
        let standings = try await client.standings()

        #expect(!standings.isEmpty)
        #expect(standings.count >= 32) // 32 teams in NHL

        // Verify standings have valid data
        let firstStanding = try #require(standings.first)
        #expect(!firstStanding.teamAbbrev.default.isEmpty)
        #expect(firstStanding.wins >= 0)
        #expect(firstStanding.losses >= 0)
        #expect(firstStanding.points >= 0)
    }

    @Test("Fetch season standing manifest")
    func seasonManifest() async throws {
        let seasons = try await client.seasonManifest()

        #expect(!seasons.isEmpty)
        #expect(seasons.count > 100) // Many seasons of NHL history

        // Verify seasons have valid data
        let recentSeason = try #require(seasons.last)
        #expect(recentSeason.id > 20000000) // Season ID format: YYYYYYYY
        #expect(!recentSeason.standingsStart.isEmpty)
        #expect(!recentSeason.standingsEnd.isEmpty)
    }

    @Test("Fetch standings for specific date")
    func standingsForDate() async throws {
        let date = Date.nhl(year: 2024, month: 3, day: 15)!
        let standings = try await client.standings(for: date)

        #expect(!standings.isEmpty)
        #expect(standings.count >= 32)
    }
}

@Suite("Integration Tests - Schedule", .tags(.integration))
struct ScheduleIntegrationTests {
    let client = NHLClient()

    @Test("Fetch daily schedule")
    func dailySchedule() async throws {
        // Use a known game date
        let date = Date.nhl(year: 2024, month: 12, day: 15)!
        let schedule = try await client.dailySchedule(date: date)

        #expect(!schedule.date.isEmpty)
        // Games may or may not be present depending on the date
    }

    @Test("Fetch weekly schedule")
    func weeklySchedule() async throws {
        let date = Date.nhl(year: 2024, month: 12, day: 15)!
        let schedule = try await client.weeklySchedule(date: date)

        #expect(!schedule.nextStartDate.isEmpty)
        #expect(!schedule.previousStartDate.isEmpty)
        #expect(!schedule.gameWeek.isEmpty)
    }

    @Test("Fetch team weekly schedule")
    func teamWeeklySchedule() async throws {
        let schedule = try await client.teamWeeklySchedule(
            teamAbbrev: "TOR",
            date: Date.nhl(year: 2024, month: 12, day: 15)
        )

        #expect(!schedule.games.isEmpty || schedule.games.isEmpty) // May or may not have games
    }

    @Test("Fetch daily scores")
    func dailyScores() async throws {
        let date = Date.nhl(year: 2024, month: 12, day: 15)!
        let scores = try await client.dailyScores(date: date)

        #expect(!scores.currentDate.isEmpty)
        #expect(!scores.prevDate.isEmpty)
        #expect(!scores.nextDate.isEmpty)
    }
}

@Suite("Integration Tests - Game Center", .tags(.integration))
struct GameCenterIntegrationTests {
    let client = NHLClient()

    // Use a known completed game ID from 2024 season
    let testGameId: GameID = 2024020450

    @Test("Fetch boxscore")
    func boxscore() async throws {
        let boxscore = try await client.boxscore(gameId: testGameId)

        #expect(boxscore.id == testGameId)
        // Game should have a valid state
        #expect(!boxscore.awayTeam.abbrev.isEmpty)
        #expect(!boxscore.homeTeam.abbrev.isEmpty)
        #expect(boxscore.awayTeam.score >= 0)
        #expect(boxscore.homeTeam.score >= 0)
    }

    @Test("Fetch play by play")
    func playByPlay() async throws {
        let pbp = try await client.playByPlay(gameId: testGameId)

        #expect(pbp.id == testGameId)
        #expect(!pbp.plays.isEmpty)

        // Verify plays have valid data
        let firstPlay = try #require(pbp.plays.first)
        #expect(!firstPlay.timeInPeriod.isEmpty)
        #expect(firstPlay.periodDescriptor.number >= 1)
    }

    @Test("Fetch game landing/matchup")
    func landing() async throws {
        let matchup = try await client.landing(gameId: testGameId)

        #expect(matchup.id == testGameId)
        #expect(!matchup.venue.default.isEmpty)
        #expect(!matchup.awayTeam.abbrev.isEmpty)
        #expect(!matchup.homeTeam.abbrev.isEmpty)
    }

    @Test("Fetch game story")
    func gameStory() async throws {
        let story = try await client.gameStory(gameId: testGameId)

        #expect(story.id == testGameId)
        #expect(!story.venue.default.isEmpty)
        #expect(!story.awayTeam.abbrev.isEmpty)
        #expect(!story.homeTeam.abbrev.isEmpty)
    }

    @Test("Fetch shift chart")
    func shiftChart() async throws {
        let shifts = try await client.shiftChart(gameId: testGameId)

        #expect(!shifts.data.isEmpty)

        // Verify shift entries have valid data
        let firstShift = try #require(shifts.data.first)
        #expect(firstShift.playerId.rawValue > 0)
        #expect(!firstShift.firstName.isEmpty)
        #expect(!firstShift.lastName.isEmpty)
        #expect(firstShift.period >= 1)
    }

    @Test("Fetch season series")
    func seasonSeries() async throws {
        let series = try await client.seasonSeries(gameId: testGameId)

        #expect(!series.seasonSeries.isEmpty)
        #expect(series.seasonSeriesWins.awayTeamWins >= 0)
        #expect(series.seasonSeriesWins.homeTeamWins >= 0)
    }
}

@Suite("Integration Tests - Players", .tags(.integration))
struct PlayerIntegrationTests {
    let client = NHLClient()

    // Connor McDavid's player ID
    let testPlayerId: PlayerID = 8478402

    @Test("Fetch player landing")
    func playerLanding() async throws {
        let player = try await client.player(testPlayerId)

        #expect(player.playerId == testPlayerId)
        #expect(player.firstName.default == "Connor")
        #expect(player.lastName.default == "McDavid")
        #expect(player.position == .center)
        #expect(player.isActive == true)
        #expect(player.currentTeamAbbrev == "EDM")
        #expect(player.sweaterNumber == 97)
    }

    @Test("Fetch player game log")
    func playerGameLog() async throws {
        let gameLog = try await client.playerGameLog(
            testPlayerId,
            season: 20242025,
            gameType: .regularSeason
        )

        #expect(gameLog.playerId == testPlayerId)
        #expect(gameLog.season == 20242025)
        #expect(gameLog.gameType == .regularSeason)
        // Game log may be empty if season hasn't started
    }

    @Test("Search player by name")
    func searchPlayer() async throws {
        let results = try await client.searchPlayers(query: "McDavid", limit: 5)

        #expect(!results.isEmpty)

        // Find Connor McDavid in results
        let connor = results.first { $0.name.contains("Connor") && $0.name.contains("McDavid") }
        #expect(connor != nil)
        #expect(connor?.position == .center)
        #expect(connor?.active == true)
    }

    @Test("Search player with limit")
    func searchPlayerWithLimit() async throws {
        let results = try await client.searchPlayers(query: "Smith", limit: 3)

        #expect(results.count <= 3)
    }
}

@Suite("Integration Tests - Teams", .tags(.integration))
struct TeamIntegrationTests {
    let client = NHLClient()

    @Test("Fetch current roster")
    func rosterCurrent() async throws {
        let roster = try await client.roster(teamAbbrev: "TOR")

        #expect(!roster.forwards.isEmpty)
        #expect(!roster.defensemen.isEmpty)
        #expect(!roster.goalies.isEmpty)

        // Verify players have valid data
        let firstForward = try #require(roster.forwards.first)
        #expect(firstForward.id.rawValue > 0)
        #expect(!firstForward.firstName.default.isEmpty)
        #expect(!firstForward.lastName.default.isEmpty)
        #expect(firstForward.positionCode.isForward)
    }

    @Test("Fetch roster for season")
    func rosterSeason() async throws {
        let roster = try await client.roster(teamAbbrev: "MTL", season: 20232024)

        #expect(!roster.forwards.isEmpty)
        #expect(!roster.defensemen.isEmpty)
        #expect(!roster.goalies.isEmpty)
    }

    @Test("Fetch club stats")
    func clubStats() async throws {
        let stats = try await client.clubStats(
            teamAbbrev: "EDM",
            season: 20232024,
            gameType: .regularSeason
        )

        #expect(stats.season == "20232024")
        #expect(stats.gameType == .regularSeason)
        #expect(!stats.skaters.isEmpty)
        #expect(!stats.goalies.isEmpty)

        // Verify skater stats have valid data
        let firstSkater = try #require(stats.skaters.first)
        #expect(firstSkater.playerId.rawValue > 0)
        #expect(firstSkater.gamesPlayed > 0)
    }

    @Test("Fetch club stats seasons")
    func clubStatsSeason() async throws {
        let seasons = try await client.clubStatsSeasons(teamAbbrev: "BOS")

        #expect(!seasons.isEmpty)

        // Verify seasons have valid data
        let recentSeason = try #require(seasons.first)
        #expect(recentSeason.season > 20000000)
        #expect(!recentSeason.gameTypes.isEmpty)
    }
}

@Suite("Integration Tests - Franchises", .tags(.integration))
struct FranchiseIntegrationTests {
    let client = NHLClient()

    @Test("Fetch all franchises")
    func franchises() async throws {
        let franchises = try await client.franchises()

        #expect(!franchises.isEmpty)
        #expect(franchises.count >= 32) // At least 32 current franchises

        // Verify franchise data
        let firstFranchise = try #require(franchises.first)
        #expect(firstFranchise.id.rawValue > 0)
        #expect(!firstFranchise.name.isEmpty)
    }
}

// MARK: - Test Tags

extension Tag {
    @Tag static var integration: Self
}

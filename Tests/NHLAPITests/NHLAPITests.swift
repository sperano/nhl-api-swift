import Testing
@testable import NHLAPI
import Foundation

// MARK: - Error Tests

@Suite("NHLAPIError Tests")
struct ErrorTests {
    @Test("Error description for resourceNotFound")
    func resourceNotFoundDescription() {
        let error = NHLAPIError.resourceNotFound(message: "Player not found")
        #expect(error.errorDescription?.contains("Resource not found") == true)
        #expect(error.errorDescription?.contains("Player not found") == true)
    }

    @Test("Error description for rateLimitExceeded")
    func rateLimitExceededDescription() {
        let error = NHLAPIError.rateLimitExceeded
        #expect(error.errorDescription == "Rate limit exceeded")
    }

    @Test("Error description for serverError")
    func serverErrorDescription() {
        let error = NHLAPIError.serverError(statusCode: 503, message: "Service unavailable")
        #expect(error.errorDescription?.contains("503") == true)
        #expect(error.errorDescription?.contains("Service unavailable") == true)
    }

}

// MARK: - ID Tests

@Suite("GameID Tests")
struct GameIDTests {
    @Test("GameID from integer literal")
    func integerLiteral() {
        let gameId: GameID = 2023020001
        #expect(gameId.rawValue == 2023020001)
    }

    @Test("GameID from string")
    func fromString() {
        let gameId = GameID("2023020001")
        #expect(gameId?.rawValue == 2023020001)
    }

    @Test("GameID invalid string returns nil")
    func invalidString() {
        let gameId = GameID("invalid")
        #expect(gameId == nil)
    }

    @Test("GameID description")
    func description() {
        let gameId: GameID = 2023020001
        #expect(gameId.description == "2023020001")
    }

    @Test("GameID equality")
    func equality() {
        let id1: GameID = 2023020001
        let id2: GameID = 2023020001
        let id3: GameID = 2023020002
        #expect(id1 == id2)
        #expect(id1 != id3)
    }

    @Test("GameID Codable roundtrip")
    func codable() throws {
        let gameId: GameID = 2023020001
        let encoded = try JSONEncoder().encode(gameId)
        let decoded = try JSONDecoder().decode(GameID.self, from: encoded)
        #expect(decoded == gameId)
    }

    @Test("GameID RawRepresentable")
    func rawRepresentable() {
        let gameId = GameID(rawValue: 2023020001)
        #expect(gameId.rawValue == 2023020001)
    }
}

@Suite("PlayerID Tests")
struct PlayerIDTests {
    @Test("PlayerID from integer literal")
    func integerLiteral() {
        let playerId: PlayerID = 8478402
        #expect(playerId.rawValue == 8478402)
    }

    @Test("PlayerID RawRepresentable")
    func rawRepresentable() {
        let playerId = PlayerID(rawValue: 8478402)
        #expect(playerId.rawValue == 8478402)
    }
}

@Suite("TeamID Tests")
struct TeamIDTests {
    @Test("TeamID from integer literal")
    func integerLiteral() {
        let teamId: TeamID = 10
        #expect(teamId.rawValue == 10)
    }

    @Test("TeamID RawRepresentable")
    func rawRepresentable() {
        let teamId = TeamID(rawValue: 10)
        #expect(teamId.rawValue == 10)
    }
}

// MARK: - Date Tests

@Suite("Date Extension Tests")
struct DateExtensionTests {
    @Test("Date.nhl creates valid date")
    func nhlDate() {
        let date = Date.nhl(year: 2024, month: 1, day: 15)
        #expect(date != nil)
    }

    @Test("NHLDateFormatter formats date correctly")
    func dateFormatting() {
        let date = Date.nhl(year: 2024, month: 1, day: 15)!
        let formatted = NHLDateFormatter.apiString(from: date)
        #expect(formatted == "2024-01-15")
    }
}

// MARK: - Season Tests

@Suite("Season Tests")
struct SeasonTests {
    @Test("Season from start year")
    func fromStartYear() {
        let season = Season(startYear: 2024)
        #expect(season.startYear == 2024)
        #expect(season.endYear == 2025)
    }

    @Test("Season from start and end years")
    func fromBothYears() {
        let season = Season(startYear: 2024, endYear: 2025)
        #expect(season.startYear == 2024)
        #expect(season.endYear == 2025)
    }

    @Test("Season parse from 8-digit string")
    func parseEightDigit() {
        let season = Season.parse("20242025")
        #expect(season?.startYear == 2024)
        #expect(season?.endYear == 2025)
    }

    @Test("Season parse from hyphenated string")
    func parseHyphenated() {
        let season = Season.parse("2024-2025")
        #expect(season?.startYear == 2024)
        #expect(season?.endYear == 2025)
    }

    @Test("Season invalid parse returns nil")
    func invalidParse() {
        let season = Season.parse("invalid")
        #expect(season == nil)
    }

    @Test("Season API format")
    func apiFormat() {
        let season = Season(startYear: 2024)
        #expect(season.apiFormat == "20242025")
    }

    @Test("Season display format")
    func displayFormat() {
        let season = Season(startYear: 2024)
        #expect(season.displayFormat == "2024-2025")
    }

    @Test("Season description")
    func description() {
        let season = Season(startYear: 2024)
        #expect(season.description == "2024-2025")
    }

    @Test("Season Codable roundtrip")
    func codable() throws {
        let season = Season(startYear: 2024)
        let encoded = try JSONEncoder().encode(season)
        let decoded = try JSONDecoder().decode(Season.self, from: encoded)
        #expect(decoded == season)
    }

    @Test("Season Comparable")
    func comparable() {
        let season1 = Season(startYear: 2023)
        let season2 = Season(startYear: 2024)
        #expect(season1 < season2)
        #expect(season2 > season1)
    }
}

// MARK: - GameType Tests

@Suite("GameType Tests")
struct GameTypeTests {
    @Test("GameType raw values")
    func rawValues() {
        #expect(GameType.preseason.rawValue == 1)
        #expect(GameType.regularSeason.rawValue == 2)
        #expect(GameType.playoffs.rawValue == 3)
        #expect(GameType.allStar.rawValue == 4)
    }

    @Test("GameType display names")
    func displayNames() {
        #expect(GameType.preseason.displayName == "Preseason")
        #expect(GameType.regularSeason.displayName == "Regular Season")
        #expect(GameType.playoffs.displayName == "Playoffs")
        #expect(GameType.allStar.displayName == "All-Star")
    }

    @Test("GameType gameIDCode")
    func gameIDCode() {
        #expect(GameType.preseason.gameIDCode == "01")
        #expect(GameType.regularSeason.gameIDCode == "02")
        #expect(GameType.playoffs.gameIDCode == "03")
        #expect(GameType.allStar.gameIDCode == "04")
    }
}

// MARK: - GameState Tests

@Suite("GameState Tests")
struct GameStateTests {
    @Test("GameState raw values")
    func rawValues() {
        #expect(GameState.future.rawValue == "FUT")
        #expect(GameState.preGame.rawValue == "PRE")
        #expect(GameState.live.rawValue == "LIVE")
        #expect(GameState.final.rawValue == "FINAL")
        #expect(GameState.off.rawValue == "OFF")
        #expect(GameState.postponed.rawValue == "PPD")
        #expect(GameState.suspended.rawValue == "SUSP")
        #expect(GameState.critical.rawValue == "CRIT")
    }

    @Test("GameState hasStarted")
    func hasStarted() {
        #expect(GameState.future.hasStarted == false)
        #expect(GameState.off.hasStarted == false)
        #expect(GameState.postponed.hasStarted == false)
        #expect(GameState.preGame.hasStarted == true)
        #expect(GameState.live.hasStarted == true)
        #expect(GameState.final.hasStarted == true)
        #expect(GameState.critical.hasStarted == true)
    }

    @Test("GameState isLive")
    func isLive() {
        #expect(GameState.live.isLive == true)
        #expect(GameState.critical.isLive == true)
        #expect(GameState.future.isLive == false)
        #expect(GameState.final.isLive == false)
    }

    @Test("GameState isFinal")
    func isFinal() {
        #expect(GameState.final.isFinal == true)
        #expect(GameState.live.isFinal == false)
    }
}

// MARK: - Position Tests

@Suite("Position Tests")
struct PositionTests {
    @Test("Position raw values")
    func rawValues() {
        #expect(Position.center.rawValue == "C")
        #expect(Position.leftWing.rawValue == "L")
        #expect(Position.rightWing.rawValue == "R")
        #expect(Position.defenseman.rawValue == "D")
        #expect(Position.goalie.rawValue == "G")
    }

    @Test("Position isForward")
    func isForward() {
        #expect(Position.center.isForward == true)
        #expect(Position.leftWing.isForward == true)
        #expect(Position.rightWing.isForward == true)
        #expect(Position.defenseman.isForward == false)
        #expect(Position.goalie.isForward == false)
    }

    @Test("Position isSkater")
    func isSkater() {
        #expect(Position.center.isSkater == true)
        #expect(Position.leftWing.isSkater == true)
        #expect(Position.rightWing.isSkater == true)
        #expect(Position.defenseman.isSkater == true)
        #expect(Position.goalie.isSkater == false)
    }
}

// MARK: - GameSituation Tests

@Suite("GameSituation Tests")
struct GameSituationTests {
    @Test("GameSituation from valid code")
    func fromValidCode() {
        let situation = GameSituation(code: "1551")
        #expect(situation != nil)
        #expect(situation?.awayGoalieIn == true)
        #expect(situation?.awaySkaters == 5)
        #expect(situation?.homeSkaters == 5)
        #expect(situation?.homeGoalieIn == true)
    }

    @Test("GameSituation from invalid code returns nil")
    func fromInvalidCode() {
        #expect(GameSituation(code: "123") == nil)
        #expect(GameSituation(code: "12345") == nil)
        #expect(GameSituation(code: "abcd") == nil)
    }

    @Test("GameSituation isEvenStrength")
    func isEvenStrength() {
        let fiveOnFive = GameSituation(code: "1551")
        let fourOnFour = GameSituation(code: "1441")
        let powerPlay = GameSituation(code: "1541")

        #expect(fiveOnFive?.isEvenStrength == true)
        #expect(fourOnFour?.isEvenStrength == true)
        #expect(powerPlay?.isEvenStrength == false)
    }

    @Test("GameSituation power play detection")
    func powerPlay() {
        let awayPP = GameSituation(code: "1541")
        let homePP = GameSituation(code: "1451")

        #expect(awayPP?.isAwayPowerPlay == true)
        #expect(awayPP?.isHomePowerPlay == false)
        #expect(homePP?.isAwayPowerPlay == false)
        #expect(homePP?.isHomePowerPlay == true)
    }

    @Test("GameSituation empty net")
    func emptyNet() {
        let emptyAway = GameSituation(code: "0551")
        let emptyHome = GameSituation(code: "1550")
        let bothIn = GameSituation(code: "1551")

        #expect(emptyAway?.isEmptyNet == true)
        #expect(emptyHome?.isEmptyNet == true)
        #expect(bothIn?.isEmptyNet == false)
    }

    @Test("GameSituation strength description")
    func strengthDescription() {
        let fiveOnFive = GameSituation(code: "1551")
        let powerPlay = GameSituation(code: "1541")
        let emptyNet = GameSituation(code: "0651")

        #expect(fiveOnFive?.strengthDescription == "5v5")
        #expect(powerPlay?.strengthDescription == "5v4 PP")
        #expect(emptyNet?.strengthDescription == "6v5 EN")
    }
}

// MARK: - LocalizedString Tests

@Suite("LocalizedString Tests")
struct LocalizedStringTests {
    @Test("LocalizedString from string literal")
    func stringLiteral() {
        let localized: LocalizedString = "Hello"
        #expect(localized.default == "Hello")
        #expect(localized.translations.isEmpty)
    }

    @Test("LocalizedString value for language")
    func valueForLanguage() {
        let localized = LocalizedString(
            default: "Hello",
            translations: ["fr": "Bonjour", "es": "Hola"]
        )
        #expect(localized.value(for: "en") == "Hello")
        #expect(localized.value(for: "fr") == "Bonjour")
        #expect(localized.value(for: "es") == "Hola")
        #expect(localized.value(for: "de") == "Hello") // Falls back to default
    }

    @Test("LocalizedString description")
    func description() {
        let localized: LocalizedString = "Test"
        #expect(localized.description == "Test")
    }
}

// MARK: - PeriodType Tests

@Suite("PeriodType Tests")
struct PeriodTypeTests {
    @Test("PeriodType raw values")
    func rawValues() {
        #expect(PeriodType.regulation.rawValue == "REG")
        #expect(PeriodType.overtime.rawValue == "OT")
        #expect(PeriodType.shootout.rawValue == "SO")
    }
}

// MARK: - HomeRoad Tests

@Suite("HomeRoad Tests")
struct HomeRoadTests {
    @Test("HomeRoad raw values")
    func rawValues() {
        #expect(HomeRoad.home.rawValue == "H")
        #expect(HomeRoad.road.rawValue == "R")
    }
}

// MARK: - PlayEventType Tests

@Suite("PlayEventType Tests")
struct PlayEventTypeTests {
    @Test("PlayEventType isScoringEvent")
    func isScoringEvent() {
        #expect(PlayEventType.goal.isScoringEvent == true)
        #expect(PlayEventType.shot.isScoringEvent == true)
        #expect(PlayEventType.missedShot.isScoringEvent == true)
        #expect(PlayEventType.blockedShot.isScoringEvent == true)
        #expect(PlayEventType.hit.isScoringEvent == false)
        #expect(PlayEventType.penalty.isScoringEvent == false)
    }

    @Test("PlayEventType isPeriodBoundary")
    func isPeriodBoundary() {
        #expect(PlayEventType.gameStart.isPeriodBoundary == true)
        #expect(PlayEventType.periodStart.isPeriodBoundary == true)
        #expect(PlayEventType.periodEnd.isPeriodBoundary == true)
        #expect(PlayEventType.gameEnd.isPeriodBoundary == true)
        #expect(PlayEventType.goal.isPeriodBoundary == false)
    }
}

// MARK: - Config Tests

@Suite("ClientConfig Tests")
struct ConfigTests {
    @Test("Default config values")
    func defaultValues() {
        let config = ClientConfig.default
        #expect(config.timeout == 10)
        #expect(config.sslVerify == true)
        #expect(config.followRedirects == true)
    }

    @Test("Custom config")
    func customConfig() {
        let config = ClientConfig(timeout: 30, sslVerify: false, followRedirects: false)
        #expect(config.timeout == 30)
        #expect(config.sslVerify == false)
        #expect(config.followRedirects == false)
    }
}

// MARK: - TeamGameStats Tests

@Suite("TeamGameStats Tests")
struct TeamGameStatsTests {
    @Test("TeamGameStats faceoff percentage")
    func faceoffPercentage() {
        var stats = TeamGameStats()
        stats.faceoffWins = 30
        stats.faceoffTotal = 60
        #expect(stats.faceoffPercentage == 50.0)
    }

    @Test("TeamGameStats faceoff percentage with zero total")
    func faceoffPercentageZero() {
        let stats = TeamGameStats()
        #expect(stats.faceoffPercentage == 0.0)
    }

    @Test("TeamGameStats power play percentage")
    func powerPlayPercentage() {
        var stats = TeamGameStats()
        stats.powerPlayGoals = 2
        stats.powerPlayOpportunities = 5
        #expect(stats.powerPlayPercentage == 40.0)
    }
}

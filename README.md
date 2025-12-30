# NHLAPI

Swift client for the NHL API.

## Installation

```swift
.package(url: "https://github.com/sperano/nhl-api-swift", from: "0.9.0")
```

## Usage

```swift
import NHLAPI

let client = NHLClient()

// Standings
let standings = try await client.standings()
for team in standings.prefix(5) {
    print("\(team.teamAbbrev.default): \(team.points) pts")
}

// Player info
let mcdavid: PlayerID = 8478402
let player = try await client.player(mcdavid)
print("\(player.fullName) - \(player.heightFormatted), age \(player.age ?? 0)")

// Game data
let gameId: GameID = 2024020450
let boxscore = try await client.boxscore(gameId: gameId)
print("\(boxscore.awayTeam.abbrev) \(boxscore.awayTeam.score) - \(boxscore.homeTeam.score) \(boxscore.homeTeam.abbrev)")

// Roster lookup
let roster = try await client.roster(teamAbbrev: "EDM")
if let player = roster.playerByNumber(97) {
    print("#97: \(player.fullName)")
}
```

## API Coverage

- **Standings**: Current, by date, by season
- **Schedule**: Daily, weekly, team-specific, scores
- **Game Center**: Boxscore, play-by-play, landing, story, shift charts, season series
- **Players**: Profile, game log, search
- **Teams**: Roster, club stats, seasons
- **Franchises**: All NHL franchises

## Requirements

- Swift 6.0+
- macOS 13+ / iOS 16+ / tvOS 16+ / watchOS 9+

# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build Commands

```bash
swift build                              # Build
swift test                               # Run all tests
swift test --filter NHLAPITests          # Unit tests only (fast)
swift test --filter IntegrationTests     # Integration tests only (network)
swift test --filter "Season Tests"       # Specific test suite
```

## Architecture

NHL API client library using Swift 6 strict concurrency.

### Core Components

- **NHLClient** (`Client.swift`) - Main API client actor, entry point for all API calls
- **HTTPClient** (`HttpClient.swift`) - Internal HTTP layer with `HTTPDataProvider` protocol for testing
- **IDs.swift** - Type-safe identifiers (`GameID`, `PlayerID`, `TeamID`, `FranchiseID`, `EventID`) via `NHLIdentifier` protocol

### Data Flow

```
NHLClient (public API) → HTTPClient (networking) → NHL API endpoints
                                                 ↓
                              Codable models (Boxscore, PlayByPlay, etc.)
```

### Key Patterns

- All public types are `Sendable` for Swift 6 concurrency
- IDs use `NHLIdentifier` protocol: `RawRepresentable<Int>`, `ExpressibleByIntegerLiteral`, `LosslessStringConvertible`
- `LocalizedString` handles NHL's multi-language responses with `default` + `translations` dictionary
- Date handling via `Date.nhl(year:month:day:)` and `NHLDateFormatter` (thread-safe, no DateFormatter)

### Testing

- Unit tests: Type behavior, enums, date parsing (no network)
- Integration tests: Real API calls, tagged with `.integration`

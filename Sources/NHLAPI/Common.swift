import Foundation

// MARK: - Localized String

/// A string that can be localized in multiple languages
public struct LocalizedString: Sendable, Hashable, Codable {
    /// The default (English) value
    public let `default`: String

    /// Translations keyed by language code (e.g., "fr", "es", "de")
    public let translations: [String: String]

    public init(default value: String, translations: [String: String] = [:]) {
        self.default = value
        self.translations = translations
    }

    /// Get the localized value for a given language code, falling back to default
    public func value(for languageCode: String) -> String {
        translations[languageCode.lowercased()] ?? `default`
    }

    // MARK: - Codable

    private enum CodingKeys: String, CodingKey {
        case `default`
        case fr, es, sv, fi, cs, sk, de
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.default = try container.decode(String.self, forKey: .default)

        var translations: [String: String] = [:]
        for key in [CodingKeys.fr, .es, .sv, .fi, .cs, .sk, .de] {
            if let value = try container.decodeIfPresent(String.self, forKey: key) {
                translations[key.stringValue] = value
            }
        }
        self.translations = translations
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(`default`, forKey: .default)
        for (key, value) in translations {
            if let codingKey = CodingKeys(stringValue: key) {
                try container.encode(value, forKey: codingKey)
            }
        }
    }
}

extension LocalizedString: CustomStringConvertible {
    public var description: String { `default` }
}

extension LocalizedString: ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        self.default = value
        self.translations = [:]
    }
}

// MARK: - Team

/// Basic team information
public struct Team: Sendable, Hashable, Codable, Identifiable {
    public let id: TeamID
    public let abbrev: String
    public let name: LocalizedString?
    public let commonName: LocalizedString?
    public let placeName: LocalizedString?
    public let logo: String?
    public let darkLogo: String?

    private enum CodingKeys: String, CodingKey {
        case id, abbrev
        case name = "fullName"
        case commonName, placeName, logo, darkLogo
    }
}

// MARK: - Conference

/// NHL conference information
public struct Conference: Sendable, Hashable, Codable, Identifiable {
    public let id: Int
    public let name: String
    public let abbrev: String
}

// MARK: - Division

/// NHL division information
public struct Division: Sendable, Hashable, Codable, Identifiable {
    public let id: Int
    public let name: String
    public let abbrev: String
}

// MARK: - Franchise

/// NHL franchise information (historical team data)
public struct Franchise: Sendable, Hashable, Codable, Identifiable {
    public let id: FranchiseID
    public let name: String
    public let slug: String?

    private enum CodingKeys: String, CodingKey {
        case id
        case name = "fullName"
        case slug = "teamCommonName"
    }
}

// MARK: - Roster

/// Team roster
public struct Roster: Sendable, Hashable, Codable {
    public let forwards: [RosterPlayer]
    public let defensemen: [RosterPlayer]
    public let goalies: [RosterPlayer]

    /// All players on the roster
    public var allPlayers: [RosterPlayer] {
        forwards + defensemen + goalies
    }

    /// Find a player by sweater number
    public func playerByNumber(_ number: Int) -> RosterPlayer? {
        allPlayers.first { $0.sweaterNumber == number }
    }

    /// Find a player by name (case-insensitive)
    public func playerByName(_ firstName: String, _ lastName: String) -> RosterPlayer? {
        let first = firstName.lowercased()
        let last = lastName.lowercased()
        return allPlayers.first {
            $0.firstName.default.lowercased() == first &&
            $0.lastName.default.lowercased() == last
        }
    }

    /// Find players by last name (case-insensitive, may return multiple)
    public func playersByLastName(_ lastName: String) -> [RosterPlayer] {
        let last = lastName.lowercased()
        return allPlayers.filter { $0.lastName.default.lowercased() == last }
    }
}

/// Player on a team roster
public struct RosterPlayer: Sendable, Hashable, Codable, Identifiable {
    public let id: PlayerID
    public let headshot: String
    public let firstName: LocalizedString
    public let lastName: LocalizedString
    public let sweaterNumber: Int?
    public let positionCode: Position
    public let shootsCatches: Handedness
    public let heightInInches: Int?
    public let weightInPounds: Int?
    public let heightInCentimeters: Int?
    public let weightInKilograms: Int?
    public let birthDate: String?
    public let birthCity: LocalizedString?
    public let birthCountry: String?

    /// Full name (first + last)
    public var fullName: String {
        "\(firstName.default) \(lastName.default)"
    }
}

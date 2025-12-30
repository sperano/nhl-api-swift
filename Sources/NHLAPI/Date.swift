import Foundation

// MARK: - Date Extensions

extension Date {
    /// Creates a date from year, month, and day components
    /// - Parameters:
    ///   - year: The year
    ///   - month: The month (1-12)
    ///   - day: The day of the month
    /// - Returns: A Date, or nil if the components don't form a valid date
    public static func nhl(year: Int, month: Int, day: Int) -> Date? {
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = day
        return Calendar(identifier: .gregorian).date(from: components)
    }
}

// MARK: - Date Formatting

/// Thread-safe date formatting for NHL API
public enum NHLDateFormatter: Sendable {
    /// Formats a date as YYYY-MM-DD for API requests
    public static func apiString(from date: Date) -> String {
        let calendar = Calendar(identifier: .gregorian)
        let components = calendar.dateComponents([.year, .month, .day], from: date)
        return String(
            format: "%04d-%02d-%02d",
            components.year ?? 0,
            components.month ?? 0,
            components.day ?? 0
        )
    }

    /// Parses a YYYY-MM-DD string into a Date
    public static func date(from string: String) -> Date? {
        let parts = string.split(separator: "-")
        guard parts.count == 3,
              let year = Int(parts[0]),
              let month = Int(parts[1]),
              let day = Int(parts[2]) else {
            return nil
        }
        return Date.nhl(year: year, month: month, day: day)
    }
}

// MARK: - Season

/// Represents an NHL season (e.g., 2024-2025)
public struct Season: Sendable, Hashable, Codable {
    /// The year the season starts (e.g., 2024 for the 2024-2025 season)
    public let startYear: Int

    /// The year the season ends (e.g., 2025 for the 2024-2025 season)
    public let endYear: Int

    /// Creates a Season from start and end years
    public init(startYear: Int, endYear: Int) {
        self.startYear = startYear
        self.endYear = endYear
    }

    /// Creates a Season from just the start year (end year = startYear + 1)
    public init(startYear: Int) {
        self.startYear = startYear
        self.endYear = startYear + 1
    }

    /// Parses a season from a string in format "20242025" or "2024-2025"
    public static func parse(_ string: String) -> Season? {
        let cleaned = string.replacingOccurrences(of: "-", with: "")
        guard cleaned.count == 8,
              let startYear = Int(cleaned.prefix(4)),
              let endYear = Int(cleaned.suffix(4)) else {
            return nil
        }
        return Season(startYear: startYear, endYear: endYear)
    }

    /// Formats the season as "20242025" for API requests
    public var apiFormat: String {
        "\(startYear)\(endYear)"
    }

    /// Formats the season as "2024-2025" for display
    public var displayFormat: String {
        "\(startYear)-\(endYear)"
    }

    /// Returns the current season based on today's date
    /// Seasons typically start in October, so before October we're in the previous season
    public static var current: Season {
        let components = Calendar(identifier: .gregorian).dateComponents([.year, .month], from: Date())
        let year = components.year ?? 2024
        let month = components.month ?? 1
        let seasonStartMonth = 10
        return month < seasonStartMonth ? Season(startYear: year - 1) : Season(startYear: year)
    }

    // MARK: - Codable

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let value = try container.decode(Int.self)
        self.startYear = value / 10000
        self.endYear = value % 10000
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(startYear * 10000 + endYear)
    }
}

// MARK: - Season Protocol Conformances

extension Season: CustomStringConvertible {
    public var description: String { displayFormat }
}

extension Season: LosslessStringConvertible {
    public init?(_ description: String) {
        guard let season = Season.parse(description) else { return nil }
        self = season
    }
}

extension Season: Comparable {
    public static func < (lhs: Season, rhs: Season) -> Bool {
        lhs.startYear < rhs.startYear
    }
}

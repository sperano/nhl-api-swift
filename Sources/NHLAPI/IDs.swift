import Foundation

// MARK: - Base ID Protocol

/// Protocol for strongly-typed ID wrappers
public protocol NHLIdentifier: Sendable, Hashable, Codable, RawRepresentable,
                               CustomStringConvertible, LosslessStringConvertible,
                               ExpressibleByIntegerLiteral where RawValue == Int {
    init(rawValue: Int)
}

extension NHLIdentifier {
    public var description: String {
        String(rawValue)
    }

    public init?(_ description: String) {
        guard let value = Int(description) else { return nil }
        self.init(rawValue: value)
    }

    public init(integerLiteral value: Int) {
        self.init(rawValue: value)
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        // Handle both Int and Int64 from JSON
        if let value = try? container.decode(Int.self) {
            self.init(rawValue: value)
        } else {
            let int64Value = try container.decode(Int64.self)
            self.init(rawValue: Int(int64Value))
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }
}

// MARK: - ID Types

/// A strongly-typed wrapper for NHL game IDs
///
/// Game IDs are 10-digit numbers in the format: YYYYTTNNNN
/// - YYYY: Season start year
/// - TT: Game type (01=preseason, 02=regular, 03=playoffs, 04=all-star)
/// - NNNN: Game number
public struct GameID: NHLIdentifier {
    public let rawValue: Int

    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
}

/// A strongly-typed wrapper for NHL player IDs
public struct PlayerID: NHLIdentifier {
    public let rawValue: Int

    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
}

/// A strongly-typed wrapper for NHL team IDs
public struct TeamID: NHLIdentifier {
    public let rawValue: Int

    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
}

/// A strongly-typed wrapper for NHL franchise IDs
public struct FranchiseID: NHLIdentifier {
    public let rawValue: Int

    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
}

/// A strongly-typed wrapper for NHL event IDs
public struct EventID: NHLIdentifier {
    public let rawValue: Int

    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
}

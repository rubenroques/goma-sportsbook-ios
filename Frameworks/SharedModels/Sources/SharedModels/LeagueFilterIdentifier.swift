//
//  LeagueFilterIdentifier.swift
//  SharedModels
//

import Foundation
import Combine

/// Represents a league filter with three possible states
public enum LeagueFilterIdentifier: Codable, Equatable, Hashable {
    case all
    case allInCountry(countryId: String)
    case singleLeague(id: String)

    // MARK: - Initialization

    public init(stringValue: String) {
        if stringValue == "all" || stringValue == "0" || stringValue.isEmpty {
            self = .all
        } else if stringValue.hasSuffix("_all") {
            let countryId = String(stringValue.dropLast(4))
            if countryId.isEmpty {
                self = .all
            } else {
                self = .allInCountry(countryId: countryId)
            }
        } else {
            self = .singleLeague(id: stringValue)
        }
    }

    // MARK: - Codable

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)
        self.init(stringValue: rawValue)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }

    // MARK: - Properties

    public var rawValue: String {
        switch self {
        case .all:
            return "all"
        case .allInCountry(let countryId):
            return "\(countryId)_all"
        case .singleLeague(let id):
            return id
        }
    }

    public var isAll: Bool {
        if case .all = self { return true }
        return false
    }

    public var countryId: String? {
        if case .allInCountry(let id) = self { return id }
        return nil
    }

    public var leagueId: String? {
        if case .singleLeague(let id) = self { return id }
        return nil
    }
}

// MARK: - ExpressibleByStringLiteral
extension LeagueFilterIdentifier: ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        self.init(stringValue: value)
    }
}

// MARK: - CustomStringConvertible
extension LeagueFilterIdentifier: CustomStringConvertible {
    public var description: String {
        switch self {
        case .all:
            return "LeagueFilterIdentifier.all"
        case .allInCountry(let countryId):
            return "LeagueFilterIdentifier.allInCountry(\"\(countryId)\")"
        case .singleLeague(let id):
            return "LeagueFilterIdentifier.singleLeague(\"\(id)\")"
        }
    }
}

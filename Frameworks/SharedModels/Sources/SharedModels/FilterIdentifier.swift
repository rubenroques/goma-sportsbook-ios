//
//  FilterIdentifier.swift
//  SharedModels
//

import Foundation
import Combine

/// Represents a filter that can be "all" or a single specific item
public enum FilterIdentifier: Codable, Equatable, Hashable {
    case all
    case singleSport(id: String)

    // MARK: - Initialization

    public init(stringValue: String) {
        if stringValue == "all" || stringValue == "0" || stringValue.isEmpty {
            self = .all
        } else {
            self = .singleSport(id: stringValue)
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
        case .singleSport(let id):
            return id
        }
    }

    public var isAll: Bool {
        if case .all = self { return true }
        return false
    }

    public var sportId: String? {
        if case .singleSport(let id) = self { return id }
        return nil
    }
}

// MARK: - ExpressibleByStringLiteral
extension FilterIdentifier: ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        self.init(stringValue: value)
    }
}

// MARK: - CustomStringConvertible
extension FilterIdentifier: CustomStringConvertible {
    public var description: String {
        switch self {
        case .all:
            return "FilterIdentifier.all"
        case .singleSport(let id):
            return "FilterIdentifier.singleSport(\"\(id)\")"
        }
    }
}

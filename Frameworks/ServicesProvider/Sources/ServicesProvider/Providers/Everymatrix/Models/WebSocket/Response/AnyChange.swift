//
//  AnyCodable.swift
//  ServicesProvider
//
//  Created by Ruben Roques on 26/06/2025.
//

import Foundation

extension EveryMatrix {
    struct AnyChange: Codable, CustomStringConvertible, CustomDebugStringConvertible {
        let value: Any

        init<T>(_ value: T?) {
            self.value = value ?? ()
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()

            // Handle nil first
            if container.decodeNil() {
                value = ()
                return
            }

            // Try string first (most specific, can't be confused with other types)
            if let string = try? container.decode(String.self) {
                value = string
                return
            }

            // For numbers, try Int first, then Double
            // This preserves integer precision when possible
            if let int = try? container.decode(Int.self) {
                value = int
                return
            }

            // If Int failed, it's either a Double or too large for Int
            if let double = try? container.decode(Double.self) {
                value = double
                return
            }

            // Try Bool LAST to avoid the numeric-as-boolean issue
            if let bool = try? container.decode(Bool.self) {
                value = bool
                return
            }

            throw DecodingError.dataCorrupted(
                DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Unable to decode value")
            )
        }

        func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()

            switch value {
            case let int as Int:
                try container.encode(int)
            case let double as Double:
                try container.encode(double)
            case let string as String:
                try container.encode(string)
            case let bool as Bool:
                try container.encode(bool)
            default:
                try container.encodeNil()
            }
        }
        
        public var description: String {
            switch value {
            case is Void:
                return String(describing: nil as Any?)
            case let value as CustomStringConvertible:
                return value.description
            default:
                return String(describing: value)
            }
        }
        
        public var debugDescription: String {
            switch value {
            case let value as CustomDebugStringConvertible:
                return "AnyChange(\(value.debugDescription))"
            default:
                return "AnyChange(\(description))"
            }
        }
    }
}

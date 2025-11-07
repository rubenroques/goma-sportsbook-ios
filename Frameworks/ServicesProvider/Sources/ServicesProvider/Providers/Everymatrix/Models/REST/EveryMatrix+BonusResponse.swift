//
//  EveryMatrix+BonusResponse.swift
//  ServicesProvider
//
//  Created by André Lascas on 23/10/2025.
//

import Foundation

extension EveryMatrix {
    
    public struct BonusResponse: Codable {
        public let bonuses: [BonusItem]
        public let total: Int
        public let pages: Pages
        public let success: Bool
        public let executionTime: Double
        public let requestId: String
        
        enum CodingKeys: String, CodingKey {
            case bonuses
            case total
            case pages
            case success
            case executionTime
            case requestId
        }
    }
    
    public struct BonusItem: Codable {
        public let id: String
        public let realm: String
        public let domainID: Int
        public let code: String
        public let type: String
        public let selectable: Bool
        public let trigger: Trigger
        public let presentation: Presentation
        
        enum CodingKeys: String, CodingKey {
            case id
            case realm
            case domainID
            case code
            case type
            case selectable
            case trigger
            case presentation
        }
    }
    
    public struct Trigger: Codable {
        public let startTime: String
        public let endTime: String
        public let timeZone: TimeZone
        public let totalGrantCountLimit: Double
        public let player: [String: AnyCodable]?
        public let method: Method
        
        enum CodingKeys: String, CodingKey {
            case startTime
            case endTime
            case timeZone
            case totalGrantCountLimit
            case player
            case method
        }
    }
    
    public struct TimeZone: Codable {
        public let id: Int
        public let dstPeriods: [AnyCodable]
        
        enum CodingKeys: String, CodingKey {
            case id
            case dstPeriods
        }
    }
    
    public struct Method: Codable {
        public let deposit: Deposit
        
        enum CodingKeys: String, CodingKey {
            case deposit
        }
    }
    
    public struct Deposit: Codable {
        public let depositHistory: [DepositHistory]
        public let minimumAmount: [String: Double]
        public let action: Double
        
        enum CodingKeys: String, CodingKey {
            case depositHistory
            case minimumAmount
            case action
        }
    }
    
    public struct DepositHistory: Codable {
        public let comparison: String
        public let value: Double
        
        enum CodingKeys: String, CodingKey {
            case comparison
            case value
        }
    }
    
    public struct Presentation: Codable {
        public let name: Content
        public let url: Content
        public let description: Content
        public let html: Content
        public let assets: Content
        
        enum CodingKeys: String, CodingKey {
            case name
            case url
            case description
            case html
            case assets
        }
    }
    
    public struct Content: Codable {
        public let content: String
        
        enum CodingKeys: String, CodingKey {
            case content
        }
    }
    
    public struct Pages: Codable {
        public let first: String
        public let last: String
        
        enum CodingKeys: String, CodingKey {
            case first
            case last
        }
    }
}

// Helper for handling dynamic JSON values
public struct AnyCodable: Codable {
    public let value: Any
    
    public init<T>(_ value: T?) {
        self.value = value ?? ()
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        if container.decodeNil() {
            self.init(())
        } else if let bool = try? container.decode(Bool.self) {
            self.init(bool)
        } else if let int = try? container.decode(Int.self) {
            self.init(int)
        } else if let double = try? container.decode(Double.self) {
            self.init(double)
        } else if let string = try? container.decode(String.self) {
            self.init(string)
        } else if let array = try? container.decode([AnyCodable].self) {
            self.init(array.map { $0.value })
        } else if let dictionary = try? container.decode([String: AnyCodable].self) {
            self.init(dictionary.mapValues { $0.value })
        } else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "AnyCodable value cannot be decoded")
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        
        switch value {
        case is Void:
            try container.encodeNil()
        case let bool as Bool:
            try container.encode(bool)
        case let int as Int:
            try container.encode(int)
        case let double as Double:
            try container.encode(double)
        case let string as String:
            try container.encode(string)
        case let array as [Any]:
            try container.encode(array.map { AnyCodable($0) })
        case let dictionary as [String: Any]:
            try container.encode(dictionary.mapValues { AnyCodable($0) })
        default:
            let context = EncodingError.Context(codingPath: container.codingPath, debugDescription: "AnyCodable value cannot be encoded")
            throw EncodingError.invalidValue(value, context)
        }
    }
}

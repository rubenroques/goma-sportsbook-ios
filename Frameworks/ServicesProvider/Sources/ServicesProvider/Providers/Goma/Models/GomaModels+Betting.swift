//
//  File.swift
//  
//
//  Created by Ruben Roques on 19/01/2024.
//

import Foundation
import Extensions

extension GomaModels {
    
    struct PlaceBetTicketResponse: Codable {
        
        let id: String
        let userId: String
        let type: String
        let stake: Double
        let odds: Double
        let possibleWinnings: Double
        let shareId: String
        let status: String
        let selections: [MyTicketSelection]
        var createdAt: String?
        
        init(id: String,
             userId: String,
             type: String,
             stake: Double,
             odds: Double,
             possibleWinnings: Double,
             shareId: String,
             status: String,
             selections: [MyTicketSelection]) {
            self.userId = userId
            self.type = type
            self.stake = stake
            self.odds = odds
            self.possibleWinnings = possibleWinnings
            self.shareId = shareId
            self.id = id
            self.status = status
            self.selections = selections
        }
        
        enum CodingKeys: String, CodingKey {
            case id
            case userId = "user_id"
            case shareId = "share_id"
            case possibleWinnings = "possible_winnings"
            case type
            case stake
            case odds = "odds"
            case status
            case selections = "selections"
            case createdAt = "created_at"
        }
        
        init(from decoder: Decoder) throws {
            let container: KeyedDecodingContainer<GomaModels.PlaceBetTicketResponse.CodingKeys> = try decoder.container(keyedBy: GomaModels.PlaceBetTicketResponse.CodingKeys.self)
            self.type = try container.decode(String.self, forKey: GomaModels.PlaceBetTicketResponse.CodingKeys.type)
            self.stake = try container.decode(Double.self, forKey: GomaModels.PlaceBetTicketResponse.CodingKeys.stake)
            
            // Decode Odd
            if let priceValue = try? container.decode(Double.self, forKey: .odds) {
                self.odds = priceValue
            } else if let priceString = try? container.decode(String.self, forKey: .odds), let priceValue = Double(priceString) {
                self.odds = priceValue
            } else {
                throw DecodingError.dataCorruptedError(forKey: .odds, in: container, debugDescription: "Odds is not a Double or String")
            }
            
            self.possibleWinnings = try container.decode(Double.self, forKey: GomaModels.PlaceBetTicketResponse.CodingKeys.possibleWinnings)
            self.shareId = try container.decode(String.self, forKey: GomaModels.PlaceBetTicketResponse.CodingKeys.shareId)
            self.status = try container.decode(String.self, forKey: GomaModels.PlaceBetTicketResponse.CodingKeys.status)
            
            if let userIdInt = try? container.decode(Int.self, forKey: .userId) {
                self.userId = String(userIdInt)
            } else {
                self.userId = try container.decode(String.self, forKey: .userId)
            }
            
            if let idInt = try? container.decode(Int.self, forKey: .id) {
                self.id = String(idInt)
            } else {
                self.id = try container.decode(String.self, forKey: .id)
            }
            
            let rawSelections = try container.decode([FailableDecodable<MyTicketSelection>].self, forKey: .selections)
            self.selections = rawSelections.compactMap({ $0.content })
            
            self.createdAt = try container.decodeIfPresent(String.self, forKey: .createdAt)
        }
        
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(self.userId, forKey: CodingKeys.userId)
            try container.encode(self.type, forKey: CodingKeys.type)
            try container.encode(self.stake, forKey: CodingKeys.stake)
            try container.encode(self.odds, forKey: CodingKeys.odds)
            try container.encode(self.possibleWinnings, forKey: CodingKeys.possibleWinnings)
            try container.encode(self.shareId, forKey: CodingKeys.shareId)
            try container.encode(self.id, forKey: CodingKeys.id)
            try container.encode(self.status, forKey: CodingKeys.status)
        }
    }

    
    struct AllowedBets: Codable {
        
        var allowedTypes: [BetType]
        var allowedStakes: [Double]
        
        enum CodingKeys: String, CodingKey {
            case allowedTypes = "allowed_types"
            case allowedStakes = "allowed_stakes"
            case allowedSystemBetTypes = "allowed_system_types"
        }

        init(from decoder: Decoder) throws {
            let container: KeyedDecodingContainer<GomaModels.AllowedBets.CodingKeys> = try decoder.container(keyedBy: GomaModels.AllowedBets.CodingKeys.self)
            
            self.allowedStakes = try container.decode([Double].self, forKey: GomaModels.AllowedBets.CodingKeys.allowedStakes)
            
            let allowedTypesStrings = try container.decode([String].self, forKey: GomaModels.AllowedBets.CodingKeys.allowedTypes)
            let allowedSystemBetTypes = try container.decode([GomaModels.SystemBetType].self, forKey: GomaModels.AllowedBets.CodingKeys.allowedSystemBetTypes)
            
            var allowedBetTypes: [BetType] = []
            
            for allowedTypeString in allowedTypesStrings {
                switch allowedTypeString.lowercased() {
                case "single":
                    allowedBetTypes.append(.single)
                case "multiple":
                    allowedBetTypes.append(.multiple)
                case "system":
                    for allowedSystemBetType in allowedSystemBetTypes {
                        allowedBetTypes.append(.system(type: allowedSystemBetType))
                    }
                default:
                    ()
                }
            }
            
            self.allowedTypes = allowedBetTypes
        }
        
        func encode(to encoder: Encoder) throws {
            
        }
        
        init(allowedTypes: [BetType], allowedStakes: [Double]) {
            self.allowedTypes = allowedTypes
            self.allowedStakes = allowedStakes
        }
        
    }

    
    enum BetType: Codable {
        case single
        case multiple
        case system(type: SystemBetType)
        
        var identifier: String {
            switch self {
            case .single:
                return "single"
            case .multiple:
                return "multiple"
            case .system(let systemType):
                return systemType.type
            }
        }
        
        var name: String {
            switch self {
            case .single:
                return "Single"
            case .multiple:
                return "Multiple"
            case .system(let systemType):
                return systemType.label
            }
        }
    }
    
    struct SystemBetType: Codable {
        var type: String
        var label: String
        
        enum CodingKeys: String, CodingKey {
            case type = "type"
            case label = "label"
        }
    }
    
    // MARK: - BetslipPotentialReturn
    struct BetslipPotentialReturn: Codable {
        var stake: Double
        var type: String
        var selections: [BettingSelection]
        var odds: Double
        var possibleWinnings: Double

        enum CodingKeys: String, CodingKey {
            case stake = "total_stake"
            case type = "type"
            case selections = "selections"
            case odds = "odds"
            case possibleWinnings = "possible_winnings"
        }
        
        init(from decoder: Decoder) throws {
            let container: KeyedDecodingContainer<GomaModels.BetslipPotentialReturn.CodingKeys> = try decoder.container(keyedBy: GomaModels.BetslipPotentialReturn.CodingKeys.self)
            
            if let stakeString = try? container.decode(String.self, forKey: GomaModels.BetslipPotentialReturn.CodingKeys.stake),
               let stake = Double(stakeString) {
                self.stake = stake
            }
            else {
                let stakeDouble = try container.decode(Double.self, forKey: GomaModels.BetslipPotentialReturn.CodingKeys.stake)
                self.stake = stakeDouble
            }
            
            self.type = try container.decode(String.self, forKey: GomaModels.BetslipPotentialReturn.CodingKeys.type)
            self.selections = try container.decode([GomaModels.BettingSelection].self, forKey: GomaModels.BetslipPotentialReturn.CodingKeys.selections)
            self.possibleWinnings = try container.decode(Double.self, forKey: GomaModels.BetslipPotentialReturn.CodingKeys.possibleWinnings)
            
            // Decode Odd
            if let priceValue = try? container.decode(Double.self, forKey: .odds) {
                self.odds = priceValue
            } else if let priceString = try? container.decode(String.self, forKey: .odds), let priceValue = Double(priceString) {
                self.odds = priceValue
            } else {
                throw DecodingError.dataCorruptedError(forKey: .odds, in: container, debugDescription: "Odds is not a Double or String")
            }
            
        }
    }

    // MARK: - Selection
    struct BettingSelection: Codable {
        var sportEventId: String
        var outcomeId: String
        var odd: Double

        enum CodingKeys: String, CodingKey {
            case sportEventId = "sport_event_id"
            case outcomeId = "outcome_id"
            case odd = "odd"
        }
        
        init(from decoder: Decoder) throws {
            let container: KeyedDecodingContainer<GomaModels.BettingSelection.CodingKeys> = try decoder.container(keyedBy: GomaModels.BettingSelection.CodingKeys.self)
            self.sportEventId = try container.decode(String.self, forKey: GomaModels.BettingSelection.CodingKeys.sportEventId)
            self.outcomeId = try container.decode(String.self, forKey: GomaModels.BettingSelection.CodingKeys.outcomeId)
            
            // Decode odds
            if let oddValue = try? container.decode(Double.self, forKey: .odd) {
                self.odd = oddValue
            } else if let oddString = try? container.decode(String.self, forKey: .odd), let oddValue = Double(oddString) {
                self.odd = oddValue
            } else {
                throw DecodingError.dataCorruptedError(forKey: .odd, in: container, debugDescription: "Odd is not a Double or String")
            }
        }
        
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: GomaModels.BettingSelection.CodingKeys.self)
            try container.encode(self.sportEventId, forKey: GomaModels.BettingSelection.CodingKeys.sportEventId)
            try container.encode(self.outcomeId, forKey: GomaModels.BettingSelection.CodingKeys.outcomeId)
            try container.encode(self.odd, forKey: GomaModels.BettingSelection.CodingKeys.odd)
        }
    }

    
}

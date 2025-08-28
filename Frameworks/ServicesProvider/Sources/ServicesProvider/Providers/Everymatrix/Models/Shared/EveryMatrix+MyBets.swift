//
//  EveryMatrix+MyBets.swift
//  ServicesProvider
//
//  Created by Assistant on 28/08/2025.
//

import Foundation

extension EveryMatrix {
    
    // MARK: - MyBets Request Models
    
    struct CashoutRequest: Codable {
        let betId: String
        let cashoutValue: Double
        let cashoutType: String
        let partialCashoutStake: Double?
        
        init(betId: String, cashoutValue: Double, cashoutType: String, partialCashoutStake: Double? = nil) {
            self.betId = betId
            self.cashoutValue = cashoutValue
            self.cashoutType = cashoutType
            self.partialCashoutStake = partialCashoutStake
        }
    }
    
    // MARK: - MyBets Response Models
    
    struct Bet: Codable {
        let id: String?
        let betId: String?
        let status: String?
        let odds: Double?
        let amount: Double?
        let stake: Double?
        let afterTaxAmount: Double?
        let potentialWinnings: Double?
        let currentPossibleWinning: Double?
        let wht: Double?
        let payout: Double?
        let currency: String?
        let placedDate: String?
        let type: String?
        let result: String?
        let partialCashoutValue: Double?
        let partialCashoutStake: Double?
        let selections: [BetSelection]?
        
        enum CodingKeys: String, CodingKey {
            case id
            case betId
            case status
            case odds
            case amount
            case stake
            case afterTaxAmount
            case potentialWinnings
            case currentPossibleWinning
            case wht
            case payout
            case currency
            case placedDate
            case type = "betType"
            case result
            case partialCashoutValue
            case partialCashoutStake
            case selections
        }
    }
    
    struct BetSelection: Codable {
        let id: String?
        let matchName: String?
        let marketType: String?
        let selection: String?
        let odds: Double?
        let status: String?
        let homeTeam: String?
        let awayTeam: String?
        let homeScore: String?
        let awayScore: String?
        let eventId: String?
        let marketId: String?
        let outcomeId: String?
        let competition: String?
        
        enum CodingKeys: String, CodingKey {
            case id
            case matchName
            case marketType
            case selection
            case odds
            case status
            case homeTeam
            case awayTeam
            case homeScore
            case awayScore
            case eventId
            case marketId
            case outcomeId
            case competition
        }
    }
    
    struct CashoutResponse: Codable {
        let cashoutValue: Double?
        let currency: String?
        let success: Bool?
        let errorMessage: String?
        
        enum CodingKeys: String, CodingKey {
            case cashoutValue
            case currency
            case success
            case errorMessage
        }
    }
    
    struct CashoutExecuteResponse: Codable {
        let success: Bool?
        let cashoutValue: Double?
        let errorMessage: String?
        let transactionId: String?
        
        enum CodingKeys: String, CodingKey {
            case success
            case cashoutValue
            case errorMessage
            case transactionId
        }
    }
}
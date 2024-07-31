//
//  BetslipModels.swift
//  Sportsbook
//
//  Created by Ruben Roques on 31/07/2024.
//

import Foundation
import ServicesProvider

enum BetslipErrorType: Error {
    case emptyBetslip
    case betPlacementError
    case potentialReturn
    case betPlacementDetailedError(message: String)
    case betNeedsUserConfirmation(betDetails: PlacedBetsResponse)
    case forbiddenRequest
    case invalidStake
    case insufficientSelections
    case noValidSelectionsFound
    case none
}

struct BetslipError {
    var errorMessage: String
    var errorType: BetslipErrorType
    
    init(errorMessage: String = "", errorType: BetslipErrorType = .none) {
        self.errorMessage = errorMessage
        self.errorType = errorType
    }
    
}

struct BetPlacedDetails {
    var response: BetslipPlaceBetResponse
}

struct BetPotencialReturn: Codable {
    var potentialReturn: Double
    var totalStake: Double
    var numberOfBets: Int
    var totalOdd: Double
}

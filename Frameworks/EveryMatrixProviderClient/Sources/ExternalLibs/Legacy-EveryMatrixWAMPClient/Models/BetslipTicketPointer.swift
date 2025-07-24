//
//  BetslipTicketPointer.swift
//  EveryMatrixProviderClient
//
//  Created by Ruben Roques on 28/05/2025.
//


struct BetslipTicketPointer: Decodable {

    var outcomeId: String
    var bettingOfferId: String
    var bettingTypeId: String
    
    enum CodingKeys: String, CodingKey {
        case outcomeId = "outcomeId"
        case bettingOfferId = "bettingOfferId"
        case bettingTypeId = "bettingTypeId"
    }
}
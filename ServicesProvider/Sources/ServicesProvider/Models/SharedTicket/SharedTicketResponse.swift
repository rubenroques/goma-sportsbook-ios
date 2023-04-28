//
//  SharedTicketResponse.swift
//  
//
//  Created by André Lascas on 21/04/2023.
//

import Foundation

public struct SharedTicketResponse: Codable {

    public var bets: [SharedBet]
    public var totalStake: Double?
    public var betId: Double

    enum CodingKeys: String, CodingKey {
        case bets = "bets"
        case totalStake = "totalStake"
        case betId = "idFOBetSlip"
    }
}

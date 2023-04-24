//
//  SharedBet.swift
//  
//
//  Created by André Lascas on 21/04/2023.
//

import Foundation

public struct SharedBet: Codable {

    public var betSelections: [SharedBetSelection]
    public var winStake: Double
    public var potentialReturn: Double
    public var totalStake: Double

    enum CodingKeys: String, CodingKey {
        case betSelections = "betLegs"
        case winStake = "winStake"
        case potentialReturn = "potentialReturn"
        case totalStake = "totalStake"
    }
}

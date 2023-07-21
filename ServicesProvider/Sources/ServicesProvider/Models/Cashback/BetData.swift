//
//  BetData.swift
//  
//
//  Created by André Lascas on 18/07/2023.
//

import Foundation

public struct BetData: Codable {
    public let betLegs: [BetLeg]
    public let betType: String
    public let wunitstake: String
}

public struct BetLeg: Codable {
    public let idFOEvent: String
    public let idFOMarket: String
    public let idFOSport: String
    public let idFOSelection: String
    public let priceType: String
    public let priceUp: String
    public let priceDown: String
}

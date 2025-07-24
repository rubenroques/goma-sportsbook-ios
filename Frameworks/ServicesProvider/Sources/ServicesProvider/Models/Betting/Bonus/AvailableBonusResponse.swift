//
//  AvailableBonusResponse.swift
//  
//
//  Created by André Lascas on 24/03/2023.
//

import Foundation

public struct AvailableBonusResponse: Codable {

    public var status: String
    public var bonuses: [AvailableBonus]

    enum CodingKeys: String, CodingKey {
        case status = "status"
        case bonuses = "optInBonusPlans"
    }
}

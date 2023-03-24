//
//  GrantedBonusResponse.swift
//  
//
//  Created by André Lascas on 16/03/2023.
//

import Foundation

public struct GrantedBonusResponse: Codable {

    public var status: String
    public var bonuses: [GrantedBonus]

    enum CodingKeys: String, CodingKey {
        case status = "status"
        case bonuses = "bonuses"
    }
}

//
//  RedeemBonusResponse.swift
//  
//
//  Created by André Lascas on 17/03/2023.
//

import Foundation

public struct RedeemBonusResponse: Codable {
    public var status: String
    public var message: String?
    public var bonus: RedeemBonus?


    enum CodingKeys: String, CodingKey {
        case status = "status"
        case message = "message"
        case bonus = "bonus"
    }
}

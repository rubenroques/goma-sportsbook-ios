//
//  BankPaymentInfo.swift
//  
//
//  Created by André Lascas on 15/03/2023.
//

import Foundation

public struct BankPaymentInfo: Codable {

    public var id: Int
    public var partyId: Int
    public var type: String
    public var description: String?
    public var details: [BankPaymentDetail]

    enum CodingKeys: String, CodingKey {
        case id = "id"
        case partyId = "partyId"
        case type = "type"
        case description = "description"
        case details = "details"
    }
}

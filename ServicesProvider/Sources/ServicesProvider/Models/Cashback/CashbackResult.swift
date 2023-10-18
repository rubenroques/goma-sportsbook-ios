//
//  CashbackResult.swift
//  
//
//  Created by André Lascas on 18/07/2023.
//

import Foundation

public struct CashbackResult: Codable {
    public var id: Double
    public var amount: Double?
    public var amountFree: Double?

    enum CodingKeys: String, CodingKey {
        case id = "idFoSOOffer"
        case amount = "soReturn"
        case amountFree = "soFreeReturn"
    }
}

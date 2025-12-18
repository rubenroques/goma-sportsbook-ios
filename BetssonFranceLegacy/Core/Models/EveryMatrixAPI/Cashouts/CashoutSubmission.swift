//
//  CashoutSubmission.swift
//  Sportsbook
//
//  Created by André Lascas on 29/11/2021.
//

import Foundation

struct CashoutSubmission: Decodable {

    var cashoutSucceed: Bool
    var betId: String?
    var requestId: String?

    enum CodingKeys: String, CodingKey {
        case cashoutSucceed = "success"
        case betId = "betId"
        case requestId = "requestId"

    }
}

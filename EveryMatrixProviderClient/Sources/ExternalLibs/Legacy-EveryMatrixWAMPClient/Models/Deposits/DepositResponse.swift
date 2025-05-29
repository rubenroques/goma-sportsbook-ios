//
//  DepositResponse.swift
//  Sportsbook
//
//  Created by André Lascas on 17/12/2021.
//

import Foundation

extension EveryMatrix {
    struct DepositResponse: Decodable {

        let pid: String?
        let cashierUrl: String

        enum CodingKeys: String, CodingKey {
            case pid = "pid"
            case cashierUrl = "cashierUrl"
        }

    }
}

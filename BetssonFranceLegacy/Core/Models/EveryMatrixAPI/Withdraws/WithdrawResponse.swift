//
//  WithdrawResponse.swift
//  Sportsbook
//
//  Created by André Lascas on 21/12/2021.
//

import Foundation

extension EveryMatrix {
    struct WithdrawResponse: Decodable {

        let pid: String?
        let cashierUrl: String

        enum CodingKeys: String, CodingKey {
            case pid = "pid"
            case cashierUrl = "cashierUrl"
        }

    }
}

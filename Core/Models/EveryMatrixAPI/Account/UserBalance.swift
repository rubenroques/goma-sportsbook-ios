//
//  UserBalance.swift
//  Sportsbook
//
//  Created by Ruben Roques on 07/11/2021.
//

import Foundation

extension EveryMatrix {
    struct UserBalance: Decodable {
        var wallets: [UserBalanceWallet]

        enum CodingKeys: String, CodingKey {
            case wallets = "wallets"
        }
    }

    struct UserBalanceWallet: Decodable {

        var name: String
        var realMoney: Double
        var realMoneyCurrency: String
        var bonusMoney: Double
        var bonusMoneyCurrency: String
        var lockedMoney: Double
        var lockedMoneyCurrency: String

        enum CodingKeys: String, CodingKey {
            case name = "name"
            case realMoney = "realMoney"
            case realMoneyCurrency = "realMoneyCurrency"
            case bonusMoney = "bonusMoney"
            case bonusMoneyCurrency = "bonusMoneyCurrency"
            case lockedMoney = "lockedMoney"
            case lockedMoneyCurrency = "lockedMoneyCurrency"
        }
    }
}

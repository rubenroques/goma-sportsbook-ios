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
            case wallets = "accounts"
        }
    }

    struct UserBalanceWallet: Decodable {

        var id: Int
        var name: String?
        var currency: String
        var amount: Double
        var vendor: String
        var isBonus: Bool

        enum CodingKeys: String, CodingKey {
            case id = "id"
            case name = "name"
            case currency = "currency"
            case amount = "amount"
            case vendor = "vendor"
            case isBonus = "isBonusAccount"
        }

        func userBalanceWalletUpdated(amount: Double?) -> Self {

            return Self(id: self.id,
                        name: self.name,
                        currency: self.currency,
                        amount: amount ?? self.amount,
                        vendor: self.vendor,
                        isBonus: self.isBonus
            )
        }
    }

    struct AccountBalance: Decodable {

        var id: Int
        var vendor: String
        var type: String
        var amount: Double
        var bonusAmount: Double
        var isFirstDeposit: Bool

        enum CodingKeys: String, CodingKey {
            case id = "id"
            case vendor = "vendor"
            case type = "type"
            case amount = "amount"
            case bonusAmount = "bonusAmount"
            case isFirstDeposit = "isFirstDeposit"
        }
    }

    struct AccountBalanceWatcher: Decodable {
    }
}

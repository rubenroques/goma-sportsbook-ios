//
//  UserWallet.swift
//  BetssonCameroonApp
//
//  Created by Ruben Roques on 22/07/2025.
//

import Foundation

struct UserWallet: Codable, Hashable {
    let total: Double
    let totalRealAmount: Double?
    let bonus: Double?
    let totalWithdrawable: Double?
    let currency: String
}

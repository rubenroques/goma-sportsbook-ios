//
//  PartialCashOut.swift
//  BetssonCameroonApp
//

import Foundation

/// Represents a historical partial cashout entry for a bet
struct PartialCashOut: Codable, Equatable, Hashable {
    let requestId: String?
    let usedStake: Double?
    let cashOutAmount: Double?
    let status: String?
    let cashOutDate: Date?

    init(
        requestId: String? = nil,
        usedStake: Double? = nil,
        cashOutAmount: Double? = nil,
        status: String? = nil,
        cashOutDate: Date? = nil
    ) {
        self.requestId = requestId
        self.usedStake = usedStake
        self.cashOutAmount = cashOutAmount
        self.status = status
        self.cashOutDate = cashOutDate
    }
}

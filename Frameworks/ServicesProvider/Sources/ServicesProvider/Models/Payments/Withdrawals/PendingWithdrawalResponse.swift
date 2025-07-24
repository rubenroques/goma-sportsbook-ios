//
//  PendingWithdrawalResponse.swift
//  
//
//  Created by André Lascas on 28/02/2023.
//

import Foundation

public struct PendingWithdrawalResponse: Codable {

    public var status: String
    public var pendingWithdrawals: [PendingWithdrawal]

    enum CodingKeys: String, CodingKey {
        case status = "status"
        case pendingWithdrawals = "withdrawals"
    }
}

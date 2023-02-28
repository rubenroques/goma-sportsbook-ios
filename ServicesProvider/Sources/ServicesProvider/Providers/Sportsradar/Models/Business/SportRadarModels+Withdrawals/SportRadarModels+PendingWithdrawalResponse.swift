//
//  SportRadarModels+PendingWithdrawalResponse.swift
//  
//
//  Created by André Lascas on 28/02/2023.
//

import Foundation

extension SportRadarModels {

    struct PendingWithdrawalResponse: Codable {

        var status: String
        var pendingWithdrawals: [PendingWithdrawal]

        enum CodingKeys: String, CodingKey {
            case status = "status"
            case pendingWithdrawals = "withdrawals"
        }
    }

}

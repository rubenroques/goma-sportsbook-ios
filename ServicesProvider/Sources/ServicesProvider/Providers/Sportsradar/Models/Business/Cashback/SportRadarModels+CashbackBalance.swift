//
//  SportRadarModels+CashbackBalance.swift
//  
//
//  Created by André Lascas on 17/07/2023.
//

import Foundation

extension SportRadarModels {

    struct CashbackBalance: Codable {
        var status: String
        var balance: String?
        var message: String?

        enum CodingKeys: String, CodingKey {
            case status = "status"
            case balance = "balance"
            case message = "message"
        }
        
        init(status: String, balance: String? = nil, message: String? = nil) {
            self.status = status
            self.balance = balance
            self.message = message
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.status = try container.decode(String.self, forKey: .status)
            self.message = try container.decodeIfPresent(String.self, forKey: .message)
            
            if let balanceString = try? container.decodeIfPresent(String.self, forKey: .balance) {
                self.balance = balanceString
            }
            else if let balanceDouble = try? container.decodeIfPresent(Double.self, forKey: .balance) {
                self.balance = String(balanceDouble)
            }
            else {
                self.balance = nil
            }
        }
    }

}

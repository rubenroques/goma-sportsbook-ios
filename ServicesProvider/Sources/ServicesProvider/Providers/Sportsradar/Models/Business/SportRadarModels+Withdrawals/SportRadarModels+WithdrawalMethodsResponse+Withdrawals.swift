//
//  SportRadarModels+WithdrawalMethodsResponse.swift
//  
//
//  Created by André Lascas on 24/02/2023.
//

import Foundation

extension SportRadarModels {

    struct WithdrawalMethodsResponse: Codable {

        var status: String
        var withdrawalMethods: [WithdrawalMethod]

        enum CodingKeys: String, CodingKey {
            case status = "status"
            case withdrawalMethods = "withdrawalMethods"
        }
    }
    
}

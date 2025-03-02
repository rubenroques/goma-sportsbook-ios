//
//  WithdrawalMethodsResponse.swift
//  
//
//  Created by André Lascas on 24/02/2023.
//

import Foundation

public struct WithdrawalMethodsResponse: Codable {
    public var status: String
    public var withdrawalMethods: [WithdrawalMethod]

    enum CodingKeys: String, CodingKey {
        case status = "status"
        case withdrawalMethods = "withdrawalMethods"
    }
}

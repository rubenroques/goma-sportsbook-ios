//
//  ProcessWithdrawalResponse.swift
//  
//
//  Created by André Lascas on 27/02/2023.
//

import Foundation

public struct ProcessWithdrawalResponse: Codable {

    public var status: String
    public var paymentId: String?
    public var message: String?

    enum CodingKeys: String, CodingKey {
        case status = "status"
        case paymentId = "paymentId"
        case message = "message"
    }
}

public struct PrepareWithdrawalResponse: Codable {

    public var status: String
    public var conversionId: String?
    public var message: String?

    enum CodingKeys: String, CodingKey {
        case status = "status"
        case conversionId = "conversionId"
        case message = "message"
    }
}

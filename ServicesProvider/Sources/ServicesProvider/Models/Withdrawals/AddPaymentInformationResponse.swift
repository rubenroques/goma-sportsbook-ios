//
//  AddPaymentInformationResponse.swift
//  
//
//  Created by André Lascas on 16/03/2023.
//

import Foundation

public struct AddPaymentInformationResponse: Codable {
    public var status: String
    public var message: String?

    enum CodingKeys: String, CodingKey {
        case status = "status"
        case message = "message"
    }
}

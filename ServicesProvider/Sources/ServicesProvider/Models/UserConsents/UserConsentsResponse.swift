//
//  UserConsentsResponse.swift
//  
//
//  Created by André Lascas on 09/05/2023.
//

import Foundation

public struct UserConsentsResponse: Codable {
    public var status: String
    public var message: String?
    public var userConsents: [UserConsent]

    enum CodingKeys: String, CodingKey {
        case status = "status"
        case message = "message"
        case userConsents = "userConsents"
    }

}

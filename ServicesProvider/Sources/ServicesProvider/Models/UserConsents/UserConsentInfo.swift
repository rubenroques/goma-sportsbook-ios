//
//  UserConsentInfo.swift
//  
//
//  Created by André Lascas on 09/05/2023.
//

import Foundation

public struct ConsentInfo: Codable {

    public var id: Int
    public var key: String
    public var name: String
    public var consentVersionId: Int

    enum CodingKeys: String, CodingKey {
        case id = "id"
        case key = "key"
        case name = "name"
        case consentVersionId = "consentVersionId"
    }
}


public struct UserConsentInfo: Codable {

    public var id: Int
    public var key: String
    public var name: String
    public var consentVersionId: Int

    enum CodingKeys: String, CodingKey {
        case id = "id"
        case key = "key"
        case name = "name"
        case consentVersionId = "consentVersionId"
    }
}

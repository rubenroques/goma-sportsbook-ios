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

    public var status: String?
    public var isMandatory: Bool?
    
}


public struct UserConsentInfo: Codable, Hashable {

    public var id: Int
    public var key: String
    public var name: String
    public var consentVersionId: Int    
    public var isMandatory: Bool?

}

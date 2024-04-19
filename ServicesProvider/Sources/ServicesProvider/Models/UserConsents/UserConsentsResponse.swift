//
//  UserConsentsResponse.swift
//  
//
//  Created by André Lascas on 09/05/2023.
//

import Foundation

public struct UserConsentsResponse: Hashable {
    public var status: String
    public var message: String?
    public var userConsents: [UserConsent]
}

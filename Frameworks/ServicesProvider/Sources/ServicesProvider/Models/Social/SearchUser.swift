//
//  SearchUser.swift
//  
//
//  Created by André Lascas on 26/03/2024.
//

import Foundation

public struct SearchUser: Decodable {
    public let id: Int
    public let username: String
    public let avatar: String?
}

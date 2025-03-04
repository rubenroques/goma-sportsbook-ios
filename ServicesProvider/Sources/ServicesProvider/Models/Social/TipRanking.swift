//
//  TipRanking.swift
//
//
//  Created by André Lascas on 21/02/2024.
//

import Foundation

public struct TipRanking: Codable {
    public var position: Int
    public var result: Double
    public var userId: Int
    public var name: String
    public var code: String
    public var avatar: String?
    public var anonymous: Bool
}

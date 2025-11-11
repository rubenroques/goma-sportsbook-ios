//
//  ParticipantStats.swift
//
//
//  Created by Ruben Roques on 11/10/2022.
//

import Foundation

public struct ParticipantStats: Codable, Equatable {
    public var total: Int
    public var wins: Int?
    public var draws: Int?
    public var losses: Int?
    public var over: Int?
    public var under: Int?
}

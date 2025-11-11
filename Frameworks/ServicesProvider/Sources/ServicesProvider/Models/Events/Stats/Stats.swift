//
//  Stats.swift
//
//
//  Created by Ruben Roques on 11/10/2022.
//

import Foundation

public struct Stats: Codable, Equatable {
    public var homeParticipant: ParticipantStats
    public var awayParticipant: ParticipantStats
}

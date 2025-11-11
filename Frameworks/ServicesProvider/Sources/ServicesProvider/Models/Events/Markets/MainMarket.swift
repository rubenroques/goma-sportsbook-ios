//
//  MainMarket.swift
//
//
//  Created by Ruben Roques on 11/10/2022.
//

import Foundation

public struct MainMarket: Codable, Hashable, Identifiable {
    public let id: String
    public let bettingTypeId: String
    public let eventPartId: String
    public let sportId: String
    public let bettingTypeName: String
    public let eventPartName: String
    public let numberOfOutcomes: Int?
    public let liveMarket: Bool
    public let outright: Bool

    public init(
        id: String,
        bettingTypeId: String,
        eventPartId: String,
        sportId: String,
        bettingTypeName: String,
        eventPartName: String,
        numberOfOutcomes: Int?,
        liveMarket: Bool,
        outright: Bool
    ) {
        self.id = id
        self.bettingTypeId = bettingTypeId
        self.eventPartId = eventPartId
        self.sportId = sportId
        self.bettingTypeName = bettingTypeName
        self.eventPartName = eventPartName
        self.numberOfOutcomes = numberOfOutcomes
        self.liveMarket = liveMarket
        self.outright = outright
    }
}

//
//  SportCompetitionInfo.swift
//
//
//  Created by Ruben Roques on 11/10/2022.
//

import Foundation

public struct SportCompetitionInfo: Codable, Hashable {
    public var id: String
    public var name: String
    public var marketGroups: [SportCompetitionMarketGroup]
    public var numberOutrightEvents: String
    public var numberOutrightMarkets: String
    public var parentId: String?

    enum CodingKeys: String, CodingKey {
        case id = "idfwbonavigation"
        case name = "name"
        case marketGroups = "marketgroups"
        case numberOutrightEvents = "numoutrightevents"
        case numberOutrightMarkets = "numoutrightmarkets"
        case parentId = "idfwbonavigation_parent"
    }

}

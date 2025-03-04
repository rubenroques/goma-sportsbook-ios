//
//  EventPartScore.swift
//  Sportsbook
//
//  Created by Ruben Roques on 22/12/2021.
//

import Foundation

extension EveryMatrix {

    struct EventPartScore: Codable {

        let type: String?
        let id: String?
        let eventPartName: String?
        let shortEventPartName: String?
        let eventPartKey: String?
        let homeScore: String?
        let awayScore: String?
        let eventInfoTypeID: String?
        let eventInfoTypeName: String?
        let eventInfoTypeShortName: String?
        let currentEventPart: Bool?

        enum CodingKeys: String, CodingKey {
            case type = "_type"
            case id = "id"
            case eventPartName = "eventPartName"
            case shortEventPartName = "shortEventPartName"
            case eventPartKey = "eventPartKey"
            case homeScore = "homeScore"
            case awayScore = "awayScore"
            case eventInfoTypeID = "eventInfoTypeId"
            case eventInfoTypeName = "eventInfoTypeName"
            case eventInfoTypeShortName = "eventInfoTypeShortName"
            case currentEventPart = "currentEventPart"
        }
    }

}

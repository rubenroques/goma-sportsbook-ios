//
//  Match.swift
//  Sportsbook
//
//  Created by André Lascas on 06/09/2021.
//

import Foundation

typealias Matches = [Match]

struct Match: Decodable {

    let type: String?
    let id: String?
    let idAsString: String?
    let typeId: String?
    let name: String?
    let shortName: String?
    let statusId: String?
    let statusName: String?
    let typeName: String?
    let numberOfMarkets: Int?
    let numberOfBettingOffers: Int?
    let sportId: String?
    let sportName: String?
    let shortSportName: String?
    let venueId: String?
    let venueName: String?
    let shortVenueName: String?
    let rootPartId: String?
    let rootPartName: String?
    let shortRootPartName: String?
    let startTimestamp: Int?
    let parentId: String?
    let parentName: String?
    let shortParentName: String?
    let parentStartTime: Int?
    let parentEndTime: Int?
    let parentTemplateId: String?
    let homeParticipantId: String?
    let homeParticipantName: String?
    let homeShortParticipantName: String?
    let awayParticipantId: String?
    let awayParticipantName: String?
    let awayShortParticipantName: String?
    let parentPartId: String?
    let parentPartName: String?

    // Optional Data
    let eventId: String?
    let streamingProviderId: String?
    let url: String?
    let language: String?
    let renderType: String?
    let requiresToken: Bool?
    let requiresParent: Bool?

    enum CodingKeys: String, CodingKey {
        case type = "_type"
        case id = "id"
        case idAsString = "idAsString"
        case typeId = "typeId"
        case name = "name"
        case shortName = "shortName"
        case statusId = "statusId"
        case statusName = "statusName"
        case typeName = "typeName"
        case numberOfMarkets = "numberOfMarkets"
        case numberOfBettingOffers = "numberOfBettingOffers"
        case sportId = "sportId"
        case sportName = "sportName"
        case shortSportName = "shortSportName"
        case venueId = "venueId"
        case venueName = "venueName"
        case shortVenueName = "shortVenueName"
        case rootPartId = "rootPartId"
        case rootPartName = "rootPartName"
        case shortRootPartName = "shortRootPartName"
        case startTimestamp = "startTime"
        case parentId = "parentId"
        case parentName = "parentName"
        case shortParentName = "shortParentName"
        case parentStartTime = "parentStartTime"
        case parentEndTime = "parentEndTime"
        case parentTemplateId = "parentTemplateId"
        case homeParticipantId = "homeParticipantId"
        case homeParticipantName = "homeParticipantName"
        case homeShortParticipantName = "homeShortParticipantName"
        case awayParticipantId = "awayParticipantId"
        case awayParticipantName = "awayParticipantName"
        case awayShortParticipantName = "awayShortParticipantName"
        case parentPartId = "parentPartId"
        case parentPartName = "parentPartName"

        case eventId = "eventId"
        case streamingProviderId = "streamingProviderId"
        case url = "url"
        case language = "language"
        case renderType = "renderType"
        case requiresToken = "requiresToken"
        case requiresParent = "requiresParent"
    }
}

extension Match {
    var startDate: Date? {
        if let timestamp = startTimestamp {
            let normalizedTimestamp: Double = Double(timestamp)/100.0
            return Date(timeIntervalSince1970: normalizedTimestamp)
        }
        return nil
    }
}

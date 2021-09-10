//
//  Market.swift
//  Sportsbook
//
//  Created by André Lascas on 08/09/2021.
//

import Foundation

struct Market: Decodable {

    let type: String
    let id: String
    let name: String
    let shortName: String
    let displayKey: String
    let displayName: String
    let displayShortName: String
    let eventId: String
    let eventPartId: String
    let bettingTypeId: String
    let numberOfOutcomes: Int
    let scoringUnitId: String?
    let isComplete: Bool
    let isClosed: Bool
    let bettingTypeName: String
    let shortBettingTypeName: String
    let eventPartName: String
    let mainLine: Bool
    let isAvailable: Bool
    let shortEventPartName: String
    let scoringUnitName: String?
    let asianLine: Bool
    let paramFloat1: Double?
    let paramFloat2: Double?
    let paramFloat3: Double?
    let paramParticipantId1: String?
    let paramParticipantId2: String?
    let paramParticipantId3: String?

    enum CodingKeys: String, CodingKey {
        case type = "_type"
        case id = "id"
        case name = "name"
        case shortName = "shortName"
        case displayKey = "displayKey"
        case displayName = "displayName"
        case displayShortName = "displayShortName"
        case eventId = "eventId"
        case eventPartId = "eventPartId"
        case bettingTypeId = "bettingTypeId"
        case numberOfOutcomes = "numberOfOutcomes"
        case scoringUnitId = "scoringUnitId"
        case isComplete = "isComplete"
        case isClosed = "isClosed"
        case bettingTypeName = "bettingTypeName"
        case shortBettingTypeName = "shortBettingTypeName"
        case eventPartName = "eventPartName"
        case mainLine = "mainLine"
        case isAvailable = "isAvailable"
        case shortEventPartName = "shortEventPartName"
        case scoringUnitName = "scoringUnitName"
        case asianLine = "asianLine"
        case paramFloat1 = "paramFloat1"
        case paramFloat2 = "paramFloat2"
        case paramFloat3 = "paramFloat3"
        case paramParticipantId1 = "paramParticipantId1"
        case paramParticipantId2 = "paramParticipantId2"
        case paramParticipantId3 = "paramParticipantId3"
    }


}

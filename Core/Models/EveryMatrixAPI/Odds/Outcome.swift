//
//  Outcome.swift
//  Sportsbook
//
//  Created by André Lascas on 08/09/2021.
//

import Foundation

struct Outcome: Decodable {

    let type: String?
    let id: String?
    let typeId: String?
    let statusId: String?
    let eventId: String?
    let eventPartId: String?
    let code: String?
    let typeName: String?
    let translatedName: String?
    let shortTranslatedName: String?
    let eventPartName: String?
    let shortEventPartName: String?
    let headerName: String?
    let headerShortName: String?
    let headerNameKey: String?
    let paramFloat1: Double?
    let paramFloat2: Double?
    let paramFloat3: Double?
    let paramParticipantId1: String?
    let paramParticipantId2: String?
    let paramParticipantId3: String?
    let paramScoringUnitId1: String?
    let paramScoringUnitName1: String?
    let paramParticipantName1: String?
    let paramParticipantName2: String?
    let paramParticipantName3: String?
    let shortParamParticipantName1: String?
    let shortParamParticipantName2: String?
    let shortParamParticipantName3: String?

    enum CodingKeys: String, CodingKey {
        case type = "_type"
        case id = "id"
        case typeId = "typeId"
        case statusId = "statusId"
        case eventId = "eventId"
        case eventPartId = "eventPartId"
        case code = "code"
        case typeName = "typeName"
        case translatedName = "translatedName"
        case shortTranslatedName = "shortTranslatedName"
        case eventPartName = "eventPartName"
        case shortEventPartName = "shortEventPartName"
        case headerName = "headerName"
        case headerShortName = "headerShortName"
        case headerNameKey = "headerNameKey"
        case paramFloat1 = "paramFloat1"
        case paramFloat2 = "paramFloat2"
        case paramFloat3 = "paramFloat3"
        case paramParticipantId1 = "paramParticipantId1"
        case paramParticipantId2 = "paramParticipantId2"
        case paramParticipantId3 = "paramParticipantId3"
        case paramScoringUnitId1 = "paramScoringUnitId1"
        case paramScoringUnitName1 = "paramScoringUnitName1"
        case paramParticipantName1 = "paramParticipantName1"
        case paramParticipantName2 = "paramParticipantName2"
        case paramParticipantName3 = "paramParticipantName3"
        case shortParamParticipantName1 = "shortParamParticipantName1"
        case shortParamParticipantName2 = "shortParamParticipantName2"
        case shortParamParticipantName3 = "shortParamParticipantName3"

    }


}

//
//  MatchInfo.swift
//  Sportsbook
//
//  Created by Ruben Roques on 29/10/2021.
//

import Foundation

extension EveryMatrix {

    struct MatchInfo: Codable {

        let id: String
        let typeId: String?
        let matchId: String?
        let providerId: String?
        let statusId: String?
        let eventPartId: String?

        let paramFloat1: Int?
        let paramFloat2: Int?
        let paramParticipantId1: String?
        let paramParticipantId2: String?
        let paramScoringUnitId1: String?
        let paramScoringUnitName1: String?

        let paramEventPartId1: String?
        let paramEventStatusId1: String?
        let paramEventPartName1: String?
        let paramEventStatusName1: String?
        let eventPartName: String?
        let shortEventPartName: String?
        let shortParamEventPartName1: String?
        let eventPartRelativePosition: Int?

        enum CodingKeys: String, CodingKey {
            case id = "id"
            case typeId = "typeId"
            case matchId = "eventId"
            case providerId = "providerId"
            case statusId = "statusId"
            case eventPartId = "eventPartId"

            case paramFloat1 = "paramFloat1"
            case paramFloat2 = "paramFloat2"
            case paramParticipantId1 = "paramParticipantId1"
            case paramParticipantId2 = "paramParticipantId2"
            case paramScoringUnitId1 = "paramScoringUnitId1"
            case paramScoringUnitName1 = "paramScoringUnitName1"

            case paramEventPartId1 = "paramEventPartId1"
            case paramEventStatusId1 = "paramEventStatusId1"
            case paramEventPartName1 = "paramEventPartName1"
            case paramEventStatusName1 = "paramEventStatusName1"
            case eventPartName = "eventPartName"
            case shortEventPartName = "shortEventPartName"
            case shortParamEventPartName1 = "shortParamEventPartName1"
            case eventPartRelativePosition = "eventPartRelativePosition"
        }
    }

    func updateWith(newMatchInfo: MatchInfo) -> MatchInfo {

        return newMatchInfo
    }
}

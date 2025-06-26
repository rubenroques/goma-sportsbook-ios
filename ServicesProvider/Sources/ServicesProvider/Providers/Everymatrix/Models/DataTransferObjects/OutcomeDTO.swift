//
//  OutcomeDTO.swift
//  ServicesProvider
//
//  Created by Ruben Roques on 26/06/2025.
//

import Foundation

extension EveryMatrix {
    struct OutcomeDTO: Entity, EntityContainer {
        let id: String
        static let rawType: String = "OUTCOME"
        let typeId: String
        let statusId: String
        let eventId: String
        let eventPartId: String
        let paramFloat1: Double?
        let paramParticipantId1: String?
        let paramScoringUnitId1: String?
        let code: String
        let typeName: String
        let translatedName: String
        let shortTranslatedName: String
        let eventPartName: String
        let paramParticipantName1: String?
        let shortParamParticipantName1: String?
        let shortEventPartName: String
        let paramScoringUnitName1: String?
        let headerName: String?
        let headerShortName: String?
        let headerNameKey: String?

        func getReferencedIds() -> [String: [String]] {
            return [
                "Match": [eventId]
            ]
        }
    }
}
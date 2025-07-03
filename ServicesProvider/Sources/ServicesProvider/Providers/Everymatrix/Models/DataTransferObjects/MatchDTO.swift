//
//  MatchDTO.swift
//  ServicesProvider
//
//  Created by Ruben Roques on 26/06/2025.
//

import Foundation

extension EveryMatrix {
    struct MatchDTO: Entity, EntityContainer {
        let id: String
        static let rawType: String = "MATCH"
        let typeId: String
        let sportId: String
        let parentId: String
        let parentPartId: String
        let name: String
        let startTime: Int64
        let venueId: String
        let statusId: String
        let rootPartId: String
        let allowsLiveOdds: Bool
        let numberOfMarkets: Int
        let numberOfBettingOffers: Int
        let typeName: String
        let sportName: String
        let shortSportName: String
        let parentName: String
        let shortParentName: String
        let parentPartName: String
        let shortParentPartName: String
        let venueName: String
        let shortVenueName: String
        let statusName: String
        let rootPartName: String
        let shortRootPartName: String
        let shortName: String
        let parentStartTime: Int64
        let parentEndTime: Int64
        let parentTemplateId: String
        let homeParticipantId: String
        let homeParticipantName: String
        let awayParticipantId: String
        let awayParticipantName: String
        let homeShortParticipantName: String
        let awayShortParticipantName: String
        let categoryId: String
        let categoryName: String
        let displayChildren: Bool
        let layoutStyle: String

        func getReferencedIds() -> [String: [String]] {
            return [
                "Sport": [sportId],
                "Location": [venueId],
                "EventCategory": [categoryId]
            ]
        }
    }
}
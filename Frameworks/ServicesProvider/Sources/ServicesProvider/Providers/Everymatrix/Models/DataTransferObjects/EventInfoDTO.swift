//
//  EventInfoDTO.swift
//  ServicesProvider
//
//  Created by Ruben Roques on 26/06/2025.
//

import Foundation

extension EveryMatrix {
    struct EventInfoDTO: Entity, Hashable {
        let id: String
        static let rawType: String = "EVENT_INFO"
        let typeId: String
        let eventId: String
        let providerId: String
        let statusId: String
        let eventPartId: String?
        
        // Optional parameters for different types
        let paramFloat1: Double?
        let paramFloat2: Double?
        let paramParticipantId1: String?
        let paramParticipantId2: String?
        let paramScoringUnitId1: String?
        let paramEventPartId1: String?
        let paramEventStatusId1: String?
        
        // Display names
        let eventPartName: String?
        let typeName: String?
        let shortTypeName: String?
        let shortEventPartName: String?
        let paramScoringUnitName1: String?
        let paramEventPartName1: String?
        let paramEventStatusName1: String?
        let shortParamEventPartName1: String?
        
        let eventPartRelativePosition: Int?
    }
}
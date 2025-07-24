//
//  VaixAnalyticsEvent.swift
//  
//
//  Created by Ruben Roques on 14/05/2024.
//

import Foundation

public enum VaixAnalyticsEvent: AnalyticsEvent {
    
    case impressionsEvents(eventsIds: [String])
    case clickEvent(id: String)
    case clickOutcome(eventId: String, outcomeId: String)
    
    public var type: String {
        switch self {
        case .impressionsEvents:
            return "impressions:events"
        case .clickEvent:
            return "clicks:event"
        case .clickOutcome:
            return "clicks:outcome"
        }
    }

    public var data: [String : Any]? {
        switch self {
            
        case .impressionsEvents(let eventsIds):
            return [
                "position": 0,
                "location": "liveevent-popular",
                "channel": "ios",
                "events": eventsIds.map { ["id": $0] }
            ]
        case .clickEvent(let id):
           return [
                "position": 0,
                "location": "liveevent-popular",
                "channel": "ios",
                "event_id": id
            ]
        case .clickOutcome(let eventId, let outcomeId):
            return [
                 "position": 0,
                 "location": "liveevent-popular",
                 "channel": "ios",
                 "event_id": eventId,
                 "outcome_id": outcomeId
             ]
        }
    }
    
}


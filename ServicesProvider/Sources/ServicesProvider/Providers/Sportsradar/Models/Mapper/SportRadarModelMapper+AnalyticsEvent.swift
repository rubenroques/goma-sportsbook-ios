//
//  File.swift
//  
//
//  Created by Ruben Roques on 28/05/2024.
//

import Foundation


extension SportRadarModelMapper {
    static func vaixAnalyticsEvent(fromAnalyticsTrackedEvent analyticsTrackedEvent: AnalyticsTrackedEvent) -> VaixAnalyticsEvent {
        switch analyticsTrackedEvent {
        case .impressionsEvents(let eventsIds):
            return VaixAnalyticsEvent.impressionsEvents(eventsIds: eventsIds)
        case .clickEvent(let id):
            return VaixAnalyticsEvent.clickEvent(id: id)
        case .clickOutcome(let id):
            return VaixAnalyticsEvent.clickOutcome(id: id)
        }
    }
}

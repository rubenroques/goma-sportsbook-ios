//
//  AnalyticsTrackedEvent.swift
//
//
//  Created by Ruben Roques on 28/05/2024.
//

import Foundation


public enum AnalyticsTrackedEvent {
    
    case impressionsEvents(eventsIds: [String])
    case clickEvent(id: String)
    case clickOutcome(id: String)
 
}


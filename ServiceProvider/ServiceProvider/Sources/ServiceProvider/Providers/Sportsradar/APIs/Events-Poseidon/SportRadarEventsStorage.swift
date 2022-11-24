//
//  SportRadarEventsStorage.swift
//  
//
//  Created by Ruben Roques on 23/11/2022.
//

import Foundation

class SportRadarEventsStorage {
    
    let topicIdentifier: TopicIdentifier
    
    private var events: [String] = []
    
    init(topicIdentifier: TopicIdentifier) {
        self.topicIdentifier = topicIdentifier
    }
    
}

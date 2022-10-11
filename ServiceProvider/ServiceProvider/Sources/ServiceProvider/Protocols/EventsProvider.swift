//
//  EventsProvider.swift
//  
//
//  Created by Ruben Roques on 29/09/2022.
//

import Foundation
import Combine

protocol EventsProvider {

    func subscribeLiveMatches(forSportType sportType: SportType) -> AnyPublisher<SubscribableContent<[EventsGroup]>, ServiceProviderError>?
    
}

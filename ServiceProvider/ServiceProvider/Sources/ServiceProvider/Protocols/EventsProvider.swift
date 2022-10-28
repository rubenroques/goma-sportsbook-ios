//
//  EventsProvider.swift
//  
//
//  Created by Ruben Roques on 29/09/2022.
//

import Foundation
import Combine

protocol EventsProvider {

    func liveSportTypes() -> AnyPublisher<SubscribableContent<[SportTypeDetails]>, ServiceProviderError>?
    func subscribeLiveMatches(forSportType sportType: SportType) -> AnyPublisher<SubscribableContent<[EventsGroup]>, ServiceProviderError>?
    func allSportTypes(initialDate: Date?, endDate: Date?) -> AnyPublisher<SubscribableContent<[SportType]>, ServiceProviderError>?
    func subscribePreLiveMatches(forSportType sportType: SportType, initialDate: Date?, endDate: Date?, sortType: String) -> AnyPublisher<SubscribableContent<[EventsGroup]>, ServiceProviderError>?
//    func subscribeUpcomingMatches(forSportType sportType: SportType, dateRangeId: String, sortType: String) -> AnyPublisher<SubscribableContent<[EventsGroup]>, ServiceProviderError>?
    func unsubscribePreLiveMatches()
//    func unsubscribeUpcomingMatches()
    func unsubscribeAllSportTypes()

}

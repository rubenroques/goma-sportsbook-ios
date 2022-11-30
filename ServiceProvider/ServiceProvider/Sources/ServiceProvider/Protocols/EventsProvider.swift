//
//  EventsProvider.swift
//  
//
//  Created by Ruben Roques on 29/09/2022.
//

import Foundation
import Combine

protocol EventsProvider {
    
    func subscribeLiveMatches(forSportType sportType: SportType, pageIndex: Int) -> AnyPublisher<SubscribableContent<[EventsGroup]>, ServiceProviderError>

    func subscribePreLiveMatches(forSportType sportType: SportType, pageIndex: Int, initialDate: Date?, endDate: Date?, eventCount: Int, sortType: EventListSort) -> AnyPublisher<SubscribableContent<[EventsGroup]>, ServiceProviderError>
    
    func subscribeMatchDetails(matchId: String) -> AnyPublisher<SubscribableContent<[EventsGroup]>, ServiceProviderError>

    func subscribeAvailableSportTypes(initialDate: Date?, endDate: Date?) -> AnyPublisher<SubscribableContent<[SportType]>, ServiceProviderError>

    func subscribeLiveSportTypes() -> AnyPublisher<SubscribableContent<[SportType]>, ServiceProviderError>

    //
    func getAvailableSportTypes(initialDate: Date?, endDate: Date?) -> AnyPublisher<[SportType], ServiceProviderError>

    func getMarketsFilter(event: Event) -> AnyPublisher<[MarketGroup], ServiceProviderError>
    
    func getFieldWidgetId(eventId: String) -> AnyPublisher<FieldWidget, ServiceProviderError>
    
    func getFieldWidget(eventId: String, isDarkTheme: Bool?) -> AnyPublisher<FieldWidgetRenderData, ServiceProviderError>

    func getSportRegions(sportId: String) -> AnyPublisher<SportNodeInfo, ServiceProviderError>

    func getRegionCompetitions(regionId: String) -> AnyPublisher<SportRegionInfo, ServiceProviderError>

}

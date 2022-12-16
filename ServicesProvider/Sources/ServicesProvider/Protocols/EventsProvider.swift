//
//  EventsProvider.swift
//  
//
//  Created by Ruben Roques on 29/09/2022.
//

import Foundation
import Combine

protocol EventsProvider {
    
    func subscribeLiveMatches(forSportType sportType: SportType) -> AnyPublisher<SubscribableContent<[EventsGroup]>, ServiceProviderError>

    func requestLiveMatchesNextPage(forSportType sportType: SportType) -> AnyPublisher<Bool, ServiceProviderError>

    //
    func subscribePreLiveMatches(forSportType sportType: SportType, initialDate: Date?, endDate: Date?,  eventCount: Int?, sortType: EventListSort) -> AnyPublisher<SubscribableContent<[EventsGroup]>, ServiceProviderError>

    func requestPreLiveMatchesNextPage(forSportType sportType: SportType, initialDate: Date?, endDate: Date?, sortType: EventListSort) -> AnyPublisher<Bool, ServiceProviderError>

    func subscribeCompetitionMatches(forMarketGroupId marketGroupId: String) -> AnyPublisher<SubscribableContent<[EventsGroup]>, ServiceProviderError>

    //
    func subscribeMatchDetails(matchId: String) -> AnyPublisher<SubscribableContent<[EventsGroup]>, ServiceProviderError>

    func subscribeOutrightMarkets(forMarketGroupId marketGroupId: String) -> AnyPublisher<SubscribableContent<[EventsGroup]>, ServiceProviderError>

    //
    func subscribePreLiveSportTypes(initialDate: Date?, endDate: Date?) -> AnyPublisher<SubscribableContent<[SportType]>, ServiceProviderError>

    func subscribeLiveSportTypes() -> AnyPublisher<SubscribableContent<[SportType]>, ServiceProviderError>

    //
    func getAvailableSportTypes(initialDate: Date?, endDate: Date?) -> AnyPublisher<[SportType], ServiceProviderError>

    func getMarketsFilter(event: Event) -> AnyPublisher<[MarketGroup], ServiceProviderError>
    
    func getFieldWidgetId(eventId: String) -> AnyPublisher<FieldWidget, ServiceProviderError>
    
    func getFieldWidget(eventId: String, isDarkTheme: Bool?) -> AnyPublisher<FieldWidgetRenderDataType, ServiceProviderError>

    func getSportRegions(sportId: String) -> AnyPublisher<SportNodeInfo, ServiceProviderError>

    func getRegionCompetitions(regionId: String) -> AnyPublisher<SportRegionInfo, ServiceProviderError>

    func getCompetitionMarketGroups(competitionId: String) -> AnyPublisher<SportCompetitionInfo, ServiceProviderError>

    func getSearchEvents(query: String, resultLimit: String, page: String) -> AnyPublisher<EventsGroup, ServiceProviderError>

}

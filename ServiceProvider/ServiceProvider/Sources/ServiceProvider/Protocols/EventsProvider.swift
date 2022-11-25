//
//  EventsProvider.swift
//  
//
//  Created by Ruben Roques on 29/09/2022.
//

import Foundation
import Combine

protocol EventsProvider {

    func liveSportTypes() -> AnyPublisher<SubscribableContent<[SportType]>, ServiceProviderError>?
    func subscribeLiveMatches(forSportType sportType: SportType) -> AnyPublisher<SubscribableContent<[EventsGroup]>, ServiceProviderError>?
    func allSportTypes(initialDate: Date?, endDate: Date?) -> AnyPublisher<SubscribableContent<[SportType]>, ServiceProviderError>?
    func subscribePreLiveMatches(forSportType sportType: SportType, initialDate: Date?, endDate: Date?, sortType: String) -> AnyPublisher<SubscribableContent<[EventsGroup]>, ServiceProviderError>?
//    func subscribeUpcomingMatches(forSportType sportType: SportType, dateRangeId: String, sortType: String) -> AnyPublisher<SubscribableContent<[EventsGroup]>, ServiceProviderError>?
    func unsubscribePreLiveMatches()
//    func unsubscribeUpcomingMatches()
    func unsubscribeAllSportTypes()

    func subscribeMatchDetails(matchId: String) -> AnyPublisher<SubscribableContent<[EventsGroup]>, ServiceProviderError>?

    // REST API
    func getMarketsFilter(event: Event) -> AnyPublisher<[MarketGroup], ServiceProviderError>?

    func getFieldWidgetId(eventId: String) -> AnyPublisher<FieldWidget, ServiceProviderError>

    func getSportsList() -> AnyPublisher<SportRadarResponse<SportsList>, ServiceProviderError>?

    func getAllSportsList(initialDate: Date?, endDate: Date?) -> AnyPublisher<[SportType], ServiceProviderError>

    func getFieldWidget(eventId: String, isDarkTheme: Bool?) -> AnyPublisher<FieldWidgetRenderData, ServiceProviderError>
}

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
    func getMarketsFilter() -> AnyPublisher<MarketFilter, ServiceProviderError>?

    func getFieldWidgetId(eventId: String) -> AnyPublisher<FieldWidget, ServiceProviderError>?

    func getSportsList() -> AnyPublisher<SportRadarResponse<SportsList>, ServiceProviderError>?

    func getAllSportsList(initialDate: Date?, endDate: Date?) -> AnyPublisher<[SportType], ServiceProviderError>

    func getFieldWidgetURLRequest(urlString: String?, widgetFile: String?) -> URLRequest?

    func getFieldWidgetHtml(widgetFile: String, eventId: String, providerId: String?) -> String?

}

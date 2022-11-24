//
//  EventsProvider.swift
//  
//
//  Created by Ruben Roques on 29/09/2022.
//

import Foundation
import Combine

protocol EventsProvider {
    
    func allSportTypes(initialDate: Date?, endDate: Date?) -> AnyPublisher<SubscribableContent<[SportType]>, ServiceProviderError>
    func liveSportTypes() -> AnyPublisher<SubscribableContent<[SportTypeDetails]>, ServiceProviderError>
    
    func subscribeLiveMatches(forSportType sportType: SportType, pageIndex: Int) -> AnyPublisher<SubscribableContent<[EventsGroup]>, ServiceProviderError>
    func unsubscribeAllSportTypes()
    
    func subscribePreLiveMatches(forSportType sportType: SportType, pageIndex: Int, initialDate: Date?, endDate: Date?, eventCount: Int, sortType: EventListSort) -> AnyPublisher<SubscribableContent<[EventsGroup]>, ServiceProviderError>
    
    func subscribeMatchDetails(matchId: String) -> AnyPublisher<SubscribableContent<[EventsGroup]>, ServiceProviderError>
    
    // REST API
    func getMarketsFilter() -> AnyPublisher<MarketFilter, ServiceProviderError>
    
    func getFieldWidgetId(eventId: String) -> AnyPublisher<FieldWidget, ServiceProviderError>
    
    func getFieldWidgetURLRequest(urlString: String?, widgetFile: String?) -> URLRequest?
    
    func getFieldWidgetHtml(widgetFile: String, eventId: String, providerId: String?) -> String?
    
}

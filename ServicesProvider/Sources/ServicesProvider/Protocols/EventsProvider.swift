//
//  EventsProvider.swift
//  
//
//  Created by Ruben Roques on 29/09/2022.
//

import Foundation
import Combine

protocol EventsProvider: Connector {

    //
    //
    func reconnectIfNeeded()

    //
    //
    func subscribeLiveMatches(forSportType sportType: SportType) -> AnyPublisher<SubscribableContent<[EventsGroup]>, ServiceProviderError>
    func requestLiveMatchesNextPage(forSportType sportType: SportType) -> AnyPublisher<Bool, ServiceProviderError>

    //
    //
    func subscribePreLiveMatches(forSportType sportType: SportType, initialDate: Date?, endDate: Date?,  eventCount: Int?, sortType: EventListSort) -> AnyPublisher<SubscribableContent<[EventsGroup]>, ServiceProviderError>
    func requestPreLiveMatchesNextPage(forSportType sportType: SportType, initialDate: Date?, endDate: Date?, sortType: EventListSort) -> AnyPublisher<Bool, ServiceProviderError>

    //
    //
    func subscribeCompetitionMatches(forMarketGroupId marketGroupId: String) -> AnyPublisher<SubscribableContent<[EventsGroup]>, ServiceProviderError>

    //
    //
    func subscribeToMarketDetails(withId marketId: String, onEventId eventId:String) -> AnyPublisher<SubscribableContent<Market>, ServiceProviderError>
    func subscribeEventDetails(eventId: String) -> AnyPublisher<SubscribableContent<Event>, ServiceProviderError>
    func subscribeEventSummary(eventId: String) -> AnyPublisher<SubscribableContent<[EventsGroup]>, ServiceProviderError>
    func subscribeOutrightMarkets(forMarketGroupId marketGroupId: String) -> AnyPublisher<SubscribableContent<[EventsGroup]>, ServiceProviderError>
    func subscribeOutrightEvent(forMarketGroupId marketGroupId: String) -> AnyPublisher<SubscribableContent<Event>, ServiceProviderError>
    
    //
    //
    func subscribePreLiveSportTypes(initialDate: Date?, endDate: Date?) -> AnyPublisher<SubscribableContent<[SportType]>, ServiceProviderError>
    func subscribeLiveSportTypes() -> AnyPublisher<SubscribableContent<[SportType]>, ServiceProviderError>
    func subscribeAllSportTypes() -> AnyPublisher<SubscribableContent<[SportType]>, ServiceProviderError>

    //
    // Live Data extended info independent from the lists
    // This one creates a new subscription
    func subscribeToLiveDataUpdates(forEventWithId id: String) -> AnyPublisher<SubscribableContent<EventLiveData>, ServiceProviderError>
    
    // Publishers associated with the events lists (prelive and live)
    // Those publishers come from the paginator events
    func subscribeToEventOnListsLiveDataUpdates(withId id: String) -> AnyPublisher<Event?, ServiceProviderError>
    func subscribeToEventOnListsMarketUpdates(withId id: String) -> AnyPublisher<Market?, ServiceProviderError>
    func subscribeToEventOnListsOutcomeUpdates(withId id: String) -> AnyPublisher<Outcome?, ServiceProviderError>


    //
    //
    func getAvailableSportTypes(initialDate: Date?, endDate: Date?) -> AnyPublisher<[SportType], ServiceProviderError>

    func getMarketsFilters(event: Event) -> AnyPublisher<[MarketGroup], Never>
    
    func getFieldWidgetId(eventId: String) -> AnyPublisher<FieldWidget, ServiceProviderError>
    
    func getFieldWidget(eventId: String, isDarkTheme: Bool?) -> AnyPublisher<FieldWidgetRenderDataType, ServiceProviderError>

    func getStatsWidget(eventId: String, marketTypeName: String, isDarkTheme: Bool?) -> AnyPublisher<StatsWidgetRenderDataType, ServiceProviderError>
    
    func getSportRegions(sportId: String) -> AnyPublisher<SportNodeInfo, ServiceProviderError>

    func getRegionCompetitions(regionId: String) -> AnyPublisher<SportRegionInfo, ServiceProviderError>

    func getCompetitionMarketGroups(competitionId: String) -> AnyPublisher<SportCompetitionInfo, ServiceProviderError>

    func getSearchEvents(query: String, resultLimit: String, page: String, isLive: Bool) -> AnyPublisher<EventsGroup, ServiceProviderError>

    func getEventSummary(eventId: String) -> AnyPublisher<Event, ServiceProviderError>
    
    func getEventSummary(forMarketId marketId: String) -> AnyPublisher<Event, ServiceProviderError>
    
    func getMarketInfo(marketId: String) -> AnyPublisher<Market, ServiceProviderError>

    func getHomeSliders() -> AnyPublisher<BannerResponse, ServiceProviderError>

    func getPromotionalTopBanners() -> AnyPublisher<[PromotionalBanner], ServiceProviderError>
    func getPromotionalSlidingTopEvents() -> AnyPublisher<[Event], ServiceProviderError>
    func getPromotionalTopStories() -> AnyPublisher<[PromotionalStory], ServiceProviderError>

    func getHighlightedBoostedEvents() -> AnyPublisher<[Event], ServiceProviderError>
    func getHighlightedVisualImageEvents() -> AnyPublisher<[Event], ServiceProviderError>
    
    func getHeroGameEvent() -> AnyPublisher<Event, ServiceProviderError>

    func getPromotedSports() -> AnyPublisher<[PromotedSport], ServiceProviderError>

    func getCashbackSuccessBanner() -> AnyPublisher<BannerResponse, ServiceProviderError>

    func getTopCompetitionsPointers() -> AnyPublisher<[TopCompetitionPointer], ServiceProviderError>

    func getTopCompetitions() -> AnyPublisher<[TopCompetition], ServiceProviderError>

    func getEventsForEventGroup(withId eventGroupId: String) -> AnyPublisher<EventsGroup, ServiceProviderError>

    func getEventForMarketGroup(withId marketGroupId: String) -> AnyPublisher<Event, ServiceProviderError>
    
    func getEventDetails(eventId: String) -> AnyPublisher<Event, ServiceProviderError>

    func getEventSecundaryMarkets(eventId: String) -> AnyPublisher<Event, ServiceProviderError>
    
    func getEventLiveData(eventId: String) -> AnyPublisher<EventLiveData, ServiceProviderError>
    
    // Only the markets updates
    func subscribeEventSecundaryMarkets(eventId: String) -> AnyPublisher<SubscribableContent<Event>, ServiceProviderError>
    
    // Event and markets updates
    func subscribeToEventAndSecondaryMarkets(withId id: String) -> AnyPublisher<SubscribableContent<Event>, ServiceProviderError>
    
    func getHighlightedLiveEventsIds(eventCount: Int, userId: String?) -> AnyPublisher<[String], ServiceProviderError>
    func getHighlightedLiveEvents(eventCount: Int, userId: String?) -> AnyPublisher<[Event], ServiceProviderError>
    
    //
    // Favorites
    func getFavoritesList() -> AnyPublisher<FavoritesListResponse, ServiceProviderError>
    func addFavoritesList(name: String) -> AnyPublisher<FavoritesListAddResponse, ServiceProviderError>
    func deleteFavoritesList(listId: Int) -> AnyPublisher<FavoritesListDeleteResponse, ServiceProviderError>
    func addFavoriteToList(listId: Int, eventId: String) -> AnyPublisher<FavoriteAddResponse, ServiceProviderError>
    func getFavoritesFromList(listId: Int) -> AnyPublisher<FavoriteEventResponse, ServiceProviderError>
    func deleteFavoriteFromList(eventId: Int) -> AnyPublisher<FavoritesListDeleteResponse, ServiceProviderError>

    //
    // Utilities
    func getDatesFilter(timeRange: String) -> [Date]

}

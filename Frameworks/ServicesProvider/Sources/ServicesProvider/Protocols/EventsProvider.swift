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
    func reconnectIfNeeded()

    //
    func subscribeLiveMatches(forSportType sportType: SportType) -> AnyPublisher<SubscribableContent<[EventsGroup]>, ServiceProviderError>
    func requestLiveMatchesNextPage(forSportType sportType: SportType) -> AnyPublisher<Bool, ServiceProviderError>

    //
    func subscribePreLiveMatches(forSportType sportType: SportType, initialDate: Date?, endDate: Date?,  eventCount: Int?, sortType: EventListSort) -> AnyPublisher<SubscribableContent<[EventsGroup]>, ServiceProviderError>
    func requestPreLiveMatchesNextPage(forSportType sportType: SportType, initialDate: Date?, endDate: Date?, sortType: EventListSort) -> AnyPublisher<Bool, ServiceProviderError>
    
    // New filtered subscription methods using custom-matches-aggregator
    func subscribeToFilteredPreLiveMatches(filters: MatchesFilterOptions) -> AnyPublisher<SubscribableContent<[EventsGroup]>, ServiceProviderError>
    func subscribeToFilteredLiveMatches(filters: MatchesFilterOptions) -> AnyPublisher<SubscribableContent<[EventsGroup]>, ServiceProviderError>

    //
    func subscribeEndedMatches(forSportType sportType: SportType) -> AnyPublisher<SubscribableContent<[EventsGroup]>, ServiceProviderError>
    func requestEndedMatchesNextPage(forSportType sportType: SportType) -> AnyPublisher<Bool, ServiceProviderError>
    
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

    // sports list
    func subscribeSportTypes() -> AnyPublisher<SubscribableContent<[SportType]>, ServiceProviderError>

    //
    // Live Data extended info independent from the lists
    // This one creates a new subscription
    func subscribeToLiveDataUpdates(forEventWithId id: String) -> AnyPublisher<SubscribableContent<EventLiveData>, ServiceProviderError>

    // Publishers associated with the events lists (prelive and live)
    // Those publishers come from the paginator events
    func subscribeToEventOnListsLiveDataUpdates(withId id: String) -> AnyPublisher<Event?, ServiceProviderError>
    func subscribeToEventOnListsMarketUpdates(withId id: String) -> AnyPublisher<Market?, ServiceProviderError>
    func subscribeToEventOnListsOutcomeUpdates(withId id: String) -> AnyPublisher<Outcome?, ServiceProviderError>
    
    // Tournaments
    func subscribePopularTournaments(forSportType sportType: SportType, tournamentsCount: Int) -> AnyPublisher<SubscribableContent<[Tournament]>, ServiceProviderError>
    
    func subscribeSportTournaments(forSportType sportType: SportType) -> AnyPublisher<SubscribableContent<[Tournament]>, ServiceProviderError>
    
    // Tournament RPC Methods (one-time fetch)
    func getPopularTournaments(forSportType sportType: SportType, tournamentsCount: Int) -> AnyPublisher<[Tournament], ServiceProviderError>
    
    func getTournaments(forSportType sportType: SportType) -> AnyPublisher<[Tournament], ServiceProviderError>

    //
    //
    func getMarketGroups(forEvent event: Event, includeMixMatchGroup: Bool, includeAllMarketsGroup: Bool) -> AnyPublisher<[MarketGroup], Never>

    func getFieldWidgetId(eventId: String) -> AnyPublisher<FieldWidget, ServiceProviderError>

    func getFieldWidget(eventId: String, isDarkTheme: Bool?) -> AnyPublisher<FieldWidgetRenderDataType, ServiceProviderError>

    func getStatsWidget(eventId: String, marketTypeName: String, isDarkTheme: Bool?) -> AnyPublisher<StatsWidgetRenderDataType, ServiceProviderError>

    func getSportRegions(sportId: String) -> AnyPublisher<SportNodeInfo, ServiceProviderError>

    func getRegionCompetitions(regionId: String) -> AnyPublisher<SportRegionInfo, ServiceProviderError>

    func getCompetitionMarketGroups(competitionId: String) -> AnyPublisher<SportCompetitionInfo, ServiceProviderError>

    func getSearchEvents(query: String, resultLimit: String, page: String, isLive: Bool) -> AnyPublisher<EventsGroup, ServiceProviderError>

    func getEventSummary(eventId: String, marketLimit: Int?) -> AnyPublisher<Event, ServiceProviderError>
    func getEventSummary(forMarketId: String) -> AnyPublisher<Event, ServiceProviderError>

    func getMarketInfo(marketId: String) -> AnyPublisher<Market, ServiceProviderError>

    func getHomeSliders() -> AnyPublisher<BannerResponse, ServiceProviderError>

    func getPromotedSports() -> AnyPublisher<[PromotedSport], ServiceProviderError>

    func getCashbackSuccessBanner() -> AnyPublisher<BannerResponse, ServiceProviderError>

    func getEventGroup(withId eventGroupId: String) -> AnyPublisher<EventsGroup, ServiceProviderError>

    func getEventForMarketGroup(withId marketGroupId: String) -> AnyPublisher<Event, ServiceProviderError>

    func getEventDetails(eventId: String) -> AnyPublisher<Event, ServiceProviderError>

    func getEventSecundaryMarkets(eventId: String) -> AnyPublisher<Event, ServiceProviderError>

    func getEventLiveData(eventId: String) -> AnyPublisher<EventLiveData, ServiceProviderError>

    // Only the secundary markets updates
    func subscribeEventMarkets(eventId: String) -> AnyPublisher<SubscribableContent<Event>, ServiceProviderError>
    
    // Market group specific subscriptions
    func subscribeToMarketGroups(eventId: String) -> AnyPublisher<SubscribableContent<[MarketGroup]>, ServiceProviderError>
    func subscribeToMarketGroupDetails(eventId: String, marketGroupKey: String) -> AnyPublisher<SubscribableContent<[Market]>, ServiceProviderError>

    // Event and markets updates
    func subscribeToEventAndSecondaryMarkets(withId id: String) -> AnyPublisher<SubscribableContent<Event>, ServiceProviderError>

    func getHighlightedLiveEventsPointers(eventCount: Int, userId: String?) -> AnyPublisher<[String], ServiceProviderError>
    func getHighlightedLiveEvents(eventCount: Int, userId: String?) -> AnyPublisher<Events, ServiceProviderError>

    func getPromotedBetslips(userId: String?) -> AnyPublisher<[PromotedBetslip], ServiceProviderError>

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
    func getNews() -> AnyPublisher<[News], ServiceProviderError>
    func addFavoriteItem(favoriteId: Int, type: String) -> AnyPublisher<BasicMessageResponse, ServiceProviderError>
    func deleteFavoriteItem(favoriteId: Int, type: String) -> AnyPublisher<BasicMessageResponse, ServiceProviderError>
    func getFeaturedTips(page: Int?, limit: Int?, topTips: Bool?, followersTips: Bool?, friendsTips: Bool?, userId: String?, homeTips: Bool?) -> AnyPublisher<FeaturedTips, ServiceProviderError>
}

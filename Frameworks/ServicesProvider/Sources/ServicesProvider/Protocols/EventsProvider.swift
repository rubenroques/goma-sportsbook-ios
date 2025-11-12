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

    // Filtered pagination methods
    func requestFilteredPreLiveMatchesNextPage(filters: MatchesFilterOptions) -> AnyPublisher<Bool, ServiceProviderError>
    func requestFilteredLiveMatchesNextPage(filters: MatchesFilterOptions) -> AnyPublisher<Bool, ServiceProviderError>

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
    
    // health check
    func checkServicesHealth() -> AnyPublisher<Bool, ServiceProviderError>

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
    
    func getMultiSearchEvents(query: String, resultLimit: String, page: String, isLive: Bool) -> AnyPublisher<EventsGroup, ServiceProviderError>

    func getEventSummary(eventId: String, marketLimit: Int?) -> AnyPublisher<Event, ServiceProviderError>
    func getEventSummary(forMarketId: String) -> AnyPublisher<Event, ServiceProviderError>

    func getMarketInfo(marketId: String) -> AnyPublisher<Market, ServiceProviderError>

    /// Resolves a betting outcome ID to its current betting offer IDs and parent event.
    ///
    /// This is primarily used for the **rebet feature** to reconstruct betting tickets.
    /// Historical bets store outcome IDs, but placing new bets requires betting offer IDs.
    ///
    /// **Use Case**: When a user taps "Rebet" on a historical bet, we need to convert the
    /// stored outcome IDs into current betting offer IDs to place a fresh bet.
    ///
    /// - Parameter outcomeId: The outcome identifier from a historical bet selection
    /// - Returns: Reference containing event ID and betting offer IDs, or error if outcome not found
    func getBettingOfferReference(forOutcomeId outcomeId: String) -> AnyPublisher<OutcomeBettingOfferReference, ServiceProviderError>

    /// Fetches Event with single outcome for a betting offer (one-time RPC request)
    ///
    /// Returns Event containing:
    /// - Full event details (teams, scores, status)
    /// - Single market in markets array
    /// - Single outcome in that market
    ///
    /// **Use Case**: Quick betslip validation or initial odds check without subscription overhead
    ///
    /// - Parameter bettingOfferId: The betting offer identifier
    /// - Returns: Publisher emitting Event with single outcome, or error if not found
    func getEventWithSingleOutcome(bettingOfferId: String) -> AnyPublisher<Event, ServiceProviderError>

    /// Load full Events from a booking code for betslip population.
    ///
    /// Converts a booking code to its betting offer IDs, then fetches full Event data
    /// for each offer so selections can be added to the betslip.
    ///
    /// **Use Case**: User receives shared booking code and wants to load bets into betslip
    ///
    /// **Implementation Strategy**:
    /// 1. Retrieve betting offer IDs from booking code via PrivilegedAccessManager
    /// 2. Fetch Event for each betting offer ID (provider-specific)
    /// 3. Return array of Events ready for betslip
    ///
    /// - Parameter bookingCode: The booking code to load (e.g., "7YRLO2UQ")
    /// - Returns: Publisher emitting array of Events or error
    func loadEventsFromBookingCode(bookingCode: String) -> AnyPublisher<[Event], ServiceProviderError>

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

    /// Subscribe to live updates for a single outcome (for betslip odds tracking)
    /// - Parameters:
    ///   - eventId: The match/event identifier
    ///   - outcomeId: The outcome identifier (equivalent to bettingOfferId in EveryMatrix)
    /// - Returns: Publisher emitting Event with single market containing single outcome
    func subscribeToEventWithSingleOutcome(eventId: String, outcomeId: String) -> AnyPublisher<SubscribableContent<Event>, ServiceProviderError>

    /// Subscribe to event with the most balanced market for given betting type + event part
    ///
    /// Returns Event with:
    /// - Full event details (teams, scores, status, live data)
    /// - Single market in markets array (the most balanced for the specified betting type and event part)
    ///
    /// Note: The specific market returned may change over time as the provider rebalances odds.
    /// Subscription is automatically cleaned up when the subscriber is deallocated.
    ///
    /// - Parameters:
    ///   - eventId: The match/event identifier
    ///   - marketIdentifier: Provider-specific market identification (EveryMatrix uses eventPartId + bettingTypeId)
    /// - Returns: Publisher emitting Event with single balanced market
    func subscribeToEventWithBalancedMarket(eventId: String, marketIdentifier: MarketIdentifier) -> AnyPublisher<SubscribableContent<Event>, ServiceProviderError>

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
    
    // User Favorites
    func getUserFavorites() -> AnyPublisher<UserFavoritesResponse, ServiceProviderError>

    //
    // Utilities
    func getDatesFilter(timeRange: String) -> [Date]
    func getNews() -> AnyPublisher<[News], ServiceProviderError>
    func addFavoriteItem(favoriteId: Int, type: String) -> AnyPublisher<BasicMessageResponse, ServiceProviderError>
    func deleteFavoriteItem(favoriteId: Int, type: String) -> AnyPublisher<BasicMessageResponse, ServiceProviderError>
    func getFeaturedTips(page: Int?, limit: Int?, topTips: Bool?, followersTips: Bool?, friendsTips: Bool?, userId: String?, homeTips: Bool?) -> AnyPublisher<FeaturedTips, ServiceProviderError>
    
    // Recommendations
    func getRecommendedMatch(userId: String, isLive: Bool, limit: Int) -> AnyPublisher<[Event], ServiceProviderError>
    
    func getComboRecommendedMatch(userId: String, isLive: Bool, limit: Int) -> AnyPublisher<[Event], ServiceProviderError>
}

//
//  MatchDetailsManager.swift
//  ServicesProvider
//
//  Created on 2025-07-17.
//

import Foundation
import Combine
import SharedModels
import GomaLogger

/// Manages subscription to match details including event info and all markets
/// 
/// This class provides subscriptions for:
/// 1. Event details with statistics and live data
/// 2. All markets for a match with real-time odds updates
class MatchDetailsManager {
    
    // MARK: - Dependencies
    private let connector: EveryMatrixSocketConnector
    private let operatorId: String

    // MARK: - State Management
    private let store = EveryMatrix.EntityStore()
    private var marketGroupStores = [String: EveryMatrix.EntityStore]()
    
    private var matchAggregatorSubscription: EndpointPublisherIdentifiable?
    private var marketGroupsSubscription: EndpointPublisherIdentifiable?
    private var marketGroupDetailsSubscriptions = [String: EndpointPublisherIdentifiable]()
    
    private var marketDetailsSubscription: EndpointPublisherIdentifiable?
    
    private var cancellables = Set<AnyCancellable>()
    
    // Cached data
    private var cachedMarketGroups: [MarketGroup] = []
    private var marketGroupsLoaded = false
    
    // MARK: - Configuration
    let matchId: String
    
    // MARK: - Initialization
    
    init(connector: EveryMatrixSocketConnector,
         operatorId: String,
         matchId: String) {
        self.connector = connector
        self.matchId = matchId
        self.operatorId = operatorId
    }
    
    deinit {
        unsubscribe()
    }
    
    // MARK: - Public Interface
    
    /// Subscribe to event details including live data, statistics, and market groups
    func subscribeEventDetails() -> AnyPublisher<SubscribableContent<Event>, ServiceProviderError> {
        // Clean up any existing subscription
        unsubscribeMatchAggregator()
        
        // Subscribe to match aggregator for live data, scores, match status
        let router = WAMPRouter.matchDetailsAggregatorPublisher(
            operatorId: operatorId,
            language: EveryMatrixUnifiedConfiguration.shared.defaultLanguage,
            matchId: matchId
        )
        
        return connector.subscribe(router)
            .handleEvents(receiveOutput: { [weak self] content in
                // Store subscription reference for cleanup
                if case .connect(let subscription) = content {
                    self?.matchAggregatorSubscription = subscription
                }
            })
            .compactMap { [weak self] content -> SubscribableContent<Event>? in
                return try? self?.handleMatchAggregatorContent(content)
            }
            .eraseToAnyPublisher()
    }
    
    /// Subscribe to market groups for the match
    func subscribeToMarketGroups() -> AnyPublisher<SubscribableContent<[MarketGroup]>, ServiceProviderError> {
        // Clean up any existing subscription
        unsubscribeMarketGroups()
        
        let router = WAMPRouter.matchMarketGroupsPublisher(
            operatorId: operatorId,
            language: EveryMatrixUnifiedConfiguration.shared.defaultLanguage,
            matchId: matchId
        )
        
        return connector.subscribe(router)
            .handleEvents(receiveOutput: { [weak self] content in
                // Store subscription reference for cleanup
                if case .connect(let subscription) = content {
                    self?.marketGroupsSubscription = subscription
                }
            })
            .compactMap { [weak self] content -> SubscribableContent<[MarketGroup]>? in
                return try? self?.handleMarketGroupsContent(content)
            }
            .eraseToAnyPublisher()
    }
    
    /// Subscribe to specific market group details
    func subscribeToMarketGroupDetails(marketGroupKey: String) -> AnyPublisher<SubscribableContent<[Market]>, ServiceProviderError> {
        // Unsubscribe existing subscription for this group if any
        if let existing = marketGroupDetailsSubscriptions[marketGroupKey] {
            connector.unsubscribe(existing)
        }
        
        // Create isolated EntityStore for this market group
        marketGroupStores[marketGroupKey] = EveryMatrix.EntityStore()
        
        let router = WAMPRouter.matchMarketGroupDetailsPublisher(
            operatorId: operatorId,
            language: EveryMatrixUnifiedConfiguration.shared.defaultLanguage,
            matchId: matchId,
            marketGroupName: marketGroupKey
        )
        
        return connector.subscribe(router)
            .handleEvents(receiveOutput: { [weak self] content in
                if case .connect(let subscription) = content {
                    self?.marketGroupDetailsSubscriptions[marketGroupKey] = subscription
                }
            })
            .compactMap { [weak self] content -> SubscribableContent<[Market]>? in
                return try? self?.handleMarketGroupDetailsContent(content, marketGroupKey: marketGroupKey)
            }
            .mapError { error -> ServiceProviderError in
                if let serviceError = error as? ServiceProviderError {
                    return serviceError
                }
                return ServiceProviderError.unknown
            }
            .eraseToAnyPublisher()
    }
    
    /// Subscribe to all markets for the match (deprecated - use market group subscriptions)
    func subscribeEventMarkets() -> AnyPublisher<SubscribableContent<Event>, ServiceProviderError> {
        // Clean up any existing subscription
        unsubscribeMarketDetails()
        
        // Use oddsMatch for all markets subscription
        let router = WAMPRouter.oddsMatch(
            operatorId: operatorId,
            language: EveryMatrixUnifiedConfiguration.shared.defaultLanguage,
            matchId: matchId
        )
        
        return connector.subscribe(router)
            .handleEvents(receiveOutput: { [weak self] content in
                // Store subscription reference for cleanup
                if case .connect(let subscription) = content {
                    self?.marketDetailsSubscription = subscription
                }
            })
            .compactMap { [weak self] content -> SubscribableContent<Event>? in
                return try? self?.handleMarketDetailsContent(content)
            }
            .mapError { error -> ServiceProviderError in
                if let serviceError = error as? ServiceProviderError {
                    return serviceError
                }
                return ServiceProviderError.unknown
            }
            .eraseToAnyPublisher()
    }
    
    /// Clean up all subscriptions
    func unsubscribe() {
        unsubscribeMatchAggregator()
        unsubscribeMarketGroups()
        unsubscribeAllMarketGroupDetails()
        unsubscribeMarketDetails()
        cancellables.removeAll()
        store.clear()
        marketGroupStores.removeAll()
        cachedMarketGroups.removeAll()
        marketGroupsLoaded = false
    }
    
    // MARK: - Private Methods
    
    private func unsubscribeMatchAggregator() {
        if let subscription = matchAggregatorSubscription {
            connector.unsubscribe(subscription)
            matchAggregatorSubscription = nil
        }
    }
    
    private func unsubscribeMarketGroups() {
        if let subscription = marketGroupsSubscription {
            connector.unsubscribe(subscription)
            marketGroupsSubscription = nil
        }
    }
    
    private func unsubscribeAllMarketGroupDetails() {
        for (_, subscription) in marketGroupDetailsSubscriptions {
            connector.unsubscribe(subscription)
        }
        marketGroupDetailsSubscriptions.removeAll()
        marketGroupStores.removeAll()
    }
    
    private func unsubscribeMarketDetails() {
        if let subscription = marketDetailsSubscription {
            connector.unsubscribe(subscription)
            marketDetailsSubscription = nil
        }
    }
    
    private func handleMatchAggregatorContent(_ content: WAMPSubscriptionContent<EveryMatrix.AggregatorResponse>) throws -> SubscribableContent<Event>? {
        switch content {
        case .connect(let publisherIdentifiable):
            // Return connection confirmation
            let subscription = Subscription(id: "\(publisherIdentifiable.identificationCode)")
            return SubscribableContent.connected(subscription: subscription)
            
        case .initialContent(let response):
            // Process initial dump
            parseMatchAggregatorData(from: response)
            
            // Build and return event
            if let event = buildEvent() {
                return .contentUpdate(content: event)
            }
            return nil
            
        case .updatedContent(let response):
            // Process real-time updates
            parseMatchAggregatorData(from: response)
            
            // Rebuild and return updated event
            if let event = buildEvent() {
                return .contentUpdate(content: event)
            }
            return nil
            
        case .disconnect:
            return .disconnected
        }
    }
    
    private func handleMarketGroupsContent(_ content: WAMPSubscriptionContent<EveryMatrix.AggregatorResponse>) throws -> SubscribableContent<[MarketGroup]>? {
        switch content {
        case .connect(let publisherIdentifiable):
            let subscription = Subscription(id: "\(publisherIdentifiable.identificationCode)")
            return SubscribableContent.connected(subscription: subscription)
            
        case .initialContent(let response), .updatedContent(let response):
            // Parse market groups data and cache it
            parseMarketGroupsData(from: response)
            marketGroupsLoaded = true
            
            // Return the cached market groups
            return .contentUpdate(content: cachedMarketGroups)
            
        case .disconnect:
            return .disconnected
        }
    }
    
    private func handleMarketGroupDetailsContent(_ content: WAMPSubscriptionContent<EveryMatrix.AggregatorResponse>, marketGroupKey: String) throws -> SubscribableContent<[Market]>? {
        switch content {
        case .connect(let publisherIdentifiable):
            let subscription = Subscription(id: "\(publisherIdentifiable.identificationCode)")
            return SubscribableContent.connected(subscription: subscription)

        case .initialContent(let response):
            GomaLogger.debug(.realtime, category: "BLINK_SOURCE",
                "MatchDetailsManager[\(marketGroupKey)] - INITIAL_CONTENT received, records: \(response.records.count)")

            parseMarketsDataForGroup(from: response, marketGroupKey: marketGroupKey)
            let markets = buildMarketsArrayForGroup(marketGroupKey: marketGroupKey)

            GomaLogger.debug(.realtime, category: "BLINK_SOURCE",
                "MatchDetailsManager[\(marketGroupKey)] - EMITTING \(markets.count) markets (initial)")
            return .contentUpdate(content: markets)

        case .updatedContent(let response):
            // Log what entity types are in this update
            let entityTypeCounts = categorizeRecords(response.records)
            GomaLogger.debug(.realtime, category: "BLINK_SOURCE",
                "MatchDetailsManager[\(marketGroupKey)] - UPDATE received: \(entityTypeCounts)")

            parseMarketsDataForGroup(from: response, marketGroupKey: marketGroupKey)
            let markets = buildMarketsArrayForGroup(marketGroupKey: marketGroupKey)

            GomaLogger.debug(.realtime, category: "BLINK_SOURCE",
                "MatchDetailsManager[\(marketGroupKey)] - EMITTING \(markets.count) markets (update)")
            return .contentUpdate(content: markets)

        case .disconnect:
            return .disconnected
        }
    }

    /// Helper to categorize records by entity type for diagnostic logging
    private func categorizeRecords(_ records: [EveryMatrix.EntityRecord]) -> String {
        var counts: [String: Int] = [:]
        for record in records {
            let typeName: String
            switch record {
            case .match: typeName = "MATCH"
            case .market: typeName = "MARKET"
            case .outcome: typeName = "OUTCOME"
            case .bettingOffer: typeName = "BETTING_OFFER"
            case .changeRecord(let cr): typeName = "CHANGE(\(cr.entityType))"
            case .eventInfo: typeName = "EVENT_INFO"
            case .marketInfo: typeName = "MARKET_INFO"
            default: typeName = "OTHER"
            }
            counts[typeName, default: 0] += 1
        }
        return counts.map { "\($0.key):\($0.value)" }.joined(separator: ", ")
    }
    
    private func handleEventDetailsContent(_ content: WAMPSubscriptionContent<EveryMatrix.AggregatorResponse>) throws -> SubscribableContent<Event>? {
        switch content {
        case .connect(let publisherIdentifiable):
            // Return connection confirmation
            let subscription = Subscription(id: "\(publisherIdentifiable.identificationCode)")
            return SubscribableContent.connected(subscription: subscription)
            
        case .initialContent(let response):
            // Process initial dump
            parseMarketsData(from: response)
            
            // Build and return event
            if let event = buildEvent() {
                return .contentUpdate(content: event)
            }
            return nil
            
        case .updatedContent(let response):
            // Process real-time updates
            parseMarketsData(from: response)
            
            // Rebuild and return updated event
            if let event = buildEvent() {
                return .contentUpdate(content: event)
            }
            return nil
            
        case .disconnect:
            return .disconnected
        }
    }
    
    private func handleMarketDetailsContent(_ content: WAMPSubscriptionContent<EveryMatrix.AggregatorResponse>) throws -> SubscribableContent<Event>? {
        switch content {
        case .connect(let publisherIdentifiable):
            // Return connection confirmation
            let subscription = Subscription(id: "\(publisherIdentifiable.identificationCode)")
            return SubscribableContent.connected(subscription: subscription)
            
        case .initialContent(let response):
            // Process initial dump of markets data
            parseMarketsData(from: response)
            
            // Build and return event with markets
            if let event = buildEvent() {
                return .contentUpdate(content: event)
            }
            return nil
            
        case .updatedContent(let response):
            // Process real-time market updates
            parseMarketsData(from: response)
            
            // Rebuild and return updated event
            if let event = buildEvent() {
                return .contentUpdate(content: event)
            }
            return nil
            
        case .disconnect:
            return .disconnected
        }
    }
    
    // MARK: - Data Building
    
    private func buildEvent() -> Event? {
        // Get the match DTO
        guard let matchDTO = store.get(EveryMatrix.MatchDTO.self, id: matchId) else {
            return nil
        }
        
        // Build hierarchical match with all related data
        guard let internalMatch = EveryMatrix.MatchBuilder.build(from: matchDTO, store: store) else {
            return nil
        }
        
        // Convert to domain Event model
        return EveryMatrixModelMapper.event(fromInternalMatch: internalMatch)
    }
    
    private func buildMarketsArray() -> [Market] {
        // Get all markets from store
        let marketDTOs = store.getAll(EveryMatrix.MarketDTO.self)
        
        // Build markets
        let markets = marketDTOs.compactMap { marketDTO -> Market? in
            guard let internalMarket = EveryMatrix.MarketBuilder.build(from: marketDTO, store: store) else {
                return nil
            }
            return EveryMatrixModelMapper.market(fromInternalMarket: internalMarket)
        }
        
        return markets
    }
    
    private func buildMarketsArrayForGroup(marketGroupKey: String) -> [Market] {
        // Get markets from isolated store for this market group
        guard let groupStore = marketGroupStores[marketGroupKey] else {
            return []
        }
        
        let marketDTOs = groupStore.getAll(EveryMatrix.MarketDTO.self)
        
        // Build markets using the isolated store
        let markets = marketDTOs.compactMap { marketDTO -> Market? in
            guard let internalMarket = EveryMatrix.MarketBuilder.build(from: marketDTO, store: groupStore) else {
                return nil
            }
            return EveryMatrixModelMapper.market(fromInternalMarket: internalMarket)
        }
        
        return markets
    }
    
    // MARK: - Match Aggregator Parsing
    
    private func parseMatchAggregatorData(from response: EveryMatrix.AggregatorResponse) {
        for record in response.records {
            switch record {
            // Process all relevant entities for match aggregator
            case .match(let dto):
                store.store(dto)
            case .eventInfo(let dto):
                store.store(dto)
            case .eventCategory(let dto):
                store.store(dto)
            case .tournament(let dto):
                store.store(dto)
            case .location(let dto):
                store.store(dto)
            case .sport(let dto):
                store.store(dto)
                
            // Handle change records
            case .changeRecord(let changeRecord):
                handleMatchAggregatorChangeRecord(changeRecord)
                
            // Skip market-related entities for aggregator subscription
            case .market, .outcome, .bettingOffer, .marketOutcomeRelation, .marketInfo, .mainMarket, .marketGroup:
                break
                
            case .nextMatchesNumber(let dto):
                store.store(dto)
            case .unknown:
                break
            }
        }
    }
    
    private func handleMatchAggregatorChangeRecord(_ change: EveryMatrix.ChangeRecord) {
        // Only process relevant entity changes for match aggregator
        let relevantTypes = [
            EveryMatrix.MatchDTO.rawType,
            EveryMatrix.EventInfoDTO.rawType,
            EveryMatrix.EventCategoryDTO.rawType,
            EveryMatrix.TournamentDTO.rawType,
            EveryMatrix.LocationDTO.rawType,
            EveryMatrix.SportDTO.rawType
        ]
        
        guard relevantTypes.contains(change.entityType) else {
            return
        }
        
        switch change.changeType {
        case .create:
            if let entityData = change.entity {
                storeEntity(entityData)
            }
            
        case .update:
            guard let changedProperties = change.changedProperties else {
                return
            }
            store.updateEntity(type: change.entityType, id: change.id, changedProperties: changedProperties)
            
        case .delete:
            store.deleteEntity(type: change.entityType, id: change.id)
        }
    }
    
    // MARK: - Market Groups Parsing
    
    private func parseMarketGroupsData(from response: EveryMatrix.AggregatorResponse) {
        var marketGroupDTOs: [EveryMatrix.MarketGroupDTO] = []
        
        for record in response.records {
            switch record {
            case .marketGroup(let dto):
                marketGroupDTOs.append(dto)
                store.store(dto)
                
            case .changeRecord(let changeRecord):
                if changeRecord.entityType == EveryMatrix.MarketGroupDTO.rawType {
                    handleMarketGroupChangeRecord(changeRecord)
                }
                
            default:
                break
            }
        }
        
        // Update cached market groups
        updateCachedMarketGroups(from: marketGroupDTOs)
    }
    
    private func handleMarketGroupChangeRecord(_ change: EveryMatrix.ChangeRecord) {
        switch change.changeType {
        case .create:
            if let entityData = change.entity,
               case .marketGroup(let dto) = entityData {
                store.store(dto)
                // Rebuild cached market groups
                rebuildCachedMarketGroups()
            }
            
        case .update:
            guard let changedProperties = change.changedProperties else { return }
            store.updateEntity(type: change.entityType, id: change.id, changedProperties: changedProperties)
            // Rebuild cached market groups
            rebuildCachedMarketGroups()
            
        case .delete:
            store.deleteEntity(type: change.entityType, id: change.id)
            // Rebuild cached market groups
            rebuildCachedMarketGroups()
        }
    }
    
    private func updateCachedMarketGroups(from dtos: [EveryMatrix.MarketGroupDTO]) {
        cachedMarketGroups = dtos.compactMap { dto in
            return MarketGroup(
                type: dto.groupKey ?? dto.id,
                id: dto.id,
                groupKey: dto.groupKey,
                translatedName: dto.translatedName,
                position: dto.position,
                isDefault: dto.isDefault,
                numberOfMarkets: dto.numberOfMarkets,
                loaded: true,
                markets: [],
                isBetBuilder: dto.isBetBuilder,
                isFast: dto.isFast,
                isOutright: dto.isOutright
            )
        }.sorted { ($0.position ?? 0) < ($1.position ?? 0) }
    }
    
    private func rebuildCachedMarketGroups() {
        let dtos = store.getAll(EveryMatrix.MarketGroupDTO.self)
        updateCachedMarketGroups(from: dtos)
    }
    
    // MARK: - Markets Parsing
    private func parseMarketsDataForGroup(from response: EveryMatrix.AggregatorResponse, marketGroupKey: String) {
        guard let groupStore = marketGroupStores[marketGroupKey] else {
            return
        }
        
        for record in response.records {
            switch record {
            case .match(let dto):
                groupStore.store(dto)
                
            case .market(let dto):
                groupStore.store(dto)
            case .outcome(let dto):
                groupStore.store(dto)
            case .bettingOffer(let dto):
                groupStore.store(dto)
            case .marketOutcomeRelation(let dto):
                groupStore.store(dto)
            case .marketInfo(let dto):
                groupStore.store(dto)
            case .mainMarket(let dto):
                groupStore.store(dto)
            case .eventInfo(let dto):
                groupStore.store(dto)
            case .eventCategory(let dto):
                groupStore.store(dto)
            case .marketGroup(let dto):
                groupStore.store(dto)
            
                
            // Handle change records
            case .changeRecord(let changeRecord):
                handleMarketsChangeRecordForGroup(changeRecord, groupStore: groupStore)
                
            // Skip non-market entities
            case .sport, .location, .tournament, .nextMatchesNumber:
                break
            case .unknown:
                break
            }
        }
    }
    
    private func parseMarketsData(from response: EveryMatrix.AggregatorResponse) {
        for record in response.records {
            switch record {
            case .match(let dto):
                store.store(dto)
                
            case .market(let dto):
                store.store(dto)
            case .outcome(let dto):
                store.store(dto)
            case .bettingOffer(let dto):
                store.store(dto)
            case .marketOutcomeRelation(let dto):
                store.store(dto)
            case .marketInfo(let dto):
                store.store(dto)
            case .mainMarket(let dto):
                store.store(dto)
            case .eventInfo(let dto):
                store.store(dto)
            case .eventCategory(let dto):
                store.store(dto)
            case .marketGroup(let dto):
                store.store(dto)
            
                
            // Handle change records
            case .changeRecord(let changeRecord):
                handleMarketsChangeRecord(changeRecord)
                
            // Skip non-market entities
            case .sport, .location, .tournament, .nextMatchesNumber:
                break
            case .unknown:
                break
            }
        }
    }
    
    private func handleMarketsChangeRecordForGroup(_ change: EveryMatrix.ChangeRecord, groupStore: EveryMatrix.EntityStore) {
        // Process all entity types for markets using isolated store
        switch change.changeType {
        case .create:
            if let entityData = change.entity {
                storeEntityInStore(entityData, store: groupStore)
            }
            
        case .update:
            guard let changedProperties = change.changedProperties else {
                return
            }
            groupStore.updateEntity(type: change.entityType, id: change.id, changedProperties: changedProperties)
            
        case .delete:
            groupStore.deleteEntity(type: change.entityType, id: change.id)
        }
    }
    
    private func handleMarketsChangeRecord(_ change: EveryMatrix.ChangeRecord) {
        // Process all entity types for markets
        switch change.changeType {
        case .create:
            if let entityData = change.entity {
                storeEntity(entityData)
            }
            
        case .update:
            guard let changedProperties = change.changedProperties else {
                return
            }
            store.updateEntity(type: change.entityType, id: change.id, changedProperties: changedProperties)
            
        case .delete:
            store.deleteEntity(type: change.entityType, id: change.id)
        }
    }
    
    private func storeEntityInStore(_ entity: EveryMatrix.EntityData, store: EveryMatrix.EntityStore) {
        switch entity {
        case .match(let dto):
            store.store(dto)
        case .market(let dto):
            store.store(dto)
        case .outcome(let dto):
            store.store(dto)
        case .bettingOffer(let dto):
            store.store(dto)
        case .marketOutcomeRelation(let dto):
            store.store(dto)
        case .marketInfo(let dto):
            store.store(dto)
        case .mainMarket(let dto):
            store.store(dto)
        case .eventInfo(let dto):
            store.store(dto)
        case .eventCategory(let dto):
            store.store(dto)
        case .tournament(let dto):
            store.store(dto)
        case .location(let dto):
            store.store(dto)
        case .sport(let dto):
            store.store(dto)
        case .nextMatchesNumber(let dto):
            store.store(dto)
        case .marketGroup(let dto):
            store.store(dto)
        case .unknown:
            break
        }
    }
    
    private func storeEntity(_ entity: EveryMatrix.EntityData) {
        switch entity {
        case .match(let dto):
            store.store(dto)
        case .market(let dto):
            store.store(dto)
        case .outcome(let dto):
            store.store(dto)
        case .bettingOffer(let dto):
            store.store(dto)
        case .marketOutcomeRelation(let dto):
            store.store(dto)
        case .marketInfo(let dto):
            store.store(dto)
        case .mainMarket(let dto):
            store.store(dto)
        case .eventInfo(let dto):
            store.store(dto)
        case .eventCategory(let dto):
            store.store(dto)
        case .tournament(let dto):
            store.store(dto)
        case .location(let dto):
            store.store(dto)
        case .sport(let dto):
            store.store(dto)
        case .nextMatchesNumber(let dto):
            store.store(dto)
        case .marketGroup(let dto):
            store.store(dto)
        case .unknown:
            break
        }
    }
}

// MARK: - Entity Store Access

extension MatchDetailsManager {
    
    /// Exposes the entity store for granular observations if needed
    var entityStore: EveryMatrix.EntityStore {
        return store
    }
    
    /// Observe changes to a specific market
    func observeMarket(withId id: String) -> AnyPublisher<Market?, Never> {
        return store.observeMarket(id: id)
            .compactMap { [weak self] marketDTO -> EveryMatrix.Market? in
                guard let marketDTO = marketDTO else { return nil }
                return EveryMatrix.MarketBuilder.build(from: marketDTO, store: self?.store ?? EveryMatrix.EntityStore())
            }
            .compactMap { internalMarket -> Market? in
                return EveryMatrixModelMapper.market(fromInternalMarket: internalMarket)
            }
            .eraseToAnyPublisher()
    }
    
    /// Observe changes to a specific outcome
    func observeOutcome(withId id: String) -> AnyPublisher<Outcome?, Never> {
        return store.observeOutcome(id: id)
            .compactMap { [weak self] outcomeDTO -> EveryMatrix.Outcome? in
                guard let outcomeDTO = outcomeDTO else { return nil }
                return EveryMatrix.OutcomeBuilder.build(from: outcomeDTO, store: self?.store ?? EveryMatrix.EntityStore())
            }
            .compactMap { internalOutcome -> Outcome? in
                return EveryMatrixModelMapper.outcome(fromInternalOutcome: internalOutcome)
            }
            .eraseToAnyPublisher()
    }

    /// Subscribe to betting offer updates and return the parent Outcome with updated odds
    /// This fixes the entity mismatch where BETTING_OFFER updates don't notify OUTCOME observers
    /// Note: Searches all stores (main + market group stores) to find the betting offer
    func subscribeToBettingOfferAsOutcomeUpdates(bettingOfferId: String) -> AnyPublisher<Outcome?, ServiceProviderError> {
        // Find the store that contains this betting offer
        guard let targetStore = findStoreContainingBettingOffer(bettingOfferId) else {
            GomaLogger.debug(.realtime, category: "ODDS_FLOW",
                "MatchDetailsManager.subscribeToBettingOfferAsOutcomeUpdates - BETTING_OFFER:\(bettingOfferId) not found in any store")
            return Just(nil)
                .setFailureType(to: ServiceProviderError.self)
                .eraseToAnyPublisher()
        }

        GomaLogger.debug(.realtime, category: "ODDS_FLOW",
            "MatchDetailsManager.subscribeToBettingOfferAsOutcomeUpdates - SUBSCRIBING to BETTING_OFFER:\(bettingOfferId)")

        return targetStore.observeBettingOffer(id: bettingOfferId)
            .handleEvents(receiveOutput: { bettingOfferDTO in
                if bettingOfferDTO != nil {
                    GomaLogger.info(.realtime, category: "ODDS_FLOW",
                        "MatchDetailsManager - RECEIVED BettingOfferDTO update for BETTING_OFFER:\(bettingOfferId)")
                }
            })
            .compactMap { [weak self] bettingOfferDTO -> Outcome? in
                guard self != nil,
                      let bettingOfferDTO = bettingOfferDTO else { return nil }

                // Look up parent OutcomeDTO using the foreign key - from the SAME store
                let outcomeId = bettingOfferDTO.outcomeId
                guard let outcomeDTO = targetStore.get(EveryMatrix.OutcomeDTO.self, id: outcomeId) else {
                    GomaLogger.error(.realtime, category: "ODDS_FLOW",
                        "MatchDetailsManager - Parent OUTCOME:\(outcomeId) not found for BETTING_OFFER:\(bettingOfferId)")
                    return nil
                }

                // Build hierarchical Outcome with updated BettingOffers - using SAME store
                guard let internalOutcome = EveryMatrix.OutcomeBuilder.build(from: outcomeDTO, store: targetStore) else {
                    return nil
                }

                // Map to domain Outcome
                return EveryMatrixModelMapper.outcome(fromInternalOutcome: internalOutcome)
            }
            .setFailureType(to: ServiceProviderError.self)
            .eraseToAnyPublisher()
    }

    /// Get market groups for the match
    /// Returns empty array if market groups haven't been loaded yet
    func getMarketGroups() -> [MarketGroup] {
        guard marketGroupsLoaded else { 
            print("⚠️ Market groups not loaded yet, returning empty array")
            return [] 
        }
        return cachedMarketGroups
    }
    
    /// Check if market groups have been loaded
    var areMarketGroupsLoaded: Bool {
        return marketGroupsLoaded
    }

    /// Find the EntityStore that contains a specific betting offer
    /// Searches main store first, then all market group stores
    private func findStoreContainingBettingOffer(_ bettingOfferId: String) -> EveryMatrix.EntityStore? {
        // Check main store first
        if store.get(EveryMatrix.BettingOfferDTO.self, id: bettingOfferId) != nil {
            return store
        }

        // Check market group stores
        for (_, groupStore) in marketGroupStores {
            if groupStore.get(EveryMatrix.BettingOfferDTO.self, id: bettingOfferId) != nil {
                return groupStore
            }
        }

        return nil
    }

    /// Check if a betting offer with the given ID exists in this manager's stores
    /// Checks both main store and all market group stores
    func bettingOfferExists(id: String) -> Bool {
        return findStoreContainingBettingOffer(id) != nil
    }

    /// Observe live data (EventInfo entities) for this match
    /// Returns EventLiveData with scores, status, and match time updates
    func observeEventInfosForEvent(eventId: String) -> AnyPublisher<EventLiveData, Never> {
        return store.observeEventInfosForEvent(eventId: eventId)
            .map { [weak self] eventInfos in
                guard let self = self else {
                    return EventLiveData(id: eventId, homeScore: nil, awayScore: nil, matchTime: nil, status: nil, detailedScores: nil, activePlayerServing: nil)
                }

                // Get the match data for participant mapping
                let matchData = self.store.get(EveryMatrix.MatchDTO.self, id: eventId)

                // Delegate to shared EventLiveDataBuilder for consistent transformation logic
                return EventLiveDataBuilder.buildEventLiveData(
                    eventId: eventId,
                    from: eventInfos,
                    matchData: matchData
                )
            }
            .eraseToAnyPublisher()
    }
}

//
//  SportsManager.swift
//  ServicesProvider
//
//  Created by Ruben Roques on 13/06/2025.
//

import Foundation
import Combine

class SportsManager {

    // MARK: - Dependencies
    private let connector: EveryMatrixSocketConnector
    private let operatorId: String

    // MARK: - State Management
    private let store = EveryMatrix.EntityStore()
    private var currentSubscription: Subscription?
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Publishers
    private let sportsSubject = CurrentValueSubject<SubscribableContent<[SportType]>, ServiceProviderError>(.disconnected)

    // MARK: - Initialization

    init(connector: EveryMatrixSocketConnector, operatorId: String) {
        self.connector = connector
        self.operatorId = operatorId
    }

    // MARK: - Public Interface

    func subscribe() -> AnyPublisher<SubscribableContent<[SportType]>, ServiceProviderError> {
        // print("SportsManager: Starting subscription for operator \(operatorId)")
        // Clean up any existing subscription
        unsubscribe()

        // Clear the entity store
        store.clear()

        // Create the router for sports subscription with configured language
        let language = EveryMatrixUnifiedConfiguration.shared.defaultLanguage
        let router = WAMPRouter.sportsPublisher(operatorId: operatorId, language: language)
        // print("SportsManager: Created router for endpoint: \(router.procedure)")

        return connector.subscribe(router)
            .handleEvents(receiveOutput: { [weak self] content in
                // Store subscription reference for cleanup
                if case .connect(let subscription) = content {
                    self?.currentSubscription = Subscription(id: "\(subscription.identificationCode)")
                }
            })
            .compactMap { [weak self] content -> SubscribableContent<[SportType]>? in
                return try? self?.handleSubscriptionContent(content)
            }
            .mapError { error -> ServiceProviderError in
                if let serviceError = error as? ServiceProviderError {
                    return serviceError
                }
                return ServiceProviderError.unknown
            }
            .eraseToAnyPublisher()
    }

    func unsubscribe() {
        currentSubscription = nil
        cancellables.removeAll()
    }

    // MARK: - Private Implementation

    private func handleSubscriptionContent(_ content: WAMPSubscriptionContent<EveryMatrix.AggregatorResponse>) throws -> SubscribableContent<[SportType]>? {

        switch content {
        case .connect(let publisherIdentifiable):
            // print("SportsManager: Connected to WAMP subscription (id: \(publisherIdentifiable.identificationCode))")
            // Return connection confirmation
            let subscription = Subscription(id: "\(publisherIdentifiable.identificationCode)")
            return SubscribableContent.connected(subscription: subscription)

        case .initialContent(let response):
            // print("SportsManager: Received initial content with \(response.records.count) records")
            // Process initial dump of sports data (SPORT entities only)
            parseSportsData(from: response)

            // Build and return sports list
            let sports = buildSportTypes()
            // print("SportsManager: Built \(sports.count) sport types from initial data")
            return .contentUpdate(content: sports)

        case .updatedContent(let response):
            // print("SportsManager: Received update with \(response.records.count) records")
            // Process real-time updates (SPORT entities only)
            parseSportsData(from: response)

            // Always rebuild sports list on updates since sports are typically few in number
            let sports = buildSportTypes()
            // print("SportsManager: Built \(sports.count) sport types from update")
            return .contentUpdate(content: sports)

        case .disconnect:
            // print("SportsManager: Disconnected from WAMP subscription")
            // Handle disconnection
            return nil
        }
    }

    private func buildSportTypes() -> [SportType] {
        // Get all sports from the entity store
        let sportsDTO = store.getAllInOrder(EveryMatrix.SportDTO.self)

        // Convert DTOs to internal sports model
        let internalSports = sportsDTO.compactMap { sportDTO in
            EveryMatrix.SportBuilder.build(from: sportDTO, store: store)
        }

        // Map to domain SportType objects
        let sportTypes = internalSports.compactMap { internalSport in
            EveryMatrixModelMapper.sportType(fromInternalSport: internalSport)
        }

        // Filter sports that have at least some events or live events
        let filteredSports = sportTypes.filter { sport in
            sport.numberEvents > 0 || sport.numberLiveEvents > 0 || sport.numberOutrightEvents > 0
        }

        // Sort by name for consistent ordering
        return filteredSports
    }
    
    // MARK: - Sports-Specific Parsing
    
    /// Parse only SPORT entities from the aggregator response
    private func parseSportsData(from response: EveryMatrix.AggregatorResponse) {
        var sportsCount = 0
        var otherEntityCount = 0
        
        for record in response.records {
            switch record {
            // INITIAL_DUMP records - only process SPORT entities
            case .sport(let dto):
                store.store(dto)
                sportsCount += 1
                
            // UPDATE/DELETE/CREATE records - only process SPORT changes
            case .changeRecord(let changeRecord):
                if changeRecord.entityType == EveryMatrix.SportDTO.rawType {
                    sportsCount += 1
                } else {
                    otherEntityCount += 1
                }
                handleSportsChangeRecord(changeRecord)
                
            // Ignore all other entity types for sports manager
            case .match, .market, .outcome, .bettingOffer, .location, .eventCategory:
                otherEntityCount += 1
                break // Ignore non-sport entities
            case .marketOutcomeRelation, .mainMarket, .marketInfo, .nextMatchesNumber, .tournament:
                otherEntityCount += 1
                break // Ignore non-sport entities
            case .eventInfo:
                otherEntityCount += 1
                break // Ignore non-sport entities
            case .marketGroup:
                otherEntityCount += 1
                break // Ignore non-sport entities
                
            case .unknown(let type):
                if type == "SPORT" {
                    print("Unknown SPORT entity type: \(type)")
                }
                otherEntityCount += 1
                // Ignore unknown non-sport entities
            }
        }
        
        // print("SportsManager: Parsed \(sportsCount) sport entities, \(otherEntityCount) other entities")
    }
    
    /// Handle change records for SPORT entities only
    private func handleSportsChangeRecord(_ change: EveryMatrix.ChangeRecord) {
        // Only process SPORT entity changes
        guard change.entityType == EveryMatrix.SportDTO.rawType else {
            return // Ignore non-sport changes
        }
        
        switch change.changeType {
        case .create:
            // CREATE: Store the full entity if provided
            if let entityData = change.entity,
               case .sport(let dto) = entityData {
                store.store(dto)
            }
            
        case .update:
            // UPDATE: Merge changedProperties for sports
            guard let changedProperties = change.changedProperties else {
                print("UPDATE change record missing changedProperties for SPORT:\(change.id)")
                return
            }
            
            // Update sport with changed properties (e.g., numberOfEvents, numberOfLiveEvents)
            store.updateEntity(type: change.entityType, id: change.id, changedProperties: changedProperties)
            
        case .delete:
            // DELETE: Remove sport from store
            store.deleteEntity(type: change.entityType, id: change.id)
        }
    }
}

// MARK: - Entity Store Access

extension SportsManager {

    /// Exposes the entity store for granular sport observations if needed
    var entityStore: EveryMatrix.EntityStore {
        return store
    }

    /// Observe changes to a specific sport
    func observeSport(withId id: String) -> AnyPublisher<SportType?, Never> {
        return store.observeEntity(EveryMatrix.SportDTO.self, id: id)
            .compactMap { [weak self] sportDTO -> EveryMatrix.Sport? in
                guard let sportDTO = sportDTO else { return nil }
                return EveryMatrix.SportBuilder.build(from: sportDTO, store: self?.store ?? EveryMatrix.EntityStore())
            }
            .compactMap { internalSport -> SportType? in
                return EveryMatrixModelMapper.sportType(fromInternalSport: internalSport)
            }
            .eraseToAnyPublisher()
    }
}

//
//  PopularTournamentsManager.swift
//  ServicesProvider
//
//  Created by André Lascas on 17/06/2025.
//

import Foundation
import Combine
import SharedModels

class PopularTournamentsManager {
    
    // MARK: - Dependencies
    private let connector: EveryMatrixSocketConnector
    private let operatorId: String
    private let language: String
    private let sportId: String
    private let tournamentsCount: Int
    
    // MARK: - State Management
    private let store = EveryMatrix.EntityStore()
    private var currentSubscription: Subscription?
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Publishers
    private let tournamentsSubject = CurrentValueSubject<SubscribableContent<[Tournament]>, ServiceProviderError>(.disconnected)
    
    // MARK: - Initialization
    
    init(connector: EveryMatrixSocketConnector, operatorId: String, sportId: String, tournamentsCount: Int = 10, language: String = "en") {
        self.connector = connector
        self.sportId = sportId
        self.tournamentsCount = tournamentsCount
        self.operatorId = operatorId
        self.language = language
    }
    
    // MARK: - Public Interface
    
    /// Subscribe to popular tournaments for the specified sport
    func subscribe() -> AnyPublisher<SubscribableContent<[Tournament]>, ServiceProviderError> {
        // Clean up any existing subscription
        unsubscribe()
        
        // Clear the store for fresh subscription
        store.clear()
        
        // Create the WAMP router for popular tournaments
        let router = WAMPRouter.popularTournamentsPublisher(
            operatorId: operatorId,
            language: language,
            sportId: sportId,
            tournamentsCount: tournamentsCount
        )
        
        // Subscribe to the websocket topic
        return connector.subscribe(router)
            .handleEvents(receiveOutput: { [weak self] content in
                // Store the subscription for cleanup later
                if case .connect(let subscription) = content {
                    self?.currentSubscription = Subscription(id: "\(subscription.identificationCode)")
                }
            })
            .compactMap { [weak self] (content: WAMPSubscriptionContent<EveryMatrix.AggregatorResponse>) -> SubscribableContent<[Tournament]>? in
                guard let self = self else {
                    return nil
                }
                
                return try? self.handleSubscriptionContent(content)
            }
            .mapError { error -> ServiceProviderError in
                if let serviceError = error as? ServiceProviderError {
                    return serviceError
                }
                return ServiceProviderError.unknown
            }
            .eraseToAnyPublisher()
    }
    
    /// Unsubscribe from the current subscription
    func unsubscribe() {
        currentSubscription = nil
        cancellables.removeAll()
    }
    
    // MARK: - Private Methods
    
    /// Handle subscription content and convert to domain models
    private func handleSubscriptionContent(_ content: WAMPSubscriptionContent<EveryMatrix.AggregatorResponse>) throws -> SubscribableContent<[Tournament]>? {
        
        switch content {
        case .connect(let publisherIdentifiable):
            // Return connection confirmation
            let subscription = Subscription(id: "\(publisherIdentifiable.identificationCode)")
            return SubscribableContent.connected(subscription: subscription)
            
        case .initialContent(let response):
            // Process initial dump of tournaments data
            parseTournamentsData(from: response)
            
            // Build and return tournaments list
            let tournaments = buildTournaments()
            return .contentUpdate(content: tournaments)
            
        case .updatedContent(let response):
            // Process real-time updates
            parseTournamentsData(from: response)
            
            // Rebuild tournaments list on updates
            let tournaments = buildTournaments()
            return .contentUpdate(content: tournaments)
            
        case .disconnect:
            // Handle disconnection
            return nil
        }
    }
    
    private func buildTournaments() -> [Tournament] {
        // Get all tournaments from the entity store
//        let tournamentsDTO = store.getAll(EveryMatrix.TournamentDTO.self)
        let tournamentsDTO = store.getAllInOrder(EveryMatrix.TournamentDTO.self)

        // Convert DTOs to internal tournament models
        let internalTournaments = tournamentsDTO.compactMap { tournamentDTO in
            EveryMatrix.TournamentBuilder.build(from: tournamentDTO, store: store)
        }
        
        // Map to domain Tournament objects
        let tournaments = internalTournaments.compactMap { internalTournament in
            EveryMatrixModelMapper.tournament(fromInternalTournament: internalTournament)
        }
        
        // Filter tournaments that have events or are active
        let filteredTournaments = tournaments.filter { tournament in
            tournament.numberOfEvents > 0
        }
        
        // Sort by number of events (most popular first)
//        return filteredTournaments.sorted {
//            ($0.numberOfEvents) > ($1.numberOfEvents)
//        }
        return filteredTournaments
    }
    
    // MARK: - Tournaments-Specific Parsing
    
    /// Parse only TOURNAMENT entities from the aggregator response
    private func parseTournamentsData(from response: EveryMatrix.AggregatorResponse) {
        for record in response.records {
            switch record {
            // INITIAL_DUMP records - only process TOURNAMENT entities
            case .tournament(let dto):
                store.store(dto)
                
            // UPDATE/DELETE/CREATE records - only process TOURNAMENT changes
            case .changeRecord(let changeRecord):
                handleTournamentsChangeRecord(changeRecord)
                
            // Ignore all other entity types for tournaments manager
            case .sport, .match, .market, .outcome, .bettingOffer, .location, .eventInfo:
                break
            case .eventCategory, .marketOutcomeRelation, .mainMarket, .marketInfo, .nextMatchesNumber:
                break // Ignore non-tournament entities
            case .marketGroup:
                break // Ignore non-tournament entities
                
            case .unknown(let type):
                if type == "TOURNAMENT" {
                    print("Unknown TOURNAMENT entity type: \(type)")
                }
                // Ignore unknown non-tournament entities
            }
        }
    }
    
    /// Handle change records for TOURNAMENT entities only
    private func handleTournamentsChangeRecord(_ change: EveryMatrix.ChangeRecord) {
        // Only process TOURNAMENT entity changes
        guard change.entityType == EveryMatrix.TournamentDTO.rawType else {
            return // Ignore non-tournament changes
        }
        
        switch change.changeType {
        case .create:
            // CREATE: Store the full entity if provided
            if let entityData = change.entity,
               case .tournament(let dto) = entityData {
                store.store(dto)
            }
            
        case .update:
            // UPDATE: Merge changedProperties for tournaments
            guard let changedProperties = change.changedProperties else {
                print("UPDATE change record missing changedProperties for TOURNAMENT:\(change.id)")
                return
            }
            
            // Update tournament with changed properties (e.g., numberOfEvents, numberOfUpcomingMatches)
            store.updateEntity(type: change.entityType, id: change.id, changedProperties: changedProperties)
            
        case .delete:
            // DELETE: Remove tournament from store
            store.deleteEntity(type: change.entityType, id: change.id)
        }
    }
}

// MARK: - Entity Store Access

extension PopularTournamentsManager {
    
    /// Exposes the entity store for granular tournament observations if needed
    var entityStore: EveryMatrix.EntityStore {
        return store
    }
    
    /// Observe changes to a specific tournament
    func observeTournament(withId id: String) -> AnyPublisher<Tournament?, Never> {
        return store.observeEntity(EveryMatrix.TournamentDTO.self, id: id)
            .compactMap { [weak self] tournamentDTO -> EveryMatrix.Tournament? in
                guard let tournamentDTO = tournamentDTO else { return nil }
                return EveryMatrix.TournamentBuilder.build(from: tournamentDTO, store: self?.store ?? EveryMatrix.EntityStore())
            }
            .compactMap { internalTournament -> Tournament? in
                return EveryMatrixModelMapper.tournament(fromInternalTournament: internalTournament)
            }
            .eraseToAnyPublisher()
    }
}

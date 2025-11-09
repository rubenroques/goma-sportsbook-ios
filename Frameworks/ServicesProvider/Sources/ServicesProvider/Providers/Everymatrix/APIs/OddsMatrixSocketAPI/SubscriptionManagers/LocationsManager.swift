//
//  LocationsManager.swift
//  ServicesProvider
//
//  Created by Ruben Roques on 13/06/2025.
//

import Foundation
import Combine
import SharedModels

class LocationsManager {
    
    // MARK: - Dependencies
    private let connector: EveryMatrixSocketConnector
    private let operatorId: String
    private let sportId: String
    
    // MARK: - State Management
    private let store = EveryMatrix.EntityStore()
    private var currentSubscription: Subscription?
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    
    init(connector: EveryMatrixSocketConnector, sportId: String, operatorId: String) {
        self.connector = connector
        self.sportId = sportId
        self.operatorId = operatorId
    }
    
    // MARK: - Public Interface
    
    func subscribe() -> AnyPublisher<SubscribableContent<[Country]>, ServiceProviderError> {
        // Clean up any existing subscription
        unsubscribe()
        
        // Clear the entity store
        store.clear()
        
        // Create the router for sport-specific locations subscription
        let router = WAMPRouter.locationsPublisher(operatorId: operatorId, language: EveryMatrixUnifiedConfiguration.shared.defaultLanguage, sportId: sportId)
        
        return connector.subscribe(router)
            .handleEvents(receiveOutput: { [weak self] content in
                // Store subscription reference for cleanup
                if case .connect(let subscription) = content {
                    self?.currentSubscription = Subscription(id: "\(subscription.identificationCode)")
                }
            })
            .compactMap { [weak self] content -> SubscribableContent<[Country]>? in
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
    
    private func handleSubscriptionContent(_ content: WAMPSubscriptionContent<EveryMatrix.AggregatorResponse>) throws -> SubscribableContent<[Country]>? {
        
        switch content {
        case .connect(let publisherIdentifiable):
            // Return connection confirmation
            let subscription = Subscription(id: "\(publisherIdentifiable.identificationCode)")
            return SubscribableContent.connected(subscription: subscription)
            
        case .initialContent(let response):
            // Process initial dump of locations data (LOCATION entities only)
            parseLocationsData(from: response)
            
            // Build and return countries list
            let countries = buildCountries()
            return .contentUpdate(content: countries)
            
        case .updatedContent(let response):
            // Process real-time updates (LOCATION entities only)
            parseLocationsData(from: response)
            
            // Always rebuild countries list on updates (typically few locations per sport)
            let countries = buildCountries()
            return .contentUpdate(content: countries)
            
        case .disconnect:
            // Handle disconnection
            return nil
        }
    }
    
    private func buildCountries() -> [Country] {
        // Get all locations from the entity store
        let locationsDTO = store.getAll(EveryMatrix.LocationDTO.self)
        
        // Convert DTOs to internal location model
        let internalLocations = locationsDTO.compactMap { locationDTO in
            EveryMatrix.LocationBuilder.build(from: locationDTO, store: store)
        }
        
        // Map to Country objects using existing mapping logic
        let countries = internalLocations.compactMap { internalLocation -> Country? in
            // Use existing Country mapping by name (same logic as in EveryMatrixModelMapper+Events.swift)
            return Country.country(withName: internalLocation.name)
        }
        
        // Remove duplicates (same country might appear multiple times)
        let uniqueCountries = Array(Set(countries))
        
        // Sort by country name for consistent ordering
        return uniqueCountries.sorted { $0.name < $1.name }
    }
    
    // MARK: - Locations-Specific Parsing
    
    /// Parse only LOCATION entities from the aggregator response
    private func parseLocationsData(from response: EveryMatrix.AggregatorResponse) {
        for record in response.records {
            switch record {
            // INITIAL_DUMP records - only process LOCATION entities
            case .location(let dto):
                store.store(dto)
                
            // UPDATE/DELETE/CREATE records - only process LOCATION changes
            case .changeRecord(let changeRecord):
                handleLocationsChangeRecord(changeRecord)
                
            // Ignore all other entity types for locations manager
            case .sport, .match, .market, .outcome, .bettingOffer, .eventCategory, .eventInfo:
                break
            case .marketOutcomeRelation, .mainMarket, .marketInfo, .nextMatchesNumber, .tournament:
                break // Ignore non-location entities
            case .marketGroup:
                break // Ignore non-location entities
                
            case .unknown(let type):
                if type == "LOCATION" {
                    print("Unknown LOCATION entity type: \(type)")
                }
                // Ignore unknown non-location entities
            }
        }
    }
    
    /// Handle change records for LOCATION entities only
    private func handleLocationsChangeRecord(_ change: EveryMatrix.ChangeRecord) {
        // Only process LOCATION entity changes
        guard change.entityType == EveryMatrix.LocationDTO.rawType else {
            return // Ignore non-location changes
        }
        
        switch change.changeType {
        case .create:
            // CREATE: Store the full entity if provided
            if let entityData = change.entity,
               case .location(let dto) = entityData {
                store.store(dto)
            }
            
        case .update:
            // UPDATE: Merge changedProperties for locations
            guard let changedProperties = change.changedProperties else {
                print("UPDATE change record missing changedProperties for LOCATION:\(change.id)")
                return
            }
            
            // Update location with changed properties
            store.updateEntity(type: change.entityType, id: change.id, changedProperties: changedProperties)
            
        case .delete:
            // DELETE: Remove location from store
            store.deleteEntity(type: change.entityType, id: change.id)
        }
    }
}

// MARK: - Entity Store Access

extension LocationsManager {
    
    /// Exposes the entity store for granular location observations if needed
    var entityStore: EveryMatrix.EntityStore {
        return store
    }
    
    /// Observe changes to a specific location
    func observeLocation(withId id: String) -> AnyPublisher<Country?, Never> {
        return store.observeEntity(EveryMatrix.LocationDTO.self, id: id)
            .compactMap { [weak self] locationDTO -> EveryMatrix.Location? in
                guard let locationDTO = locationDTO else { return nil }
                return EveryMatrix.LocationBuilder.build(from: locationDTO, store: self?.store ?? EveryMatrix.EntityStore())
            }
            .compactMap { internalLocation -> Country? in
                return Country.country(withName: internalLocation.name)
            }
            .eraseToAnyPublisher()
    }
    
    /// Get current sport ID this manager is subscribed to
    var currentSportId: String {
        return sportId
    }
}

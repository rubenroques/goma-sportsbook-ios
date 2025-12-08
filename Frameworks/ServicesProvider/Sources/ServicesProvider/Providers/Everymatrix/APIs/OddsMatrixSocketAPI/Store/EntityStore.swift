//
//  EntityStore.swift
//  ServicesProvider
//
//  Created by Ruben Roques on 26/06/2025.
//

import Foundation
import Combine
import GomaLogger

extension EveryMatrix {
    
    class EntityStore: ObservableObject {
        
        @Published private var entities: [String: [String: any Entity]] = [:]
        
        private var entityOrder: [String: [String]] = [:] // [EntityType: [Ordered IDs]]

        // MARK: - Publisher Infrastructure
        private var entityPublishers: [String: [String: CurrentValueSubject<(any Entity)?, Never>]] = [:]
        private var collectionPublishers: [String: CurrentValueSubject<[any Entity], Never>] = [:]
        private var cancellables = Set<AnyCancellable>()

        // Store entity by type and id
        func store<T: Entity>(_ entity: T) {
            let type = T.rawType
            if entities[type] == nil {
                entities[type] = [:]
                entityOrder[type] = []
            }
            entities[type]?[entity.id] = entity

            // Add to order if not already present
            if !(entityOrder[type]?.contains(entity.id) ?? false) {
                entityOrder[type]?.append(entity.id)
            }
            
            // Notify observers of the change
            notifyEntityChange(entity)
        }
        
        // Store entity from EntityRecord - automatically handles all entity types
        func storeFromRecord(_ record: EntityRecord) {
            switch record {
            case .sport(let dto):
                store(dto)
            case .match(let dto):
                store(dto)
            case .market(let dto):
                store(dto)
            case .outcome(let dto):
                store(dto)
            case .bettingOffer(let dto):
                store(dto)
            case .location(let dto):
                store(dto)
            case .eventCategory(let dto):
                store(dto)
            case .marketOutcomeRelation(let dto):
                store(dto)
            case .mainMarket(let dto):
                store(dto)
            case .marketInfo(let dto):
                store(dto)
            case .nextMatchesNumber(let dto):
                store(dto)
            case .tournament(let dto):
                store(dto)
            case .eventInfo(let dto):
                store(dto)
            case .marketGroup(let dto):
                store(dto)
            case .changeRecord(_):
                // Change records are not entities, skip them
                break
            case .unknown:
                // Skip unknown record types
                break
            }
        }
        
        // Bulk store multiple records
        func storeRecords(_ records: [EntityRecord]) {
            records.forEach { storeFromRecord($0) }
        }

        // Retrieve entity by type and id
        func get<T: Entity>(_ type: T.Type, id: String) -> T? {
            guard let typeDict = entities[T.rawType] else { return nil }
            return typeDict[id] as? T
        }

        // Get all entities of a specific type
        func getAll<T: Entity>(_ type: T.Type) -> [T] {
            guard let typeDict = entities[T.rawType] else { return [] }
            return typeDict.values.compactMap { $0 as? T }
        }
        
        // Add method to get entities in original order
        func getAllInOrder<T: Entity>(_ type: T.Type) -> [T] {
            guard let typeDict = entities[T.rawType],
                  let order = entityOrder[T.rawType] else { return [] }
            
            return order.compactMap { id in
                typeDict[id] as? T
            }
        }

        // Store multiple entities while preserving insertion order
        func store<T: Entity>(_ entities: [T]) {
            for entity in entities {
                let type = T.rawType
                if self.entities[type] == nil {
                    self.entities[type] = [:]
                    entityOrder[type] = []
                }
                self.entities[type]?[entity.id] = entity

                // Add to order if not already present
                if !(entityOrder[type]?.contains(entity.id) ?? false) {
                    entityOrder[type]?.append(entity.id)
                }

                // Notify observers of each change
                notifyEntityChange(entity)
            }
        }

        // Clear all data
        func clear() {
            entities.removeAll()
            entityOrder.removeAll()
        }

        // Update entity with changed properties
        func updateEntity(type entityType: String, id: String, changedProperties: [String: AnyChange]) {
            guard let existingEntity = entities[entityType]?[id] else {
                GomaLogger.debug(.realtime, category: "ODDS_FLOW", "EntityStore.updateEntity - entity NOT FOUND: \(entityType):\(id)")
                return
            }

            // Log betting offer odds updates specifically
            if entityType == "BETTING_OFFER", let oddsChange = changedProperties["odds"] {
                GomaLogger.info(.realtime, category: "ODDS_FLOW", "EntityStore.updateEntity - BETTING_OFFER:\(id) odds changed to: \(oddsChange.jsonSafeValue ?? "nil")")
            }

            // Create updated entity by merging changed properties
            let updatedEntity = mergeChangedProperties(entity: existingEntity, changes: changedProperties)

            if let updatedEntityValue = updatedEntity {
                entities[entityType]?[id] = updatedEntityValue

                // Notify observers of the update
                notifyEntityChange(updatedEntityValue)
            } else {
                GomaLogger.error(.realtime, category: "ODDS_FLOW", "EntityStore.updateEntity - MERGE FAILED for \(entityType):\(id)")
            }
        }

        // Delete entity from store
        func deleteEntity(type entityType: String, id: String) {
            entities[entityType]?[id] = nil
            
            // print("Deleted entity \(entityType):\(id)")

            // Notify observers of the deletion
            notifyEntityDeletion(entityType: entityType, id: id)
        }

        // Helper method to merge changed properties into existing entity
        private func mergeChangedProperties(entity: any Entity, changes: [String: AnyChange]) -> (any Entity)? {
            // This is complex because we need to create a new instance with updated properties
            // For now, we'll use a reflection-based approach

            // Convert entity to JSON, update properties, and decode back
            do {
                let encoder = JSONEncoder()
                let decoder = JSONDecoder()

                // Encode existing entity to JSON
                var entityData = try encoder.encode(entity)
                var json = try JSONSerialization.jsonObject(with: entityData) as? [String: Any] ?? [:]

                // Apply changed properties using JSON-safe values
                for (key, value) in changes {
                    json[key] = value.jsonSafeValue
                }

                // Encode back to data
                entityData = try JSONSerialization.data(withJSONObject: json)

                // Decode to appropriate type based on entity type
                switch type(of: entity).rawType {
                case "SPORT":
                    return try decoder.decode(SportDTO.self, from: entityData)
                case "MATCH":
                    return try decoder.decode(MatchDTO.self, from: entityData)
                case "MARKET":
                    return try decoder.decode(MarketDTO.self, from: entityData)
                case "OUTCOME":
                    return try decoder.decode(OutcomeDTO.self, from: entityData)
                case "BETTING_OFFER":
                    return try decoder.decode(BettingOfferDTO.self, from: entityData)
                case "LOCATION":
                    return try decoder.decode(LocationDTO.self, from: entityData)
                case "EVENT_CATEGORY":
                    return try decoder.decode(EventCategoryDTO.self, from: entityData)
                case "MARKET_OUTCOME_RELATION":
                    return try decoder.decode(MarketOutcomeRelationDTO.self, from: entityData)
                case "MAIN_MARKET":
                    return try decoder.decode(MainMarketDTO.self, from: entityData)
                case "MARKET_INFO":
                    return try decoder.decode(MarketInfoDTO.self, from: entityData)
                case "NEXT_MATCHES_NUMBER":
                    return try decoder.decode(NextMatchesNumberDTO.self, from: entityData)
                case "TOURNAMENT":
                    return try decoder.decode(TournamentDTO.self, from: entityData)
                case "EVENT_INFO":
                    return try decoder.decode(EventInfoDTO.self, from: entityData)
                case "MARKET_GROUP":
                    return try decoder.decode(MarketGroupDTO.self, from: entityData)
                default:
                    print("Unknown entity type for merge: \(type(of: entity).rawType)")
                    return nil
                }
            } catch {
                print("Failed to merge changed properties for \(type(of: entity).rawType):\(entity.id) - \(error)")
                return nil
            }
        }

        // MARK: - Entity Observation Methods

        /// Observe changes to a specific entity by type and ID
        func observeEntity<T: Entity>(_ type: T.Type, id: String) -> AnyPublisher<T?, Never> {
            // Get current entity value
            let currentEntity = entities[T.rawType]?[id] as? T

            // Log if entity not found - this is a potential issue
            if currentEntity == nil {
                GomaLogger.debug(.realtime, category: "ODDS_FLOW", "EntityStore.observeEntity - WARNING: No \(T.rawType):\(id) found in store (subscription created anyway)")
            }

            // Get or create publisher for this entity
            let publisher = getOrCreatePublisher(entityType: T.rawType, id: id, currentValue: currentEntity)

            // Return publisher that already has current value and future changes
            return publisher.compactMap { $0 as? T }.eraseToAnyPublisher()
        }

        /// Convenience method to observe market changes
        func observeMarket(id: String) -> AnyPublisher<MarketDTO?, Never> {
            GomaLogger.debug(.realtime, category: "ODDS_FLOW", "EntityStore.observeMarket - SUBSCRIBING to MARKET:\(id)")
            return observeEntity(MarketDTO.self, id: id)
        }

        /// Convenience method to observe outcome changes
        func observeOutcome(id: String) -> AnyPublisher<OutcomeDTO?, Never> {
            GomaLogger.debug(.realtime, category: "ODDS_FLOW", "EntityStore.observeOutcome - SUBSCRIBING to OUTCOME:\(id)")
            return observeEntity(OutcomeDTO.self, id: id)
        }

        /// Convenience method to observe betting offer changes
        func observeBettingOffer(id: String) -> AnyPublisher<BettingOfferDTO?, Never> {
            GomaLogger.debug(.realtime, category: "ODDS_FLOW", "EntityStore.observeBettingOffer - SUBSCRIBING to BETTING_OFFER:\(id)")
            return observeEntity(BettingOfferDTO.self, id: id)
        }

        /// Convenience method to observe match changes
        func observeMatch(id: String) -> AnyPublisher<MatchDTO?, Never> {
            return observeEntity(MatchDTO.self, id: id)
        }
        
        /// Convenience method to observe event info changes
        func observeEventInfo(id: String) -> AnyPublisher<EventInfoDTO?, Never> {
            return observeEntity(EventInfoDTO.self, id: id)
        }
        
        /// Observe all EVENT_INFO entities for a specific event
        func observeEventInfosForEvent(eventId: String) -> AnyPublisher<[EventInfoDTO], Never> {
            let collectionKey = "EVENT_INFO_FOR_EVENT_\(eventId)"
            
            // Get current EVENT_INFO entities for this event
            let currentEventInfos = getCurrentEventInfosForEvent(eventId: eventId)
            
            // Get or create publisher for this collection
            let publisher = getOrCreateCollectionPublisher(collectionKey: collectionKey, currentValue: currentEventInfos)
            
            // Return publisher that filters and maps to EventInfoDTO
            return publisher
                .map { entities in
                    entities.compactMap { $0 as? EventInfoDTO }
                }
                .eraseToAnyPublisher()
        }

        // MARK: - Publisher Management
        
        /// Get current EVENT_INFO entities for a specific event ID
        private func getCurrentEventInfosForEvent(eventId: String) -> [any Entity] {
            return entities[EventInfoDTO.rawType]?.values.compactMap { entity in
                if let eventInfo = entity as? EventInfoDTO,
                   eventInfo.eventId == eventId {
                    return eventInfo
                }
                return nil
            } ?? []
        }
        
        /// Get or create collection publisher with CurrentValueSubject pattern
        private func getOrCreateCollectionPublisher(collectionKey: String, currentValue: [any Entity]) -> CurrentValueSubject<[any Entity], Never> {
            if let existingPublisher = collectionPublishers[collectionKey] {
                return existingPublisher
            }
            
            // Create CurrentValueSubject with current collection value
            let newPublisher = CurrentValueSubject<[any Entity], Never>(currentValue)
            collectionPublishers[collectionKey] = newPublisher
            
            return newPublisher
        }

        private func getOrCreatePublisher(entityType: String, id: String, currentValue: (any Entity)? = nil) -> CurrentValueSubject<(any Entity)?, Never> {

            if self.entityPublishers[entityType] == nil {
                self.entityPublishers[entityType] = [:]
            }

            if let existingPublisher = self.entityPublishers[entityType]?[id] {
                return existingPublisher
            }

            // Create CurrentValueSubject with current value (or nil if not found)
            let initialValue = currentValue ?? entities[entityType]?[id]
            
            let newPublisher = CurrentValueSubject<(any Entity)?, Never>(initialValue)
            self.entityPublishers[entityType]?[id] = newPublisher

            return newPublisher
        }

        private func notifyEntityChange(_ entity: (any Entity)?) {
            guard let entity = entity else {
                // Handle deletion case - notify with nil
                return
            }

            let entityType = type(of: entity).rawType
            let id = entity.id

            // Update CurrentValueSubject with new value if it exists
            if let publisher = entityPublishers[entityType]?[id] {
                GomaLogger.info(.realtime, category: "ODDS_FLOW", "EntityStore.notifyEntityChange - NOTIFYING observer for \(entityType):\(id)")
                publisher.send(entity)
            } else {
                // Log when there's NO observer - this is the key debugging point
                if entityType == "BETTING_OFFER" {
                    // Check if there ARE observers for related OUTCOME (the parent)
                    if let bettingOffer = entity as? BettingOfferDTO {
                        let hasOutcomeObserver = entityPublishers["OUTCOME"]?[bettingOffer.outcomeId] != nil
                        if hasOutcomeObserver {
                            GomaLogger.error(.realtime, category: "ODDS_FLOW", "EntityStore.notifyEntityChange - MISMATCH! BETTING_OFFER:\(id) updated but UI observes OUTCOME:\(bettingOffer.outcomeId) - OUTCOME won't be notified!")
                        } else {
                            GomaLogger.debug(.realtime, category: "ODDS_FLOW", "EntityStore.notifyEntityChange - NO OBSERVER for BETTING_OFFER:\(id) (no related OUTCOME observer either)")
                        }
                    }
                }
            }

            // Update collection publishers if this is an EVENT_INFO
            if let eventInfo = entity as? EventInfoDTO {
                updateEventInfoCollectionPublisher(for: eventInfo.eventId)
            }
        }

        private func notifyEntityDeletion(entityType: String, id: String) {
            // Update CurrentValueSubject with nil to indicate deletion
            entityPublishers[entityType]?[id]?.send(nil)
            
            // Update collection publishers if this was an EVENT_INFO
            if entityType == EventInfoDTO.rawType {
                // We need to find which event this EVENT_INFO belonged to
                // Since we're deleting, we need to check existing entities to find eventId
                if let deletedEntity = entities[entityType]?[id] as? EventInfoDTO {
                    updateEventInfoCollectionPublisher(for: deletedEntity.eventId)
                }
            }
        }
        
        /// Update EVENT_INFO collection publisher for a specific event
        private func updateEventInfoCollectionPublisher(for eventId: String) {
            let collectionKey = "EVENT_INFO_FOR_EVENT_\(eventId)"
            
            // Only update if publisher exists (someone is observing)
            if let publisher = collectionPublishers[collectionKey] {
                let currentEventInfos = getCurrentEventInfosForEvent(eventId: eventId)
                publisher.send(currentEventInfos)
            }
        }

        // MARK: - Publisher Cleanup

        private func cleanupUnusedPublishers() {
            // Remove publishers with no active subscribers
            // This is a simplified cleanup - can be enhanced with subscription counting
            for (entityType, publishersDict) in entityPublishers {
                let filteredDict = publishersDict.filter { (_, publisher) in
                    // Keep publishers that have active subscriptions
                    // For now, we'll keep all publishers for simplicity
                    return true
                }
                entityPublishers[entityType] = filteredDict
            }
            
            // Cleanup collection publishers as well
            let filteredCollectionPublishers = collectionPublishers.filter { (_, publisher) in
                // Keep publishers that have active subscriptions
                // For now, we'll keep all publishers for simplicity
                return true
            }
            collectionPublishers = filteredCollectionPublishers
        }
    }
}

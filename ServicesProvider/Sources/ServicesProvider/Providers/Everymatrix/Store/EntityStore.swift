//
//  EntityStore.swift
//  ServicesProvider
//
//  Created by Ruben Roques on 26/06/2025.
//

import Foundation
import Combine

extension EveryMatrix {
    class EntityStore: ObservableObject {
        @Published private var entities: [String: [String: any Entity]] = [:]
        private let queue = DispatchQueue(label: "entity.store.queue", attributes: .concurrent)
        private var entityOrder: [String: [String]] = [:] // [EntityType: [Ordered IDs]]

        // MARK: - Publisher Infrastructure
        private var entityPublishers: [String: [String: CurrentValueSubject<(any Entity)?, Never>]] = [:]
        private let publisherQueue = DispatchQueue(label: "entity.publisher.queue", attributes: .concurrent)
        private var cancellables = Set<AnyCancellable>()

        // Store entity by type and id
        func store<T: Entity>(_ entity: T) {
            queue.async(flags: .barrier) { [weak self] in
                let type = T.rawType
                if self?.entities[type] == nil {
                    self?.entities[type] = [:]
                    self?.entityOrder[type] = []
                }
                self?.entities[type]?[entity.id] = entity

                // Add to order if not already present
                if !(self?.entityOrder[type]?.contains(entity.id) ?? false) {
                    self?.entityOrder[type]?.append(entity.id)
                }
                
                // Notify observers of the change
                self?.notifyEntityChange(entity)
            }
        }

        // Retrieve entity by type and id
        func get<T: Entity>(_ type: T.Type, id: String) -> T? {
            return queue.sync {
                guard let typeDict = entities[T.rawType] else { return nil }
                return typeDict[id] as? T
            }
        }

        // Get all entities of a specific type
        func getAll<T: Entity>(_ type: T.Type) -> [T] {
            return queue.sync {
                guard let typeDict = entities[T.rawType] else { return [] }
                return typeDict.values.compactMap { $0 as? T }
            }
        }
        
        // Add method to get entities in original order
        func getAllInOrder<T: Entity>(_ type: T.Type) -> [T] {
            return queue.sync {
                guard let typeDict = entities[T.rawType],
                      let order = entityOrder[T.rawType] else { return [] }
                
                return order.compactMap { id in
                    typeDict[id] as? T
                }
            }
        }

        // Store multiple entities
        func store<T: Entity>(_ entities: [T]) {
            queue.async(flags: .barrier) { [weak self] in
                for entity in entities {
                    let type = T.rawType
                    if self?.entities[type] == nil {
                        self?.entities[type] = [:]
                    }
                    self?.entities[type]?[entity.id] = entity

                    // Notify observers of each change
                    self?.notifyEntityChange(entity)
                }
            }
        }

        // Clear all data
        func clear() {
            queue.async(flags: .barrier) { [weak self] in
                self?.entities.removeAll()
            }
        }

        // Update entity with changed properties
        func updateEntity(type entityType: String, id: String, changedProperties: [String: AnyCodable]) {
            queue.async(flags: .barrier) { [weak self] in
                guard let existingEntity = self?.entities[entityType]?[id] else {
                    print("Cannot update entity \(entityType):\(id) - entity not found")
                    return
                }

                // Create updated entity by merging changed properties
                let updatedEntity = self?.mergeChangedProperties(entity: existingEntity, changes: changedProperties)

                if let updatedEntityValue = updatedEntity {
                    self?.entities[entityType]?[id] = updatedEntityValue

                    // Notify observers of the update
                    self?.notifyEntityChange(updatedEntityValue)
                }
            }
        }

        // Delete entity from store
        func deleteEntity(type entityType: String, id: String) {
            queue.async(flags: .barrier) { [weak self] in
                self?.entities[entityType]?[id] = nil
                
                // print("Deleted entity \(entityType):\(id)")

                // Notify observers of the deletion
                self?.notifyEntityDeletion(entityType: entityType, id: id)
            }
        }

        // Helper method to merge changed properties into existing entity
        private func mergeChangedProperties(entity: any Entity, changes: [String: AnyCodable]) -> (any Entity)? {
            // This is complex because we need to create a new instance with updated properties
            // For now, we'll use a reflection-based approach

            // Convert entity to JSON, update properties, and decode back
            do {
                let encoder = JSONEncoder()
                let decoder = JSONDecoder()

                // Encode existing entity to JSON
                var entityData = try encoder.encode(entity)
                var json = try JSONSerialization.jsonObject(with: entityData) as? [String: Any] ?? [:]

                // Apply changed properties
                for (key, value) in changes {
                    json[key] = value.value
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
            return self.publisherQueue.sync { [weak self] in
                guard let self = self else {
                    return Just(nil).eraseToAnyPublisher()
                }

                // Get current entity value
                let currentEntity = self.queue.sync {
                    self.entities[T.rawType]?[id] as? T
                }

                // Get or create publisher for this entity
                let publisher = self.getOrCreatePublisher(entityType: T.rawType, id: id, currentValue: currentEntity)

                // Return publisher that already has current value and future changes
                return publisher.compactMap { $0 as? T }.eraseToAnyPublisher()
            }
        }

        /// Convenience method to observe market changes
        func observeMarket(id: String) -> AnyPublisher<MarketDTO?, Never> {
            return observeEntity(MarketDTO.self, id: id)
        }

        /// Convenience method to observe outcome changes
        func observeOutcome(id: String) -> AnyPublisher<OutcomeDTO?, Never> {
            return observeEntity(OutcomeDTO.self, id: id)
        }

        /// Convenience method to observe betting offer changes
        func observeBettingOffer(id: String) -> AnyPublisher<BettingOfferDTO?, Never> {
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
            return $entities
                .map { (entitiesDict: [String: [String: any Entity]]) -> [EventInfoDTO] in
                    return entitiesDict[EventInfoDTO.rawType]?.values.compactMap { entity in
                        if let eventInfo = entity as? EventInfoDTO,
                           eventInfo.eventId == eventId {
                            return eventInfo
                        }
                        return nil
                    } ?? []
                }
                .removeDuplicates()
                .eraseToAnyPublisher()
        }

        // MARK: - Publisher Management

        private func getOrCreatePublisher(entityType: String, id: String, currentValue: (any Entity)? = nil) -> CurrentValueSubject<(any Entity)?, Never> {

            if self.entityPublishers[entityType] == nil {
                self.entityPublishers[entityType] = [:]
            }

            if let existingPublisher = self.entityPublishers[entityType]?[id] {
                return existingPublisher
            }

            // Create CurrentValueSubject with current value (or nil if not found)
            let initialValue = currentValue ?? self.queue.sync {
                self.entities[entityType]?[id]
            }
            
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

            publisherQueue.async { [weak self] in
                // Update CurrentValueSubject with new value if it exists
                if let publisher = self?.entityPublishers[entityType]?[id] {
                    publisher.send(entity)
                }
            }
        }

        private func notifyEntityDeletion(entityType: String, id: String) {
            publisherQueue.async { [weak self] in
                // Update CurrentValueSubject with nil to indicate deletion
                self?.entityPublishers[entityType]?[id]?.send(nil)
            }
        }

        // MARK: - Publisher Cleanup

        private func cleanupUnusedPublishers() {
            publisherQueue.async(flags: .barrier) { [weak self] in
                guard let self = self else { return }

                // Remove publishers with no active subscribers
                // This is a simplified cleanup - can be enhanced with subscription counting
                for (entityType, publishersDict) in self.entityPublishers {
                    let filteredDict = publishersDict.filter { (_, publisher) in
                        // Keep publishers that have active subscriptions
                        // For now, we'll keep all publishers for simplicity
                        return true
                    }
                    self.entityPublishers[entityType] = filteredDict
                }
            }
        }
    }
}
//
//  ResponseParser.swift
//  ServicesProvider
//
//  Created by Ruben Roques on 26/06/2025.
//

import Foundation

extension EveryMatrix {
    struct ResponseParser {
        static func parseAndStore(response: AggregatorResponse, in store: EntityStore) {
            for record in response.records {
                switch record {
                // INITIAL_DUMP records - store full entities
                case .sport(let dto):
                    store.store(dto)
                case .match(let dto):
                    store.store(dto)
                case .market(let dto):
                    store.store(dto)
                case .outcome(let dto):
                    store.store(dto)
                case .bettingOffer(let dto):
                    store.store(dto)
                case .location(let dto):
                    store.store(dto)
                case .eventCategory(let dto):
                    store.store(dto)
                case .marketOutcomeRelation(let dto):
                    store.store(dto)
                case .mainMarket(let dto):
                    store.store(dto)
                case .marketInfo(let dto):
                    store.store(dto)
                case .nextMatchesNumber(let dto):
                    store.store(dto)
                case .tournament(let dto):
                    store.store(dto)
                case .eventInfo(let dto):
                    store.store(dto)
                // UPDATE/DELETE/CREATE records - handle changes
                case .changeRecord(let changeRecord):
                    handleChangeRecord(changeRecord, in: store)

                case .unknown(let type):
                    print("Unknown entity type: \(type)")
                }
            }
        }

        private static func handleChangeRecord(_ change: ChangeRecord, in store: EntityStore) {
            switch change.changeType {
            case .create:
                
                /*
                // CREATE: Store the full entity
                guard let entityData = change.entity else {
                    print("CREATE change record missing entity data for \(change.entityType):\(change.id)")
                    return
                }
                storeEntityData(entityData, in: store)
                */
                break
            case .update:
                // UPDATE: Merge changedProperties with existing entity
                guard let changedProperties = change.changedProperties else {
                    print("UPDATE change record missing changedProperties for \(change.entityType):\(change.id)")
                    return
                }
                
                if change.entityType == BettingOfferDTO.rawType && changedProperties.keys.contains("odds"){
                    store.updateEntity(type: change.entityType, id: change.id, changedProperties: changedProperties)
                }
                else {
                    return
                }
                
            case .delete:
                // DELETE: Remove entity from store
                // store.deleteEntity(type: change.entityType, id: change.id)
                break
            }
        }

        private static func storeEntityData(_ entityData: EntityData, in store: EntityStore) {
            switch entityData {
            case .sport(let dto):
                store.store(dto)
            case .match(let dto):
                store.store(dto)
            case .market(let dto):
                store.store(dto)
            case .outcome(let dto):
                store.store(dto)
            case .bettingOffer(let dto):
                store.store(dto)
            case .location(let dto):
                store.store(dto)
            case .eventCategory(let dto):
                store.store(dto)
            case .marketOutcomeRelation(let dto):
                store.store(dto)
            case .mainMarket(let dto):
                store.store(dto)
            case .marketInfo(let dto):
                store.store(dto)
            case .nextMatchesNumber(let dto):
                store.store(dto)
            case .tournament(let dto):
                store.store(dto)
            case .eventInfo(let dto):
                store.store(dto)
            case .unknown(let type):
                print("Unknown entity data type: \(type)")
            }
        }
    }
}
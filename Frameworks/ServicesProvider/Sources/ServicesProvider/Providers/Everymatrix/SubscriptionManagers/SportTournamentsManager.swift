//
//  SportTournamentsManager.swift
//  ServicesProvider
//
//  Created by André Lascas on 17/06/2025.
//

import Foundation
import Combine
import SharedModels

class SportTournamentsManager {
    
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
    init(connector: EveryMatrixSocketConnector, sportId: String, tournamentsCount: Int = 10, operatorId: String = "4093", language: String = "en") {
        self.connector = connector
        self.sportId = sportId
        self.tournamentsCount = tournamentsCount
        self.operatorId = operatorId
        self.language = language
    }
    
    // MARK: - Public Interface
    func subscribe() -> AnyPublisher<SubscribableContent<[Tournament]>, ServiceProviderError> {
        unsubscribe()
        store.clear()
        
        let router = WAMPRouter.tournamentsPublisher(
            operatorId: operatorId,
            language: language,
            sportId: sportId
        )
        
        return connector.subscribe(router)
            .handleEvents(receiveOutput: { [weak self] content in
                if case .connect(let subscription) = content {
                    self?.currentSubscription = Subscription(id: "\(subscription.identificationCode)")
                }
            })
            .compactMap { [weak self] (content: WAMPSubscriptionContent<EveryMatrix.AggregatorResponse>) -> SubscribableContent<[Tournament]>? in
                guard let self = self else { return nil }
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
    
    func unsubscribe() {
        currentSubscription = nil
        cancellables.removeAll()
    }
    
    // MARK: - Private Methods
    private func handleSubscriptionContent(_ content: WAMPSubscriptionContent<EveryMatrix.AggregatorResponse>) throws -> SubscribableContent<[Tournament]>? {
        switch content {
        case .connect(let publisherIdentifiable):
            let subscription = Subscription(id: "\(publisherIdentifiable.identificationCode)")
            return SubscribableContent.connected(subscription: subscription)
        case .initialContent(let response):
            parseTournamentsData(from: response)
            let tournaments = buildTournaments()
            return .contentUpdate(content: tournaments)
        case .updatedContent(let response):
            parseTournamentsData(from: response)
            let tournaments = buildTournaments()
            return .contentUpdate(content: tournaments)
        case .disconnect:
            return nil
        }
    }
    
    private func buildTournaments() -> [Tournament] {
        let tournamentsDTO = store.getAllInOrder(EveryMatrix.TournamentDTO.self)
        let internalTournaments = tournamentsDTO.compactMap { tournamentDTO in
            EveryMatrix.TournamentBuilder.build(from: tournamentDTO, store: store)
        }
        let tournaments = internalTournaments.compactMap { internalTournament in
            EveryMatrixModelMapper.tournament(fromInternalTournament: internalTournament)
        }
        let filteredTournaments = tournaments.filter { tournament in
            tournament.numberOfEvents ?? 0 > 0
        }
        return filteredTournaments
    }
    
    private func parseTournamentsData(from response: EveryMatrix.AggregatorResponse) {
        for record in response.records {
            switch record {
            case .tournament(let dto):
                store.store(dto)
            case .changeRecord(let changeRecord):
                handleTournamentsChangeRecord(changeRecord)
            default:
                break
            }
        }
    }
    
    private func handleTournamentsChangeRecord(_ change: EveryMatrix.ChangeRecord) {
        guard change.entityType == EveryMatrix.TournamentDTO.rawType else { return }
        switch change.changeType {
        case .create:
            if let entityData = change.entity, case .tournament(let dto) = entityData {
                store.store(dto)
            }
        case .update:
            guard let changedProperties = change.changedProperties else { return }
            store.updateEntity(type: change.entityType, id: change.id, changedProperties: changedProperties)
        case .delete:
            store.deleteEntity(type: change.entityType, id: change.id)
        }
    }
}

// MARK: - Entity Store Access

extension SportTournamentsManager {
    var entityStore: EveryMatrix.EntityStore { store }
    
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

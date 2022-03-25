//
//  MarketGroupDetailsViewModel.swift
//  Sportsbook
//
//  Created by Ruben Roques on 16/03/2022.
//

import Foundation
import Combine

class MarketGroupDetailsViewModel {

    var match: Match
    var isLoadingPublisher: CurrentValueSubject<Bool, Never> = .init(true)
    var marketGroupOrganizersPublisher: CurrentValueSubject<[MarketGroupOrganizer], Never>  = .init([])

    private var marketGroupId: String

    private var marketGroupsDetailsRegister: EndpointPublisherIdentifiable?
    private var store: MarketGroupDetailsStore

    private var cancellables: Set<AnyCancellable> = []

    init(match: Match, marketGroupId: String, store: MarketGroupDetailsStore = MarketGroupDetailsStore()) {
        self.match = match
        self.marketGroupId = marketGroupId
        self.store = store
    }

    func fetchMarketGroupDetails() {

        if let marketGroupsDetailsRegister = self.marketGroupsDetailsRegister {
            Env.everyMatrixClient.manager.unregisterFromEndpoint(endpointPublisherIdentifiable: marketGroupsDetailsRegister)
        }

        let language = "en"
        let endpoint = TSRouter.matchMarketGroupDetailsPublisher(operatorId: Env.appSession.operatorId,
                                                                 language: language,
                                                                 matchId: self.match.id,
                                                                 marketGroupName: marketGroupId)

        Env.everyMatrixClient.manager
            .registerOnEndpoint(endpoint, decodingType: EveryMatrix.Aggregator.self)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .failure:
                    print("Error retrieving data!")
                case .finished:
                    print("Data retrieved!")
                }
                self?.isLoadingPublisher.send(false)
            }, receiveValue: { [weak self] state in
                switch state {
                case .connect(let publisherIdentifiable):
                    print("SportsViewModel competitionsMatchesPublisher connect")
                    self?.marketGroupsDetailsRegister = publisherIdentifiable
                case .initialContent(let aggregator):
                    print("SportsViewModel competitionsMatchesPublisher initialContent")
                    self?.storeMarketGroupDetails(fromAggregator: aggregator)
                case .updatedContent(let aggregatorUpdates):
                    print("SportsViewModel competitionsMatchesPublisher updatedContent")
                    self?.updateMarketGroupDetails(fromAggregator: aggregatorUpdates)
                case .disconnect:
                    print("SportsViewModel competitionsMatchesPublisher disconnect")
                }
            })
            .store(in: &cancellables)
    }

    func storeMarketGroupDetails(fromAggregator aggregator: EveryMatrix.Aggregator) {
        self.store.storeMarketGroupDetails(fromAggregator: aggregator, onMarketGroup: "MarketKey")
        let marketGroupOrganizers = self.store.marketGroupOrganizers(withGroupKey: "MarketKey")

        self.marketGroupOrganizersPublisher.send(marketGroupOrganizers)
        self.isLoadingPublisher.send(false)
    }

    func updateMarketGroupDetails(fromAggregator aggregator: EveryMatrix.Aggregator) {
        self.store.updateMarketGroupDetails(fromAggregator: aggregator)
    }

}

extension MarketGroupDetailsViewModel {

    func numberOfSections() -> Int {
        return 1
    }

    func numberOfRows() -> Int {
        let count = self.marketGroupOrganizersPublisher.value.count
        return count
    }

    func marketGroupOrganizer(forRow row: Int) -> MarketGroupOrganizer? {
        return self.marketGroupOrganizersPublisher.value[safe: row]
    }

}

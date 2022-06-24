//
//  OutrightMarketDetailsViewModel.swift
//  Sportsbook
//
//  Created by Ruben Roques on 22/02/2022.
//

import Combine

class OutrightMarketDetailsViewModel {

    // MARK: - Public Properties
    var competition: Competition

    var isLoadingPublisher = CurrentValueSubject<Bool, Never>.init(true)
    var isCompetitionBettingAvailablePublisher = CurrentValueSubject<Bool, Never>.init(true)
    
    var refreshPublisher = PassthroughSubject<Void, Never>.init()

    // MARK: - Private Properties
    private var marketGroupOrganizers: [MarketGroupOrganizer] = []
    private var competitionMarketPublisher: AnyCancellable?
    private var competitionMarketRegister: EndpointPublisherIdentifiable?

    private var store: OutrightMarketDetailsStore

    private static let groupKey = "Main"

    // MARK: - Lifetime and Cycle
    init(competition: Competition, store: OutrightMarketDetailsStore) {
        self.competition = competition
        self.store = store

        self.fetchCompetitionMarkets(competitionId: competition.id)
    }

    // MARK: - View Configuration
    var competitionName: String {
        return self.competition.name
    }

    var countryImageName: String {
        if let isoCode = self.competition.venue?.isoCode {
            return Assets.flagName(withCountryCode: isoCode)
        }
        else {
            return "country_flag_240"
        }
    }
    
    func numberOfSections() -> Int {
        return 1
    }

    func numberOfRows(forSection section: Int) -> Int {
        return marketGroupOrganizers.count
    }

    func marketGroupOrganizer(forIndex index: Int) -> MarketGroupOrganizer? {
        return self.marketGroupOrganizers[safe: index]
    }

    // MARK: - Internal functions
    private func fetchCompetitionMarkets(competitionId id: String) {

        self.isLoadingPublisher.send(true)

        let language = "en"
        let endpoint = TSRouter.tournamentOddsPublisher(operatorId: Env.appSession.operatorId,
                                                        language: language,
                                                        eventId: id)

        if let competitionMarketRegister = self.competitionMarketRegister {
            Env.everyMatrixClient.manager.unregisterFromEndpoint(endpointPublisherIdentifiable: competitionMarketRegister)
        }

        self.competitionMarketPublisher?.cancel()
        self.competitionMarketPublisher = nil

        self.competitionMarketPublisher = Env.everyMatrixClient.manager
            .registerOnEndpoint(endpoint, decodingType: EveryMatrix.Aggregator.self)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure:
                    print("Error retrieving data!")
                case .finished:
                    print("Data retrieved!")
                }
                self.isLoadingPublisher.send(false)
            }, receiveValue: { [weak self] state in
                switch state {
                case .connect(let publisherIdentifiable):
                    self?.competitionMarketRegister = publisherIdentifiable
                case .initialContent(let aggregator):
                    self?.storeAggregator(aggregator)
                case .updatedContent(let aggregatorUpdates):
                    self?.updateWithAggregator(aggregatorUpdates)
                case .disconnect:
                    ()

                }
            })
    }

    private func storeAggregator(_ aggregator: EveryMatrix.Aggregator) {
        self.store.storeMarketGroupDetails(fromAggregator: aggregator, onMarketGroup: Self.groupKey)
        self.marketGroupOrganizers = self.store.marketGroupOrganizers(withGroupKey: Self.groupKey)
        
        self.isCompetitionBettingAvailablePublisher.send(self.marketGroupOrganizers.isNotEmpty)
                
        self.refreshPublisher.send()
        self.isLoadingPublisher.send(false)
    }

    private func updateWithAggregator(_ aggregator: EveryMatrix.Aggregator) {
        self.store.updateMarketGroupDetails(fromAggregator: aggregator)
        
        let updatedMarketGroupOrganizers = self.store.marketGroupOrganizers(withGroupKey: Self.groupKey)
        self.isCompetitionBettingAvailablePublisher.send(updatedMarketGroupOrganizers.isNotEmpty)
        
        self.isLoadingPublisher.send(false)
    }

}

//
//  OutrightMarketDetailsViewModel.swift
//  Sportsbook
//
//  Created by Ruben Roques on 22/02/2022.
//
import Foundation
import Combine
import ServicesProvider

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

    private var cancellables = Set<AnyCancellable>()
    private var subscriptions = Set<ServicesProvider.Subscription>()

    // MARK: - Lifetime and Cycle
    init(competition: Competition, store: OutrightMarketDetailsStore) {
        self.competition = competition
        self.store = store

        self.fetchCompetitionMarkets(competition: competition)
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
    private func fetchCompetitionMarkets(competition: Competition) {

        self.isLoadingPublisher.send(true)

        if competition.competitionInfo == nil {
            Env.servicesProvider.subscribeMatchDetails(matchId: competition.id)
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { [weak self] completion in
                    print("Env.servicesProvider.subscribeEventDetails completed \(completion)")
                    switch completion {
                    case .finished:
                        ()
                    case .failure(let error):
                        print("OUTRIGHTS DETAILS ERROR: \(error)")
                    }
                }, receiveValue: { (subscribableContent: SubscribableContent<[EventsGroup]>) in
                    print("Env.servicesProvider.subscribeEventDetails value \(subscribableContent)")
                    switch subscribableContent {
                    case .connected(let subscription):
                        print("Connected to ws")
                    case .contentUpdate(let events):
                        //self.isLoadingMarketGroups.send(true)
                        if let eventGroup = events[safe: 0] {

                            if let eventMapped = ServiceProviderModelMapper.event(fromEventGroup: eventGroup){
                                //self.getMarketGroups(event: eventMapped)
                                let markets = ServiceProviderModelMapper.markets(fromServiceProviderMarkets: eventMapped.markets)
                                self.storeMarkets(markets: markets)
                            }
                        }
                        //                    else {
                        //                        self.isLoadingMarketGroups.send(false)
                        //                    }

                    case .disconnected:
                        print("Disconnected from ws")

                    }
                })
                .store(in: &cancellables)
        }
        else {
            Env.servicesProvider.getCompetitionMarketGroups(competitionId: competition.id)
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { [weak self] completion in
                    switch completion {
                    case .finished:
                        ()
                    case .failure(let error):
                        print("COMPETITION INFO ERROR: \(error)")
                        self?.isLoadingPublisher.send(false)
                    }

                }, receiveValue: { [weak self] competitionInfo in

                    self?.subscribeOutrightMarkets(competition: competition)

                })
                .store(in: &cancellables)
        }


        // EM
//        let language = "en"
//        let endpoint = TSRouter.tournamentOddsPublisher(operatorId: Env.appSession.operatorId,
//                                                        language: language,
//                                                        eventId: competition.id)
//
//        if let competitionMarketRegister = self.competitionMarketRegister {
//            Env.everyMatrixClient.manager.unregisterFromEndpoint(endpointPublisherIdentifiable: competitionMarketRegister)
//        }
//
//        self.competitionMarketPublisher?.cancel()
//        self.competitionMarketPublisher = nil
//
//        self.competitionMarketPublisher = Env.everyMatrixClient.manager
//            .registerOnEndpoint(endpoint, decodingType: EveryMatrix.Aggregator.self)
//            .sink(receiveCompletion: { completion in
//                switch completion {
//                case .failure:
//                    print("Error retrieving data!")
//                case .finished:
//                    print("Data retrieved!")
//                }
//                self.isLoadingPublisher.send(false)
//            }, receiveValue: { [weak self] state in
//                switch state {
//                case .connect(let publisherIdentifiable):
//                    self?.competitionMarketRegister = publisherIdentifiable
//                case .initialContent(let aggregator):
//                    self?.storeAggregator(aggregator)
//                case .updatedContent(let aggregatorUpdates):
//                    self?.updateWithAggregator(aggregatorUpdates)
//                case .disconnect:
//                    ()
//
//                }
//            })
        //self.isLoadingPublisher.send(false)
    }

    private func subscribeOutrightMarkets(competition: Competition) {

        if let outrightMarketGroup = competition.competitionInfo?.marketGroups.filter({
            $0.name == "Outright"
        }).first {

            Env.servicesProvider.subscribeOutrightMarkets(forMarketGroupId: outrightMarketGroup.id)
                .sink {  [weak self] (completion: Subscribers.Completion<ServiceProviderError>) in
                    switch completion {
                    case .finished:
                        ()
                    case .failure:
                        print("SUBSCRIPTION COMPETITION OUTRIGHTS ERROR")
                    }
                } receiveValue: { [weak self] (subscribableContent: SubscribableContent<[EventsGroup]>) in
                    switch subscribableContent {
                    case .connected(let subscription):
                        self?.subscriptions.insert(subscription)
                    case .contentUpdate(let eventsGroups):
                        print("OUTRIGHTS EVENTS: \(eventsGroups)")
                        if let event = eventsGroups.first?.events.first {
                            //self.storeMarkets(markets: eventsGroups)
                            let markets = ServiceProviderModelMapper.markets(fromServiceProviderMarkets: event.markets)
                            self?.storeMarkets(markets: markets)
                            //self?.isLoadingPublisher.send(false)
                        }

                    case .disconnected:
                        ()
                    }
                }
                .store(in: &cancellables)
        }
//        else {
//            if let markets = competition.outrightMarkets {
//                self.storeMarkets(markets: markets)
//            }
//        }
    }

//    private func fetchMarketGroupsPublisher(marketGroups: [ServicesProvider.MarketGroup]) {
//
//        let marketGroups = marketGroups.map { rawMarketGroup in
//
//            MarketGroup(id: rawMarketGroup.id,
//                        type: rawMarketGroup.type,
//                        groupKey: rawMarketGroup.groupKey,
//                        translatedName: rawMarketGroup.translatedName,
//                        isDefault: rawMarketGroup.isDefault,
//                        markets: ServiceProviderModelMapper.optionalMarkets(fromServiceProviderMarkets: rawMarketGroup.markets))
//
//        }
//
//        let sortedMarketGroups = marketGroups.sorted(by: {
//            $0.id < $1.id
//        })
//
//        self.marketGroupsPublisher.send(sortedMarketGroups)
//
//        self.isLoadingMarketGroups.send(false)
//
//    }

    private func storeMarkets(markets: [Market]) {
        self.store.storeMarketGroupDetailsFromMarkets(markets: markets, onMarketGroup: "MarketKey")

        let marketGroupOrganizers = self.store.marketGroupOrganizersFromGroups(withGroupKey: "MarketKey")

        self.marketGroupOrganizers = marketGroupOrganizers

        self.isCompetitionBettingAvailablePublisher.send(self.marketGroupOrganizers.isNotEmpty)

        self.refreshPublisher.send()
        self.isLoadingPublisher.send(false)
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

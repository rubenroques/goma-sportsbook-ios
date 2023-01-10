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
    
    var grayedOutSelectionsPublisher: CurrentValueSubject<BetBuilderGrayoutsState, Never>  = .init(BetBuilderGrayoutsState.defaultState)

    var isBetBuilder: Bool {
        return marketGroupId == "Bet_Builder"
    }
    
    private var marketGroupId: String

    private var marketGroupsDetailsRegister: EndpointPublisherIdentifiable?
    private var store: MarketGroupDetailsStore

    var availableMarkets: [Market] = []

    private var cancellables: Set<AnyCancellable> = []

    init(match: Match, marketGroupId: String, store: MarketGroupDetailsStore = MarketGroupDetailsStore()) {
        self.match = match
        self.marketGroupId = marketGroupId
        self.store = store
    
        // Listen to
        Env.betslipManager.bettingTicketsPublisher
            .receive(on: DispatchQueue.main)
            .map(Array.init)
            .removeDuplicates(by: { previous, current in
                let result = previous.map(\.id).elementsEqual(current.map(\.id))
                return result
            })
            .sink { [weak self] _ in
                self?.fetchGrayedOutSelections()
            }
            .store(in: &cancellables)
        
    }

    func fetchMarketGroupDetails() {

//        if let marketGroupsDetailsRegister = self.marketGroupsDetailsRegister {
//            Env.everyMatrixClient.manager.unregisterFromEndpoint(endpointPublisherIdentifiable: marketGroupsDetailsRegister)
//        }
//
//        let language = "en"
//        let endpoint = TSRouter.matchMarketGroupDetailsPublisher(operatorId: Env.appSession.operatorId,
//                                                                 language: language,
//                                                                 matchId: self.match.id,
//                                                                 marketGroupName: marketGroupId)
//
//        Env.everyMatrixClient.manager
//            .registerOnEndpoint(endpoint, decodingType: EveryMatrix.Aggregator.self)
//            .sink(receiveCompletion: { [weak self] completion in
//                switch completion {
//                case .failure:
//                    print("Error retrieving data!")
//                case .finished:
//                    print("Data retrieved!")
//                }
//                self?.isLoadingPublisher.send(false)
//            }, receiveValue: { [weak self] state in
//                switch state {
//                case .connect(let publisherIdentifiable):
//                    print("SportsViewModel competitionsMatchesPublisher connect")
//                    self?.marketGroupsDetailsRegister = publisherIdentifiable
//                case .initialContent(let aggregator):
//                    print("SportsViewModel competitionsMatchesPublisher initialContent")
//                    self?.storeMarketGroupDetails(fromAggregator: aggregator)
//                case .updatedContent(let aggregatorUpdates):
//                    print("SportsViewModel competitionsMatchesPublisher updatedContent")
//                    self?.updateMarketGroupDetails(fromAggregator: aggregatorUpdates)
//                case .disconnect:
//                    print("SportsViewModel competitionsMatchesPublisher disconnect")
//                }
//            })
//            .store(in: &cancellables)

        // TEMP

        self.storeMarketGroupDetailsFromMarkets(markets: self.availableMarkets)
        //self.isLoadingPublisher.send(false)
    }

    func storeMarketGroupDetailsFromMarkets(markets: [Market]) {
        self.store.storeMarketGroupDetailsFromMarkets(markets: markets, onMarketGroup: "MarketKey")

        let marketGroupOrganizers = self.store.marketGroupOrganizersFromFilters(withGroupKey: "MarketKey", match: match, markets: markets)

        self.marketGroupOrganizersPublisher.send(marketGroupOrganizers)
        self.isLoadingPublisher.send(false)
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

    func fetchGrayedOutSelections() {
        
        if !self.isBetBuilder {
            return
        }
        
        let tickets = Env.betslipManager.bettingTicketsPublisher.value
        let ticketSelections = tickets
            .map({ EveryMatrix.BetslipTicketSelection(id: $0.id, currentOdd: $0.decimalOdd) })
        
        if ticketSelections.isEmpty {
            self.grayedOutSelectionsPublisher.send(BetBuilderGrayoutsState.defaultState)
            print("grayoutdebug no tickets, send empty")
            return
        }
        
        let route = TSRouter.getSelectionsGreyout(tickets: ticketSelections)
        Env.everyMatrixClient.manager.getModel(router: route, decodingType: BetBuilderGrayoutsState.self)
            .sink { completion in
                print("GrayoutDebug \(completion)")
                
            } receiveValue: { [weak self] betBuilderGrayoutsState in
                print("grayoutdebug getSelectionsGreyout response")
                self?.grayedOutSelectionsPublisher.send(betBuilderGrayoutsState)
            }
            .store(in: &cancellables)

    }
    
    func firstMarket() -> Market? {
        return self.store.firstMarket()
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

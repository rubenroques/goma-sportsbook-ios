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
        self.storeMarketGroupDetailsFromMarkets(markets: self.availableMarkets)
    }

    func storeMarketGroupDetailsFromMarkets(markets: [Market]) {
        self.store.storeMarketGroupDetailsFromMarkets(markets: markets, onMarketGroup: "MarketKey")

        let marketGroupOrganizers = self.store.marketGroupOrganizersFromFilters(withGroupKey: "MarketKey", match: match, markets: markets)

        self.marketGroupOrganizersPublisher.send(marketGroupOrganizers)
        self.isLoadingPublisher.send(false)
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

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
    
    var marketGroupId: String

    private var store: MarketGroupDetailsStore

    var availableMarkets: [Market] = []
    
    var hasPopularBetbuilder: Bool = false
    
    var betbuilderCellViewModels: [BetbuilderSelectionCellViewModel] = []
    var betbuilderLineCellViewModels: [BetbuilderLineCellViewModel] = []

    private var cancellables: Set<AnyCancellable> = []

    init(match: Match, marketGroupId: String, store: MarketGroupDetailsStore = MarketGroupDetailsStore()) {
        self.match = match
        self.marketGroupId = marketGroupId
        self.store = store
        
        if TargetVariables.hasPopularBetbuilder && marketGroupId == "Popular" {
            self.hasPopularBetbuilder = true
        }
        else {
            self.hasPopularBetbuilder = false
        }
    
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
        
//        self.createPopularBetbuilderDummyContent()
    }
    
    func createPopularBetbuilderDummyContent() {
        // Create sample betbuilder options for demonstration
        let betSelections1 = createSampleBetSelections(
            titles: ["Doumbia, Kamory 2+", "Stade Rennas Football Club (0:3)", "Stade Rennas Football Club ou Match nul"],
            subtitles: ["Buts du joueur (Remboursé si remplaçant)", "Handicap", "1er buteur"]
        )
        
        let betSelections2 = createSampleBetSelections(
            titles: ["Match nul", "Plus de 2.5 buts", "Les deux équipes marquent"],
            subtitles: ["Résultat du match", "Total de buts", "Les deux équipes marquent"]
        )
        
        let betSelections3 = createSampleBetSelections(
            titles: ["Moins de 10.5 corners", "Stade Rennas gagne", "Doumbia marque"],
            subtitles: ["Total de corners", "Résultat du match", "Buteur"]
        )
        
        // Create view models for each betbuilder option
        let betbuilderOptions = [
            BetbuilderSelectionCellViewModel(betSelections: betSelections1),
            BetbuilderSelectionCellViewModel(betSelections: betSelections2),
            BetbuilderSelectionCellViewModel(betSelections: betSelections3)
        ]
        
        self.betbuilderCellViewModels = betbuilderOptions
    }
    
    func getViewModelForPopularBetbuilder(withIndex index: Int? = nil) -> [BetbuilderSelectionCellViewModel] {
        
        if let index {
            if let viewModel = self.betbuilderCellViewModels[safe: index] {
                return [viewModel]
            }
            
            return []
        }
        return self.betbuilderCellViewModels
    }
    
    func getBetbuilderLineCellViewModel(withIndex index: Int, presentationMode: ClientManagedHomeViewTemplateDataSource.HighlightsPresentationMode) -> BetbuilderLineCellViewModel {
        
        switch presentationMode {
        case .onePerLine:
            if let viewModel = self.betbuilderLineCellViewModels[safe: index] {
                return viewModel
            }
            else {
                let options = self.getViewModelForPopularBetbuilder(withIndex: index)
                
                let viewModel = BetbuilderLineCellViewModel(betBuilderoptions: options)
                
                self.betbuilderLineCellViewModels.append(viewModel)
                
                return viewModel
            }
        case .multiplesPerLineByType:
            if let viewModel = self.betbuilderLineCellViewModels[safe: index] {
                return viewModel
            }
            else {
                let options = self.getViewModelForPopularBetbuilder()
                
                let viewModel = BetbuilderLineCellViewModel(betBuilderoptions: options)
                
                self.betbuilderLineCellViewModels.append(viewModel)
                
                return viewModel
            }
        }
        
    }
    
    func shouldShowPopularBetbuilderForSport() -> Bool {
        
        let sportIdCode = match.sport.alphaId
        
        let matchStatus = match.status
        
        return false
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

    }
    
    func firstMarket() -> Market? {
        return self.store.firstMarket()
    }
    
    func getMarketById(marketId: String) -> Market? {
        // First check if the market is in the availableMarkets array
        if let market = availableMarkets.first(where: { $0.id == marketId }) {
            return market
        }
                
        // If not found in availableMarkets, check in the match's markets
        return match.markets.first(where: {
            $0.id == marketId
        })
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

    // Helper method to create sample bet selections
    private func createSampleBetSelections(titles: [String], subtitles: [String]) -> [BettingTicket] {
        var betSelections = [BettingTicket]()
        
        for i in 0..<min(titles.count, subtitles.count) {
            let ticket = BettingTicket(id: "",
                                       outcomeId: "",
                                       marketId: "",
                                       matchId: "",
                                       decimalOdd: 0.0,
                                       isAvailable: true,
                                       matchDescription: "",
                                       marketDescription: subtitles[i],
                                       outcomeDescription: titles[i],
                                       homeParticipantName: nil,
                                       awayParticipantName: nil,
                                       sportIdCode: nil)
            betSelections.append(ticket)
        }
        
        return betSelections
    }
}

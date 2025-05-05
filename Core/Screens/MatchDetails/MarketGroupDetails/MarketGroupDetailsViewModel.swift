//
//  MarketGroupDetailsViewModel.swift
//  Sportsbook
//
//  Created by Ruben Roques on 16/03/2022.
//

import Foundation
import Combine
import ServicesProvider

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
    
    var betbuilderPresentationMode: ClientManagedHomeViewTemplateDataSource.HighlightsPresentationMode = .multiplesPerLineByType
    
    var shouldShowBetbuilderSection: Bool = false

    var hasPopularBetbuilder: Bool = false
    
    var betbuilderCellViewModels: [BetbuilderSelectionCellViewModel] = []
    var betbuilderLineCellViewModels: [BetbuilderLineCellViewModel] = []
    
    var shouldReloadDataPublisher: PassthroughSubject<Void, Never> = .init()

    private var cancellables: Set<AnyCancellable> = []

    init(match: Match, marketGroupId: String, store: MarketGroupDetailsStore = MarketGroupDetailsStore()) {
        self.match = match
        self.marketGroupId = marketGroupId
        self.store = store
        
        // Force expand Popular bet builder group
        if TargetVariables.hasFeatureEnabled(feature: .popularBetBuilder) && marketGroupId == "Popular" {
            self.hasPopularBetbuilder = true
        }
        else {
            self.hasPopularBetbuilder = false
        }
        
        self.betbuilderPresentationMode = TargetVariables.popularBetbuilderPresentationMode
    
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
    
    func getViewModelForPopularBetbuilder(withIndex index: Int? = nil) -> [BetbuilderSelectionCellViewModel] {
        
        if let index {
            if let viewModel = self.betbuilderCellViewModels[safe: index] {
                return [viewModel]
            }
            
            return []
        }
        return self.betbuilderCellViewModels
    }
    
    func getBetbuilderLineCellViewModel(
        withIndex index: Int) -> BetbuilderLineCellViewModel {
        
        switch self.betbuilderPresentationMode {
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
        
        let sportCodes = TargetVariables.supportedSportCodesForBetbuilder
        
        let sportIdCode = self.match.sport.alphaId ?? ""
        
        let matchStatus = self.match.status
        
        let isBetbuilderSportAllowed = sportCodes.contains(sportIdCode)
        
        if isBetbuilderSportAllowed && matchStatus.isPreLive {
            
            return true
        }
        
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
    
    func setupRecommendedBetBuilder(recommendedBetBuilder: [RecommendedBetBuilder]) {
        
        var betbuilderLineCellViewModels = [BetbuilderLineCellViewModel]()
        
        switch self.betbuilderPresentationMode {
        case .onePerLine:
            for betbuilder in recommendedBetBuilder {
                
                let bettingTickets = betbuilder.selections.map({
                    return ServiceProviderModelMapper.bettingTicket(fromRecommendedBetbuilderSelection: $0)
                })
                
                var mappedBettingTickets = [BettingTicket]()
                
                for bettingTicket in bettingTickets {
                    
                    if let marketFound = self.getMarketById(marketId: bettingTicket.marketId) {
                        
                        let outcomeFound = marketFound.outcomes.filter({
                            $0.id == bettingTicket.outcomeId
                        }).first
                        
                        let newBettingTicket = BettingTicket(
                            id: bettingTicket.id,
                            outcomeId: bettingTicket.outcomeId,
                            marketId: bettingTicket.marketId,
                            matchId: bettingTicket.matchId,
                            decimalOdd: bettingTicket.decimalOdd,
                            isAvailable: bettingTicket.isAvailable,
                            matchDescription: bettingTicket.matchDescription,
                            marketDescription: marketFound.name,
                            outcomeDescription: outcomeFound?.translatedName ?? bettingTicket.outcomeDescription,
                            homeParticipantName: bettingTicket.homeParticipantName,
                            awayParticipantName: bettingTicket.awayParticipantName,
                            sportIdCode: bettingTicket.sportIdCode
                        )
                        
                        mappedBettingTickets.append(newBettingTicket)
                    }
                }
                
                if mappedBettingTickets.count == 3 {
                    let betbuilderCellViewModel = BetbuilderSelectionCellViewModel(betSelections: mappedBettingTickets)
                    
                    let betbuilderLineCellViewModel = BetbuilderLineCellViewModel(betBuilderoptions: [betbuilderCellViewModel])
                    
                    betbuilderLineCellViewModels.append(betbuilderLineCellViewModel)
                }
            }
        case .multiplesPerLineByType:
            
            var betbuilderSelectionCellViewModels = [BetbuilderSelectionCellViewModel]()
            
            for betbuilder in recommendedBetBuilder {
                
                let bettingTickets = betbuilder.selections.map({
                    return ServiceProviderModelMapper.bettingTicket(fromRecommendedBetbuilderSelection: $0)
                })
                
                var mappedBettingTickets = [BettingTicket]()
                
                for bettingTicket in bettingTickets {
                    
                    if let marketFound = self.getMarketById(marketId: bettingTicket.marketId) {
                        
                        let outcomeFound = marketFound.outcomes.filter({
                            $0.id == bettingTicket.outcomeId
                        }).first
                        
                        let newBettingTicket = BettingTicket(
                            id: bettingTicket.id,
                            outcomeId: bettingTicket.outcomeId,
                            marketId: bettingTicket.marketId,
                            matchId: bettingTicket.matchId,
                            decimalOdd: bettingTicket.decimalOdd,
                            isAvailable: bettingTicket.isAvailable,
                            matchDescription: bettingTicket.matchDescription,
                            marketDescription: marketFound.name,
                            outcomeDescription: outcomeFound?.translatedName ?? bettingTicket.outcomeDescription,
                            homeParticipantName: bettingTicket.homeParticipantName,
                            awayParticipantName: bettingTicket.awayParticipantName,
                            sportIdCode: bettingTicket.sportIdCode
                        )
                        
                        mappedBettingTickets.append(newBettingTicket)
                    }
                }
                
                if mappedBettingTickets.count == 3 {
                    let betbuilderCellViewModel = BetbuilderSelectionCellViewModel(betSelections: mappedBettingTickets)
                    
                    betbuilderSelectionCellViewModels.append(betbuilderCellViewModel)
                }
            }
            
            if betbuilderSelectionCellViewModels.isNotEmpty {
                let betbuilderLineCellViewModel = BetbuilderLineCellViewModel(betBuilderoptions: betbuilderSelectionCellViewModels)
                
                betbuilderLineCellViewModels.append(betbuilderLineCellViewModel)
            }
        }
        
        self.checkAvailableBetbuilderSelections(betbuilderLineCellViewModels: betbuilderLineCellViewModels)
        
    }
    
    private func checkAvailableBetbuilderSelections(betbuilderLineCellViewModels: [BetbuilderLineCellViewModel]) {
        // Create a structure to track validation results with original indices
        var validationResults = [(lineCellViewModel: BetbuilderLineCellViewModel, validOptions: [(option: BetbuilderSelectionCellViewModel, originalIndex: Int)])]()
        
        // Initialize validation results for each line
        for lineCellViewModel in betbuilderLineCellViewModels {
            validationResults.append((lineCellViewModel, []))
        }
        
        // Create a dispatch group for synchronization
        let group = DispatchGroup()
        
        for (lineIndex, lineCellViewModel) in betbuilderLineCellViewModels.enumerated() {
            
            for (optionIndex, betbuilderOption) in lineCellViewModel.betBuilderOptions.enumerated() {
                
                switch betbuilderOption.fetchedBetbuilderValuePublisher.value {
                case .fetched(let alertType):
                    
                    if case .success = alertType {
                        validationResults[lineIndex].validOptions.append((betbuilderOption, optionIndex))
                    }
                case .notFetched:
                    
                    group.enter()
                    
                    let cancellable = betbuilderOption.fetchedBetbuilderValuePublisher
                        .filter { state in
                            if case .fetched = state {
                                return true
                            }
                            return false
                        } // Only proceed when fetched
                        .first() // Take only the first fetched value
                        .sink { [weak self, weak betbuilderOption, lineIndex, optionIndex] state in
                            defer {
                                group.leave() // Always leave the group
                            }
                            
                            guard let self = self, let betbuilderOption = betbuilderOption else {
                                return
                            }
                            
                            // Check if valid (success)
                            if case .fetched(let alertType) = state, case .success = alertType {
                                validationResults[lineIndex].validOptions.append((betbuilderOption, optionIndex))
                            }
                        }
                    
                    self.cancellables.insert(cancellable)
                }
            }
        }
        
        // Wait for all validations to complete
        group.notify(queue: .main) { [weak self] in
            guard let self = self else { return }
            
            var processedLineCellViewModels = [BetbuilderLineCellViewModel]()
            
            for result in validationResults {
                if result.validOptions.isNotEmpty {
                    // Sort the valid options by their original index to preserve order
                    let sortedOptions = result.validOptions.sorted { $0.originalIndex < $1.originalIndex }.map { $0.option }
                    
                    let updatedLine = BetbuilderLineCellViewModel(betBuilderoptions: sortedOptions)
                    processedLineCellViewModels.append(updatedLine)
                }
            }
            
            self.betbuilderLineCellViewModels = processedLineCellViewModels
            
            self.checkBetbuilderAvailability()
        }
    }
    
    private func checkBetbuilderAvailability() {
        
        self.shouldShowBetbuilderSection = self.hasPopularBetbuilder &&
        !self.betbuilderLineCellViewModels.isEmpty && self.shouldShowPopularBetbuilderForSport()
        
        self.shouldReloadDataPublisher.send()
        
    }
}

extension MarketGroupDetailsViewModel {

    func numberOfSections() -> Int {
        return self.shouldShowBetbuilderSection ? 2 : 1
//        return 1
    }

    func numberOfRows(section: Int) -> Int {
        if self.shouldShowBetbuilderSection && section == 0 {
            switch self.betbuilderPresentationMode {
            case .onePerLine:
                return self.betbuilderLineCellViewModels.count
            case .multiplesPerLineByType:
                return 1
            }
        }
        
        let count = self.marketGroupOrganizersPublisher.value.count
        return count
    }

    func marketGroupOrganizer(forRow row: Int) -> MarketGroupOrganizer? {
        return self.marketGroupOrganizersPublisher.value[safe: row]
    }

}

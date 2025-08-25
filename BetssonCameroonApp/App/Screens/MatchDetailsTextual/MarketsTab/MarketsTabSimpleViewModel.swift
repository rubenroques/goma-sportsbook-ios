//
//  MarketsTabSimpleViewModel.swift
//  Sportsbook
//
//  Created on 2025-07-16.
//

import Foundation
import Combine
import ServicesProvider
import GomaUI

class MarketsTabSimpleViewModel: MarketsTabSimpleViewModelProtocol {
    
    // MARK: - Properties
    
    let marketGroupId: String
    let marketGroupTitle: String
    
    // MARK: - Private Properties
    
    private let eventId: String
    private let marketGroupKey: String
    private let servicesProvider: ServicesProvider.Client
    
    private let isLoadingSubject = CurrentValueSubject<Bool, Never>(false)
    private let errorSubject = CurrentValueSubject<String?, Never>(nil)
    private let marketGroupsSubject = CurrentValueSubject<[MarketGroupWithIcons], Never>([])
    
    private var cancellables = Set<AnyCancellable>()
    
    // Callbacks
    var onOutcomeSelected: ((MarketGroupWithIcons, String) -> Void)?
    var onOutcomeDeselected: ((MarketGroupWithIcons, String) -> Void)?

    // MARK: - Initialization
    
    init(
        marketGroupId: String,
        marketGroupTitle: String,
        eventId: String,
        marketGroupKey: String,
        servicesProvider: ServicesProvider.Client = Env.servicesProvider
    ) {
        self.marketGroupId = marketGroupId
        self.marketGroupTitle = marketGroupTitle
        self.eventId = eventId
        self.marketGroupKey = marketGroupKey
        self.servicesProvider = servicesProvider
        
        // Start loading markets
        loadMarkets()
    }
    
    // MARK: - Publishers
    
    var isLoadingPublisher: AnyPublisher<Bool, Never> {
        isLoadingSubject.eraseToAnyPublisher()
    }
    
    var errorPublisher: AnyPublisher<String?, Never> {
        errorSubject.eraseToAnyPublisher()
    }
    
    var marketGroupsPublisher: AnyPublisher<[MarketGroupWithIcons], Never> {
        marketGroupsSubject.eraseToAnyPublisher()
    }
    
    // MARK: - Methods
    
    func loadMarkets() {
        isLoadingSubject.send(true)
        errorSubject.send(nil)
        
        // Subscribe to market group details via WebSocket
        servicesProvider.subscribeToMarketGroupDetails(eventId: eventId, marketGroupKey: marketGroupKey)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.errorSubject.send("Failed to load markets: \(error.localizedDescription)")
                    self?.isLoadingSubject.send(false)
                }
            } receiveValue: { [weak self] subscribableContent in
                self?.handleMarketGroupDetailsContent(subscribableContent)
            }
            .store(in: &cancellables)
    }
    
    func refreshMarkets() {
        loadMarkets()
    }
    
    func handleOutcomeSelection(marketGroupId: String, lineId: String, outcomeType: OutcomeType, isSelected: Bool) {
        print("Outcome selection - Group: \(marketGroupId), Line: \(lineId), Type: \(outcomeType)")
                
        if let marketGroup = marketGroupsSubject.value.first(where: {
            $0.marketGroup.id == marketGroupId
        }) {
            if isSelected {
                onOutcomeSelected?(marketGroup, lineId)
            }
            else {
                onOutcomeDeselected?(marketGroup, lineId)
            }
        }
        
    }
    
    // MARK: - Private Methods
    
    private func handleMarketGroupDetailsContent(_ content: SubscribableContent<[ServicesProvider.Market]>) {
        switch content {
        case .connected(let subscription):
            print("✅ Connected to market group details: \(subscription.id)")
            // Keep loading state active until we get content
            
        case .contentUpdate(let markets):
            // print("📊 Received \(markets.count) markets for group: \(marketGroupId)")
            
            // Group markets by type and convert to MarketGroupData
            let mappedMarkets = ServiceProviderModelMapper.markets(fromServiceProviderMarkets: markets)
            let marketGroups = groupMarketsByType(mappedMarkets)
            marketGroupsSubject.send(marketGroups)
            isLoadingSubject.send(false)
            
        case .disconnected:
            print("❌ Disconnected from market group details")
            // Keep existing data but stop loading
            isLoadingSubject.send(false)
        }
    }
    
    private func groupMarketsByType(_ markets: [Market]) -> [MarketGroupWithIcons] {
        // Group markets by typeId
        let groupedMarkets = Dictionary(grouping: markets) { market in
            market.marketTypeId ?? market.id
        }
        
        // Convert each group to MarketGroupWithIcons
        let marketGroups = groupedMarkets.compactMap { (typeId, marketsInGroup) -> MarketGroupWithIcons? in
            guard let firstMarket = marketsInGroup.first else { return nil }
            
            // Sort markets within group (e.g., by nameDigit1 for Over/Under)
            let sortedMarkets = marketsInGroup.sorted { market1, market2 in
                let id1 = market1.id
                let id2 = market2.id
                return id1 < id2
            }
            
            // Use MarketOutcomesMultiLineViewModel's existing factory method
            let marketLines = Self.createMarketLinesFromMarkets(marketsInGroup)
            
            // Create market group data with empty groupTitle to hide MarketOutcomesMultiLineView title
            let marketGroup = MarketGroupData(
                id: typeId,
                groupTitle: nil, // Hide title in MarketOutcomesMultiLineView
                marketLines: marketLines
            )

            return MarketGroupWithIcons(
                marketGroup: marketGroup,
                icons: [],
                groupName: firstMarket.marketTypeName ?? firstMarket.name // Title for collection view cell
            )
        }
        
        // Sort groups by position or name
        return marketGroups.sorted { group1, group2 in
            return group1.groupName < group2.groupName
        }
    }
    
    private static func createMarketLinesFromMarkets(_ markets: [Market]) -> [MarketLineData] {
        return markets.compactMap { market in
            guard !market.outcomes.isEmpty else { return nil }
            
            let outcomes = market.outcomes.map { outcome in
                MarketOutcomeData(
                    id: outcome.id,
                    bettingOfferId: outcome.bettingOffer.id,
                    title: outcome.translatedName,
                    value: OddFormatter.formatOdd(withValue: outcome.bettingOffer.decimalOdd),
                    oddsChangeDirection: .none,
                    isSelected: false,
                    isDisabled: !outcome.bettingOffer.isAvailable
                )
            }
            
            // Determine line structure based on number of outcomes
            let lineType: MarketLineType = outcomes.count == 3 ? .threeColumn : .twoColumn
            let displayMode: MarketDisplayMode = outcomes.count == 3 ? .triple : .double
            
            return MarketLineData(
                id: market.id,
                leftOutcome: outcomes.first,
                middleOutcome: outcomes.count == 3 ? outcomes[1] : nil,
                rightOutcome: outcomes.last,
                displayMode: displayMode,
                lineType: lineType
            )
        }
    }
    
}

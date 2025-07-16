//
//  MatchDetailsTextualViewModel.swift
//  Sportsbook
//
//  Created on 2025-07-16.
//

import Foundation
import Combine
import GomaUI

public class MatchDetailsTextualViewModel: MatchDetailsTextualViewModelProtocol {
    
    // MARK: - Private Properties
    
    private let isLoadingSubject = CurrentValueSubject<Bool, Never>(false)
    private let errorSubject = CurrentValueSubject<String?, Never>(nil)
    private let navigationRequestSubject = PassthroughSubject<MatchDetailsNavigationAction, Never>()
    private let statisticsVisibilitySubject = CurrentValueSubject<Bool, Never>(false)
    
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Child ViewModels (Vertical Pattern)
    
    // Step 2: MultiWidgetToolbarView
    public let multiWidgetToolbarViewModel: MultiWidgetToolbarViewModelProtocol
    
    // Step 3: MatchDateNavigationBarView
    public let matchDateNavigationBarViewModel: MatchDateNavigationBarViewModelProtocol
    
    // Step 4: MatchHeaderCompactView
    public let matchHeaderCompactViewModel: MatchHeaderCompactViewModelProtocol
    
    // Step 5: StatisticsWidgetView (collapsible)
    public let statisticsWidgetViewModel: StatisticsWidgetViewModelProtocol
    
    // Step 6: MarketGroupSelectorTabView
    public let marketGroupSelectorTabViewModel: MarketGroupSelectorTabViewModelProtocol
    
    // These will be added step by step as we integrate each component
    
    // MARK: - Initialization
    
    public init() {
        // Create child ViewModels (Vertical Pattern)
        self.multiWidgetToolbarViewModel = MockMultiWidgetToolbarViewModel.defaultMock
        self.matchDateNavigationBarViewModel = MockMatchDateNavigationBarViewModel.liveMock
        self.matchHeaderCompactViewModel = MockMatchHeaderCompactViewModel.default
        self.statisticsWidgetViewModel = MockStatisticsWidgetViewModel.footballMatch
        self.marketGroupSelectorTabViewModel = MockMarketGroupSelectorTabViewModel.standardSportsMarkets
        
        setupBindings()
        loadMatchDetails()
    }
    
    // MARK: - Publishers
    
    public var isLoadingPublisher: AnyPublisher<Bool, Never> {
        isLoadingSubject.eraseToAnyPublisher()
    }
    
    public var errorPublisher: AnyPublisher<String?, Never> {
        errorSubject.eraseToAnyPublisher()
    }
    
    public var navigationRequestPublisher: AnyPublisher<MatchDetailsNavigationAction, Never> {
        navigationRequestSubject.eraseToAnyPublisher()
    }
    
    public var statisticsVisibilityPublisher: AnyPublisher<Bool, Never> {
        statisticsVisibilitySubject.eraseToAnyPublisher()
    }
    
    // MARK: - Methods
    
    public func loadMatchDetails() {
        isLoadingSubject.send(true)
        
        // Simulate async loading
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.isLoadingSubject.send(false)
        }
    }
    
    public func toggleStatistics() {
        let currentVisibility = statisticsVisibilitySubject.value
        statisticsVisibilitySubject.send(!currentVisibility)
    }
    
    public func refresh() {
        errorSubject.send(nil)
        loadMatchDetails()
    }
    
    // MARK: - Private Methods
    
    private func setupBindings() {
        // Setup communication between child ViewModels
        
        // Step 4: Wire up MatchHeaderCompactView statistics button to toggle StatisticsWidgetView
        matchHeaderCompactViewModel.onStatisticsTapped = { [weak self] in
            self?.toggleStatistics()
        }
        
        // This will be expanded as we add each component
    }
}
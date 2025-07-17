//
//  MockMatchDetailsTextualViewModel.swift
//  Sportsbook
//
//  Created on 2025-07-16.
//

import Foundation
import Combine
import GomaUI

public class MockMatchDetailsTextualViewModel: MatchDetailsTextualViewModelProtocol {
    
    // MARK: - Private Properties
    
    private let isLoadingSubject = CurrentValueSubject<Bool, Never>(false)
    private let errorSubject = CurrentValueSubject<String?, Never>(nil)
    
    private let statisticsVisibilitySubject = CurrentValueSubject<Bool, Never>(false)
    private let marketGroupSelectorTabViewModelSubject = CurrentValueSubject<MarketGroupSelectorTabViewModelProtocol?, Never>(nil)
    
    // MARK: - Child ViewModels (Vertical Pattern)
    
    public let multiWidgetToolbarViewModel: MultiWidgetToolbarViewModelProtocol
    
    public let matchDateNavigationBarViewModel: MatchDateNavigationBarViewModelProtocol
    
    public let matchHeaderCompactViewModel: MatchHeaderCompactViewModelProtocol
    
    public let statisticsWidgetViewModel: StatisticsWidgetViewModelProtocol
    
    public let marketGroupSelectorTabViewModel: MarketGroupSelectorTabViewModelProtocol
    
    // MARK: - Initialization
    
    public init() {
        // Create child ViewModels (Vertical Pattern)
        self.multiWidgetToolbarViewModel = MockMultiWidgetToolbarViewModel.defaultMock
        self.matchDateNavigationBarViewModel = MockMatchDateNavigationBarViewModel.liveMock
        self.matchHeaderCompactViewModel = MockMatchHeaderCompactViewModel.default
        self.statisticsWidgetViewModel = MockStatisticsWidgetViewModel.footballMatch
        self.marketGroupSelectorTabViewModel = MockMarketGroupSelectorTabViewModel.standardSportsMarkets
        marketGroupSelectorTabViewModelSubject.send(self.marketGroupSelectorTabViewModel)
        
        // Setup bindings
        setupBindings()
    }
    
    private func setupBindings() {
        // Wire up MatchHeaderCompactView statistics button to toggle StatisticsWidgetView
        matchHeaderCompactViewModel.onStatisticsTapped = { [weak self] in
            self?.toggleStatistics()
        }
    }
    
    // MARK: - Factory Methods
    
    public static var defaultMock: MockMatchDetailsTextualViewModel {
        return MockMatchDetailsTextualViewModel()
    }
    
    public static var loadingMock: MockMatchDetailsTextualViewModel {
        let mock = MockMatchDetailsTextualViewModel()
        mock.isLoadingSubject.send(true)
        return mock
    }
    
    public static var errorMock: MockMatchDetailsTextualViewModel {
        let mock = MockMatchDetailsTextualViewModel()
        mock.errorSubject.send("Failed to load match details")
        return mock
    }
    
    public static var statisticsVisibleMock: MockMatchDetailsTextualViewModel {
        let mock = MockMatchDetailsTextualViewModel()
        mock.statisticsVisibilitySubject.send(true)
        return mock
    }
    
    // MARK: - Publishers
    
    public var isLoadingPublisher: AnyPublisher<Bool, Never> {
        isLoadingSubject.eraseToAnyPublisher()
    }
    
    public var errorPublisher: AnyPublisher<String?, Never> {
        errorSubject.eraseToAnyPublisher()
    }
    
    public var statisticsVisibilityPublisher: AnyPublisher<Bool, Never> {
        statisticsVisibilitySubject.eraseToAnyPublisher()
    }
    
    public var marketGroupSelectorTabViewModelPublisher: AnyPublisher<MarketGroupSelectorTabViewModelProtocol, Never> {
        marketGroupSelectorTabViewModelSubject
            .compactMap { $0 }
            .eraseToAnyPublisher()
    }
    
    // MARK: - Methods
    
    public func loadMatchDetails() {
        isLoadingSubject.send(true)
        
        // Simulate async loading
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
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
    
    // MARK: - Test Helper Methods
    
    public func simulateError() {
        errorSubject.send("Mock error for testing")
    }
    
    public func simulateLoading() {
        isLoadingSubject.send(true)
    }
    
    public func simulateLoadingComplete() {
        isLoadingSubject.send(false)
    }
}

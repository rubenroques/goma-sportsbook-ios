//
//  MarketsTabSimpleViewModel.swift
//  Sportsbook
//
//  Created on 2025-07-16.
//

import Foundation
import Combine

public class MarketsTabSimpleViewModel: MarketsTabSimpleViewModelProtocol {
    
    // MARK: - Properties
    
    public let marketGroupId: String
    public let marketGroupTitle: String
    
    // MARK: - Private Properties
    
    private let isLoadingSubject = CurrentValueSubject<Bool, Never>(false)
    private let errorSubject = CurrentValueSubject<String?, Never>(nil)
    private let marketsSubject = CurrentValueSubject<[MarketData], Never>([])
    
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    
    public init(marketGroupId: String, marketGroupTitle: String) {
        self.marketGroupId = marketGroupId
        self.marketGroupTitle = marketGroupTitle
        
        // Start loading markets
        loadMarkets()
    }
    
    // MARK: - Publishers
    
    public var isLoadingPublisher: AnyPublisher<Bool, Never> {
        isLoadingSubject.eraseToAnyPublisher()
    }
    
    public var errorPublisher: AnyPublisher<String?, Never> {
        errorSubject.eraseToAnyPublisher()
    }
    
    public var marketsPublisher: AnyPublisher<[MarketData], Never> {
        marketsSubject.eraseToAnyPublisher()
    }
    
    // MARK: - Methods
    
    public func loadMarkets() {
        isLoadingSubject.send(true)
        errorSubject.send(nil)
        
        // Simulate async loading
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            
            // Generate sample markets based on market group
            let markets = self.generateSampleMarkets()
            self.marketsSubject.send(markets)
            self.isLoadingSubject.send(false)
        }
    }
    
    public func refreshMarkets() {
        loadMarkets()
    }
    
    public func selectMarket(id: String) {
        // Handle market selection
        print("Selected market: \(id) in group: \(marketGroupId)")
    }
    
    // MARK: - Private Methods
    
    private func generateSampleMarkets() -> [MarketData] {
        return [MarketData(), MarketData()]
    }
}

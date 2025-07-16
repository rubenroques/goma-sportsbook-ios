//
//  MockMarketsTabSimpleViewModel.swift
//  Sportsbook
//
//  Created on 2025-07-16.
//

import Foundation
import Combine

public class MockMarketsTabSimpleViewModel: MarketsTabSimpleViewModelProtocol {
    
    // MARK: - Properties
    
    public let marketGroupId: String
    public let marketGroupTitle: String
    
    // MARK: - Private Properties
    
    private let isLoadingSubject = CurrentValueSubject<Bool, Never>(false)
    private let errorSubject = CurrentValueSubject<String?, Never>(nil)
    private let marketsSubject = CurrentValueSubject<[MarketData], Never>([])
    
    // MARK: - Initialization
    
    public init(marketGroupId: String, marketGroupTitle: String) {
        self.marketGroupId = marketGroupId
        self.marketGroupTitle = marketGroupTitle

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
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            // TODO
            self?.isLoadingSubject.send(false)
        }
    }
    
    public func refreshMarkets() {
        loadMarkets()
    }
    
    public func selectMarket(id: String) {
        print("Mock: Selected market \(id) in group \(marketGroupId)")
    }
    
    // MARK: - Private Methods
    
    // MARK: - Factory Methods
    
    public static func defaultMock(for marketGroupId: String, title: String) -> MockMarketsTabSimpleViewModel {
        return MockMarketsTabSimpleViewModel(marketGroupId: marketGroupId, marketGroupTitle: title)
    }
    
}

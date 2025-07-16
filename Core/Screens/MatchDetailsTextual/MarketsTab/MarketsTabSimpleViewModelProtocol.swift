//
//  MarketsTabSimpleViewModelProtocol.swift
//  Sportsbook
//
//  Created on 2025-07-16.
//

import Foundation
import Combine

public protocol MarketsTabSimpleViewModelProtocol: AnyObject {
    
    // MARK: - Properties
    
    /// The market group ID this view model represents
    var marketGroupId: String { get }
    
    /// The title of the market group
    var marketGroupTitle: String { get }
    
    // MARK: - Publishers
    
    /// Published when the view model is loading data
    var isLoadingPublisher: AnyPublisher<Bool, Never> { get }
    
    /// Published when an error occurs
    var errorPublisher: AnyPublisher<String?, Never> { get }
    
    /// Published when markets data is available
    var marketsPublisher: AnyPublisher<[MarketData], Never> { get }
    
    // MARK: - Methods
    
    /// Load markets data for this market group
    func loadMarkets()
    
    /// Refresh markets data
    func refreshMarkets()
    
    /// Handle market selection
    func selectMarket(id: String)
}

// MARK: - Data Models

public struct MarketData: Equatable, Hashable {
    
}

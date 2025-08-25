//
//  MarketsTabSimpleViewModelProtocol.swift
//  Sportsbook
//
//  Created on 2025-07-16.
//

import Foundation
import Combine
import GomaUI

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
    
    /// Published when market groups data is available
    /// Each MarketGroupData represents one collection view cell
    var marketGroupsPublisher: AnyPublisher<[MarketGroupWithIcons], Never> { get }
    
    // MARK: - Methods
    
    /// Load markets data for this market group
    func loadMarkets()
    
    /// Refresh markets data
    func refreshMarkets()
    
    /// Handle outcome selection
    func handleOutcomeSelection(marketGroupId: String, lineId: String, outcomeType: OutcomeType, isSelected: Bool)

}

// MARK: - Data Models

/// Wrapper to include icons with MarketGroupData
public struct MarketGroupWithIcons: Equatable, Hashable {
    public let marketGroup: MarketGroupData
    public let icons: [MarketInfoIcon]
    public let groupName: String
    
    public init(marketGroup: MarketGroupData, icons: [MarketInfoIcon], groupName: String) {
        self.marketGroup = marketGroup
        self.icons = icons
        self.groupName = groupName
    }
}

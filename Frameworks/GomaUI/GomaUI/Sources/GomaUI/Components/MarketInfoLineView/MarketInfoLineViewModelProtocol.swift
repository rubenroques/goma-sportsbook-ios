import Combine
import UIKit

// MARK: - Data Models
public enum MarketInfoIconType: String, CaseIterable, Equatable, Hashable {
    case expressPickShort = "erep_short_info"
    case mostPopular = "most_popular_info"
    case statistics = "stats_info"
    case betBuilder = "bet_builder_info"
    
    public var iconName: String {
        return self.rawValue
    }
}

public struct MarketInfoIcon: Equatable, Hashable {
    public let type: MarketInfoIconType
    public let isVisible: Bool
    
    public init(type: MarketInfoIconType, isVisible: Bool = true) {
        self.type = type
        self.isVisible = isVisible
    }
    
    public var iconName: String {
        return type.iconName
    }
}

public struct MarketInfoData: Equatable, Hashable {
    public let marketName: String
    public let marketCount: Int
    public let marketId: String
    public let marketTypeId: String?
    public let icons: [MarketInfoIcon]
    
    public init(marketName: String, marketCount: Int, icons: [MarketInfoIcon], marketId: String, marketTypeId: String?) {
        self.marketName = marketName
        self.marketCount = marketCount
        self.icons = icons
        self.marketId = marketId
        self.marketTypeId = marketTypeId
    }
}

// MARK: - Display State
public struct MarketInfoLineDisplayState: Equatable {
    public let marketName: String
    public let marketCountText: String
    public let visibleIcons: [MarketInfoIcon]
    public let shouldShowMarketCount: Bool
    
    public init(marketName: String, marketCountText: String, visibleIcons: [MarketInfoIcon], shouldShowMarketCount: Bool) {
        self.marketName = marketName
        self.marketCountText = marketCountText
        self.visibleIcons = visibleIcons
        self.shouldShowMarketCount = shouldShowMarketCount
    }
}

// MARK: - View Model Protocol
public protocol MarketInfoLineViewModelProtocol {
    var displayStatePublisher: AnyPublisher<MarketInfoLineDisplayState, Never> { get }
    var marketNamePillViewModelPublisher: AnyPublisher<MarketNamePillLabelViewModelProtocol, Never> { get }
    var marketInfoData: MarketInfoData { get }

}

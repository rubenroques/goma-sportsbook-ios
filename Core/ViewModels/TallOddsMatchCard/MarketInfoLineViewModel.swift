import GomaUI
import Combine
import UIKit

final class MarketInfoLineViewModel: MarketInfoLineViewModelProtocol {
    
    // MARK: - Private Properties
    private let displayStateSubject: CurrentValueSubject<MarketInfoLineDisplayState, Never>
    private let marketNamePillViewModelSubject: CurrentValueSubject<MarketNamePillLabelViewModelProtocol, Never>
    
    // MARK: - Published Properties
    public var displayStatePublisher: AnyPublisher<MarketInfoLineDisplayState, Never> {
        return displayStateSubject.eraseToAnyPublisher()
    }
    
    public var marketNamePillViewModelPublisher: AnyPublisher<MarketNamePillLabelViewModelProtocol, Never> {
        return marketNamePillViewModelSubject.eraseToAnyPublisher()
    }
    
    private let marketInfoData: MarketInfoData
    
    // MARK: - Initialization
    init(marketInfoData: MarketInfoData) {
        self.marketInfoData = marketInfoData
        
        // Create initial display state
        let initialDisplayState = Self.createDisplayState(from: marketInfoData)
        
        // Create market name pill view model
        let marketNamePillViewModel = Self.createMarketNamePillViewModel(from: marketInfoData)
        
        // Initialize subjects
        self.displayStateSubject = CurrentValueSubject(initialDisplayState)
        self.marketNamePillViewModelSubject = CurrentValueSubject(marketNamePillViewModel)
    }
    
    // MARK: - Public Methods
    func updateMarketInfo(_ data: MarketInfoData) {
        let newDisplayState = Self.createDisplayState(from: data)
        let newPillViewModel = Self.createMarketNamePillViewModel(from: data)
        
        displayStateSubject.send(newDisplayState)
        marketNamePillViewModelSubject.send(newPillViewModel)
    }
}

// MARK: - Factory Methods
extension MarketInfoLineViewModel {
    
    private static func createDisplayState(from data: MarketInfoData) -> MarketInfoLineDisplayState {
        let visibleIcons = data.icons.filter { $0.isVisible }
        let shouldShowMarketCount = data.marketCount > 0
        let marketCountText = formatMarketCount(data.marketCount)
        
        return MarketInfoLineDisplayState(
            marketName: data.marketName,
            marketCountText: marketCountText,
            visibleIcons: visibleIcons,
            shouldShowMarketCount: shouldShowMarketCount
        )
    }
    
    private static func createMarketNamePillViewModel(from data: MarketInfoData) -> MarketNamePillLabelViewModelProtocol {
        return MarketNamePillLabelViewModel.create(from: data)
    }
    
    private static func formatMarketCount(_ count: Int) -> String {
        return "+\(count)"
    }
}

// MARK: - Factory for Creating from Real Market Data
extension MarketInfoLineViewModel {
    
    /// Creates a MarketInfoLineViewModel from real Market data
    static func create(
        from markets: [Market],
        marketTypeId: String,
        totalMarketCount: Int
    ) -> MarketInfoLineViewModel {
        
        let marketInfoData = extractMarketInfoData(from: markets, marketTypeId: marketTypeId, totalMarketCount: totalMarketCount)
        return MarketInfoLineViewModel(marketInfoData: marketInfoData)
    }
    
    private static func extractMarketInfoData(
        from markets: [Market],
        marketTypeId: String,
        totalMarketCount: Int
    ) -> MarketInfoData {
        
        let marketName = markets.first?.marketTypeName ?? markets.first?.name ?? "Markets"
        let icons = self.determineMarketIcons(from: markets, totalMarketCount: totalMarketCount)
        
        return MarketInfoData(
            marketName: marketName,
            marketCount: totalMarketCount,
            icons: icons
        )
    }
    
    private static func determineMarketIcons(from markets: [Market], totalMarketCount: Int) -> [MarketInfoIcon] {
        var icons: [MarketInfoIcon] = []
        icons.append(MarketInfoIcon(type: .expressPickShort, isVisible: true))
        icons.append(MarketInfoIcon(type: .mostPopular, isVisible: true))
        icons.append(MarketInfoIcon(type: .betBuilder, isVisible: true))
        icons.append(MarketInfoIcon(type: .statistics, isVisible: true))
        return icons
    }
}

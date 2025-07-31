import Combine

final public class MockMarketInfoLineViewModel: MarketInfoLineViewModelProtocol {
    // MARK: - Properties
    private let displayStateSubject: CurrentValueSubject<MarketInfoLineDisplayState, Never>
    private let marketNamePillViewModelSubject: CurrentValueSubject<MarketNamePillLabelViewModelProtocol, Never>
    
    public var displayStatePublisher: AnyPublisher<MarketInfoLineDisplayState, Never> {
        return displayStateSubject.eraseToAnyPublisher()
    }
    
    public var marketNamePillViewModelPublisher: AnyPublisher<MarketNamePillLabelViewModelProtocol, Never> {
        return marketNamePillViewModelSubject.eraseToAnyPublisher()
    }
    
    private var marketInfoData: MarketInfoData
    
    // MARK: - Initialization
    public init(marketInfoData: MarketInfoData) {
        self.marketInfoData = marketInfoData
        
        // Create initial display state
        let initialDisplayState = MarketInfoLineDisplayState(
            marketName: marketInfoData.marketName,
            marketCountText: "+\(marketInfoData.marketCount)",
            visibleIcons: marketInfoData.icons.filter { $0.isVisible },
            shouldShowMarketCount: marketInfoData.marketCount > 0
        )
        
        // Create market name pill view model using factory method
        let pillViewModel = MockMarketNamePillLabelViewModel.standardPill
        
        self.displayStateSubject = CurrentValueSubject(initialDisplayState)
        self.marketNamePillViewModelSubject = CurrentValueSubject(pillViewModel)
    }
}

// MARK: - Mock Factory
extension MockMarketInfoLineViewModel {
    public static var defaultMock: MockMarketInfoLineViewModel {
        let icons = [
            MarketInfoIcon(type: .expressPickShort, isVisible: true),
            MarketInfoIcon(type: .mostPopular, isVisible: true),
            MarketInfoIcon(type: .statistics, isVisible: true)
        ]
        
        let marketInfo = MarketInfoData(
            marketName: "1X2 TR",
            marketCount: 1235,
            icons: icons
        )
        
        return MockMarketInfoLineViewModel(marketInfoData: marketInfo)
    }
    
    public static var manyIconsMock: MockMarketInfoLineViewModel {
        let icons = [
            MarketInfoIcon(type: .expressPickShort, isVisible: true),
            MarketInfoIcon(type: .mostPopular, isVisible: true),
            MarketInfoIcon(type: .statistics, isVisible: true),
            MarketInfoIcon(type: .betBuilder, isVisible: true)
        ]
        
        let marketInfo = MarketInfoData(
            marketName: "Both Teams To Score",
            marketCount: 2340,
            icons: icons
        )
        
        return MockMarketInfoLineViewModel(marketInfoData: marketInfo)
    }
    
    public static var noIconsMock: MockMarketInfoLineViewModel {
        let marketInfo = MarketInfoData(
            marketName: "Over/Under Goals",
            marketCount: 567,
            icons: []
        )
        
        return MockMarketInfoLineViewModel(marketInfoData: marketInfo)
    }
    
    public static var noCountMock: MockMarketInfoLineViewModel {
        let icons = [
            MarketInfoIcon(type: .mostPopular, isVisible: true)
        ]
        
        let marketInfo = MarketInfoData(
            marketName: "Match Winner",
            marketCount: 0,
            icons: icons
        )
        
        return MockMarketInfoLineViewModel(marketInfoData: marketInfo)
    }
    
    public static var longMarketNameMock: MockMarketInfoLineViewModel {
        let icons = [
            MarketInfoIcon(type: .expressPickShort, isVisible: true),
            MarketInfoIcon(type: .mostPopular, isVisible: true),
            MarketInfoIcon(type: .statistics, isVisible: true),
            MarketInfoIcon(type: .betBuilder, isVisible: true)
        ]
        
        let marketInfo = MarketInfoData(
            marketName: "Very Long Market Name That Should Be Truncated To Test Layout",
            marketCount: 1235,
            icons: icons
        )
        
        return MockMarketInfoLineViewModel(marketInfoData: marketInfo)
    }
}

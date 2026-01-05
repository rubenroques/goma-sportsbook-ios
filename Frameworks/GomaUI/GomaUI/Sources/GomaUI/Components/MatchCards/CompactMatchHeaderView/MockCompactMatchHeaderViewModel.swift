import UIKit
import Combine

/// Mock implementation of CompactMatchHeaderViewModelProtocol for testing and previews
public final class MockCompactMatchHeaderViewModel: CompactMatchHeaderViewModelProtocol {

    // MARK: - Private Properties
    private let displayStateSubject: CurrentValueSubject<CompactMatchHeaderDisplayState, Never>

    // MARK: - Protocol Properties
    public var displayStatePublisher: AnyPublisher<CompactMatchHeaderDisplayState, Never> {
        displayStateSubject.eraseToAnyPublisher()
    }

    public var currentDisplayState: CompactMatchHeaderDisplayState {
        displayStateSubject.value
    }

    // MARK: - Initialization
    public init(state: CompactMatchHeaderDisplayState) {
        self.displayStateSubject = CurrentValueSubject(state)
    }

    public convenience init(
        mode: CompactMatchHeaderMode,
        icons: [CompactMatchHeaderIcon] = [],
        marketCount: Int? = nil,
        showMarketCountArrow: Bool = true
    ) {
        let state = CompactMatchHeaderDisplayState(
            mode: mode,
            icons: icons,
            marketCount: marketCount,
            showMarketCountArrow: showMarketCountArrow
        )
        self.init(state: state)
    }

    // MARK: - Protocol Methods
    public func updateMode(_ mode: CompactMatchHeaderMode) {
        let newState = CompactMatchHeaderDisplayState(
            mode: mode,
            icons: displayStateSubject.value.icons,
            marketCount: displayStateSubject.value.marketCount,
            showMarketCountArrow: displayStateSubject.value.showMarketCountArrow
        )
        displayStateSubject.send(newState)
    }

    public func updateIcons(_ icons: [CompactMatchHeaderIcon]) {
        let newState = CompactMatchHeaderDisplayState(
            mode: displayStateSubject.value.mode,
            icons: icons,
            marketCount: displayStateSubject.value.marketCount,
            showMarketCountArrow: displayStateSubject.value.showMarketCountArrow
        )
        displayStateSubject.send(newState)
    }

    public func updateMarketCount(_ count: Int?) {
        let newState = CompactMatchHeaderDisplayState(
            mode: displayStateSubject.value.mode,
            icons: displayStateSubject.value.icons,
            marketCount: count,
            showMarketCountArrow: displayStateSubject.value.showMarketCountArrow
        )
        displayStateSubject.send(newState)
    }

    public func onMarketCountTapped() {
        // Mock: Log action for testing
    }
}

// MARK: - Factory Methods
extension MockCompactMatchHeaderViewModel {

    // MARK: - Standard Icons
    private static var standardIcons: [CompactMatchHeaderIcon] {
        [
            CompactMatchHeaderIcon(id: "ep", iconName: "erep_short_info", isVisible: true),
            CompactMatchHeaderIcon(id: "betBuilder", iconName: "bet_builder_info", isVisible: true)
        ]
    }

    private static var hiddenIcons: [CompactMatchHeaderIcon] {
        [
            CompactMatchHeaderIcon(id: "ep", iconName: "erep_short_info", isVisible: false),
            CompactMatchHeaderIcon(id: "betBuilder", iconName: "bet_builder_info", isVisible: false)
        ]
    }

    // MARK: - Pre-Live States

    /// Pre-live match today (e.g., "TODAY, 14:00")
    public static var preLiveToday: MockCompactMatchHeaderViewModel {
        MockCompactMatchHeaderViewModel(
            mode: .preLive(dateText: "TODAY, 14:00"),
            icons: standardIcons,
            marketCount: 123
        )
    }

    /// Pre-live match with future date
    public static var preLiveFutureDate: MockCompactMatchHeaderViewModel {
        MockCompactMatchHeaderViewModel(
            mode: .preLive(dateText: "17/07, 11:00"),
            icons: standardIcons,
            marketCount: 89
        )
    }

    /// Pre-live match tomorrow
    public static var preLiveTomorrow: MockCompactMatchHeaderViewModel {
        MockCompactMatchHeaderViewModel(
            mode: .preLive(dateText: "TOMORROW, 20:00"),
            icons: hiddenIcons,
            marketCount: 45
        )
    }

    /// Pre-live without icons (production mode)
    public static var preLiveNoIcons: MockCompactMatchHeaderViewModel {
        MockCompactMatchHeaderViewModel(
            mode: .preLive(dateText: "TODAY, 18:30"),
            icons: hiddenIcons,
            marketCount: 156
        )
    }

    // MARK: - Live States

    /// Live tennis match (2nd set)
    public static var liveTennis: MockCompactMatchHeaderViewModel {
        MockCompactMatchHeaderViewModel(
            mode: .live(statusText: "2ND SET"),
            icons: standardIcons,
            marketCount: 123
        )
    }

    /// Live football match (45 minutes)
    public static var liveFootball: MockCompactMatchHeaderViewModel {
        MockCompactMatchHeaderViewModel(
            mode: .live(statusText: "45'"),
            icons: standardIcons,
            marketCount: 78
        )
    }

    /// Live basketball (3rd quarter)
    public static var liveBasketball: MockCompactMatchHeaderViewModel {
        MockCompactMatchHeaderViewModel(
            mode: .live(statusText: "3RD QTR"),
            icons: hiddenIcons,
            marketCount: 92
        )
    }

    /// Live football halftime
    public static var liveHalftime: MockCompactMatchHeaderViewModel {
        MockCompactMatchHeaderViewModel(
            mode: .live(statusText: "HT"),
            icons: standardIcons,
            marketCount: 65
        )
    }

    /// Live tennis first set
    public static var liveTennisFirstSet: MockCompactMatchHeaderViewModel {
        MockCompactMatchHeaderViewModel(
            mode: .live(statusText: "1ST SET"),
            icons: standardIcons,
            marketCount: 34
        )
    }

    /// Live without icons (production mode)
    public static var liveNoIcons: MockCompactMatchHeaderViewModel {
        MockCompactMatchHeaderViewModel(
            mode: .live(statusText: "65'"),
            icons: hiddenIcons,
            marketCount: 112
        )
    }

    // MARK: - Edge Cases

    /// High market count
    public static var highMarketCount: MockCompactMatchHeaderViewModel {
        MockCompactMatchHeaderViewModel(
            mode: .preLive(dateText: "TODAY, 15:00"),
            icons: standardIcons,
            marketCount: 999
        )
    }

    /// No market count
    public static var noMarketCount: MockCompactMatchHeaderViewModel {
        MockCompactMatchHeaderViewModel(
            mode: .preLive(dateText: "TODAY, 12:00"),
            icons: standardIcons,
            marketCount: nil
        )
    }

    /// Minimal header (no icons, no arrow)
    public static var minimal: MockCompactMatchHeaderViewModel {
        MockCompactMatchHeaderViewModel(
            mode: .preLive(dateText: "TODAY, 10:00"),
            icons: [],
            marketCount: 42,
            showMarketCountArrow: false
        )
    }

    // MARK: - Custom Factory

    /// Create custom header state
    public static func custom(
        mode: CompactMatchHeaderMode,
        icons: [CompactMatchHeaderIcon] = [],
        marketCount: Int? = nil,
        showMarketCountArrow: Bool = true
    ) -> MockCompactMatchHeaderViewModel {
        MockCompactMatchHeaderViewModel(
            mode: mode,
            icons: icons,
            marketCount: marketCount,
            showMarketCountArrow: showMarketCountArrow
        )
    }
}

import UIKit
import Combine

// MARK: - Data Models

/// Represents display mode for the header left side
public enum CompactMatchHeaderMode: Equatable, Hashable {
    /// Pre-live mode showing date/time (e.g., "TODAY, 14:00" or "17/07, 11:00")
    case preLive(dateText: String)

    /// Live mode showing LIVE badge and game status (e.g., "2ND SET", "45'")
    case live(statusText: String)
}

/// Icon data for the header right side
public struct CompactMatchHeaderIcon: Equatable, Hashable {
    public let id: String
    public let iconName: String
    public let isVisible: Bool

    public init(id: String, iconName: String, isVisible: Bool = true) {
        self.id = id
        self.iconName = iconName
        self.isVisible = isVisible
    }
}

/// Display state for CompactMatchHeaderView
public struct CompactMatchHeaderDisplayState: Equatable, Hashable {
    public let mode: CompactMatchHeaderMode
    public let icons: [CompactMatchHeaderIcon]
    public let marketCount: Int?
    public let showMarketCountArrow: Bool

    public init(
        mode: CompactMatchHeaderMode,
        icons: [CompactMatchHeaderIcon] = [],
        marketCount: Int? = nil,
        showMarketCountArrow: Bool = true
    ) {
        self.mode = mode
        self.icons = icons
        self.marketCount = marketCount
        self.showMarketCountArrow = showMarketCountArrow
    }

    /// Formatted market count text (e.g., "+123")
    public var marketCountText: String? {
        guard let count = marketCount, count > 0 else { return nil }
        return "+\(count)"
    }
}

// MARK: - Protocol

/// Protocol defining the interface for CompactMatchHeaderView ViewModels
public protocol CompactMatchHeaderViewModelProtocol: AnyObject {
    /// Publisher for the display state
    var displayStatePublisher: AnyPublisher<CompactMatchHeaderDisplayState, Never> { get }

    /// Current display state (for synchronous access)
    var currentDisplayState: CompactMatchHeaderDisplayState { get }

    /// Update the header mode (pre-live/live)
    func updateMode(_ mode: CompactMatchHeaderMode)

    /// Update the icons list
    func updateIcons(_ icons: [CompactMatchHeaderIcon])

    /// Update the market count
    func updateMarketCount(_ count: Int?)

    /// Handle market count tap action
    func onMarketCountTapped()
}

import Combine
import UIKit

// MARK: - Data Models
public struct TopBannerSliderData: Equatable {
    /// The banner views to display
    public let bannerViewFactories: [BannerViewFactory]

    /// Whether auto-scroll is enabled
    public let isAutoScrollEnabled: Bool

    /// Auto-scroll interval in seconds (if auto-scroll is enabled)
    public let autoScrollInterval: TimeInterval

    /// Whether page indicators (dots) should be shown
    public let showPageIndicators: Bool

    /// The current page index
    public let currentPageIndex: Int

    public init(
        bannerViewFactories: [BannerViewFactory],
        isAutoScrollEnabled: Bool = false,
        autoScrollInterval: TimeInterval = 5.0,
        showPageIndicators: Bool = true,
        currentPageIndex: Int = 0
    ) {
        self.bannerViewFactories = bannerViewFactories
        self.isAutoScrollEnabled = isAutoScrollEnabled
        self.autoScrollInterval = autoScrollInterval
        self.showPageIndicators = showPageIndicators
        self.currentPageIndex = currentPageIndex
    }
}

// MARK: - Banner View Factory
public struct BannerViewFactory: Equatable {
    /// Unique identifier for this banner
    public let id: String

    /// Factory closure to create the banner view
    public let viewFactory: () -> TopBannerViewProtocol

    public init(id: String, viewFactory: @escaping () -> TopBannerViewProtocol) {
        self.id = id
        self.viewFactory = viewFactory
    }

    // Equatable conformance
    public static func == (lhs: BannerViewFactory, rhs: BannerViewFactory) -> Bool {
        return lhs.id == rhs.id
    }
}

// MARK: - Display State
public struct TopBannerSliderDisplayState: Equatable {
    /// The slider data to display
    public let sliderData: TopBannerSliderData

    /// Whether the slider should be visible
    public let isVisible: Bool

    /// Whether user interaction is enabled
    public let isUserInteractionEnabled: Bool

    public init(
        sliderData: TopBannerSliderData,
        isVisible: Bool = true,
        isUserInteractionEnabled: Bool = true
    ) {
        self.sliderData = sliderData
        self.isVisible = isVisible
        self.isUserInteractionEnabled = isUserInteractionEnabled
    }
}

// MARK: - View Model Protocol
public protocol TopBannerSliderViewModelProtocol {
    /// Publisher for reactive updates
    var displayStatePublisher: AnyPublisher<TopBannerSliderDisplayState, Never> { get }

    /// Called when the user scrolls to a new page
    func didScrollToPage(_ pageIndex: Int)

    /// Called when a banner is tapped
    func bannerTapped(at index: Int)

    /// Start auto-scroll (if enabled)
    func startAutoScroll()

    /// Stop auto-scroll
    func stopAutoScroll()
}
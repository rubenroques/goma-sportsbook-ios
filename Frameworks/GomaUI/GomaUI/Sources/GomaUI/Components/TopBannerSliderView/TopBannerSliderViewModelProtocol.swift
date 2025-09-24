import Combine
import UIKit

// MARK: - Data Models
public struct TopBannerSliderData: Equatable {
    /// The banner types to display
    public let banners: [BannerType]

    /// Whether page indicators (dots) should be shown
    public let showPageIndicators: Bool

    /// The current page index
    public let currentPageIndex: Int

    public init(
        banners: [BannerType],
        showPageIndicators: Bool = true,
        currentPageIndex: Int = 0
    ) {
        self.banners = banners
        self.showPageIndicators = showPageIndicators
        self.currentPageIndex = currentPageIndex
    }

    // Equatable conformance
    public static func == (lhs: TopBannerSliderData, rhs: TopBannerSliderData) -> Bool {
        return lhs.banners == rhs.banners &&
               lhs.showPageIndicators == rhs.showPageIndicators &&
               lhs.currentPageIndex == rhs.currentPageIndex
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
    /// Current display state for immediate access
    var currentDisplayState: TopBannerSliderDisplayState { get }

    /// Publisher for reactive updates
    var displayStatePublisher: AnyPublisher<TopBannerSliderDisplayState, Never> { get }

    /// Called when the user scrolls to a new page
    func didScrollToPage(_ pageIndex: Int)

    /// Called when a banner is tapped
    func bannerTapped(at index: Int)
}
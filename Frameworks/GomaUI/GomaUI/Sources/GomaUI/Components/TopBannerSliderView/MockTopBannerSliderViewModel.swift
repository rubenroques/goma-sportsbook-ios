import Combine
import UIKit

/// Mock implementation of `TopBannerSliderViewModelProtocol` for testing.
final public class MockTopBannerSliderViewModel: TopBannerSliderViewModelProtocol {

    // MARK: - Properties
    private let displayStateSubject: CurrentValueSubject<TopBannerSliderDisplayState, Never>

    public var currentDisplayState: TopBannerSliderDisplayState {
        return displayStateSubject.value
    }

    public var displayStatePublisher: AnyPublisher<TopBannerSliderDisplayState, Never> {
        return displayStateSubject.eraseToAnyPublisher()
    }

    // Internal state
    private var sliderData: TopBannerSliderData
    private var isVisible: Bool
    private var isUserInteractionEnabled: Bool

    // MARK: - Initialization
    public init(
        sliderData: TopBannerSliderData,
        isVisible: Bool = true,
        isUserInteractionEnabled: Bool = true
    ) {
        self.sliderData = sliderData
        self.isVisible = isVisible
        self.isUserInteractionEnabled = isUserInteractionEnabled

        // Create initial display state
        let initialState = TopBannerSliderDisplayState(
            sliderData: sliderData,
            isVisible: isVisible,
            isUserInteractionEnabled: isUserInteractionEnabled
        )
        self.displayStateSubject = CurrentValueSubject(initialState)
    }


    // MARK: - TopBannerSliderViewModelProtocol
    public func didScrollToPage(_ pageIndex: Int) {
        print("Scrolled to page: \(pageIndex)")

        // Update current page index
        let updatedSliderData = TopBannerSliderData(
            banners: sliderData.banners,
            showPageIndicators: sliderData.showPageIndicators,
            currentPageIndex: pageIndex
        )

        sliderData = updatedSliderData
        publishNewState()
    }

    public func bannerTapped(at index: Int) {
        print("Banner tapped at index: \(index)")
        // Mock action - could trigger navigation, analytics, etc.
    }

    // MARK: - Helper Methods

    public func updateSliderData(_ newSliderData: TopBannerSliderData) {
        sliderData = newSliderData
        publishNewState()
    }

    public func updateVisibility(_ visible: Bool) {
        isVisible = visible
        publishNewState()
    }

    public func updateUserInteraction(_ enabled: Bool) {
        isUserInteractionEnabled = enabled
        publishNewState()
    }

    private func publishNewState() {
        let newState = TopBannerSliderDisplayState(
            sliderData: sliderData,
            isVisible: isVisible,
            isUserInteractionEnabled: isUserInteractionEnabled
        )
        displayStateSubject.send(newState)
    }
}

// MARK: - Mock Factory
extension MockTopBannerSliderViewModel {

    /// Default mock with multiple single button banners
    public static var defaultMock: MockTopBannerSliderViewModel {
        let banners: [BannerType] = [
            .info(MockSingleButtonBannerViewModel.defaultMock),
            .info(MockSingleButtonBannerViewModel.customStyledMock),
            .info(MockSingleButtonBannerViewModel.noButtonMock)
        ]

        let sliderData = TopBannerSliderData(
            banners: banners,
            showPageIndicators: true,
            currentPageIndex: 0
        )

        return MockTopBannerSliderViewModel(sliderData: sliderData)
    }

    /// Mock with single banner (no page indicators)
    public static var singleBannerMock: MockTopBannerSliderViewModel {
        let banners: [BannerType] = [
            .info(MockSingleButtonBannerViewModel.defaultMock)
        ]

        let sliderData = TopBannerSliderData(
            banners: banners,
            showPageIndicators: true,
            currentPageIndex: 0
        )

        return MockTopBannerSliderViewModel(sliderData: sliderData)
    }

    /// Mock with multiple banners and no page indicators
    public static var noIndicatorsMock: MockTopBannerSliderViewModel {
        let banners: [BannerType] = [
            .info(MockSingleButtonBannerViewModel.defaultMock),
            .info(MockSingleButtonBannerViewModel.customStyledMock)
        ]

        let sliderData = TopBannerSliderData(
            banners: banners,
            showPageIndicators: false,
            currentPageIndex: 0
        )

        return MockTopBannerSliderViewModel(sliderData: sliderData)
    }

    /// Mock with disabled user interaction
    public static var disabledInteractionMock: MockTopBannerSliderViewModel {
        let banners: [BannerType] = [
            .info(MockSingleButtonBannerViewModel.disabledMock),
            .info(MockSingleButtonBannerViewModel.noButtonMock)
        ]

        let sliderData = TopBannerSliderData(
            banners: banners,
            showPageIndicators: true,
            currentPageIndex: 0
        )

        return MockTopBannerSliderViewModel(
            sliderData: sliderData,
            isVisible: true,
            isUserInteractionEnabled: false
        )
    }

    /// Mock with mixed banner types (single button and match banners)
    public static var mixedBannersMock: MockTopBannerSliderViewModel {
        let banners: [BannerType] = [
            .info(MockSingleButtonBannerViewModel.defaultMock),
            .match(MockMatchBannerViewModel.preliveMatch),
            .info(MockSingleButtonBannerViewModel.customStyledMock),
            .match(MockMatchBannerViewModel.liveMatch)
        ]

        let sliderData = TopBannerSliderData(
            banners: banners,
            showPageIndicators: true,
            currentPageIndex: 0
        )

        return MockTopBannerSliderViewModel(sliderData: sliderData)
    }

    /// Mock with only match banners
    public static var matchOnlyMock: MockTopBannerSliderViewModel {
        let banners: [BannerType] = [
            .match(MockMatchBannerViewModel.preliveMatch),
            .match(MockMatchBannerViewModel.liveMatch),
            .match(MockMatchBannerViewModel.interactiveMatch)
        ]

        let sliderData = TopBannerSliderData(
            banners: banners,
            showPageIndicators: true,
            currentPageIndex: 0
        )

        return MockTopBannerSliderViewModel(sliderData: sliderData)
    }
}

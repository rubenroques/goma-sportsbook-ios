import Combine
import UIKit

/// Mock implementation of `TopBannerSliderViewModelProtocol` for testing.
final public class MockTopBannerSliderViewModel: TopBannerSliderViewModelProtocol {

    // MARK: - Properties
    private let displayStateSubject: CurrentValueSubject<TopBannerSliderDisplayState, Never>
    public var displayStatePublisher: AnyPublisher<TopBannerSliderDisplayState, Never> {
        return displayStateSubject.eraseToAnyPublisher()
    }

    // Internal state
    private var sliderData: TopBannerSliderData
    private var isVisible: Bool
    private var isUserInteractionEnabled: Bool
    private var autoScrollTimer: Timer?

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

    deinit {
        stopAutoScroll()
    }

    // MARK: - TopBannerSliderViewModelProtocol
    public func didScrollToPage(_ pageIndex: Int) {
        print("Scrolled to page: \(pageIndex)")

        // Update current page index
        let updatedSliderData = TopBannerSliderData(
            bannerViewFactories: sliderData.bannerViewFactories,
            isAutoScrollEnabled: sliderData.isAutoScrollEnabled,
            autoScrollInterval: sliderData.autoScrollInterval,
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

    public func startAutoScroll() {
        guard sliderData.isAutoScrollEnabled else { return }

        stopAutoScroll()

        autoScrollTimer = Timer.scheduledTimer(withTimeInterval: sliderData.autoScrollInterval, repeats: true) { [weak self] _ in
            self?.autoScrollToNextPage()
        }
    }

    public func stopAutoScroll() {
        autoScrollTimer?.invalidate()
        autoScrollTimer = nil
    }

    // MARK: - Helper Methods
    private func autoScrollToNextPage() {
        let currentPage = sliderData.currentPageIndex
        let nextPage = (currentPage + 1) % sliderData.bannerViewFactories.count
        didScrollToPage(nextPage)
    }

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

    /// Default mock with multiple banners
    public static var defaultMock: MockTopBannerSliderViewModel {
        let bannerFactories = [
            BannerViewFactory(id: "welcome_banner") {
                SingleButtonBannerView(viewModel: MockSingleButtonBannerViewModel.defaultMock)
            },
            BannerViewFactory(id: "promo_banner") {
                SingleButtonBannerView(viewModel: MockSingleButtonBannerViewModel.customStyledMock)
            },
            BannerViewFactory(id: "info_banner") {
                SingleButtonBannerView(viewModel: MockSingleButtonBannerViewModel.noButtonMock)
            }
        ]

        let sliderData = TopBannerSliderData(
            bannerViewFactories: bannerFactories,
            isAutoScrollEnabled: false,
            autoScrollInterval: 3.0,
            showPageIndicators: true,
            currentPageIndex: 0
        )

        return MockTopBannerSliderViewModel(sliderData: sliderData)
    }

    /// Mock with single banner (no page indicators)
    public static var singleBannerMock: MockTopBannerSliderViewModel {
        let bannerFactories = [
            BannerViewFactory(id: "single_banner") {
                SingleButtonBannerView(viewModel: MockSingleButtonBannerViewModel.defaultMock)
            }
        ]

        let sliderData = TopBannerSliderData(
            bannerViewFactories: bannerFactories,
            isAutoScrollEnabled: false,
            autoScrollInterval: 5.0,
            showPageIndicators: true,
            currentPageIndex: 0
        )

        return MockTopBannerSliderViewModel(sliderData: sliderData)
    }

    /// Mock with auto-scroll enabled
    public static var autoScrollMock: MockTopBannerSliderViewModel {
        let bannerFactories = [
            BannerViewFactory(id: "auto_banner_1") {
                let buttonConfig = ButtonConfig(
                    title: "Learn More",
                    backgroundColor: UIColor.systemBlue,
                    textColor: UIColor.white
                )
                let bannerData = SingleButtonBannerData(
                    type: "auto_banner_1",
                    isVisible: true,
                    backgroundImage: createGradientImage(
                        colors: [UIColor.systemBlue, UIColor.systemPurple],
                        size: CGSize(width: 400, height: 200)
                    ),
                    messageText: "Auto-scrolling banner 1\nSwipe or wait to see more!",
                    buttonConfig: buttonConfig
                )
                return SingleButtonBannerView(viewModel: MockSingleButtonBannerViewModel(bannerData: bannerData))
            },
            BannerViewFactory(id: "auto_banner_2") {
                let buttonConfig = ButtonConfig(
                    title: "Discover",
                    backgroundColor: UIColor.systemGreen,
                    textColor: UIColor.white
                )
                let bannerData = SingleButtonBannerData(
                    type: "auto_banner_2",
                    isVisible: true,
                    backgroundImage: createGradientImage(
                        colors: [UIColor.systemGreen, UIColor.systemTeal],
                        size: CGSize(width: 400, height: 200)
                    ),
                    messageText: "Auto-scrolling banner 2\nThis will change automatically!",
                    buttonConfig: buttonConfig
                )
                return SingleButtonBannerView(viewModel: MockSingleButtonBannerViewModel(bannerData: bannerData))
            },
            BannerViewFactory(id: "auto_banner_3") {
                let bannerData = SingleButtonBannerData(
                    type: "auto_banner_3",
                    isVisible: true,
                    backgroundImage: createGradientImage(
                        colors: [UIColor.systemOrange, UIColor.systemRed],
                        size: CGSize(width: 400, height: 200)
                    ),
                    messageText: "Auto-scrolling banner 3\nNo button, just information!",
                    buttonConfig: nil
                )
                return SingleButtonBannerView(viewModel: MockSingleButtonBannerViewModel(bannerData: bannerData))
            }
        ]

        let sliderData = TopBannerSliderData(
            bannerViewFactories: bannerFactories,
            isAutoScrollEnabled: true,
            autoScrollInterval: 3.0,
            showPageIndicators: true,
            currentPageIndex: 0
        )

        return MockTopBannerSliderViewModel(sliderData: sliderData)
    }

    /// Mock with no page indicators
    public static var noIndicatorsMock: MockTopBannerSliderViewModel {
        let bannerFactories = [
            BannerViewFactory(id: "no_indicators_1") {
                SingleButtonBannerView(viewModel: MockSingleButtonBannerViewModel.defaultMock)
            },
            BannerViewFactory(id: "no_indicators_2") {
                SingleButtonBannerView(viewModel: MockSingleButtonBannerViewModel.customStyledMock)
            }
        ]

        let sliderData = TopBannerSliderData(
            bannerViewFactories: bannerFactories,
            isAutoScrollEnabled: false,
            autoScrollInterval: 5.0,
            showPageIndicators: false,
            currentPageIndex: 0
        )

        return MockTopBannerSliderViewModel(sliderData: sliderData)
    }

    /// Mock with disabled user interaction
    public static var disabledInteractionMock: MockTopBannerSliderViewModel {
        let bannerFactories = [
            BannerViewFactory(id: "disabled_1") {
                SingleButtonBannerView(viewModel: MockSingleButtonBannerViewModel.disabledMock)
            },
            BannerViewFactory(id: "disabled_2") {
                SingleButtonBannerView(viewModel: MockSingleButtonBannerViewModel.noButtonMock)
            }
        ]

        let sliderData = TopBannerSliderData(
            bannerViewFactories: bannerFactories,
            isAutoScrollEnabled: false,
            autoScrollInterval: 5.0,
            showPageIndicators: true,
            currentPageIndex: 0
        )

        return MockTopBannerSliderViewModel(
            sliderData: sliderData,
            isVisible: true,
            isUserInteractionEnabled: false
        )
    }

    /// Casino-themed mock with Beast Below style banner
    public static var casinoGameMock: MockTopBannerSliderViewModel {
        let bannerFactories = [
            BannerViewFactory(id: "beast_below_banner") {
                let buttonConfig = ButtonConfig(
                    title: "PLAY",
                    backgroundColor: UIColor.white,
                    textColor: StyleProvider.Color.highlightPrimary,
                    cornerRadius: 4
                )
                let bannerData = SingleButtonBannerData(
                    type: "casino_game_banner",
                    isVisible: true,
                    backgroundImage: UIImage(named: "casinoBannerGameDemo", in: Bundle.module, with: nil),
                    messageText: "Discover 10 New Tom\nHorn Games",
                    buttonConfig: buttonConfig
                )
                return SingleButtonBannerView(viewModel: MockSingleButtonBannerViewModel(bannerData: bannerData))
            },
            BannerViewFactory(id: "casino_promo_banner") {
                let buttonConfig = ButtonConfig(
                    title: "CLAIM BONUS",
                    backgroundColor: UIColor.white,
                    textColor: StyleProvider.Color.highlightPrimary,
                    cornerRadius: 4
                )
                let bannerData = SingleButtonBannerData(
                    type: "casino_promo_banner",
                    isVisible: true,
                    backgroundImage: UIImage(named: "casinoBannerGameDemo", in: Bundle.module, with: nil),
                    messageText: "Win up to €50,000\nMega Jackpot!",
                    buttonConfig: buttonConfig
                )
                return SingleButtonBannerView(viewModel: MockSingleButtonBannerViewModel(bannerData: bannerData))
            },
            BannerViewFactory(id: "welcome_bonus_banner") {
                let buttonConfig = ButtonConfig(
                    title: "GET STARTED",
                    backgroundColor: UIColor.white,
                    textColor: StyleProvider.Color.highlightPrimary,
                    cornerRadius: 4
                )
                let bannerData = SingleButtonBannerData(
                    type: "welcome_bonus_banner",
                    isVisible: true,
                    backgroundImage: UIImage(named: "casinoBannerGameDemo", in: Bundle.module, with: nil),
                    messageText: "100% Match + 50 Free Spins\nWelcome Bonus!",
                    buttonConfig: buttonConfig
                )
                return SingleButtonBannerView(viewModel: MockSingleButtonBannerViewModel(bannerData: bannerData))
            }
        ]

        let sliderData = TopBannerSliderData(
            bannerViewFactories: bannerFactories,
            isAutoScrollEnabled: false,
            autoScrollInterval: 0.0,
            showPageIndicators: true,
            currentPageIndex: 0
        )

        return MockTopBannerSliderViewModel(sliderData: sliderData)
    }
    
    private static func createGradientImage(colors: [UIColor], size: CGSize) -> UIImage? {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { context in
            let gradient = CGGradient(
                colorsSpace: CGColorSpaceCreateDeviceRGB(),
                colors: colors.map { $0.cgColor } as CFArray,
                locations: nil
            )

            guard let gradient = gradient else { return }

            context.cgContext.drawLinearGradient(
                gradient,
                start: CGPoint(x: 0, y: 0),
                end: CGPoint(x: size.width, y: size.height),
                options: []
            )
        }
    }
}

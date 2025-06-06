import UIKit
import Combine
import GomaUI

// MARK: - TopBannerSliderCollectionViewCell
final class TopBannerSliderCollectionViewCell: UICollectionViewCell {

    // MARK: - Properties
    static let identifier = "TopBannerSliderCollectionViewCell"

    private var bannerSliderView: TopBannerSliderView?
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle
    override func prepareForReuse() {
        super.prepareForReuse()
        bannerSliderView?.removeFromSuperview()
        bannerSliderView = nil

        cancellables.removeAll()
    }

    // MARK: - Setup
    private func setupViews() {
        contentView.backgroundColor = UIColor.clear
    }

    // MARK: - Configuration
    func configure(
        with viewModel: TopBannerSliderViewModelProtocol,
        onBannerTapped: @escaping (Int) -> Void = { _ in },
        onPageChanged: @escaping (Int) -> Void = { _ in }
    ) {
        // Remove existing banner view
        bannerSliderView?.removeFromSuperview()
        cancellables.removeAll()

        // Create new banner slider view
        let sliderView = TopBannerSliderView(viewModel: viewModel)
        sliderView.translatesAutoresizingMaskIntoConstraints = false

        // Handle events
        sliderView.onBannerTapped = onBannerTapped
        sliderView.onPageChanged = onPageChanged

        // Add to content view
        contentView.addSubview(sliderView)
        bannerSliderView = sliderView

        // Setup constraints for dynamic height
        NSLayoutConstraint.activate([
            sliderView.topAnchor.constraint(equalTo: contentView.topAnchor),
            sliderView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            sliderView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            sliderView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

            // Set intrinsic height for the banner slider
            sliderView.heightAnchor.constraint(equalToConstant: 136)
        ])
    }

    // MARK: - Dynamic Height Support
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        // Enable dynamic height calculation
        layoutIfNeeded()

        let targetSize = CGSize(width: layoutAttributes.frame.width, height: UIView.layoutFittingCompressedSize.height)
        let fittingSize = contentView.systemLayoutSizeFitting(
            targetSize,
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        )

        guard let attributes = layoutAttributes.copy() as? UICollectionViewLayoutAttributes else {
            return layoutAttributes
        }
        attributes.frame.size.height = fittingSize.height

        return attributes
    }
}

// MARK: - Mock ViewModel for TopBannerSlider
final class MockTopBannerSliderViewModelForNextUp: TopBannerSliderViewModelProtocol {

    // MARK: - Properties
    private let displayStateSubject: CurrentValueSubject<TopBannerSliderDisplayState, Never>

    var displayStatePublisher: AnyPublisher<TopBannerSliderDisplayState, Never> {
        displayStateSubject.eraseToAnyPublisher()
    }

    // MARK: - Initialization
    init() {
        // Create mock banner factories
        let bannerFactories = [
            BannerViewFactory(id: "promo_banner") {
                SingleButtonBannerView(viewModel: Self.createPromoBannerViewModel())
            },
            BannerViewFactory(id: "welcome_banner") {
                SingleButtonBannerView(viewModel: Self.createWelcomeBannerViewModel())
            },
            BannerViewFactory(id: "bonus_banner") {
                SingleButtonBannerView(viewModel: Self.createBonusBannerViewModel())
            }
        ]

        let sliderData = TopBannerSliderData(
            bannerViewFactories: bannerFactories,
            isAutoScrollEnabled: true,
            autoScrollInterval: 5.0,
            showPageIndicators: true,
            currentPageIndex: 0
        )

        let initialState = TopBannerSliderDisplayState(
            sliderData: sliderData,
            isVisible: true,
            isUserInteractionEnabled: true
        )

        self.displayStateSubject = CurrentValueSubject(initialState)
    }

    // MARK: - TopBannerSliderViewModelProtocol
    func didScrollToPage(_ pageIndex: Int) {
        print("TopBannerSlider scrolled to page: \(pageIndex)")
    }

    func bannerTapped(at index: Int) {
        print("TopBannerSlider banner tapped at index: \(index)")
    }

    func startAutoScroll() {
        print("TopBannerSlider auto-scroll started")
    }

    func stopAutoScroll() {
        print("TopBannerSlider auto-scroll stopped")
    }

    // MARK: - Private Helpers
    private static func createPromoBannerViewModel() -> MockSingleButtonBannerViewModel {
        let buttonConfig = ButtonConfig(
            title: "Claim Now",
            backgroundColor: StyleProvider.Color.primaryColor,
            textColor: StyleProvider.Color.buttonTextPrimary,
            cornerRadius: 8
        )

        let bannerData = SingleButtonBannerData(
            type: "promo_banner",
            isVisible: true,
            backgroundImage: createGradientImage(
                colors: [UIColor.systemPurple, UIColor.systemBlue],
                size: CGSize(width: 400, height: 200)
            ),
            messageText: "🎉 Double Your First Bet!\nUp to $100 Bonus",
            buttonConfig: buttonConfig
        )

        return MockSingleButtonBannerViewModel(bannerData: bannerData)
    }

    private static func createWelcomeBannerViewModel() -> MockSingleButtonBannerViewModel {
        let buttonConfig = ButtonConfig(
            title: "Get Started",
            backgroundColor: StyleProvider.Color.secondaryColor,
            textColor: StyleProvider.Color.buttonTextSecondary,
            cornerRadius: 8
        )

        let bannerData = SingleButtonBannerData(
            type: "welcome_banner",
            isVisible: true,
            backgroundImage: createGradientImage(
                colors: [UIColor.systemOrange, UIColor.systemYellow],
                size: CGSize(width: 400, height: 200)
            ),
            messageText: "Welcome to Sports Betting!\nPlace your first bet today",
            buttonConfig: buttonConfig
        )

        return MockSingleButtonBannerViewModel(bannerData: bannerData)
    }

    private static func createBonusBannerViewModel() -> MockSingleButtonBannerViewModel {
        let bannerData = SingleButtonBannerData(
            type: "bonus_banner",
            isVisible: true,
            backgroundImage: createGradientImage(
                colors: [UIColor.systemTeal, UIColor.systemCyan],
                size: CGSize(width: 400, height: 200)
            ),
            messageText: "🏆 Weekend Special\nBonus odds on all matches!",
            buttonConfig: nil
        )

        return MockSingleButtonBannerViewModel(bannerData: bannerData)
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
import Combine
import UIKit

/// Mock implementation of `SingleButtonBannerViewModelProtocol` for testing.
final public class MockSingleButtonBannerViewModel: SingleButtonBannerViewModelProtocol {

    // MARK: - Associated Type
    public typealias ActionType = Void

    // MARK: - Properties
    private let displayStateSubject: CurrentValueSubject<SingleButtonBannerDisplayState, Never>

    public var currentDisplayState: SingleButtonBannerDisplayState {
        return displayStateSubject.value
    }

    public var displayStatePublisher: AnyPublisher<SingleButtonBannerDisplayState, Never> {
        return displayStateSubject.eraseToAnyPublisher()
    }

    public var onButtonAction: ((Void) -> Void)?

    // Internal state
    private var bannerData: SingleButtonBannerData
    private var isButtonEnabled: Bool

    // MARK: - Initialization
    public init(bannerData: SingleButtonBannerData, isButtonEnabled: Bool = true) {
        self.bannerData = bannerData
        self.isButtonEnabled = isButtonEnabled

        // Create initial display state
        let initialState = SingleButtonBannerDisplayState(
            bannerData: bannerData,
            isButtonEnabled: isButtonEnabled
        )
        self.displayStateSubject = CurrentValueSubject(initialState)
    }

    // MARK: - SingleButtonBannerViewModelProtocol
    public func buttonTapped() {
        print("Banner button tapped for type: \(bannerData.type)")
        onButtonAction?(())
    }

    // MARK: - Helper Methods
    public func updateButtonEnabled(_ enabled: Bool) {
        isButtonEnabled = enabled
        publishNewState()
    }
    
    public func updateBannerData(_ newBannerData: SingleButtonBannerData) {
        bannerData = newBannerData
        publishNewState()
    }

    private func publishNewState() {
        let newState = SingleButtonBannerDisplayState(
            bannerData: bannerData,
            isButtonEnabled: isButtonEnabled
        )
        displayStateSubject.send(newState)
    }
}

// MARK: - Mock Factory
extension MockSingleButtonBannerViewModel {

    /// Empty state for cell reuse and initial state
    public static var emptyState: MockSingleButtonBannerViewModel {
        let bannerData = SingleButtonBannerData(
            type: "empty_banner",
            isVisible: false,
            backgroundImageURL: nil,
            messageText: "",
            buttonConfig: nil
        )

        return MockSingleButtonBannerViewModel(bannerData: bannerData, isButtonEnabled: false)
    }

    /// Default mock with gradient background and button
    public static var defaultMock: MockSingleButtonBannerViewModel {
        let buttonConfig = ButtonConfig(
            title: "Button",
            backgroundColor: UIColor.systemBlue,
            textColor: UIColor.white,
            cornerRadius: 12
        )
        
        let bannerData = SingleButtonBannerData(
            type: "welcome_banner",
            isVisible: true,
            backgroundImageURL: "https://picsum.photos/400/200?random=1",
            messageText: "Get 2X the action,\ndouble your first\ndeposit!",
            buttonConfig: buttonConfig
        )

        return MockSingleButtonBannerViewModel(bannerData: bannerData)
    }
    
    /// Mock without button - message only
    public static var noButtonMock: MockSingleButtonBannerViewModel {
        let bannerData = SingleButtonBannerData(
            type: "info_banner",
            isVisible: true,
            backgroundImageURL: "https://picsum.photos/400/200?random=2",
            messageText: "Welcome to our platform!\nEnjoy your experience.",
            buttonConfig: nil
        )

        return MockSingleButtonBannerViewModel(bannerData: bannerData)
    }
    
    /// Mock with custom styling
    public static var customStyledMock: MockSingleButtonBannerViewModel {
        let buttonConfig = ButtonConfig(
            title: "Get Started",
            backgroundColor: UIColor.systemGreen,
            textColor: UIColor.black,
            cornerRadius: 20
        )
        
        let bannerData = SingleButtonBannerData(
            type: "promo_banner",
            isVisible: true,
            backgroundImageURL: "https://picsum.photos/400/200?random=3",
            messageText: "Special Offer!\nSign up today for exclusive benefits.",
            buttonConfig: buttonConfig
        )

        return MockSingleButtonBannerViewModel(bannerData: bannerData)
    }
    
    /// Mock for disabled state
    public static var disabledMock: MockSingleButtonBannerViewModel {
        let buttonConfig = ButtonConfig(
            title: "Coming Soon",
            backgroundColor: UIColor.systemGray,
            textColor: UIColor.white
        )
        
        let bannerData = SingleButtonBannerData(
            type: "disabled_banner",
            isVisible: true,
            backgroundImageURL: "https://picsum.photos/400/200?random=4",
            messageText: "New features coming soon!",
            buttonConfig: buttonConfig
        )

        return MockSingleButtonBannerViewModel(bannerData: bannerData, isButtonEnabled: false)
    }
    
    /// Mock for hidden banner
    public static var hiddenMock: MockSingleButtonBannerViewModel {
        let bannerData = SingleButtonBannerData(
            type: "hidden_banner",
            isVisible: false,
            backgroundImageURL: nil,
            messageText: "This banner is hidden",
            buttonConfig: nil
        )

        return MockSingleButtonBannerViewModel(bannerData: bannerData)
    }
    
    // MARK: - Helper Methods
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
import Combine
import UIKit

// MARK: - Data Models
public struct SingleButtonBannerData: Equatable, Hashable, TopBannerProtocol {
    /// The type identifier for this banner
    public let type: String
    
    /// Whether this banner should be visible
    public let isVisible: Bool
    
    /// The background image for the banner
    public let backgroundImage: UIImage?
    
    /// The message text to display
    public let messageText: String
    
    /// The button configuration (optional)
    public let buttonConfig: ButtonConfig?
    
    public init(
        type: String,
        isVisible: Bool = true,
        backgroundImage: UIImage? = nil,
        messageText: String,
        buttonConfig: ButtonConfig? = nil
    ) {
        self.type = type
        self.isVisible = isVisible
        self.backgroundImage = backgroundImage
        self.messageText = messageText
        self.buttonConfig = buttonConfig
    }
}

// MARK: - Button Configuration
public struct ButtonConfig: Equatable, Hashable {
    /// The button title text
    public let title: String
    
    /// The button background color (optional, uses StyleProvider default if nil)
    public let backgroundColor: UIColor?
    
    /// The button text color (optional, uses StyleProvider default if nil)
    public let textColor: UIColor?
    
    /// The button corner radius (optional, uses default if nil)
    public let cornerRadius: CGFloat?
    
    public init(
        title: String,
        backgroundColor: UIColor? = nil,
        textColor: UIColor? = nil,
        cornerRadius: CGFloat? = nil
    ) {
        self.title = title
        self.backgroundColor = backgroundColor
        self.textColor = textColor
        self.cornerRadius = cornerRadius
    }
}

// MARK: - Display State
public struct SingleButtonBannerDisplayState: Equatable {
    /// The banner data to display
    public let bannerData: SingleButtonBannerData
    
    /// Whether the button should be enabled
    public let isButtonEnabled: Bool
    
    public init(
        bannerData: SingleButtonBannerData,
        isButtonEnabled: Bool = true
    ) {
        self.bannerData = bannerData
        self.isButtonEnabled = isButtonEnabled
    }
}

// MARK: - View Model Protocol
public protocol SingleButtonBannerViewModelProtocol {
    /// Publisher for reactive updates
    var displayStatePublisher: AnyPublisher<SingleButtonBannerDisplayState, Never> { get }
    
    /// Called when the button is tapped
    func buttonTapped()
} 
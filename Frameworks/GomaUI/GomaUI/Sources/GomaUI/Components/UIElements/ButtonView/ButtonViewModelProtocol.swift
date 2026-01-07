import Foundation
import Combine
import UIKit

// MARK: - Button Style Enum
public enum ButtonStyle {
    case solidBackground
    case bordered
    case transparent
}

// MARK: - Data Models
public struct ButtonData: Equatable, Hashable {
    public let id: String
    public let title: String
    public let style: ButtonStyle
    public let backgroundColor: UIColor?
    public let disabledBackgroundColor: UIColor?
    public let borderColor: UIColor?
    public let textColor: UIColor?
    public let fontSize: CGFloat?
    public let fontType: StyleProvider.FontType?
    public let isEnabled: Bool
    
    public init(id: String, title: String, style: ButtonStyle, backgroundColor: UIColor? = nil, disabledBackgroundColor: UIColor? = nil, borderColor: UIColor? = nil, textColor: UIColor? = nil, fontSize: CGFloat? = nil, fontType: StyleProvider.FontType? = nil, isEnabled: Bool = true) {
        self.id = id
        self.title = title
        self.style = style
        self.backgroundColor = backgroundColor
        self.disabledBackgroundColor = disabledBackgroundColor
        self.borderColor = borderColor
        self.textColor = textColor
        self.fontSize = fontSize
        self.fontType = fontType
        self.isEnabled = isEnabled
    }
}

// MARK: - View Model Protocol
public protocol ButtonViewModelProtocol {
    /// Synchronous state access (for immediate rendering in snapshot tests and cell reuse)
    var currentButtonData: ButtonData { get }

    /// Publisher for reactive updates
    var buttonDataPublisher: AnyPublisher<ButtonData, Never> { get }

    /// Button action
    func buttonTapped()

    /// Update button state
    func setEnabled(_ isEnabled: Bool)

    /// Update button title
    func updateTitle(_ title: String)

    /// Callback closure for button tap
    var onButtonTapped: (() -> Void)? { get set }

}

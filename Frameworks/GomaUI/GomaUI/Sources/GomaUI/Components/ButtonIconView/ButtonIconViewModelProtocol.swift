import Foundation
import Combine
import UIKit

/// Layout type for the button icon
public enum ButtonIconLayoutType: Equatable {
    case iconLeft
    case iconRight
}

/// Data model for the button icon view
public struct ButtonIconData: Equatable {
    public let title: String
    public let icon: String?
    public let layoutType: ButtonIconLayoutType
    public let isEnabled: Bool
    
    public init(title: String, icon: String? = nil, layoutType: ButtonIconLayoutType = .iconLeft, isEnabled: Bool = true) {
        self.title = title
        self.icon = icon
        self.layoutType = layoutType
        self.isEnabled = isEnabled
    }
}

/// Protocol defining the interface for ButtonIconView ViewModels
public protocol ButtonIconViewModelProtocol {
    /// Publisher for the button icon data
    var dataPublisher: AnyPublisher<ButtonIconData, Never> { get }
    
    /// Current data (for immediate access)
    var currentData: ButtonIconData { get }
    
    /// Update the title
    func updateTitle(_ title: String)
    
    /// Update the icon
    func updateIcon(_ icon: String?)
    
    /// Update the layout type
    func updateLayoutType(_ layoutType: ButtonIconLayoutType)
    
    /// Set the enabled state
    func setEnabled(_ isEnabled: Bool)
    
    /// Callback for button tap
    var onButtonTapped: (() -> Void)? { get set }
} 

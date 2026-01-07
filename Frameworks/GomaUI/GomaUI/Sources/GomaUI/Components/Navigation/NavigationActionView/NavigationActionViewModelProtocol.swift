import Foundation
import Combine
import UIKit

/// Data model for the navigation action view
public struct NavigationActionData: Equatable {
    public let title: String
    public let icon: String?
    public let isEnabled: Bool
    
    public init(title: String, icon: String? = nil, isEnabled: Bool = true) {
        self.title = title
        self.icon = icon
        self.isEnabled = isEnabled
    }
}

/// Protocol defining the interface for NavigationActionView ViewModels
public protocol NavigationActionViewModelProtocol {
    /// Publisher for the navigation action data
    var dataPublisher: AnyPublisher<NavigationActionData, Never> { get }
    
    /// Current data (for immediate access)
    var currentData: NavigationActionData { get }
    
    /// Update the title
    func updateTitle(_ title: String)
    
    /// Update the icon
    func updateIcon(_ icon: String?)
    
    /// Set the enabled state
    func setEnabled(_ isEnabled: Bool)
    
    /// Handle navigation action tap
    func onNavigationTapped()
} 

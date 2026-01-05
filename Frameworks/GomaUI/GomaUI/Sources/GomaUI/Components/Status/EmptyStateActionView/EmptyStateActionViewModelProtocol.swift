import Foundation
import UIKit
import Combine


// MARK: - Data Models

/// Represents the state of the empty state action view
public enum EmptyStateActionState: Equatable {
    case loggedOut
    case loggedIn
}

/// Data model for the empty state action view
public struct EmptyStateActionData: Equatable {
    public let state: EmptyStateActionState
    public let title: String
    public let actionButtonTitle: String
    public let image: String?
    public let isEnabled: Bool
    
    public init(state: EmptyStateActionState, title: String, actionButtonTitle: String = LocalizationProvider.string("log_in_to_bet"), image: String? = nil, isEnabled: Bool = true) {
        self.state = state
        self.title = title
        self.actionButtonTitle = actionButtonTitle
        self.image = image
        self.isEnabled = isEnabled
    }
}

// MARK: - View Model Protocol

/// Protocol defining the interface for EmptyStateActionView ViewModels
public protocol EmptyStateActionViewModelProtocol {
    /// Publisher for the empty state action data
    var dataPublisher: AnyPublisher<EmptyStateActionData, Never> { get }
    
    /// Current data (for immediate access)
    var currentData: EmptyStateActionData { get }
    
    /// Update the empty state
    func updateState(_ state: EmptyStateActionState)
    
    /// Update the title
    func updateTitle(_ title: String)
    
    /// Update the action button title
    func updateActionButtonTitle(_ title: String)
    
    /// Update the image
    func updateImage(_ image: String?)
    
    /// Set the enabled state
    func setEnabled(_ isEnabled: Bool)
    
    /// Callback closure for action button tap
    var onActionButtonTapped: (() -> Void)? { get set }
} 

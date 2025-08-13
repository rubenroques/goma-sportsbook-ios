import Foundation
import UIKit
import Combine

/// Data model for the quick add button view
public struct QuickAddButtonData: Equatable {
    public let amount: Int
    public let isEnabled: Bool
    
    public init(
        amount: Int,
        isEnabled: Bool = true
    ) {
        self.amount = amount
        self.isEnabled = isEnabled
    }
}

/// Protocol defining the interface for QuickAddButtonView ViewModels
public protocol QuickAddButtonViewModelProtocol {
    /// Publisher for the quick add button data
    var dataPublisher: AnyPublisher<QuickAddButtonData, Never> { get }
    
    /// Current data (for immediate access)
    var currentData: QuickAddButtonData { get }
    
    /// Update the amount
    func updateAmount(_ amount: Int)
    
    /// Set the enabled state
    func setEnabled(_ isEnabled: Bool)
    
    /// Callback closure for button tap
    var onButtonTapped: (() -> Void)? { get set }
} 
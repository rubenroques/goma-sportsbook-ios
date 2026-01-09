import Foundation
import Combine
import UIKit

/// State for the odds acceptance view
public enum OddsAcceptanceState: Equatable {
    case accepted
    case notAccepted
}

/// Data model for the odds acceptance view
public struct OddsAcceptanceData: Equatable {
    public let state: OddsAcceptanceState
    public let labelText: String
    public let linkText: String
    public let isEnabled: Bool
    
    public init(state: OddsAcceptanceState, labelText: String, linkText: String, isEnabled: Bool) {
        self.state = state
        self.labelText = labelText
        self.linkText = linkText
        self.isEnabled = isEnabled
    }
}

/// Protocol defining the interface for OddsAcceptanceView ViewModels
public protocol OddsAcceptanceViewModelProtocol {
    /// Publisher for the odds acceptance data
    var dataPublisher: AnyPublisher<OddsAcceptanceData, Never> { get }
    
    /// Current data (for immediate access)
    var currentData: OddsAcceptanceData { get }
    
    /// Update the acceptance state
    func updateState(_ state: OddsAcceptanceState)
    
    /// Update the label text
    func updateLabelText(_ text: String)
    
    /// Update the link text
    func updateLinkText(_ text: String)
    
    /// Set the enabled state
    func setEnabled(_ isEnabled: Bool)
    
    /// Handle checkbox tap
    func onCheckboxTapped()
    
    /// Handle link tap
    func onLinkTapped()
} 

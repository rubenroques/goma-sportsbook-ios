import Foundation
import Combine
import UIKit

/// State for the progress info check view
public enum ProgressInfoCheckState: Equatable {
    case incomplete(completedSegments: Int, totalSegments: Int)
    case complete
}

/// Data model for the progress info check view
public struct ProgressInfoCheckData: Equatable {
    public let state: ProgressInfoCheckState
    public let headerText: String
    public let title: String
    public let subtitle: String
    public let icon: String?
    public let isEnabled: Bool
    
    public init(state: ProgressInfoCheckState, headerText: String, title: String, subtitle: String, icon: String? = nil, isEnabled: Bool = true) {
        self.state = state
        self.headerText = headerText
        self.title = title
        self.subtitle = subtitle
        self.icon = icon
        self.isEnabled = isEnabled
    }
}

/// Protocol defining the interface for ProgressInfoCheckView ViewModels
public protocol ProgressInfoCheckViewModelProtocol {
    /// Publisher for the progress info check data
    var dataPublisher: AnyPublisher<ProgressInfoCheckData, Never> { get }
    
    /// Current data (for immediate access)
    var currentData: ProgressInfoCheckData { get }
    
    /// Update the progress state
    func updateState(_ state: ProgressInfoCheckState)
    
    /// Update the header text
    func updateHeaderText(_ text: String)
    
    /// Update the title
    func updateTitle(_ title: String)
    
    /// Update the subtitle
    func updateSubtitle(_ subtitle: String)
    
    /// Update the icon
    func updateIcon(_ icon: String?)
    
    /// Set the enabled state
    func setEnabled(_ isEnabled: Bool)
} 

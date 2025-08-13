import Foundation
import UIKit
import Combine

/// Data model for the bet summary row view
public struct BetSummaryRowData: Equatable {
    public let title: String
    public let value: String
    public let isEnabled: Bool
    
    public init(
        title: String,
        value: String,
        isEnabled: Bool = true
    ) {
        self.title = title
        self.value = value
        self.isEnabled = isEnabled
    }
}

/// Protocol defining the interface for BetSummaryRowView ViewModels
public protocol BetSummaryRowViewModelProtocol {
    /// Publisher for the bet summary row data
    var dataPublisher: AnyPublisher<BetSummaryRowData, Never> { get }
    
    /// Current data (for immediate access)
    var currentData: BetSummaryRowData { get }
    
    /// Update the title
    func updateTitle(_ title: String)
    
    /// Update the value
    func updateValue(_ value: String)
    
    /// Set the enabled state
    func setEnabled(_ isEnabled: Bool)
} 
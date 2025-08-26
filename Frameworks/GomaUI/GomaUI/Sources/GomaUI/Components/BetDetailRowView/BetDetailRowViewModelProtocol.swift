import Foundation
import Combine

/// Corner radius style for bet detail row
public enum BetDetailRowCornerStyle {
    case none
    case topOnly(radius: CGFloat)
    case bottomOnly(radius: CGFloat)
}

/// Data model for bet detail row information
public struct BetDetailRowData: Equatable {
    public let label: String
    public let value: String
    
    public init(
        label: String,
        value: String
    ) {
        self.label = label
        self.value = value
    }
}

/// Protocol defining the interface for BetDetailRowView ViewModels
public protocol BetDetailRowViewModelProtocol {
    /// Publisher for the bet detail row data
    var dataPublisher: AnyPublisher<BetDetailRowData, Never> { get }
}

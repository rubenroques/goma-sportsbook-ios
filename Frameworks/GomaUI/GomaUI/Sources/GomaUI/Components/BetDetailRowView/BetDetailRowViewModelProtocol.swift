import Foundation
import Combine

/// Corner radius style for bet detail row
public enum BetDetailRowCornerStyle {
    case none
    case topOnly(radius: CGFloat)
    case bottomOnly(radius: CGFloat)
    case all(radius: CGFloat)
}

/// Style for bet detail row presentation
public enum BetDetailRowStyle {
    case standard       // Left-aligned label, right-aligned value
    case header         // Centered text, different background
}

/// Data model for bet detail row information
public struct BetDetailRowData: Equatable {
    public let label: String
    public let value: String
    public let style: BetDetailRowStyle
    
    public init(
        label: String,
        value: String,
        style: BetDetailRowStyle = .standard
    ) {
        self.label = label
        self.value = value
        self.style = style
    }
}

/// Protocol defining the interface for BetDetailRowView ViewModels
public protocol BetDetailRowViewModelProtocol {
    /// Publisher for the bet detail row data
    var dataPublisher: AnyPublisher<BetDetailRowData, Never> { get }
}

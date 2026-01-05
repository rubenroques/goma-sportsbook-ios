import Foundation
import Combine

/// Data model for cashout slider information
public struct CashoutSliderData: Equatable {
    public let title: String
    public let minimumValue: Float
    public let maximumValue: Float
    public let currentValue: Float
    public let currency: String
    public let isEnabled: Bool
    public let selectionTitle: String
    
    public init(
        title: String,
        minimumValue: Float,
        maximumValue: Float,
        currentValue: Float,
        currency: String,
        isEnabled: Bool = true,
        selectionTitle: String
    ) {
        self.title = title
        self.minimumValue = minimumValue
        self.maximumValue = maximumValue
        self.currentValue = currentValue
        self.currency = currency
        self.isEnabled = isEnabled
        self.selectionTitle = selectionTitle
    }
}

/// Protocol defining the interface for CashoutSliderView ViewModels
public protocol CashoutSliderViewModelProtocol {
    /// Publisher for the cashout slider data
    var dataPublisher: AnyPublisher<CashoutSliderData, Never> { get }
    
    /// Button view model for the cashout button
    var buttonViewModel: ButtonViewModelProtocol { get }
    
    /// Handle slider value change
    func updateSliderValue(_ value: Float)
    
    /// Handle cashout button tap
    func handleCashoutTap()
    
    /// Set enabled state
    func setEnabled(_ isEnabled: Bool)
}

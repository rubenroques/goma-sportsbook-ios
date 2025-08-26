import Foundation
import Combine

/// State enum for cashout submission
public enum CashoutSubmissionState: Equatable {
    case success
    case error
}

/// Data model for cashout submission info
public struct CashoutSubmissionInfoData: Equatable {
    public let state: CashoutSubmissionState
    public let message: String
    public let isVisible: Bool
    
    public init(
        state: CashoutSubmissionState,
        message: String,
        isVisible: Bool = true
    ) {
        self.state = state
        self.message = message
        self.isVisible = isVisible
    }
}

/// Protocol defining the interface for CashoutSubmissionInfoView ViewModels
public protocol CashoutSubmissionInfoViewModelProtocol {
    /// Publisher for the cashout submission info data
    var dataPublisher: AnyPublisher<CashoutSubmissionInfoData, Never> { get }
    
    /// Button view model for the action button
    var buttonViewModel: ButtonViewModelProtocol { get }
    
    /// Handle button tap
    func handleButtonTap()
    
    /// Set visibility state
    func setVisible(_ isVisible: Bool)
}

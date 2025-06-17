import Combine
import UIKit

// MARK: - Display State
public struct SportTypeSelectorDisplayState: Equatable {
    public let sports: [SportTypeData]
    
    public init(sports: [SportTypeData]) {
        self.sports = sports
    }
}

// MARK: - View Model Protocol
public protocol SportTypeSelectorViewModelProtocol {
    var displayStatePublisher: AnyPublisher<SportTypeSelectorDisplayState, Never> { get }
}
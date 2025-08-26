import Foundation
import Combine
import UIKit

// MARK: - Data Models
public struct AmountPillData: Equatable, Hashable {
    public let id: String
    public let amount: String
    public let isSelected: Bool
    
    public init(id: String, amount: String, isSelected: Bool = false) {
        self.id = id
        self.amount = amount
        self.isSelected = isSelected
    }
}

// MARK: - View Model Protocol
public protocol AmountPillViewModelProtocol {
    /// Publisher for reactive updates
    var pillDataPublisher: AnyPublisher<AmountPillData, Never> { get }
    
    /// Update selection state
    func setSelected(_ isSelected: Bool)
}

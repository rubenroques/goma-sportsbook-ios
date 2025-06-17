import Combine
import UIKit

// MARK: - Data Models
public struct SportTypeData: Equatable, Hashable {
    public let id: String
    public let name: String
    public let iconName: String
    
    public init(id: String, name: String, iconName: String) {
        self.id = id
        self.name = name
        self.iconName = iconName
    }
}

// MARK: - Display State
public struct SportTypeSelectorItemDisplayState: Equatable {
    public let sportData: SportTypeData
    
    public init(sportData: SportTypeData) {
        self.sportData = sportData
    }
}

// MARK: - View Model Protocol
public protocol SportTypeSelectorItemViewModelProtocol {
    var displayStatePublisher: AnyPublisher<SportTypeSelectorItemDisplayState, Never> { get }
}
import Combine
import UIKit

// MARK: - Data Models
public struct CasinoCategoryBarData: Equatable, Hashable, Identifiable {
    
    public let id: String           // category identifier
    public let title: String        // category title (e.g., "New Games")
    public let buttonText: String   // button text (e.g., "All 41")
    
    public init(
        id: String,
        title: String,
        buttonText: String
    ) {
        self.id = id
        self.title = title
        self.buttonText = buttonText
    }
}

// MARK: - View Model Protocol
public protocol CasinoCategoryBarViewModelProtocol: AnyObject {
    // Individual property publishers for fine-grained updates
    var titlePublisher: AnyPublisher<String, Never> { get }
    var buttonTextPublisher: AnyPublisher<String, Never> { get }
    
    // Read-only properties
    var categoryId: String { get }
    
    // Actions
    func buttonTapped()
}

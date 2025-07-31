import Combine
import UIKit

// MARK: - Data Models
public struct PromotionalHeaderData: Equatable, Hashable {
    public let id: String
    public let icon: String
    public let title: String
    public let subtitle: String?
    
    public init(id: String, icon: String, title: String, subtitle: String? = nil) {
        self.id = id
        self.icon = icon
        self.title = title
        self.subtitle = subtitle
    }
}

// MARK: - View Model Protocol
public protocol PromotionalHeaderViewModelProtocol {
    func getHeaderData() -> PromotionalHeaderData
    func updateHeaderData(_ newData: PromotionalHeaderData)
} 

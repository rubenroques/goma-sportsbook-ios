import UIKit

// MARK: - View Model Protocol
public protocol BetslipTypeTabItemViewModelProtocol {
    // Content properties
    var title: String { get }
    var icon: String { get }
    var isSelected: Bool { get }
    
    // Actions
    var onTabTapped: (() -> Void)? { get set }
} 

//
//  MockQuickLinksTabBarViewModel.swift
//  GomaUI
//
//  Created by Ruben Roques on 19/05/2025.
//

import Combine
import UIKit

/// Mock implementation of `QuickLinksTabBarViewModelProtocol` for testing and previews.
final public class MockQuickLinksTabBarViewModel: QuickLinksTabBarViewModelProtocol {
    // MARK: - Properties
    private let quickLinksSubject: CurrentValueSubject<[QuickLinkItem], Never>
    
    public var quickLinksPublisher: AnyPublisher<[QuickLinkItem], Never> {
        return quickLinksSubject.eraseToAnyPublisher()
    }
    
    // MARK: - Actions
    public var onTabSelected: ((String) -> Void) = { _ in }
    
    // MARK: - Initialization
    public init(quickLinks: [QuickLinkItem]? = nil) {
        // Use provided quick links or default to standard mock links
        let links = quickLinks ?? Self.defaultQuickLinks
        self.quickLinksSubject = CurrentValueSubject(links)
    }
    
    // MARK: - QuickLinksTabBarViewModelProtocol
    public func didTapQuickLink(type: QuickLinkType) {
        print("Quick link tapped: \(type.rawValue)")
        // In a real implementation, this could send analytics events or perform other actions
    }
    
    // MARK: - Public Methods
    public func updateQuickLinks(_ newLinks: [QuickLinkItem]) {
        quickLinksSubject.send(newLinks)
    }
    
    // MARK: - Static Helpers
    private static var defaultQuickLinks: [QuickLinkItem] {
        return [
            QuickLinkItem(type: .aviator, title: "Aviator", icon: UIImage(named: "aviator_quick_link_icon", in: Bundle.module, with: nil)),
            QuickLinkItem(type: .virtual, title: "Virtual", icon: UIImage(named: "virtual_quick_link_icon", in: Bundle.module, with: nil)),
            QuickLinkItem(type: .slots, title: "Slots", icon: UIImage(named: "slots_quick_link_icon", in: Bundle.module, with: nil)),
            QuickLinkItem(type: .crash, title: "Crash", icon: UIImage(named: "crash_quick_link_icon", in: Bundle.module, with: nil)),
            QuickLinkItem(type: .promos, title: "Promos", icon: UIImage(named: "promos_quick_link_icon", in: Bundle.module, with: nil))
        ]
    }
    
    public static var sportsQuickLinks: [QuickLinkItem] {
        return [
            QuickLinkItem(type: .football, title: "Football", icon: UIImage(systemName: "soccerball")),
            QuickLinkItem(type: .basketball, title: "Basketball", icon: UIImage(systemName: "basketball")),
            QuickLinkItem(type: .tennis, title: "Tennis", icon: UIImage(systemName: "tennisball")),
            QuickLinkItem(type: .golf, title: "Golf", icon: UIImage(systemName: "figure.golf"))
        ]
    }
    
    public static var accountQuickLinks: [QuickLinkItem] {
        return [
            QuickLinkItem(type: .deposit, title: "Deposit", icon: UIImage(systemName: "arrow.down.circle")),
            QuickLinkItem(type: .withdraw, title: "Withdraw", icon: UIImage(systemName: "arrow.up.circle")),
            QuickLinkItem(type: .help, title: "Help", icon: UIImage(systemName: "questionmark.circle")),
            QuickLinkItem(type: .settings, title: "Settings", icon: UIImage(systemName: "gearshape"))
        ]
    }

}

// MARK: - Preview Provider
extension MockQuickLinksTabBarViewModel {
    public static var gamingMockViewModel: MockQuickLinksTabBarViewModel {
        return MockQuickLinksTabBarViewModel() // Uses defaultQuickLinks
    }
    
    public static var sportsMockViewModel: MockQuickLinksTabBarViewModel {
        return MockQuickLinksTabBarViewModel(quickLinks: Self.sportsQuickLinks)
    }
    
    public static var accountMockViewModel: MockQuickLinksTabBarViewModel {
        return MockQuickLinksTabBarViewModel(quickLinks: Self.accountQuickLinks)
    }
}

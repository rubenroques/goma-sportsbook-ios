//
//  QuickLinksTabBarViewModel.swift
//  BetssonCameroonApp
//
//  Created  Code on 11/09/2025.
//

import UIKit
import Combine
import GomaUI

/// Production implementation of QuickLinksTabBarViewModelProtocol for BetssonCameroonApp
final class QuickLinksTabBarViewModel: QuickLinksTabBarViewModelProtocol {
    
    // MARK: - Properties
    private let quickLinksSubject: CurrentValueSubject<[QuickLinkItem], Never>
    
    public var quickLinksPublisher: AnyPublisher<[QuickLinkItem], Never> {
        return quickLinksSubject.eraseToAnyPublisher()
    }
    
    // MARK: - Navigation Closures
    // Callback for tab selection (legacy compatibility)
    public var onTabSelected: ((String) -> Void) = { _ in }
    
    // Navigation closure for handling QuickLink selections
    public var onQuickLinkSelected: ((QuickLinkType) -> Void)?

    // MARK: - Initialization
    public init(quickLinks: [QuickLinkItem]? = nil) {
        // Use provided quick links or default to gaming links for sports screens
        let links = quickLinks ?? Self.defaultGamingQuickLinks
        self.quickLinksSubject = CurrentValueSubject(links)
    }
    
    // MARK: - QuickLinksTabBarViewModelProtocol
    public func didTapQuickLink(type: QuickLinkType) {
        print("🎯 QuickLinksTabBarViewModel: Quick link tapped - \(type.rawValue)")
        
        onQuickLinkSelected?(type)
        
        // Maintain backward compatibility with onTabSelected
        onTabSelected(type.rawValue)
    }
    
    // MARK: - Public Methods
    public func updateQuickLinks(_ newLinks: [QuickLinkItem]) {
        quickLinksSubject.send(newLinks)
    }
    
    // MARK: - Private Helper Methods
    private static func isCasinoQuickLink(_ type: QuickLinkType) -> Bool {
        switch type {
        case .aviator, .virtual, .slots, .crash, .promos:
            return true
        default:
            return false
        }
    }
    
    // MARK: - Static Configuration
    private static var defaultGamingQuickLinks: [QuickLinkItem] {
        return [
            QuickLinkItem(type: .aviator, title: localized("aviator"), icon: UIImage(named: "aviator_quick_link_icon")),
            QuickLinkItem(type: .virtual, title: localized("virtuals"), icon: UIImage(named: "virtual_quick_link_icon")),
            QuickLinkItem(type: .slots, title: localized("slots"), icon: UIImage(named: "slots_quick_link_icon")),
            QuickLinkItem(type: .crash, title: localized("crash"), icon: UIImage(named: "crash_quick_link_icon")),
            QuickLinkItem(type: .promos, title: localized("promos"), icon: UIImage(named: "promos_quick_link_icon"))
        ]
    }
}

// MARK: - Factory Methods
extension QuickLinksTabBarViewModel {
    /// Creates a ViewModel for sports screens with gaming quick links
    static func forSportsScreens() -> QuickLinksTabBarViewModel {
        return QuickLinksTabBarViewModel()
    }
    
    static func forCasinoScreens() -> QuickLinksTabBarViewModel {
        let casinoQuickLinks = [
            QuickLinkItem(type: .sports, title: localized("sports"), icon: UIImage(named: "sports_quick_link_icon")),
            QuickLinkItem(type: .live, title: localized("live"), icon: UIImage(named: "live_quick_link_icon")),
            QuickLinkItem(type: .lite, title: localized("lite"), icon: UIImage(named: "casino_quick_link_icon")),
            QuickLinkItem(type: .promos, title: localized("promos"), icon: UIImage(named: "promos_quick_link_icon"))
        ]

        return QuickLinksTabBarViewModel(quickLinks: casinoQuickLinks)
    }
    
    /// Creates a ViewModel with sports-specific quick links
    static func forSportsFilters() -> QuickLinksTabBarViewModel {
        let sportsLinks = [
            QuickLinkItem(type: .football, title: "Football", icon: UIImage(systemName: "soccerball")),
            QuickLinkItem(type: .basketball, title: "Basketball", icon: UIImage(systemName: "basketball")),
            QuickLinkItem(type: .tennis, title: "Tennis", icon: UIImage(systemName: "tennisball")),
            QuickLinkItem(type: .golf, title: "Golf", icon: UIImage(systemName: "figure.golf"))
        ]
        return QuickLinksTabBarViewModel(quickLinks: sportsLinks)
    }
    
    /// Creates a ViewModel with account-related quick links
    static func forAccountScreens() -> QuickLinksTabBarViewModel {
        let accountLinks = [
            QuickLinkItem(type: .deposit, title: "Deposit", icon: UIImage(systemName: "arrow.down.circle")),
            QuickLinkItem(type: .withdraw, title: "Withdraw", icon: UIImage(systemName: "arrow.up.circle")),
            QuickLinkItem(type: .help, title: "Help", icon: UIImage(systemName: "questionmark.circle")),
            QuickLinkItem(type: .settings, title: "Settings", icon: UIImage(systemName: "gearshape"))
        ]
        return QuickLinksTabBarViewModel(quickLinks: accountLinks)
    }
}

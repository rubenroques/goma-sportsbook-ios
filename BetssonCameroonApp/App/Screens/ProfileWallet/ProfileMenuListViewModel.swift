//
//  ProfileMenuListViewModel.swift
//  BetssonCameroonApp
//
//  Created by Claude on 29/08/2025.
//

import Foundation
import Combine
import GomaUI

/// Production implementation of ProfileMenuListViewModelProtocol for ProfileWallet feature
final class ProfileMenuListViewModel: ProfileMenuListViewModelProtocol {
    
    // MARK: - Publishers
    @Published private var menuItems: [ProfileMenuItem] = []
    @Published private var currentLanguage: String = "English"
    
    public var menuItemsPublisher: AnyPublisher<[ProfileMenuItem], Never> {
        $menuItems.eraseToAnyPublisher()
    }
    
    public var currentLanguagePublisher: AnyPublisher<String, Never> {
        $currentLanguage.eraseToAnyPublisher()
    }
    
    // MARK: - Properties
    private var onItemSelectedCallback: ((ProfileMenuItem) -> Void)?
    
    /// Set the callback for item selection after initialization
    public var onItemSelected: ((ProfileMenuItem) -> Void)? {
        get { onItemSelectedCallback }
        set { onItemSelectedCallback = newValue }
    }
    
    // MARK: - Initialization
    public init(onItemSelected: ((ProfileMenuItem) -> Void)? = nil) {
        self.onItemSelectedCallback = onItemSelected
        loadMenuConfiguration()
    }
    
    // MARK: - ProfileMenuListViewModelProtocol
    public func didSelectItem(_ item: ProfileMenuItem) {
        print("📱 ProfileMenuListViewModel: Selected menu item: \(item.title) (Action: \(item.action))")
        
        // Handle specific actions locally if needed
        switch item.action {
        case .changeLanguage:
            // Language change will be handled by coordinator/parent
            break
        case .logout:
            // Logout will be handled by coordinator
            break
        default:
            // Other navigation actions handled by coordinator
            break
        }
        
        // Delegate to parent via callback
        onItemSelectedCallback?(item)
    }
    
    public func loadConfiguration(from jsonFileName: String?) {
        // For now, use the default configuration
        // In the future, this could load from user preferences or server config
        loadMenuConfiguration()
    }
    
    public func updateCurrentLanguage(_ language: String) {
        currentLanguage = language
        print("🌐 ProfileMenuListViewModel: Language updated to \(language)")
    }
    
    // MARK: - Private Methods
    
    private func loadMenuConfiguration() {
        menuItems = [
            ProfileMenuItem(
                id: "promotions",
                icon: "promotion_icon",
                title: "Promotions",
                subtitle: nil,
                type: .navigation,
                action: .promotions
            ),
            ProfileMenuItem(
                id: "notifications",
                icon: "bell",
                title: "Notifications",
                subtitle: nil,
                type: .navigation,
                action: .notifications
            ),
            ProfileMenuItem(
                id: "transaction_history",
                icon: "clock",
                title: "Transaction History",
                subtitle: nil,
                type: .navigation,
                action: .transactionHistory
            ),
            ProfileMenuItem(
                id: "change_language",
                icon: "globe",
                title: "Change Language",
                subtitle: currentLanguage,
                type: .navigation,
                action: .changeLanguage
            ),
            ProfileMenuItem(
                id: "responsible_gaming",
                icon: "shield.checkered",
                title: "Responsible Gaming",
                subtitle: nil,
                type: .navigation,
                action: .responsibleGaming
            ),
            ProfileMenuItem(
                id: "help_center",
                icon: "questionmark.circle",
                title: "Help Center",
                subtitle: nil,
                type: .navigation,
                action: .helpCenter
            ),
            ProfileMenuItem(
                id: "change_password",
                icon: "lock",
                title: "Change Password",
                subtitle: nil,
                type: .navigation,
                action: .changePassword
            ),
            ProfileMenuItem(
                id: "logout",
                icon: "rectangle.portrait.and.arrow.right",
                title: "Logout",
                subtitle: nil,
                type: .action,
                action: .logout
            )
        ]
    }
}

//
//  ProfileMenuListViewModel.swift
//  BetssonCameroonApp
//
//  Created on 29/08/2025.
//

import Foundation
import Combine
import GomaUI

/// Production implementation of ProfileMenuListViewModelProtocol for ProfileWallet feature
final class ProfileMenuListViewModel: ProfileMenuListViewModelProtocol {
    
    // MARK: - Publishers
    @Published private var menuItems: [ActionRowItem] = []
    @Published private var currentLanguage: String = "English"

    public var menuItemsPublisher: AnyPublisher<[ActionRowItem], Never> {
        $menuItems.eraseToAnyPublisher()
    }

    public var currentLanguagePublisher: AnyPublisher<String, Never> {
        $currentLanguage.eraseToAnyPublisher()
    }

    // MARK: - Properties
    private var onItemSelectedCallback: ((ActionRowItem) -> Void)?

    /// Set the callback for item selection after initialization
    public var onItemSelected: ((ActionRowItem) -> Void)? {
        get { onItemSelectedCallback }
        set { onItemSelectedCallback = newValue }
    }

    // MARK: - Initialization
    public init(onItemSelected: ((ActionRowItem) -> Void)? = nil) {
        self.onItemSelectedCallback = onItemSelected
        loadMenuConfiguration()
    }

    // MARK: - ProfileMenuListViewModelProtocol
    public func didSelectItem(_ item: ActionRowItem) {
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
            ActionRowItem(
                id: "promotions",
                icon: "promotion_icon",
                title: "Promotions and Bonuses",
                subtitle: nil,
                type: .navigation,
                action: .promotions
            ),
            ActionRowItem(
                id: "notifications",
                icon: "bell",
                title: "Notifications",
                subtitle: nil,
                type: .navigation,
                action: .notifications
            ),
            ActionRowItem(
                id: "transaction_history",
                icon: "clock",
                title: "Transaction History",
                subtitle: nil,
                type: .navigation,
                action: .transactionHistory
            ),
            ActionRowItem(
                id: "change_language",
                icon: "globe",
                title: "Change Language",
                subtitle: currentLanguage,
                type: .navigation,
                action: .changeLanguage
            ),
            ActionRowItem(
                id: "responsible_gaming",
                icon: "shield.checkered",
                title: "Responsible Gaming",
                subtitle: nil,
                type: .navigation,
                action: .responsibleGaming
            ),
            ActionRowItem(
                id: "help_center",
                icon: "questionmark.circle",
                title: "Help Center",
                subtitle: nil,
                type: .navigation,
                action: .helpCenter
            ),
            ActionRowItem(
                id: "change_password",
                icon: "lock",
                title: "Change Password",
                subtitle: nil,
                type: .navigation,
                action: .changePassword
            ),
            ActionRowItem(
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

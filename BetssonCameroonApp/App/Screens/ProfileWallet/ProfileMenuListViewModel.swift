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
        self.currentLanguage = Self.displayNameForLanguageCode(localized("current_language_code"))
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
        loadMenuConfiguration() // Reload menu to update language subtitle
        print("🌐 ProfileMenuListViewModel: Language updated to \(language)")
    }
    
    // MARK: - Private Methods
    
    private func loadMenuConfiguration() {
        menuItems = [
            ActionRowItem(
                id: "promotions",
                icon: "promotion_icon",
                title: localized("promotions"),
                subtitle: nil,
                type: .navigation,
                action: .promotions
            ),
            ActionRowItem(
                id: "promotions",
                icon: "promotion_icon",
                title: localized("bonuses"),
                subtitle: nil,
                type: .navigation,
                action: .bonus
            ),
            ActionRowItem(
                id: "notifications",
                icon: "bell",
                title: localized("view_notifications"),
                subtitle: nil,
                type: .navigation,
                action: .notifications
            ),
            ActionRowItem(
                id: "notification_settings",
                icon: "bell.badge",
                title: localized("notifications_settings"),
                subtitle: nil,
                type: .navigation,
                action: .notificationSettings
            ),
            ActionRowItem(
                id: "transaction_history",
                icon: "clock",
                title: localized("transaction_history"),
                subtitle: nil,
                type: .navigation,
                action: .transactionHistory
            ),
            ActionRowItem(
                id: "change_language",
                icon: "globe",
                title: localized("change_language"),
                subtitle: currentLanguage,
                type: .navigation,
                action: .changeLanguage
            ),
            ActionRowItem(
                id: "responsible_gaming",
                icon: "shield.checkered",
                title: localized("responsible_gaming_title"),
                subtitle: nil,
                type: .navigation,
                action: .responsibleGaming
            ),
            ActionRowItem(
                id: "help_center",
                icon: "questionmark.circle",
                title: localized("help_center"),
                subtitle: nil,
                type: .navigation,
                action: .helpCenter
            ),
            ActionRowItem(
                id: "change_password",
                icon: "lock",
                title: localized("change_password"),
                subtitle: nil,
                type: .navigation,
                action: .changePassword
            ),
            ActionRowItem(
                id: "logout",
                icon: "rectangle.portrait.and.arrow.right",
                title: localized("logout"),
                subtitle: nil,
                type: .action,
                action: .logout
            )
        ]
    }

    /// Maps language code to display name
    static func displayNameForLanguageCode(_ code: String) -> String {
        switch code.lowercased() {
        case "en":
            return localized("language_english")
        case "fr":
            return localized("language_french")
        default:
            return localized("language_english") // Fallback to English
        }
    }
}

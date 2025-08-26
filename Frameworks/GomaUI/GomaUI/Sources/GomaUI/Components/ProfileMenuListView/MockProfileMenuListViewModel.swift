//
//  MockProfileMenuListViewModel.swift
//  GomaUI
//
//  Created by Ruben Roques Code on 25/08/2025.
//

import Foundation
import Combine

/// Mock implementation of ProfileMenuListViewModelProtocol for testing and previews
public final class MockProfileMenuListViewModel: ProfileMenuListViewModelProtocol {
    
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
    
    // MARK: - Initialization
    public init(onItemSelected: ((ProfileMenuItem) -> Void)? = nil) {
        self.onItemSelectedCallback = onItemSelected
        loadDefaultConfiguration()
    }
    
    // MARK: - ProfileMenuListViewModelProtocol
    public func didSelectItem(_ item: ProfileMenuItem) {
        print("📱 Mock: Selected menu item: \(item.title) (Action: \(item.action))")
        
        // Handle specific actions
        switch item.action {
        case .changeLanguage:
            // Simulate language change
            let languages = ["English", "French", "Spanish", "German"]
            if let currentIndex = languages.firstIndex(of: currentLanguage) {
                let nextIndex = (currentIndex + 1) % languages.count
                updateCurrentLanguage(languages[nextIndex])
            }
            
        case .logout:
            print("🚪 Mock: Logout action triggered")
            
        default:
            print("⚡ Mock: Navigation action for \(item.action)")
        }
        
        onItemSelectedCallback?(item)
    }
    
    public func loadConfiguration(from jsonFileName: String?) {
        if let jsonFileName = jsonFileName {
            loadConfigurationFromJSON(fileName: jsonFileName)
        } else {
            loadDefaultConfiguration()
        }
    }
    
    public func updateCurrentLanguage(_ language: String) {
        currentLanguage = language
        print("🌐 Mock: Language updated to \(language)")
        
        // Update the language menu item
        updateLanguageMenuItem(with: language)
    }
    
    // MARK: - Private Methods
    private func loadDefaultConfiguration() {
        menuItems = [
            ProfileMenuItem(
                id: "notifications",
                icon: "bell",
                title: "Notifications",
                type: .navigation,
                action: .notifications
            ),
            ProfileMenuItem(
                id: "transaction_history",
                icon: "clock",
                title: "Transaction History",
                type: .navigation,
                action: .transactionHistory
            ),
            ProfileMenuItem(
                id: "change_language",
                icon: "globe",
                title: "Change Language",
                type: .selection(currentLanguage),
                action: .changeLanguage
            ),
            ProfileMenuItem(
                id: "responsible_gaming",
                icon: "shield.checkered",
                title: "Responsible Gaming",
                type: .navigation,
                action: .responsibleGaming
            ),
            ProfileMenuItem(
                id: "help_center",
                icon: "questionmark.circle",
                title: "Help Center",
                type: .navigation,
                action: .helpCenter
            ),
            ProfileMenuItem(
                id: "change_password",
                icon: "lock",
                title: "Change Password",
                type: .navigation,
                action: .changePassword
            ),
            ProfileMenuItem(
                id: "logout",
                icon: "rectangle.portrait.and.arrow.right",
                title: "Logout",
                type: .action,
                action: .logout
            )
        ]
    }
    
    private func loadConfigurationFromJSON(fileName: String) {
        guard let path = Bundle.main.path(forResource: fileName, ofType: "json") else {
            print("⚠️ Mock: Could not find JSON file: \(fileName).json - using default configuration")
            loadDefaultConfiguration()
            return
        }
        
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: path))
            let configuration = try JSONDecoder().decode(ProfileMenuConfiguration.self, from: data)
            
            // Update language selection item with current language
            menuItems = configuration.menuItems.map { item in
                if item.action == .changeLanguage {
                    return ProfileMenuItem(
                        id: item.id,
                        icon: item.icon,
                        title: item.title,
                        type: .selection(currentLanguage),
                        action: item.action
                    )
                }
                return item
            }
            
            print("✅ Mock: Loaded \(menuItems.count) menu items from \(fileName).json")
        } catch {
            print("❌ Mock: Error loading JSON configuration: \(error)")
            loadDefaultConfiguration()
        }
    }
    
    private func updateLanguageMenuItem(with language: String) {
        menuItems = menuItems.map { item in
            if item.action == .changeLanguage {
                return ProfileMenuItem(
                    id: item.id,
                    icon: item.icon,
                    title: item.title,
                    type: .selection(language),
                    action: item.action
                )
            }
            return item
        }
    }
}

// MARK: - Static Factory Methods
extension MockProfileMenuListViewModel {
    
    /// Default mock instance with all menu items
    public static var defaultMock: MockProfileMenuListViewModel {
        MockProfileMenuListViewModel { item in
            print("🎯 Default Mock: Selected \(item.title)")
        }
    }
    
    /// Mock instance that loads from JSON configuration
    public static func jsonConfigurationMock(fileName: String) -> MockProfileMenuListViewModel {
        let mock = MockProfileMenuListViewModel { item in
            print("🎯 JSON Mock: Selected \(item.title)")
        }
        mock.loadConfiguration(from: fileName)
        return mock
    }
    
    /// Mock instance with French language preset
    public static var frenchLanguageMock: MockProfileMenuListViewModel {
        let mock = MockProfileMenuListViewModel { item in
            print("🎯 French Mock: Selected \(item.title)")
        }
        mock.updateCurrentLanguage("French")
        return mock
    }
    
    /// Mock instance with custom callback
    public static func customCallbackMock(onItemSelected: @escaping (ProfileMenuItem) -> Void) -> MockProfileMenuListViewModel {
        MockProfileMenuListViewModel(onItemSelected: onItemSelected)
    }
    
    /// Mock instance for interactive demo (cycles through languages)
    public static var interactiveMock: MockProfileMenuListViewModel {
        MockProfileMenuListViewModel { item in
            print("🎯 Interactive Mock: Selected \(item.title)")
            
            // Additional interactive behaviors can be added here
            switch item.action {
            case .notifications:
                print("🔔 Would open notifications screen")
            case .transactionHistory:
                print("📋 Would open transaction history")
            case .changeLanguage:
                print("🌐 Language selection triggered")
            case .responsibleGaming:
                print("🛡️ Would open responsible gaming settings")
            case .helpCenter:
                print("❓ Would open help center")
            case .changePassword:
                print("🔒 Would open change password screen")
            case .logout:
                print("🚪 Would show logout confirmation")
            }
        }
    }
}

import Foundation
import Combine

/// Mock implementation of ProfileMenuListViewModelProtocol for testing and previews
public final class MockProfileMenuListViewModel: ProfileMenuListViewModelProtocol {

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

    /// Callback for menu item selection - can be set after initialization
    public var onItemSelected: ((ActionRowItem) -> Void)? {
        get { onItemSelectedCallback }
        set { onItemSelectedCallback = newValue }
    }

    // MARK: - Initialization
    public init(onItemSelected: ((ActionRowItem) -> Void)? = nil) {
        self.onItemSelectedCallback = onItemSelected
        loadDefaultConfiguration()
    }

    // MARK: - ProfileMenuListViewModelProtocol
    public func didSelectItem(_ item: ActionRowItem) {
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
    }
    
    // MARK: - Private Methods
    private func loadDefaultConfiguration() {
        menuItems = [
            ActionRowItem(
                id: "notifications",
                icon: "bell",
                title: "Notifications",
                type: .navigation,
                action: .notifications
            ),
            ActionRowItem(
                id: "transaction_history",
                icon: "clock",
                title: "Transaction History",
                type: .navigation,
                action: .transactionHistory
            ),
            ActionRowItem(
                id: "change_language",
                icon: "globe",
                title: "Change Language",
                type: .navigation,
                action: .changeLanguage
            ),
            ActionRowItem(
                id: "responsible_gaming",
                icon: "shield.checkered",
                title: "Responsible Gaming",
                type: .navigation,
                action: .responsibleGaming
            ),
            ActionRowItem(
                id: "help_center",
                icon: "questionmark.circle",
                title: "Help Center",
                type: .navigation,
                action: .helpCenter
            ),
            ActionRowItem(
                id: "change_password",
                icon: "lock",
                title: "Change Password",
                type: .navigation,
                action: .changePassword
            ),
            ActionRowItem(
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
            
            menuItems = configuration.menuItems
            
            print("✅ Mock: Loaded \(menuItems.count) menu items from \(fileName).json")
        } catch {
            print("❌ Mock: Error loading JSON configuration: \(error)")
            loadDefaultConfiguration()
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
    public static func customCallbackMock(onItemSelected: @escaping (ActionRowItem) -> Void) -> MockProfileMenuListViewModel {
        MockProfileMenuListViewModel(onItemSelected: onItemSelected)
    }
    
    /// Mock instance for interactive demo (cycles through languages)
    public static var interactiveMock: MockProfileMenuListViewModel {
        MockProfileMenuListViewModel { item in
            print("🎯 Interactive Mock: Selected \(item.title)")
            
            // Additional interactive behaviors can be added here
            switch item.action {
            case .notifications:
                print("Would open notifications screen")
            case .transactionHistory:
                print("Would open transaction history")
            case .changeLanguage:
                print("Language selection triggered")
            case .responsibleGaming:
                print("Would open responsible gaming settings")
            case .helpCenter:
                print("Would open help center")
            case .changePassword:
                print("Would open change password screen")
            case .logout:
                print("Would show logout confirmation")
            case .promotions:
                print("🚪 Would open promotions screen")
            case .bonus:
                print("🚪 Would open bonus screen")
            case .custom:
                print("Custom action triggered")
            case .notificationSettings:
                print("Notification Settings")
            }
        }
    }
}

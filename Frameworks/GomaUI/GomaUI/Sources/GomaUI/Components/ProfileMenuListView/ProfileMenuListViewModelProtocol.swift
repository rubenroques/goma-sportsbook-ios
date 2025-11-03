import Foundation
import Combine

/// Protocol defining the interface for ProfileMenuListView view model
public protocol ProfileMenuListViewModelProtocol {

    /// Publisher that emits the list of menu items
    var menuItemsPublisher: AnyPublisher<[ActionRowItem], Never> { get }

    /// Publisher that emits the current language for the language selection item
    var currentLanguagePublisher: AnyPublisher<String, Never> { get }

    /// Callback for menu item selection - can be set after initialization
    var onItemSelected: ((ActionRowItem) -> Void)? { get set }

    /// Called when a menu item is selected
    /// - Parameter item: The selected menu item
    func didSelectItem(_ item: ActionRowItem)

    /// Loads menu configuration from a JSON file
    /// - Parameter jsonFileName: Name of the JSON file (without extension), nil for default
    func loadConfiguration(from jsonFileName: String?)

    /// Updates the current language display value
    /// - Parameter language: The new language name to display
    func updateCurrentLanguage(_ language: String)
}

/// Configuration structure for loading menu items from JSON
public struct ProfileMenuConfiguration: Codable {
    public let menuItems: [ActionRowItem]

    public init(menuItems: [ActionRowItem]) {
        self.menuItems = menuItems
    }
}

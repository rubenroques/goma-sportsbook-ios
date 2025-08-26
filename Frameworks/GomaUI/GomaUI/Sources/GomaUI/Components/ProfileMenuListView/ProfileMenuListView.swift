import UIKit
import Combine
import SwiftUI

/// Main container view for profile menu list with multiple menu items
public final class ProfileMenuListView: UIView {
    
    // MARK: Private properties
    private lazy var containerView: UIView = Self.createContainerView()
    private lazy var stackView: UIStackView = Self.createStackView()
    
    // MARK: - Properties
    private let viewModel: ProfileMenuListViewModelProtocol
    private var cancellables = Set<AnyCancellable>()
    private var menuItemViews: [ProfileMenuItemView] = []
    private var currentLanguage: String = "English"
    
    // MARK: - Lifetime and Cycle
    public init(viewModel: ProfileMenuListViewModelProtocol) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        commonInit()
        setupWithTheme()
        setupBindings()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented - use init(viewModel:) instead")
    }
    
    func commonInit() {
        setupSubviews()
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        containerView.layer.cornerRadius = 16
    }
    
    func setupWithTheme() {
        backgroundColor = .clear
        containerView.backgroundColor = StyleProvider.Color.backgroundPrimary
    }
    
    // MARK: Functions
    private func setupBindings() {
        // Bind menu items
        viewModel.menuItemsPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] menuItems in
                self?.updateMenuItems(menuItems)
            }
            .store(in: &cancellables)
        
        // Bind current language updates
        viewModel.currentLanguagePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] language in
                self?.currentLanguage = language
                self?.updateLanguageValue(language)
            }
            .store(in: &cancellables)
    }
    
    private func updateMenuItems(_ menuItems: [ProfileMenuItem]) {
        // Cache menu items
        cachedMenuItems = menuItems
        
        // Clear existing views
        clearMenuItemViews()
        
        // Create new views
        menuItemViews = menuItems.map { menuItem in
            let itemView = ProfileMenuItemView()
            
            // Create updated item with current language if needed
            var updatedItem = menuItem
            if menuItem.action == .changeLanguage,
               case .selection = menuItem.type {
                // Use actual current language from viewModel binding
                updatedItem = ProfileMenuItem(
                    id: menuItem.id,
                    icon: menuItem.icon,
                    title: menuItem.title,
                    type: .selection(currentLanguage),
                    action: menuItem.action
                )
            }
            
            itemView.configure(with: updatedItem) { [weak self] selectedItem in
                self?.viewModel.didSelectItem(selectedItem)
            }
            
            return itemView
        }
        
        // Add views to stack
        menuItemViews.forEach { itemView in
            stackView.addArrangedSubview(itemView)
        }
    }
    
    private func updateLanguageValue(_ language: String) {
        // Find and update the language menu item
        for (index, itemView) in menuItemViews.enumerated() {
            let menuItem = cachedMenuItems[index]
            if menuItem.action == .changeLanguage {
                let updatedItem = ProfileMenuItem(
                    id: menuItem.id,
                    icon: menuItem.icon,
                    title: menuItem.title,
                    type: .selection(language),
                    action: menuItem.action
                )
                
                itemView.configure(with: updatedItem) { [weak self] selectedItem in
                    self?.viewModel.didSelectItem(selectedItem)
                }
                break
            }
        }
    }
    
    private var cachedMenuItems: [ProfileMenuItem] = []
    
    private func getCurrentMenuItems() -> [ProfileMenuItem] {
        return cachedMenuItems
    }
    
    private func clearMenuItemViews() {
        menuItemViews.forEach { itemView in
            itemView.removeFromSuperview()
        }
        menuItemViews.removeAll()
    }
}

// MARK: - Subviews Initialization and Setup
extension ProfileMenuListView {
    
    private static func createContainerView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
    
    private static func createStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.spacing = 8
        return stackView
    }
    
    private func setupSubviews() {
        addSubview(containerView)
        containerView.addSubview(stackView)
        
        initConstraints()
    }
    
    private func initConstraints() {
        NSLayoutConstraint.activate([
            // Container
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            // Stack view
            stackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 8),
            stackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -8),
            stackView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 8),
            stackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -8)
        ])
    }
}

// MARK: - SwiftUI Preview
#if DEBUG

@available(iOS 17.0, *)
#Preview("Profile Menu List") {
    PreviewUIViewController {
        let vc = UIViewController()
        let mockViewModel = MockProfileMenuListViewModel.defaultMock
        let profileMenuView = ProfileMenuListView(viewModel: mockViewModel)
        profileMenuView.translatesAutoresizingMaskIntoConstraints = false
        
        vc.view.backgroundColor = StyleProvider.Color.backgroundTertiary
        vc.view.addSubview(profileMenuView)
        
        NSLayoutConstraint.activate([
            profileMenuView.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor, constant: 16),
            profileMenuView.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor, constant: -16),
            profileMenuView.centerYAnchor.constraint(equalTo: vc.view.centerYAnchor)
        ])
        
        return vc
    }
}

#endif

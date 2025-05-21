//
//  AdaptiveTabBarView.swift
//  Sportsbook
//
//  Created by Ruben Roques on 16/05/2025.
//


import UIKit
import Combine
import SwiftUI

final class AdaptiveTabBarView: UIView {
    // MARK: - Private Properties
    private lazy var stackView: UIStackView = Self.createStackView()
    private var tabItems: [AdaptiveTabBarItemView] = []
    
    private let viewModel: AdaptiveTabBarViewModel
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Public Properties
    var onTabSelected: ((AdaptiveTabBarViewModel.TabItem) -> Void)?
    
    // MARK: - Initialization
    init(viewModel: AdaptiveTabBarViewModel) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        setupSubviews()
        setupBindings()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Private Methods
    private func setupBindings() {
        viewModel.$visibleTabs
            .sink { [weak self] tabs in
                self?.updateTabs(tabs)
            }
            .store(in: &cancellables)
        
        viewModel.$selectedTab
            .sink { [weak self] selectedTab in
                self?.updateSelectedTab(selectedTab)
            }
            .store(in: &cancellables)
    }
    
    private func updateTabs(_ tabs: [AdaptiveTabBarViewModel.TabItem]) {
        // Remove existing tabs
        tabItems.forEach { $0.removeFromSuperview() }
        tabItems.removeAll()
        
        // Create new tabs
        tabs.forEach { tab in
            let tabView = createTabItem(for: tab)
            stackView.addArrangedSubview(tabView)
            tabItems.append(tabView)
        }
    }
    
    private func updateSelectedTab(_ selectedTab: AdaptiveTabBarViewModel.TabItem?) {
        for (index, tab) in viewModel.visibleTabs.enumerated() {
            let isActive = tab == selectedTab // It can be nil and nothing will appear selected
            let config = AdaptiveTabBarItemView.Configuration(
                icon: tab.icon ?? UIImage(),
                title: tab.title,
                isActive: isActive
            )
            tabItems[index].configure(with: config)
        }
    }
    
    private func createTabItem(for tab: AdaptiveTabBarViewModel.TabItem) -> AdaptiveTabBarItemView {
        let tabView = AdaptiveTabBarItemView()
        tabView.translatesAutoresizingMaskIntoConstraints = false
        
        let config = AdaptiveTabBarItemView.Configuration(
            icon: tab.icon ?? UIImage(),
            title: tab.title,
            isActive: tab == viewModel.selectedTab
        )
        tabView.configure(with: config)
        
        tabView.onTap = { [weak self, weak viewModel] in
            viewModel?.selectTab(tab)
            self?.onTabSelected?(tab)
        }
        
        return tabView
    }
}

// MARK: - Factory Methods
private extension AdaptiveTabBarView {
    static func createStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 16
        return stackView
    }
}

// MARK: - Constraints
private extension AdaptiveTabBarView {
    
    private func setupSubviews() {
        self.addSubview(self.stackView)
        self.backgroundColor = UIColor.App.backgroundSecondary
        
        self.initConstraints()
    }
    
    func initConstraints() {
        NSLayoutConstraint.activate([
            self.stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            self.stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            self.stackView.topAnchor.constraint(equalTo: topAnchor),
            self.stackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            self.heightAnchor.constraint(equalToConstant: 52)
        ])
    }
    
}

// MARK: - Preview Provider
#if DEBUG
@available(iOS 17.0, *)
#Preview("Default Tabs") {
    PreviewUIView {
        AdaptiveTabBarView(viewModel: .mockDefault())
    }
    .frame(height: 52)
    .padding()
}

@available(iOS 17.0, *)
#Preview("All Features") {
    PreviewUIView {
        AdaptiveTabBarView(viewModel: .mockAllFeatures())
    }
    .frame(height: 52)
    .padding()
}

@available(iOS 17.0, *)
#Preview("With Casino") {
    PreviewUIView {
        AdaptiveTabBarView(viewModel: .mockWithCasinoSelected())
    }
    .frame(height: 52)
    .padding()
}
#endif

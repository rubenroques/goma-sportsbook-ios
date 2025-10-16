import UIKit
import Combine
import SwiftUI

public class BetslipTypeSelectorView: UIView {
    
    // MARK: - Private Properties
    private var viewModel: BetslipTypeSelectorViewModelProtocol
    private var cancellables = Set<AnyCancellable>()
    private var tabItemViews: [String: BetslipTypeTabItemView] = [:]
    
    // MARK: - UI Components
    private let containerView = UIView()
    private let stackView = UIStackView()
    
    // MARK: - Layout Constants
    private struct Constants {
        static let horizontalPadding: CGFloat = 16.0
        static let verticalPadding: CGFloat = 12.0
        static let tabItemSpacing: CGFloat = 0.0
        static let cornerRadius: CGFloat = 8.0
        static let animationDuration: TimeInterval = 0.3
        static let height: CGFloat = 50.0
        static let indicatorHeight: CGFloat = 3.0
    }
    
    // MARK: - Initialization
    public init(viewModel: BetslipTypeSelectorViewModelProtocol) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        setupSubviews()
        setupConstraints()
        setupBindings()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup Methods
    private func setupSubviews() {
        self.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(containerView)
        containerView.addSubview(stackView)
        
        // Container view setup
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.backgroundColor = .clear
        containerView.layer.cornerRadius = Constants.cornerRadius
        
        // Stack view setup
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.spacing = Constants.tabItemSpacing
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        
        // View styling
        self.backgroundColor = .clear
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Container view
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            // Stack view
            stackView.topAnchor.constraint(equalTo: containerView.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: Constants.horizontalPadding),
            stackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -Constants.horizontalPadding),
            stackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])
    }
    
    private func setupBindings() {
        // Subscribe to tabs updates
        viewModel.tabsPublisher
            .sink { [weak self] tabs in
                self?.updateTabs(tabs)
            }
            .store(in: &cancellables)
        
        // Subscribe to selection updates
        viewModel.selectedTabIdPublisher
            .sink { [weak self] selectedId in
                self?.updateSelection(selectedId)
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Private Methods
    private func updateTabs(_ tabs: [BetslipTypeTabData]) {
        // Clear existing tab views
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        tabItemViews.removeAll()
        
        // Create new tab views
        for tab in tabs {
            let tabViewModel = MockBetslipTypeTabItemViewModel(
                title: tab.title,
                icon: tab.icon,
                isSelected: tab.isSelected
            )
            
            let tabView = BetslipTypeTabItemView(viewModel: tabViewModel)
            tabView.translatesAutoresizingMaskIntoConstraints = false
            
            // Set up tap callback
            tabViewModel.onTabTapped = { [weak self] in
                self?.viewModel.selectTab(id: tab.id)
            }
            
            stackView.addArrangedSubview(tabView)
            tabItemViews[tab.id] = tabView
        }
    }
    
    private func updateSelection(_ selectedId: String?) {
        guard let selectedId = selectedId else { return }
        
        // Update all tab views
        for (id, tabView) in tabItemViews {
            let isSelected = (id == selectedId)
            tabView.updateSelectionState(isSelected: isSelected)
        }
    }
    
    @objc private func tabTapped(_ gesture: UITapGestureRecognizer) {
        guard let tabView = gesture.view as? BetslipTypeTabItemView,
              let tabId = tabItemViews.first(where: { $0.value == tabView })?.key else { return }
        
        viewModel.selectTab(id: tabId)
    }
}

// MARK: - SwiftUI Preview
#if DEBUG

@available(iOS 17.0, *)
#Preview("Sports Selected") {
    PreviewUIViewController {
        let vc = UIViewController()
        vc.view.backgroundColor = StyleProvider.Color.backgroundPrimary

        let selectorView = BetslipTypeSelectorView(viewModel: MockBetslipTypeSelectorViewModel.sportsSelectedMock())
        selectorView.translatesAutoresizingMaskIntoConstraints = false
        vc.view.addSubview(selectorView)

        NSLayoutConstraint.activate([
            selectorView.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor, constant: 20),
            selectorView.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor, constant: -20),
            selectorView.centerYAnchor.constraint(equalTo: vc.view.centerYAnchor),
            selectorView.heightAnchor.constraint(equalToConstant: 50)
        ])

        return vc
    }
}

@available(iOS 17.0, *)
#Preview("Virtuals Selected") {
    PreviewUIViewController {
        let vc = UIViewController()
        vc.view.backgroundColor = StyleProvider.Color.backgroundPrimary

        let selectorView = BetslipTypeSelectorView(viewModel: MockBetslipTypeSelectorViewModel.virtualsSelectedMock())
        selectorView.translatesAutoresizingMaskIntoConstraints = false
        vc.view.addSubview(selectorView)

        NSLayoutConstraint.activate([
            selectorView.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor, constant: 20),
            selectorView.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor, constant: -20),
            selectorView.centerYAnchor.constraint(equalTo: vc.view.centerYAnchor),
            selectorView.heightAnchor.constraint(equalToConstant: 50)
        ])

        return vc
    }
}

#endif 

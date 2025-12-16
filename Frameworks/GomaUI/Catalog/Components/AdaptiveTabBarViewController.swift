import UIKit
import GomaUI

class AdaptiveTabBarViewController: UIViewController {
    
    private var adaptiveTabBar: AdaptiveTabBarView!
    private var tabControlButtons = [UIButton]()
    private var currentTabBarLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        
        // Setup AdaptiveTabBarView
        self.setupAdaptiveTabBar()
        
        // Setup tab control buttons and current tab bar label
        self.setupControls()
    }
    
    private func setupAdaptiveTabBar() {
        self.adaptiveTabBar = AdaptiveTabBarView(viewModel: MockAdaptiveTabBarViewModel.defaultMock)
        self.adaptiveTabBar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(self.adaptiveTabBar)
        
        NSLayoutConstraint.activate([
            adaptiveTabBar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            adaptiveTabBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            adaptiveTabBar.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        self.adaptiveTabBar.onTabSelected = { [weak self] selectedTabItem in
            self?.handleTabSelection(selectedTabItem)
        }
    }
    
    private func setupControls() {
        // Current tab bar label
        currentTabBarLabel = UILabel()
        currentTabBarLabel.translatesAutoresizingMaskIntoConstraints = false
        currentTabBarLabel.font = UIFont.boldSystemFont(ofSize: 18)
        currentTabBarLabel.textAlignment = .center
        currentTabBarLabel.text = "Current: Home Tab Bar"
        view.addSubview(currentTabBarLabel)
        
        // Tab control buttons
        let buttonTitles = ["Default Tabs", "Complex Tabs"]
        
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 10
        view.addSubview(stackView)
        
        for (index, title) in buttonTitles.enumerated() {
            let button = UIButton(type: .system)
            button.setTitle(title, for: .normal)
            button.backgroundColor = .systemBlue
            button.setTitleColor(.white, for: .normal)
            button.layer.cornerRadius = 8
            button.tag = index
            button.addTarget(self, action: #selector(tabControlButtonTapped(_:)), for: .touchUpInside)
            
            stackView.addArrangedSubview(button)
            tabControlButtons.append(button)
        }
        
        // Add information label
        let infoLabel = UILabel()
        infoLabel.translatesAutoresizingMaskIntoConstraints = false
        infoLabel.font = UIFont.systemFont(ofSize: 14)
        infoLabel.textAlignment = .center
        infoLabel.text = "Tap the buttons above to switch between tab bar configurations.\nTap tabs below to navigate between them."
        infoLabel.numberOfLines = 0
        view.addSubview(infoLabel)
        
        // Layout constraints
        NSLayoutConstraint.activate([
            currentTabBarLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            currentTabBarLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.topAnchor.constraint(equalTo: currentTabBarLabel.bottomAnchor, constant: 20),
            stackView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
            
            infoLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            infoLabel.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 20),
            infoLabel.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.9)
        ])
    }
    
    @objc private func tabControlButtonTapped(_ sender: UIButton) {
        switch sender.tag {
        case 0:
            adaptiveTabBar = AdaptiveTabBarView(viewModel: MockAdaptiveTabBarViewModel.defaultMock)
            currentTabBarLabel.text = "Current: Home Tab Bar"
        case 1:
            adaptiveTabBar = AdaptiveTabBarView(viewModel: MockAdaptiveTabBarViewModel.defaultMock)
            currentTabBarLabel.text = "missing mock"
        default:
            break
        }
        
        // Re-add and setup the tab bar
        adaptiveTabBar.removeFromSuperview()
        setupAdaptiveTabBar()
    }
    
    private func handleTabSelection(_ selectedTabItem: TabItem) {
        // Update the current tab bar label based on selected tab
        if let switchToTabBar = selectedTabItem.switchToTabBar {
            currentTabBarLabel.text = "Current: \(switchToTabBar.rawValue.capitalized) Tab Bar"
        }
    }
} 

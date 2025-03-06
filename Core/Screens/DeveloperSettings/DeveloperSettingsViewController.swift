import UIKit

class DeveloperSettingsViewController: UIViewController {
    private let scrollView = UIScrollView()
    private let stackView = UIStackView()
    
    // MARK: - Environment Settings
    private let environmentSegmentedControl = UISegmentedControl(items: ["DEV", "UAT", "PROD"])
    private let serviceProviderSegmentedControl = UISegmentedControl(items: ["DEV", "UAT", "PROD"])
    
    // MARK: - Feature Toggles
    private let featureTogglesStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 10
        return stack
    }()

    // MARK: - Debug Tools
    private let clearCacheButton = UIButton(type: .system)
    private let logoutButton = UIButton(type: .system)
    private let crashButton = UIButton(type: .system)
    private let clearUserDefaultsButton = UIButton(type: .system)
    private let viewLogsButton = UIButton(type: .system)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        loadCurrentSettings()
    }
    
    private func setupUI() {
        title = "Developer Settings"
        view.backgroundColor = .systemBackground
        
        // Setup main stack view
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.layoutMargins = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        stackView.isLayoutMarginsRelativeArrangement = true
        
        // Add sections
        addEnvironmentSection()
        addFeatureTogglesSection()
        addDebugToolsSection()
        
        // Setup scroll view
        scrollView.addSubview(stackView)
        view.addSubview(scrollView)
    }
    
    private func addEnvironmentSection() {
        let section = createSection(title: "Environment")
        
        // Environment
        let envLabel = UILabel()
        envLabel.text = "Environment:"
        section.addArrangedSubview(envLabel)
        section.addArrangedSubview(environmentSegmentedControl)
        
        // Service Provider
        let spLabel = UILabel()
        spLabel.text = "Service Provider:"
        section.addArrangedSubview(spLabel)
        section.addArrangedSubview(serviceProviderSegmentedControl)
        
        stackView.addArrangedSubview(section)
    }
    
    private func addFeatureTogglesSection() {
        let section = createSection(title: "Feature Toggles")
        
        // Add toggles for each SportsbookTargetFeatures
        SportsbookTargetFeatures.allCases.forEach { feature in
            let toggle = UISwitch()
            let label = UILabel()
            label.text = "\(feature)"
            
            // Set initial state based on current features (including any overrides)
            toggle.isOn = TargetVariables.getCurrentFeatures().contains(feature)
            toggle.addTarget(self, action: #selector(featureToggled(_:)), for: .valueChanged)
            
            let container = UIStackView(arrangedSubviews: [label, toggle])
            container.distribution = .equalSpacing
            
            featureTogglesStackView.addArrangedSubview(container)
        }
        
        // Add Reset button
        let resetButton = UIButton(type: .system)
        resetButton.setTitle("Reset to Default Features", for: .normal)
        resetButton.addTarget(self, action: #selector(resetFeatures), for: .touchUpInside)
        section.addArrangedSubview(resetButton)
        
        stackView.addArrangedSubview(section)
    }
    
    private func addDebugToolsSection() {
        let section = createSection(title: "Debug Tools")
        
        clearCacheButton.setTitle("Clear Cache", for: .normal)
        logoutButton.setTitle("Force Logout", for: .normal)
        crashButton.setTitle("Force Crash", for: .normal)
        clearUserDefaultsButton.setTitle("Clear UserDefaults", for: .normal)
        viewLogsButton.setTitle("View Logs", for: .normal)
        
        [clearCacheButton, logoutButton, crashButton, clearUserDefaultsButton, viewLogsButton].forEach {
            $0.addTarget(self, action: #selector(debugButtonTapped(_:)), for: .touchUpInside)
            section.addArrangedSubview($0)
        }
        
        stackView.addArrangedSubview(section)
    }
    
    private func createSection(title: String) -> UIStackView {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 10
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .boldSystemFont(ofSize: 18)
        stack.addArrangedSubview(titleLabel)
        
        return stack
    }
    
    private func setupConstraints() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
    }
    
    private func loadCurrentSettings() {
        // Load current environment settings
        // Load current feature toggles
        // Load current network settings
    }
    
    @objc private func debugButtonTapped(_ sender: UIButton) {
        switch sender {
        case clearCacheButton:
            // implement clear cache logic
            break
            
        case logoutButton:
            Env.userSessionStore.logout()
            break
            
        case crashButton:
            fatalError("Forced crash from developer settings")
            
        case clearUserDefaultsButton:
            showClearUserDefaultsAlert()
            
        case viewLogsButton:
            showLogViewer()
            
        default:
            break
        }
    }
    
    private func showClearUserDefaultsAlert() {
        let alert = UIAlertController(
            title: "Clear UserDefaults",
            message: "Are you sure you want to clear all UserDefaults? This will reset all app settings.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Clear", style: .destructive) { _ in
            if let bundleID = Bundle.main.bundleIdentifier {
                UserDefaults.standard.removePersistentDomain(forName: bundleID)
                UserDefaults.standard.synchronize()
            }
        })
        
        present(alert, animated: true)
    }
    
    private func showLogViewer() {
        let logViewer = LogViewerViewController()
        navigationController?.pushViewController(logViewer, animated: true)
    }

    @objc private func featureToggled(_ sender: UISwitch) {
        // Get current features
        var currentFeatures = Set(TargetVariables.getCurrentFeatures())
        
        // Find the feature that was toggled
        if let toggleView = sender.superview as? UIStackView,
           let label = toggleView.arrangedSubviews.first as? UILabel,
           let feature = SportsbookTargetFeatures.allCases.first(where: { "\($0)" == label.text }) {
            
            if sender.isOn {
                currentFeatures.insert(feature)
            } else {
                currentFeatures.remove(feature)
            }
            
            // Update dynamic features
            TargetVariables.setDynamicFeatures(Array(currentFeatures))
        }
    }

    @objc private func resetFeatures() {
        // Reset to default features
        TargetVariables.resetToDefaultFeatures()
        
        // Update UI to reflect default features
        featureTogglesStackView.arrangedSubviews.forEach { view in
            if let container = view as? UIStackView,
               let label = container.arrangedSubviews.first as? UILabel,
               let toggle = container.arrangedSubviews.last as? UISwitch,
               let feature = SportsbookTargetFeatures.allCases.first(where: { "\($0)" == label.text }) {
                toggle.isOn = TargetVariables.features.contains(feature)
            }
        }
    }
}

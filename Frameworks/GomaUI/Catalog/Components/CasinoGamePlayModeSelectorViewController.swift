import UIKit
import Combine
import GomaUI

class CasinoGamePlayModeSelectorViewController: UIViewController {
    
    // MARK: - UI Components
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let stackView = UIStackView()
    
    // Demo components for different states
    private let defaultSelector: CasinoGamePlayModeSelectorView
    private let loggedInSelector: CasinoGamePlayModeSelectorView
    private let insufficientFundsSelector: CasinoGamePlayModeSelectorView
    private let loadingSelector: CasinoGamePlayModeSelectorView
    private let disabledSelector: CasinoGamePlayModeSelectorView
    private let interactiveSelector: CasinoGamePlayModeSelectorView
    
    // Control section
    private let controlsStackView = UIStackView()
    private let stateSegmentedControl = UISegmentedControl(items: [
        "Logged Out", "Logged In", "Insufficient Funds", "Loading", "Disabled"
    ])
    
    // Interactive demo
    private var interactiveViewModel: MockCasinoGamePlayModeSelectorViewModel!
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    override init(nibName nibName: String?, bundle nibBundle: Bundle?) {
        // Initialize all demo selectors
        self.defaultSelector = CasinoGamePlayModeSelectorView(viewModel: MockCasinoGamePlayModeSelectorViewModel.defaultMock)
        self.loggedInSelector = CasinoGamePlayModeSelectorView(viewModel: MockCasinoGamePlayModeSelectorViewModel.loggedInMock)
        self.insufficientFundsSelector = CasinoGamePlayModeSelectorView(viewModel: MockCasinoGamePlayModeSelectorViewModel.insufficientFundsMock)
        self.loadingSelector = CasinoGamePlayModeSelectorView(viewModel: MockCasinoGamePlayModeSelectorViewModel.loadingMock)
        self.disabledSelector = CasinoGamePlayModeSelectorView(viewModel: MockCasinoGamePlayModeSelectorViewModel.disabledMock)
        
        // Create interactive selector with controllable ViewModel
        self.interactiveViewModel = MockCasinoGamePlayModeSelectorViewModel.interactiveMock
        self.interactiveSelector = CasinoGamePlayModeSelectorView(viewModel: interactiveViewModel)
        
        super.init(nibName: nibName, bundle: nibBundle)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupComponents()
        setupConstraints()
        setupInteractiveControls()
    }
    
    // MARK: - Setup
    private func setupView() {
        title = "Casino Game Play Mode Selector"
        view.backgroundColor = StyleProvider.Color.backgroundPrimary
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        stackView.axis = .vertical
        stackView.spacing = 32
        stackView.alignment = .fill
        stackView.distribution = .fill
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(stackView)
    }
    
    private func setupComponents() {
        // Configure all components
        [defaultSelector, loggedInSelector, insufficientFundsSelector, 
         loadingSelector, disabledSelector, interactiveSelector].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        // Add section headers and components
        addSectionHeader("Logged Out User (Default)")
        stackView.addArrangedSubview(defaultSelector)
        
        addSectionHeader("Logged In User with Funds")
        stackView.addArrangedSubview(loggedInSelector)
        
        addSectionHeader("Insufficient Funds")
        stackView.addArrangedSubview(insufficientFundsSelector)
        
        addSectionHeader("Loading State")
        stackView.addArrangedSubview(loadingSelector)
        
        addSectionHeader("Disabled/Maintenance")
        stackView.addArrangedSubview(disabledSelector)
        
        addSectionHeader("Interactive Demo")
        stackView.addArrangedSubview(interactiveSelector)
        
        // Setup button callbacks for demo
        defaultSelector.onButtonTapped = { buttonId in
            print("Default selector - Button tapped: \(buttonId)")
            self.showActionAlert(title: "Logged Out User", action: buttonId)
        }
        
        loggedInSelector.onButtonTapped = { buttonId in
            print("Logged in selector - Button tapped: \(buttonId)")
            self.showActionAlert(title: "Logged In User", action: buttonId)
        }
        
        insufficientFundsSelector.onButtonTapped = { buttonId in
            print("Insufficient funds selector - Button tapped: \(buttonId)")
            self.showActionAlert(title: "Insufficient Funds", action: buttonId)
        }
        
        interactiveSelector.onButtonTapped = { buttonId in
            print("Interactive selector - Button tapped: \(buttonId)")
            self.showActionAlert(title: "Interactive Demo", action: buttonId)
        }
    }
    
    private func setupInteractiveControls() {
        addSectionHeader("Interactive Controls")
        
        controlsStackView.axis = .vertical
        controlsStackView.spacing = 16
        controlsStackView.translatesAutoresizingMaskIntoConstraints = false
        
        // State selector
        stateSegmentedControl.selectedSegmentIndex = 0
        stateSegmentedControl.addTarget(self, action: #selector(stateChanged), for: .valueChanged)
        stateSegmentedControl.translatesAutoresizingMaskIntoConstraints = false
        
        let stateRow = createControlRow(title: "User State", control: stateSegmentedControl)
        controlsStackView.addArrangedSubview(stateRow)
        
        stackView.addArrangedSubview(controlsStackView)
    }
    
    private func createControlRow(title: String, control: UIView) -> UIView {
        let row = UIView()
        row.translatesAutoresizingMaskIntoConstraints = false
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = StyleProvider.fontWith(type: .medium, size: 16)
        titleLabel.textColor = StyleProvider.Color.textPrimary
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        control.translatesAutoresizingMaskIntoConstraints = false
        
        row.addSubview(titleLabel)
        row.addSubview(control)
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: row.leadingAnchor),
            titleLabel.topAnchor.constraint(equalTo: row.topAnchor),
            
            control.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            control.leadingAnchor.constraint(equalTo: row.leadingAnchor),
            control.trailingAnchor.constraint(equalTo: row.trailingAnchor),
            control.bottomAnchor.constraint(equalTo: row.bottomAnchor)
        ])
        
        return row
    }
    
    private func addSectionHeader(_ title: String) {
        let headerLabel = UILabel()
        headerLabel.text = title
        headerLabel.font = StyleProvider.fontWith(type: .bold, size: 18)
        headerLabel.textColor = StyleProvider.Color.textPrimary
        headerLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let headerContainer = UIView()
        headerContainer.translatesAutoresizingMaskIntoConstraints = false
        headerContainer.addSubview(headerLabel)
        
        NSLayoutConstraint.activate([
            headerLabel.leadingAnchor.constraint(equalTo: headerContainer.leadingAnchor),
            headerLabel.topAnchor.constraint(equalTo: headerContainer.topAnchor, constant: 8),
            headerLabel.bottomAnchor.constraint(equalTo: headerContainer.bottomAnchor, constant: -4)
        ])
        
        stackView.addArrangedSubview(headerContainer)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Scroll view
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // Content view
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            // Stack view
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
            
            // Selector heights (components handle their own intrinsic content size, but set minimums)
            defaultSelector.heightAnchor.constraint(greaterThanOrEqualToConstant: 400),
            loggedInSelector.heightAnchor.constraint(greaterThanOrEqualToConstant: 400),
            insufficientFundsSelector.heightAnchor.constraint(greaterThanOrEqualToConstant: 400),
            loadingSelector.heightAnchor.constraint(greaterThanOrEqualToConstant: 400),
            disabledSelector.heightAnchor.constraint(greaterThanOrEqualToConstant: 400),
            interactiveSelector.heightAnchor.constraint(greaterThanOrEqualToConstant: 400)
        ])
    }
    
    // MARK: - Actions
    @objc private func stateChanged() {
        let selectedIndex = stateSegmentedControl.selectedSegmentIndex
        
        switch selectedIndex {
        case 0: // Logged Out
            updateInteractiveSelector(with: MockCasinoGamePlayModeSelectorViewModel.defaultMock)
        case 1: // Logged In
            updateInteractiveSelector(with: MockCasinoGamePlayModeSelectorViewModel.loggedInMock)
        case 2: // Insufficient Funds
            updateInteractiveSelector(with: MockCasinoGamePlayModeSelectorViewModel.insufficientFundsMock)
        case 3: // Loading
            updateInteractiveSelector(with: MockCasinoGamePlayModeSelectorViewModel.loadingMock)
        case 4: // Disabled
            updateInteractiveSelector(with: MockCasinoGamePlayModeSelectorViewModel.disabledMock)
        default:
            break
        }
    }
    
    private func updateInteractiveSelector(with viewModel: MockCasinoGamePlayModeSelectorViewModel) {
        // Update the interactive selector's configuration
        interactiveSelector.configure(with: viewModel)
        interactiveViewModel = viewModel
    }
    
    private func showActionAlert(title: String, action: String) {
        let alert = UIAlertController(
            title: title,
            message: "Button tapped: \(action)",
            preferredStyle: .alert
        )
        
        let actionTitle: String
        switch action.lowercased() {
        case "login":
            actionTitle = "Navigate to Login"
        case "practice":
            actionTitle = "Start Practice Mode"
        case "play":
            actionTitle = "Start Real Money Play"
        case "deposit":
            actionTitle = "Navigate to Deposit"
        default:
            actionTitle = "Handle Action"
        }
        
        alert.addAction(UIAlertAction(title: actionTitle, style: .default) { _ in
            print("Demo: Would execute \(actionTitle)")
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(alert, animated: true)
    }
}

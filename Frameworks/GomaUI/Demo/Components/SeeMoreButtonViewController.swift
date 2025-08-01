//
//  SeeMoreButtonViewController.swift
//  TestCase
//
//  Created by Claude on 01/08/2025.
//

import UIKit
import Combine
import GomaUI

class SeeMoreButtonViewController: UIViewController {
    
    // MARK: - UI Components
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let stackView = UIStackView()
    
    // Demo buttons for different states
    private let defaultButton: SeeMoreButtonView
    private let loadingButton: SeeMoreButtonView
    private let withCountButton: SeeMoreButtonView
    private let disabledButton: SeeMoreButtonView
    private let interactiveButton: SeeMoreButtonView
    
    // Control section
    private let controlsStackView = UIStackView()
    private let loadingToggle = UISwitch()
    private let enabledToggle = UISwitch()
    private let countStepper = UIStepper()
    private let countLabel = UILabel()
    
    // Interactive demo
    private var interactiveViewModel: MockSeeMoreButtonViewModel!
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    override init(nibName nibName: String?, bundle nibBundle: Bundle?) {
        // Initialize all demo buttons
        self.defaultButton = SeeMoreButtonView(viewModel: MockSeeMoreButtonViewModel.defaultMock)
        self.loadingButton = SeeMoreButtonView(viewModel: MockSeeMoreButtonViewModel.loadingMock)
        self.withCountButton = SeeMoreButtonView(viewModel: MockSeeMoreButtonViewModel.withCountMock)
        self.disabledButton = SeeMoreButtonView(viewModel: MockSeeMoreButtonViewModel.disabledMock)
        
        // Create interactive button with controllable ViewModel
        self.interactiveViewModel = MockSeeMoreButtonViewModel.interactiveMock
        self.interactiveButton = SeeMoreButtonView(viewModel: interactiveViewModel)
        
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
        title = "See More Button"
        view.backgroundColor = StyleProvider.Color.backgroundColor
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        stackView.axis = .vertical
        stackView.spacing = 24
        stackView.alignment = .fill
        stackView.distribution = .fill
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(stackView)
    }
    
    private func setupComponents() {
        // Configure all components
        [defaultButton, loadingButton, withCountButton, disabledButton, interactiveButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        // Add section headers and components
        addSectionHeader("Default State")
        stackView.addArrangedSubview(defaultButton)
        
        addSectionHeader("Loading State")
        stackView.addArrangedSubview(loadingButton)
        
        addSectionHeader("With Remaining Count")
        stackView.addArrangedSubview(withCountButton)
        
        addSectionHeader("Disabled State")
        stackView.addArrangedSubview(disabledButton)
        
        addSectionHeader("Interactive Demo")
        stackView.addArrangedSubview(interactiveButton)
        
        // Setup button callbacks for demo
        defaultButton.onButtonTapped = { _ in
            print("Default button tapped!")
        }
        
        withCountButton.onButtonTapped = { _ in
            print("Count button tapped!")
        }
        
        interactiveButton.onButtonTapped = { buttonId in
            print("Interactive button tapped: \(buttonId)")
        }
    }
    
    private func setupInteractiveControls() {
        addSectionHeader("Interactive Controls")
        
        controlsStackView.axis = .vertical
        controlsStackView.spacing = 12
        controlsStackView.translatesAutoresizingMaskIntoConstraints = false
        
        // Loading toggle
        let loadingRow = createControlRow(title: "Loading", control: loadingToggle)
        loadingToggle.addTarget(self, action: #selector(loadingToggleChanged), for: .valueChanged)
        
        // Enabled toggle
        let enabledRow = createControlRow(title: "Enabled", control: enabledToggle)
        enabledToggle.isOn = true
        enabledToggle.addTarget(self, action: #selector(enabledToggleChanged), for: .valueChanged)
        
        // Count stepper
        countStepper.minimumValue = 0
        countStepper.maximumValue = 100
        countStepper.value = 15
        countStepper.stepValue = 5
        countStepper.addTarget(self, action: #selector(countStepperChanged), for: .valueChanged)
        
        countLabel.text = "Count: 15"
        countLabel.font = StyleProvider.fontWith(type: .medium, size: 14)
        countLabel.textColor = StyleProvider.Color.textSecondary
        
        let countRow = createControlRow(title: "Remaining Count", control: countStepper, extraView: countLabel)
        
        controlsStackView.addArrangedSubview(loadingRow)
        controlsStackView.addArrangedSubview(enabledRow)
        controlsStackView.addArrangedSubview(countRow)
        
        stackView.addArrangedSubview(controlsStackView)
    }
    
    private func createControlRow(title: String, control: UIView, extraView: UIView? = nil) -> UIView {
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
        
        var constraints = [
            titleLabel.leadingAnchor.constraint(equalTo: row.leadingAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: row.centerYAnchor),
            control.trailingAnchor.constraint(equalTo: row.trailingAnchor),
            control.centerYAnchor.constraint(equalTo: row.centerYAnchor),
            row.heightAnchor.constraint(equalToConstant: 44)
        ]
        
        if let extraView = extraView {
            extraView.translatesAutoresizingMaskIntoConstraints = false
            row.addSubview(extraView)
            constraints.append(contentsOf: [
                extraView.trailingAnchor.constraint(equalTo: control.leadingAnchor, constant: -12),
                extraView.centerYAnchor.constraint(equalTo: row.centerYAnchor)
            ])
        }
        
        NSLayoutConstraint.activate(constraints)
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
            
            // Button heights
            defaultButton.heightAnchor.constraint(equalToConstant: 60),
            loadingButton.heightAnchor.constraint(equalToConstant: 60),
            withCountButton.heightAnchor.constraint(equalToConstant: 60),
            disabledButton.heightAnchor.constraint(equalToConstant: 60),
            interactiveButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    // MARK: - Actions
    @objc private func loadingToggleChanged() {
        interactiveViewModel.setLoading(loadingToggle.isOn)
    }
    
    @objc private func enabledToggleChanged() {
        interactiveViewModel.setEnabled(enabledToggle.isOn)
    }
    
    @objc private func countStepperChanged() {
        let count = Int(countStepper.value)
        countLabel.text = "Count: \(count)"
        interactiveViewModel.updateRemainingCount(count > 0 ? count : nil)
    }
}
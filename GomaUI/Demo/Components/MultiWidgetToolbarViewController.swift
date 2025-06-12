//
//  MultiWidgetToolbarViewController.swift
//  TestCase
//
//  Created by Claude on 29/08/2023.
//

import UIKit
import GomaUI

class MultiWidgetToolbarViewController: UIViewController {
    
    // MARK: - Properties
    private var toolbar: MultiWidgetToolbarView!
    private var stateToggleButton: UIButton!
    private var currentStateLabel: UILabel!
    private var selectedWidgetLabel: UILabel!
    private var descriptionLabel: UILabel!
    
    private var isLoggedIn: Bool = false
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        layoutViews()
        setupActions()
    }
    
    // MARK: - Setup
    private func setupViews() {
        view.backgroundColor = .systemBackground
        
        // Create the toolbar
        let viewModel = MockMultiWidgetToolbarViewModel.defaultMock
        toolbar = MultiWidgetToolbarView(viewModel: viewModel)
        toolbar.translatesAutoresizingMaskIntoConstraints = false
        
        // Description label
        descriptionLabel = UILabel()
        descriptionLabel.text = "This MultiWidgetToolbarView example is styled to match the Betsson design, with dynamic layouts for logged-in and logged-out states."
        descriptionLabel.font = StyleProvider.fontWith(type: .regular, size: 14)
        descriptionLabel.textColor = .secondaryLabel
        descriptionLabel.numberOfLines = 0
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // State toggle button
        stateToggleButton = UIButton(type: .system)
        stateToggleButton.setTitle("Toggle Logged In State", for: .normal)
        stateToggleButton.backgroundColor = StyleProvider.Color.primaryColor
        stateToggleButton.setTitleColor(StyleProvider.Color.contrastTextColor, for: .normal)
        stateToggleButton.layer.cornerRadius = 8
        stateToggleButton.translatesAutoresizingMaskIntoConstraints = false
        
        // Current state label
        currentStateLabel = UILabel()
        currentStateLabel.text = "Current State: Logged Out"
        currentStateLabel.font = StyleProvider.fontWith(type: .medium, size: 14)
        currentStateLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Selected widget label
        selectedWidgetLabel = UILabel()
        selectedWidgetLabel.text = "No widget selected"
        selectedWidgetLabel.font = StyleProvider.fontWith(type: .medium, size: 14)
        selectedWidgetLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Add to view
        self.view.addSubview(self.toolbar)
        self.view.addSubview(self.descriptionLabel)
        self.view.addSubview(self.stateToggleButton)
        self.view.addSubview(self.currentStateLabel)
        self.view.addSubview(self.selectedWidgetLabel)
    }
    
    private func layoutViews() {
        NSLayoutConstraint.activate([
            // Toolbar at the top
            toolbar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            toolbar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            toolbar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            // Description below toolbar
            descriptionLabel.topAnchor.constraint(equalTo: toolbar.bottomAnchor, constant: 24),
            descriptionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            descriptionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            // Toggle button below description
            stateToggleButton.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 24),
            stateToggleButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stateToggleButton.widthAnchor.constraint(equalToConstant: 200),
            stateToggleButton.heightAnchor.constraint(equalToConstant: 44),
            
            // Current state label below the toggle button
            currentStateLabel.topAnchor.constraint(equalTo: stateToggleButton.bottomAnchor, constant: 16),
            currentStateLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            // Selected widget label below the state label
            selectedWidgetLabel.topAnchor.constraint(equalTo: currentStateLabel.bottomAnchor, constant: 16),
            selectedWidgetLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    private func setupActions() {
        // Toggle button action
        stateToggleButton.addTarget(self, action: #selector(toggleState), for: .touchUpInside)
        
        // Toolbar selection handler
        toolbar.onWidgetSelected = { [weak self] widgetID in
            self?.selectedWidgetLabel.text = "Selected Widget: \(widgetID)"
        }
    }
    
    // MARK: - Actions
    @objc private func toggleState() {
                
        self.isLoggedIn.toggle()
        
        // Toggle to opposite state
        let newState: LayoutState = self.isLoggedIn ? .loggedOut : .loggedIn
        toolbar.setLoggedInState(self.isLoggedIn)
        
        // Update label
        currentStateLabel.text = "Current State: \(newState.rawValue.capitalized)"
    }
} 

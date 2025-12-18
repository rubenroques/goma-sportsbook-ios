//
//  FloatingOverlayViewController.swift
//  TestCase
//
//  Created on 06/04/2025.
//

import UIKit
import Combine
import GomaUI

class FloatingOverlayViewController: UIViewController {
    
    // MARK: - UI Components
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = true
        return scrollView
    }()
    
    private lazy var contentStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 24
        stackView.alignment = .fill
        stackView.distribution = .fill
        return stackView
    }()
    
    private lazy var overlayView: FloatingOverlayView = {
        let overlay = FloatingOverlayView(viewModel: viewModel)
        overlay.translatesAutoresizingMaskIntoConstraints = false
        overlay.onTap = { [weak self] in
            self?.addLogEntry("Overlay tapped and dismissed")
        }
        return overlay
    }()
    
    private lazy var logTextView: UITextView = {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.isEditable = false
        textView.font = UIFont.monospacedSystemFont(ofSize: 12, weight: .regular)
        textView.backgroundColor = UIColor.systemGray6
        textView.layer.cornerRadius = 8
        textView.contentInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        textView.text = "Event Log:\n"
        return textView
    }()
    
    // MARK: - Properties
    private let viewModel = MockFloatingOverlayViewModel()
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupConstraints()
        observeViewModel()
    }
    
    // MARK: - Setup
    private func setupViews() {
        view.backgroundColor = .systemBackground
        
        // Add scroll view
        view.addSubview(scrollView)
        scrollView.addSubview(contentStackView)
        
        // Add sections
        contentStackView.addArrangedSubview(createModeSection())
        contentStackView.addArrangedSubview(createPositionSection())
        contentStackView.addArrangedSubview(createDurationSection())
        contentStackView.addArrangedSubview(createLogSection())
        
        // Add overlay on top
        view.addSubview(overlayView)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Scroll view
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            // Content stack
            contentStackView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 16),
            contentStackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16),
            contentStackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -16),
            contentStackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -16),
            contentStackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -32),
            
            // Overlay - bottom center by default
            overlayView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            overlayView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
    }
    
    // MARK: - Section Builders
    private func createModeSection() -> UIView {
        let section = createSection(title: "Mode Selection")
        
        let sportsbookButton = createButton(title: "Show Sportsbook Mode") { [weak self] in
            self?.viewModel.show(mode: .sportsbook, duration: 3)
            self?.addLogEntry("Showing Sportsbook mode with 3s duration")
        }
        
        let casinoButton = createButton(title: "Show Casino Mode") { [weak self] in
            self?.viewModel.show(mode: .casino, duration: 3)
            self?.addLogEntry("Showing Casino mode with 3s duration")
        }
        
        let customButton = createButton(title: "Show Custom Mode") { [weak self] in
            let icon = UIImage(systemName: "star.fill") ?? UIImage()
            self?.viewModel.show(mode: .custom(icon: icon, message: "VIP Access Granted! ⭐"), duration: 5)
            self?.addLogEntry("Showing Custom mode with 5s duration")
        }
        
        section.addArrangedSubview(sportsbookButton)
        section.addArrangedSubview(casinoButton)
        section.addArrangedSubview(customButton)
        
        return section
    }
    
    private func createPositionSection() -> UIView {
        let section = createSection(title: "Position (Visual Only)")
        
        let infoLabel = UILabel()
        infoLabel.text = "The overlay is positioned by the parent view. In this demo, it's fixed at bottom center."
        infoLabel.font = .systemFont(ofSize: 14)
        infoLabel.textColor = .secondaryLabel
        infoLabel.numberOfLines = 0
        
        section.addArrangedSubview(infoLabel)
        
        return section
    }
    
    private func createDurationSection() -> UIView {
        let section = createSection(title: "Duration Options")
        
        let quickButton = createButton(title: "Quick (2s)") { [weak self] in
            self?.viewModel.show(mode: .sportsbook, duration: 2)
            self?.addLogEntry("Showing with 2s duration")
        }
        
        let normalButton = createButton(title: "Normal (5s)") { [weak self] in
            self?.viewModel.show(mode: .casino, duration: 5)
            self?.addLogEntry("Showing with 5s duration")
        }
        
        let manualButton = createButton(title: "Manual Dismiss Only") { [weak self] in
            let icon = UIImage(systemName: "hand.tap.fill") ?? UIImage()
            self?.viewModel.show(mode: .custom(icon: icon, message: "Tap to dismiss!"), duration: nil)
            self?.addLogEntry("Showing with manual dismiss only")
        }
        
        let hideButton = createButton(title: "Hide Immediately", style: .secondary) { [weak self] in
            self?.viewModel.hide()
            self?.addLogEntry("Manually hiding overlay")
        }
        
        section.addArrangedSubview(quickButton)
        section.addArrangedSubview(normalButton)
        section.addArrangedSubview(manualButton)
        section.addArrangedSubview(hideButton)
        
        return section
    }
    
    private func createLogSection() -> UIView {
        let section = createSection(title: "Event Log")
        
        logTextView.heightAnchor.constraint(equalToConstant: 150).isActive = true
        section.addArrangedSubview(logTextView)
        
        let clearButton = createButton(title: "Clear Log", style: .secondary) { [weak self] in
            self?.logTextView.text = "Event Log:\n"
        }
        section.addArrangedSubview(clearButton)
        
        return section
    }
    
    // MARK: - Helpers
    private func createSection(title: String) -> UIStackView {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 12
        stackView.alignment = .fill
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 18, weight: .semibold)
        
        stackView.addArrangedSubview(titleLabel)
        
        return stackView
    }
    
    private func createButton(title: String, style: ButtonStyle = .primary, action: @escaping () -> Void) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.heightAnchor.constraint(equalToConstant: 44).isActive = true
        button.layer.cornerRadius = 8
        
        switch style {
        case .primary:
            button.backgroundColor = .systemBlue
            button.setTitleColor(.white, for: .normal)
        case .secondary:
            button.backgroundColor = .systemGray5
            button.setTitleColor(.label, for: .normal)
        }
        
        button.addAction(UIAction { _ in action() }, for: .touchUpInside)
        
        return button
    }
    
    private func addLogEntry(_ message: String) {
        let timestamp = DateFormatter.localizedString(from: Date(), dateStyle: .none, timeStyle: .medium)
        let newEntry = "\n[\(timestamp)] \(message)"
        logTextView.text += newEntry
        
        // Scroll to bottom
        if logTextView.text.count > 0 {
            let bottom = NSMakeRange(logTextView.text.count - 1, 1)
            logTextView.scrollRangeToVisible(bottom)
        }
    }
    
    private func observeViewModel() {
        viewModel.displayStatePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                if state.isVisible {
                    self?.addLogEntry("Overlay shown: \(state.mode)")
                } else {
                    self?.addLogEntry("Overlay hidden")
                }
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Types
    private enum ButtonStyle {
        case primary
        case secondary
    }
}
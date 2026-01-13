//
//  FloatingOverlayViewSnapshotViewController.swift
//  GomaUI
//
//  Snapshot testing view controller for FloatingOverlayView.
//

import UIKit
import SwiftUI

// MARK: - Snapshot Category
enum FloatingOverlaySnapshotCategory: String, CaseIterable {
    case modeVariants = "Mode Variants"
}

final class FloatingOverlayViewSnapshotViewController: UIViewController {

    private let category: FloatingOverlaySnapshotCategory

    init(category: FloatingOverlaySnapshotCategory) {
        self.category = category
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .backgroundTestColor
        setupUI()
    }

    private func setupUI() {
        let titleLabel = UILabel()
        titleLabel.text = "FloatingOverlayView - \(category.rawValue)"
        titleLabel.font = StyleProvider.fontWith(type: .bold, size: 16)
        titleLabel.textColor = StyleProvider.Color.textPrimary
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 24
        stackView.alignment = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(titleLabel)
        view.addSubview(stackView)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),

            stackView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 24),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])

        addVariants(to: stackView)
    }

    private func addVariants(to stackView: UIStackView) {
        switch category {
        case .modeVariants:
            addModeVariants(to: stackView)
        }
    }

    // MARK: - Mode Variants

    private func addModeVariants(to stackView: UIStackView) {
        // Sportsbook mode
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Sportsbook Mode",
            view: createOverlayView(mode: .sportsbook)
        ))

        // Casino mode
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Casino Mode",
            view: createOverlayView(mode: .casino)
        ))

        // Custom mode with star icon
        let starIcon = UIImage(systemName: "star.fill") ?? UIImage()
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Custom Mode (Star)",
            view: createOverlayView(mode: .custom(icon: starIcon, message: "Welcome to VIP Lounge"))
        ))

        // Custom mode with bell icon
        let bellIcon = UIImage(systemName: "bell.fill") ?? UIImage()
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Custom Mode (Bell)",
            view: createOverlayView(mode: .custom(icon: bellIcon, message: "New notification"))
        ))

        // Custom mode with long text
        let giftIcon = UIImage(systemName: "gift.fill") ?? UIImage()
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Custom Mode (Long Text)",
            view: createOverlayView(mode: .custom(icon: giftIcon, message: "Congratulations! You've won a bonus!"))
        ))
    }

    // MARK: - Helper Methods

    private func createOverlayView(mode: FloatingOverlayMode) -> FloatingOverlayView {
        // Create viewModel with visible state
        let viewModel = MockFloatingOverlayViewModel(
            initialState: FloatingOverlayDisplayState(
                mode: mode,
                duration: nil,
                isVisible: true
            )
        )
        let overlayView = FloatingOverlayView(viewModel: viewModel)
        overlayView.translatesAutoresizingMaskIntoConstraints = false

        // Override the alpha and transform that are set to hide the view initially
        // This is needed because the view animates in, but we want to capture it visible
        overlayView.alpha = 1
        overlayView.transform = .identity

        NSLayoutConstraint.activate([
            overlayView.heightAnchor.constraint(equalToConstant: 52)
        ])

        return overlayView
    }

    private func createLabeledVariant(label: String, view: UIView) -> UIStackView {
        let labelView = UILabel()
        labelView.text = label
        labelView.font = StyleProvider.fontWith(type: .medium, size: 12)
        labelView.textColor = StyleProvider.Color.textSecondary

        let stack = UIStackView(arrangedSubviews: [labelView, view])
        stack.axis = .vertical
        stack.spacing = 6
        stack.alignment = .fill
        return stack
    }
}

// MARK: - Preview
#if DEBUG
#Preview("Mode Variants") {
    FloatingOverlayViewSnapshotViewController(category: .modeVariants)
}
#endif

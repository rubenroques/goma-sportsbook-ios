//
//  TitleBlockViewSnapshotViewController.swift
//  GomaUI
//
//  Snapshot testing view controller for TitleBlockView component.
//

import UIKit
import SwiftUI

// MARK: - Snapshot Category
enum TitleBlockSnapshotCategory: String, CaseIterable {
    case alignmentVariants = "Alignment Variants"
    case contentVariants = "Content Variants"
}

final class TitleBlockViewSnapshotViewController: UIViewController {

    private let category: TitleBlockSnapshotCategory

    init(category: TitleBlockSnapshotCategory) {
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
        titleLabel.text = "TitleBlockView - \(category.rawValue)"
        titleLabel.font = StyleProvider.fontWith(type: .bold, size: 16)
        titleLabel.textColor = StyleProvider.Color.textPrimary
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 16
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
        case .alignmentVariants:
            addAlignmentVariants(to: stackView)
        case .contentVariants:
            addContentVariants(to: stackView)
        }
    }

    // MARK: - Category Variants

    private func addAlignmentVariants(to stackView: UIStackView) {
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Centered (Default)",
            view: createTitleBlockView(viewModel: MockTitleBlockViewModel.centeredMock)
        ))
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Left Aligned",
            view: createTitleBlockView(viewModel: MockTitleBlockViewModel.leftAlignedMock)
        ))
    }

    private func addContentVariants(to stackView: UIStackView) {
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Default (Welcome Bonus)",
            view: createTitleBlockView(viewModel: MockTitleBlockViewModel.defaultMock)
        ))
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Long Title",
            view: createTitleBlockView(viewModel: MockTitleBlockViewModel.longTitleMock)
        ))
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Short Title",
            view: createTitleBlockView(viewModel: MockTitleBlockViewModel(title: "Bonus"))
        ))
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Multi-line Title",
            view: createTitleBlockView(viewModel: MockTitleBlockViewModel(title: "Get Your Exclusive\nWelcome Bonus Today!"))
        ))
    }

    // MARK: - Helper Methods

    private func createTitleBlockView(viewModel: TitleBlockViewModelProtocol) -> TitleBlockView {
        let view = TitleBlockView(viewModel: viewModel)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private func createLabeledVariant(label: String, view: UIView) -> UIStackView {
        let labelView = UILabel()
        labelView.text = label
        labelView.font = StyleProvider.fontWith(type: .medium, size: 12)
        labelView.textColor = StyleProvider.Color.textSecondary

        // TitleBlockView uses highlightSecondaryContrast text color (white/light),
        // designed for promotional banners with gradient backgrounds.
        // Use highlightSecondary as background to make text visible.
        let containerView = UIView()
        containerView.backgroundColor = StyleProvider.Color.highlightSecondary
        containerView.layer.cornerRadius = 8
        containerView.translatesAutoresizingMaskIntoConstraints = false

        containerView.addSubview(view)
        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 8),
            view.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            view.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -8)
        ])

        let stack = UIStackView(arrangedSubviews: [labelView, containerView])
        stack.axis = .vertical
        stack.spacing = 6
        stack.alignment = .fill
        return stack
    }
}

// MARK: - Preview
#if DEBUG
#Preview("Alignment Variants") {
    TitleBlockViewSnapshotViewController(category: .alignmentVariants)
}

#Preview("Content Variants") {
    TitleBlockViewSnapshotViewController(category: .contentVariants)
}
#endif

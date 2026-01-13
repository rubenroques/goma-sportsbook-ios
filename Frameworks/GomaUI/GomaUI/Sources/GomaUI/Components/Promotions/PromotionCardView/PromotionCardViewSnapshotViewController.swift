//
//  PromotionCardViewSnapshotViewController.swift
//  GomaUI
//

import UIKit
import SwiftUI

// MARK: - Snapshot Category
enum PromotionCardSnapshotCategory: String, CaseIterable {
    case contentVariants = "Content Variants"
    case buttonConfigurations = "Button Configurations"
    case tagVariants = "Tag Variants"
    case textLengths = "Text Lengths"
}

final class PromotionCardViewSnapshotViewController: UIViewController {

    private let category: PromotionCardSnapshotCategory

    init(category: PromotionCardSnapshotCategory) {
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
        titleLabel.text = "PromotionCardView - \(category.rawValue)"
        titleLabel.font = StyleProvider.fontWith(type: .bold, size: 16)
        titleLabel.textColor = StyleProvider.Color.textPrimary
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false

        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 24
        stackView.alignment = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(titleLabel)
        view.addSubview(scrollView)
        scrollView.addSubview(stackView)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),

            scrollView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -16),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -16),
            stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -32)
        ])

        addVariants(to: stackView)
    }

    private func addVariants(to stackView: UIStackView) {
        switch category {
        case .contentVariants:
            addContentVariants(to: stackView)
        case .buttonConfigurations:
            addButtonConfigurations(to: stackView)
        case .tagVariants:
            addTagVariants(to: stackView)
        case .textLengths:
            addTextLengths(to: stackView)
        }
    }

    // MARK: - Category Variants

    private func addContentVariants(to stackView: UIStackView) {
        // Default with all content
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Default (All Content)",
            view: createPromotionCard(viewModel: MockPromotionCardViewModel.defaultMock)
        ))

        // Casino (no note)
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Casino (No Note)",
            view: createPromotionCard(viewModel: MockPromotionCardViewModel.casinoMock)
        ))

        // Sportsbook (no read more)
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Sportsbook (No Read More)",
            view: createPromotionCard(viewModel: MockPromotionCardViewModel.sportsbookMock)
        ))
    }

    private func addButtonConfigurations(to stackView: UIStackView) {
        // Both buttons visible
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Both Buttons (CTA + Read More)",
            view: createPromotionCard(viewModel: MockPromotionCardViewModel.defaultMock)
        ))

        // No CTA button
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Read More Only",
            view: createPromotionCard(viewModel: MockPromotionCardViewModel.noCTAMock)
        ))

        // CTA only, no read more
        stackView.addArrangedSubview(createLabeledVariant(
            label: "CTA Only",
            view: createPromotionCard(viewModel: MockPromotionCardViewModel.sportsbookMock)
        ))
    }

    private func addTagVariants(to stackView: UIStackView) {
        // With tag
        stackView.addArrangedSubview(createLabeledVariant(
            label: "With Tag (Limited)",
            view: createPromotionCard(viewModel: MockPromotionCardViewModel.defaultMock)
        ))

        // Casino tag
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Casino Tag",
            view: createPromotionCard(viewModel: MockPromotionCardViewModel.casinoMock)
        ))

        // No tag
        stackView.addArrangedSubview(createLabeledVariant(
            label: "No Tag",
            view: createPromotionCard(viewModel: MockPromotionCardViewModel.noTagMock)
        ))
    }

    private func addTextLengths(to stackView: UIStackView) {
        // Short title
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Short Title",
            view: createPromotionCard(viewModel: MockPromotionCardViewModel.defaultMock)
        ))

        // Long title
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Long Title (Multi-line)",
            view: createPromotionCard(viewModel: MockPromotionCardViewModel.longTitleMock)
        ))
    }

    // MARK: - Helper Methods

    private func createPromotionCard(viewModel: MockPromotionCardViewModel) -> PromotionCardView {
        let view = PromotionCardView(viewModel: viewModel)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private func createLabeledVariant(label: String, view: UIView) -> UIStackView {
        let labelView = UILabel()
        labelView.text = label
        labelView.font = StyleProvider.fontWith(type: .medium, size: 12)
        labelView.textColor = StyleProvider.Color.textSecondary

        let stack = UIStackView(arrangedSubviews: [labelView, view])
        stack.axis = .vertical
        stack.spacing = 8
        stack.alignment = .fill
        return stack
    }
}

// MARK: - Preview
#if DEBUG
#Preview("Content Variants") {
    PromotionCardViewSnapshotViewController(category: .contentVariants)
}

#Preview("Button Configurations") {
    PromotionCardViewSnapshotViewController(category: .buttonConfigurations)
}

#Preview("Tag Variants") {
    PromotionCardViewSnapshotViewController(category: .tagVariants)
}

#Preview("Text Lengths") {
    PromotionCardViewSnapshotViewController(category: .textLengths)
}
#endif

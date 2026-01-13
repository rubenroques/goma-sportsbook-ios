import UIKit
import SwiftUI

// MARK: - Snapshot Category
enum PromotionalBonusCardsScrollSnapshotCategory: String, CaseIterable {
    case defaultLayout = "Default Layout"
    case shortList = "Short List"
}

final class PromotionalBonusCardsScrollViewSnapshotViewController: UIViewController {

    private let category: PromotionalBonusCardsScrollSnapshotCategory

    init(category: PromotionalBonusCardsScrollSnapshotCategory) {
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
        titleLabel.text = "PromotionalBonusCardsScrollView - \(category.rawValue)"
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
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])

        addVariants(to: stackView)
    }

    private func addVariants(to stackView: UIStackView) {
        switch category {
        case .defaultLayout:
            addDefaultLayoutVariants(to: stackView)
        case .shortList:
            addShortListVariants(to: stackView)
        }
    }

    // MARK: - Category Variants

    private func addDefaultLayoutVariants(to stackView: UIStackView) {
        stackView.addArrangedSubview(createLabeledVariant(
            label: "4 Cards (Default Mock)",
            view: createScrollView(viewModel: MockPromotionalBonusCardsScrollViewModel.defaultMock)
        ))
    }

    private func addShortListVariants(to stackView: UIStackView) {
        stackView.addArrangedSubview(createLabeledVariant(
            label: "2 Cards (Short List Mock)",
            view: createScrollView(viewModel: MockPromotionalBonusCardsScrollViewModel.shortListMock)
        ))
    }

    // MARK: - Helper Methods

    private func createScrollView(viewModel: MockPromotionalBonusCardsScrollViewModel) -> PromotionalBonusCardsScrollView {
        let scrollView = PromotionalBonusCardsScrollView(viewModel: viewModel)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            scrollView.heightAnchor.constraint(equalToConstant: 200)
        ])
        return scrollView
    }

    private func createLabeledVariant(label: String, view: UIView) -> UIStackView {
        let labelView = UILabel()
        labelView.text = label
        labelView.font = StyleProvider.fontWith(type: .medium, size: 12)
        labelView.textColor = StyleProvider.Color.textSecondary
        labelView.translatesAutoresizingMaskIntoConstraints = false

        let labelContainer = UIView()
        labelContainer.addSubview(labelView)
        NSLayoutConstraint.activate([
            labelView.topAnchor.constraint(equalTo: labelContainer.topAnchor),
            labelView.bottomAnchor.constraint(equalTo: labelContainer.bottomAnchor),
            labelView.leadingAnchor.constraint(equalTo: labelContainer.leadingAnchor, constant: 16),
            labelView.trailingAnchor.constraint(equalTo: labelContainer.trailingAnchor, constant: -16)
        ])

        let stack = UIStackView(arrangedSubviews: [labelContainer, view])
        stack.axis = .vertical
        stack.spacing = 6
        stack.alignment = .fill
        return stack
    }
}

// MARK: - Preview
#if DEBUG
#Preview("Default Layout") {
    PromotionalBonusCardsScrollViewSnapshotViewController(category: .defaultLayout)
}

#Preview("Short List") {
    PromotionalBonusCardsScrollViewSnapshotViewController(category: .shortList)
}
#endif

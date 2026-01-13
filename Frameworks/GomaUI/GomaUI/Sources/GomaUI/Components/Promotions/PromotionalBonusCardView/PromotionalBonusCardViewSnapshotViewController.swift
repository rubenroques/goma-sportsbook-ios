import UIKit
import SwiftUI

// MARK: - Snapshot Category
enum PromotionalBonusCardSnapshotCategory: String, CaseIterable {
    case gradientStates = "Gradient States"
    case contentVariants = "Content Variants"
}

final class PromotionalBonusCardViewSnapshotViewController: UIViewController {

    private let category: PromotionalBonusCardSnapshotCategory

    init(category: PromotionalBonusCardSnapshotCategory) {
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
        titleLabel.text = "PromotionalBonusCardView - \(category.rawValue)"
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
        case .gradientStates:
            addGradientStatesVariants(to: stackView)
        case .contentVariants:
            addContentVariants(to: stackView)
        }
    }

    // MARK: - Category Variants

    private func addGradientStatesVariants(to stackView: UIStackView) {
        stackView.addArrangedSubview(createLabeledVariant(
            label: "With Gradient (Default)",
            view: createCardView(viewModel: MockPromotionalBonusCardViewModel.defaultMock)
        ))
    }

    private func addContentVariants(to stackView: UIStackView) {
        // Short content
        let shortContentData = PromotionalBonusCardData(
            id: "short",
            headerText: "Special Offer",
            mainTitle: "Get bonus now!",
            userAvatars: [],
            playersCount: "100",
            hasGradientView: true,
            claimButtonTitle: "Claim",
            termsButtonTitle: "T&Cs",
            bonusAmount: 500
        )
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Short Content",
            view: createCardView(viewModel: MockPromotionalBonusCardViewModel(cardData: shortContentData))
        ))
    }

    // MARK: - Helper Methods

    private func createCardView(viewModel: MockPromotionalBonusCardViewModel) -> PromotionalBonusCardView {
        let view = PromotionalBonusCardView(viewModel: viewModel)
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
        stack.spacing = 6
        stack.alignment = .fill
        return stack
    }
}

// MARK: - Preview
#if DEBUG
#Preview("Gradient States") {
    PromotionalBonusCardViewSnapshotViewController(category: .gradientStates)
}

#Preview("Content Variants") {
    PromotionalBonusCardViewSnapshotViewController(category: .contentVariants)
}
#endif

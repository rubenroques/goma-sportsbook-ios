import UIKit
import SwiftUI

// MARK: - Snapshot Category
enum BonusInfoCardSnapshotCategory: String, CaseIterable {
    case basicStates = "Basic States"
    case statusVariants = "Status Variants"
    case contentVariants = "Content Variants"
}

final class BonusInfoCardViewSnapshotViewController: UIViewController {

    private let category: BonusInfoCardSnapshotCategory

    init(category: BonusInfoCardSnapshotCategory) {
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
        titleLabel.text = "BonusInfoCardView - \(category.rawValue)"
        titleLabel.font = StyleProvider.fontWith(type: .bold, size: 16)
        titleLabel.textColor = StyleProvider.Color.textPrimary
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false

        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.alignment = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(titleLabel)
        view.addSubview(scrollView)
        scrollView.addSubview(stackView)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),

            scrollView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 24),
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
        case .basicStates:
            addBasicStatesVariants(to: stackView)
        case .statusVariants:
            addStatusVariants(to: stackView)
        case .contentVariants:
            addContentVariants(to: stackView)
        }
    }

    // MARK: - Category Variants

    private func addBasicStatesVariants(to stackView: UIStackView) {
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Complete (with header image, combo type)",
            view: createBonusInfoCardView(viewModel: MockBonusInfoCardViewModel.complete)
        ))
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Simple (with header image, simple type)",
            view: createBonusInfoCardView(viewModel: MockBonusInfoCardViewModel.simple)
        ))
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Minimal (no header, no subtitle)",
            view: createBonusInfoCardView(viewModel: MockBonusInfoCardViewModel.minimal)
        ))
    }

    private func addStatusVariants(to stackView: UIStackView) {
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Active Status",
            view: createBonusInfoCardView(viewModel: MockBonusInfoCardViewModel.complete)
        ))
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Released Status (completed)",
            view: createBonusInfoCardView(viewModel: MockBonusInfoCardViewModel.released)
        ))
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Almost Complete (high progress)",
            view: createBonusInfoCardView(viewModel: MockBonusInfoCardViewModel.almostComplete)
        ))
    }

    private func addContentVariants(to stackView: UIStackView) {
        stackView.addArrangedSubview(createLabeledVariant(
            label: "With Header Image",
            view: createBonusInfoCardView(viewModel: MockBonusInfoCardViewModel.complete)
        ))
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Without Header Image",
            view: createBonusInfoCardView(viewModel: MockBonusInfoCardViewModel.withoutHeader)
        ))
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Without Remaining Wager Text",
            view: createBonusInfoCardView(viewModel: MockBonusInfoCardViewModel.withoutRemainingText)
        ))
    }

    // MARK: - Helper Methods

    private func createBonusInfoCardView(viewModel: MockBonusInfoCardViewModel) -> BonusInfoCardView {
        let view = BonusInfoCardView(viewModel: viewModel)
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
@available(iOS 17.0, *)
#Preview("Basic States") {
    BonusInfoCardViewSnapshotViewController(category: .basicStates)
}

@available(iOS 17.0, *)
#Preview("Status Variants") {
    BonusInfoCardViewSnapshotViewController(category: .statusVariants)
}

@available(iOS 17.0, *)
#Preview("Content Variants") {
    BonusInfoCardViewSnapshotViewController(category: .contentVariants)
}
#endif

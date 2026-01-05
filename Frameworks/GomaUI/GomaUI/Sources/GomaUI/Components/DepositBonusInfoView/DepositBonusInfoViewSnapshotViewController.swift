import UIKit
import SwiftUI

// MARK: - Snapshot Category
enum DepositBonusInfoSnapshotCategory: String, CaseIterable {
    case basicStates = "Basic States"
    case contentVariants = "Content Variants"
}

final class DepositBonusInfoViewSnapshotViewController: UIViewController {

    private let category: DepositBonusInfoSnapshotCategory

    init(category: DepositBonusInfoSnapshotCategory) {
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
        titleLabel.text = "DepositBonusInfoView - \(category.rawValue)"
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
        case .basicStates:
            addBasicStatesVariants(to: stackView)
        case .contentVariants:
            addContentVariants(to: stackView)
        }
    }

    // MARK: - Category Variants

    private func addBasicStatesVariants(to stackView: UIStackView) {
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Default (XAF)",
            view: createView(viewModel: MockDepositBonusInfoViewModel.defaultMock)
        ))
        stackView.addArrangedSubview(createLabeledVariant(
            label: "USD Currency",
            view: createView(viewModel: MockDepositBonusInfoViewModel.usdMock)
        ))
    }

    private func addContentVariants(to stackView: UIStackView) {
        // Short amount
        let shortAmountData = DepositBonusInfoData(
            id: "short",
            icon: "deposit_gift_icon",
            balanceText: "Bonus",
            currencyAmount: "5"
        )
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Short Amount",
            view: createView(viewModel: MockDepositBonusInfoViewModel(depositBonusInfo: shortAmountData))
        ))

        // Long amount
        let longAmountData = DepositBonusInfoData(
            id: "long",
            icon: "deposit_gift_icon",
            balanceText: "Your deposit + Bonus Balance",
            currencyAmount: "XAF 1,234,567.89"
        )
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Long Amount",
            view: createView(viewModel: MockDepositBonusInfoViewModel(depositBonusInfo: longAmountData))
        ))

        // Placeholder state
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Placeholder",
            view: createView(viewModel: MockDepositBonusInfoViewModel.defaultMock)
        ))
    }

    // MARK: - Helper Methods

    private func createView(viewModel: DepositBonusBalanceViewModelProtocol) -> DepositBonusInfoView {
        let infoView = DepositBonusInfoView(viewModel: viewModel)
        infoView.translatesAutoresizingMaskIntoConstraints = false
        return infoView
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
    DepositBonusInfoViewSnapshotViewController(category: .basicStates)
}

@available(iOS 17.0, *)
#Preview("Content Variants") {
    DepositBonusInfoViewSnapshotViewController(category: .contentVariants)
}
#endif

import UIKit
import SwiftUI

final class CashoutAmountViewSnapshotViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .backgroundTestColor
        setupUI()
    }

    private func setupUI() {
        let titleLabel = UILabel()
        titleLabel.text = "CashoutAmountView"
        titleLabel.font = .systemFont(ofSize: 16, weight: .bold)
        titleLabel.textColor = .darkGray
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

        // Partial Cashout (default)
        let partialVM = MockCashoutAmountViewModel.defaultMock()
        stackView.addArrangedSubview(createLabeledVariant(label: "Partial Cashout", view: CashoutAmountView(viewModel: partialVM)))

        // Full Cashout
        let fullVM = MockCashoutAmountViewModel.customMock(
            title: "Full Cashout",
            currency: "XAF",
            amount: "150.00"
        )
        stackView.addArrangedSubview(createLabeledVariant(label: "Full Cashout", view: CashoutAmountView(viewModel: fullVM)))

        // Small Amount
        let smallVM = MockCashoutAmountViewModel.customMock(
            title: "Cashout",
            currency: "€",
            amount: "5.50"
        )
        stackView.addArrangedSubview(createLabeledVariant(label: "Small Amount", view: CashoutAmountView(viewModel: smallVM)))

        // Large Amount
        let largeVM = MockCashoutAmountViewModel.customMock(
            title: "Partial Cashout",
            currency: "XAF",
            amount: "25,000.00"
        )
        stackView.addArrangedSubview(createLabeledVariant(label: "Large Amount", view: CashoutAmountView(viewModel: largeVM)))

        // Different Currency
        let euroVM = MockCashoutAmountViewModel.customMock(
            title: "Total Amount",
            currency: "€",
            amount: "89.99"
        )
        stackView.addArrangedSubview(createLabeledVariant(label: "Euro Currency", view: CashoutAmountView(viewModel: euroVM)))
    }

    private func createLabeledVariant(label: String, view: UIView) -> UIStackView {
        let labelView = UILabel()
        labelView.text = label
        labelView.font = .systemFont(ofSize: 12, weight: .medium)
        labelView.textColor = .gray

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
#Preview {
    CashoutAmountViewSnapshotViewController()
}
#endif

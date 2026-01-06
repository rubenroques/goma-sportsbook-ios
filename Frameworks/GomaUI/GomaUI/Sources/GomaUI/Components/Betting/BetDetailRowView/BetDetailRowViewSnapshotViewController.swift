import UIKit
import SwiftUI

final class BetDetailRowViewSnapshotViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .backgroundTestColor
        setupUI()
    }

    private func setupUI() {
        let titleLabel = UILabel()
        titleLabel.text = "BetDetailRowView"
        titleLabel.font = StyleProvider.fontWith(type: .bold, size: 16)
        titleLabel.textColor = StyleProvider.Color.textSecondary
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.alignment = .leading
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

        // Standard style - no corners
        let standardVM = MockBetDetailRowViewModel.defaultMock()
        let standardView = BetDetailRowView(viewModel: standardVM, cornerStyle: .none)
        stackView.addArrangedSubview(createLabeledVariant(label: "Standard - No Corners", view: standardView))

        // Standard style - top corners
        let topCornersVM = MockBetDetailRowViewModel.customMock(
            label: "Stake",
            value: "XAF 50.00",
            style: .standard
        )
        let topCornersView = BetDetailRowView(viewModel: topCornersVM, cornerStyle: .topOnly(radius: 8))
        stackView.addArrangedSubview(createLabeledVariant(label: "Standard - Top Corners", view: topCornersView))

        // Standard style - bottom corners
        let bottomCornersVM = MockBetDetailRowViewModel.customMock(
            label: "Total Odds",
            value: "3.50",
            style: .standard
        )
        let bottomCornersView = BetDetailRowView(viewModel: bottomCornersVM, cornerStyle: .bottomOnly(radius: 8))
        stackView.addArrangedSubview(createLabeledVariant(label: "Standard - Bottom Corners", view: bottomCornersView))

        // Standard style - all corners
        let allCornersVM = MockBetDetailRowViewModel.customMock(
            label: "Potential Win",
            value: "XAF 175.00",
            style: .standard
        )
        let allCornersView = BetDetailRowView(viewModel: allCornersVM, cornerStyle: .all(radius: 8))
        stackView.addArrangedSubview(createLabeledVariant(label: "Standard - All Corners", view: allCornersView))

        // Header style
        let headerVM = MockBetDetailRowViewModel.headerMock()
        let headerView = BetDetailRowView(viewModel: headerVM, cornerStyle: .none)
        stackView.addArrangedSubview(createLabeledVariant(label: "Header Style", view: headerView))

        // Header style with top corners
        let headerTopCornersVM = MockBetDetailRowViewModel.customMock(
            label: "Bet Details",
            value: "",
            style: .header
        )
        let headerTopCornersView = BetDetailRowView(viewModel: headerTopCornersVM, cornerStyle: .topOnly(radius: 8))
        stackView.addArrangedSubview(createLabeledVariant(label: "Header - Top Corners", view: headerTopCornersView))

        // Long text values
        let longTextVM = MockBetDetailRowViewModel.customMock(
            label: "Transaction ID",
            value: "TXN-20250116-ABC123456789",
            style: .standard
        )
        let longTextView = BetDetailRowView(viewModel: longTextVM, cornerStyle: .none)
        stackView.addArrangedSubview(createLabeledVariant(label: "Long Text Value", view: longTextView))
    }

    private func createLabeledVariant(label: String, view: UIView) -> UIStackView {
        let variantLabel = UILabel()
        variantLabel.text = label
        variantLabel.font = StyleProvider.fontWith(type: .medium, size: 12)
        variantLabel.textColor = StyleProvider.Color.textSecondary

        view.translatesAutoresizingMaskIntoConstraints = false

        let containerStack = UIStackView(arrangedSubviews: [variantLabel, view])
        containerStack.axis = .vertical
        containerStack.spacing = 6
        containerStack.alignment = .leading

        NSLayoutConstraint.activate([
            view.widthAnchor.constraint(equalToConstant: 350)
        ])

        return containerStack
    }
}

// MARK: - Preview
#if DEBUG
#Preview {
    BetDetailRowViewSnapshotViewController()
}
#endif

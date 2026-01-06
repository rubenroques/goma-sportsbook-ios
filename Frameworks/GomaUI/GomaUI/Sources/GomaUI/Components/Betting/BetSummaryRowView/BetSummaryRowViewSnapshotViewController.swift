import UIKit
import SwiftUI

final class BetSummaryRowViewSnapshotViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .backgroundTestColor
        setupUI()
    }

    private func setupUI() {
        let titleLabel = UILabel()
        titleLabel.text = "BetSummaryRowView"
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

        // Potential Winnings
        let potentialWinningsView = BetSummaryRowView(viewModel: MockBetSummaryRowViewModel.potentialWinningsMock())
        potentialWinningsView.translatesAutoresizingMaskIntoConstraints = false
        stackView.addArrangedSubview(createLabeledVariant(label: "Potential Winnings", view: potentialWinningsView))

        // Win Bonus
        let winBonusView = BetSummaryRowView(viewModel: MockBetSummaryRowViewModel.winBonusMock())
        winBonusView.translatesAutoresizingMaskIntoConstraints = false
        stackView.addArrangedSubview(createLabeledVariant(label: "Win Bonus", view: winBonusView))

        // Payout
        let payoutView = BetSummaryRowView(viewModel: MockBetSummaryRowViewModel.payoutMock())
        payoutView.translatesAutoresizingMaskIntoConstraints = false
        stackView.addArrangedSubview(createLabeledVariant(label: "Payout", view: payoutView))

        // Odds
        let oddsView = BetSummaryRowView(viewModel: MockBetSummaryRowViewModel.oddsMock())
        oddsView.translatesAutoresizingMaskIntoConstraints = false
        stackView.addArrangedSubview(createLabeledVariant(label: "Odds", view: oddsView))

        // Disabled state
        let disabledView = BetSummaryRowView(viewModel: MockBetSummaryRowViewModel.disabledMock())
        disabledView.translatesAutoresizingMaskIntoConstraints = false
        stackView.addArrangedSubview(createLabeledVariant(label: "Disabled", view: disabledView))
    }

    private func createLabeledVariant(label: String, view: UIView) -> UIStackView {
        let labelView = UILabel()
        labelView.text = label
        labelView.font = .systemFont(ofSize: 12, weight: .medium)
        labelView.textColor = .gray

        let containerStack = UIStackView(arrangedSubviews: [labelView, view])
        containerStack.axis = .vertical
        containerStack.spacing = 6
        containerStack.alignment = .fill

        return containerStack
    }
}

// MARK: - Preview
#if DEBUG
#Preview {
    BetSummaryRowViewSnapshotViewController()
}
#endif

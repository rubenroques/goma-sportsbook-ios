import UIKit
import SwiftUI

// MARK: - Snapshot Category
enum BetslipTicketSnapshotCategory: String, CaseIterable {
    case oddsStates = "Odds States"
    case enabledStates = "Enabled States"
}

final class BetslipTicketViewSnapshotViewController: UIViewController {

    private let category: BetslipTicketSnapshotCategory

    init(category: BetslipTicketSnapshotCategory) {
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
        titleLabel.text = "BetslipTicketView - \(category.rawValue)"
        titleLabel.font = StyleProvider.fontWith(type: .bold, size: 16)
        titleLabel.textColor = StyleProvider.Color.textPrimary
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false

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

            scrollView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 24),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -16),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -32)
        ])

        addVariants(to: stackView)
    }

    private func addVariants(to stackView: UIStackView) {
        switch category {
        case .oddsStates:
            addOddsStatesVariants(to: stackView)
        case .enabledStates:
            addEnabledStatesVariants(to: stackView)
        }
    }

    // MARK: - Category Variants

    private func addOddsStatesVariants(to stackView: UIStackView) {
        // Normal odds
        let normalView = BetslipTicketView(viewModel: MockBetslipTicketViewModel.typicalMock())
        normalView.translatesAutoresizingMaskIntoConstraints = false
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Normal Odds",
            view: normalView
        ))

        // Increased odds
        let increasedView = BetslipTicketView(viewModel: MockBetslipTicketViewModel.increasedOddsMock())
        increasedView.translatesAutoresizingMaskIntoConstraints = false
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Increased Odds",
            view: increasedView
        ))

        // Decreased odds
        let decreasedView = BetslipTicketView(viewModel: MockBetslipTicketViewModel.decreasedOddsMock())
        decreasedView.translatesAutoresizingMaskIntoConstraints = false
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Decreased Odds",
            view: decreasedView
        ))
    }

    private func addEnabledStatesVariants(to stackView: UIStackView) {
        // Enabled
        let enabledView = BetslipTicketView(viewModel: MockBetslipTicketViewModel.typicalMock())
        enabledView.translatesAutoresizingMaskIntoConstraints = false
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Enabled",
            view: enabledView
        ))

        // Disabled
        let disabledView = BetslipTicketView(viewModel: MockBetslipTicketViewModel.disabledMock())
        disabledView.translatesAutoresizingMaskIntoConstraints = false
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Disabled",
            view: disabledView
        ))
    }

    // MARK: - Helper Methods

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
#Preview("Odds States") {
    BetslipTicketViewSnapshotViewController(category: .oddsStates)
}

#Preview("Enabled States") {
    BetslipTicketViewSnapshotViewController(category: .enabledStates)
}
#endif

import UIKit
import SwiftUI

// MARK: - Snapshot Category
enum BetslipTypeTabItemSnapshotCategory: String, CaseIterable {
    case basicStates = "Basic States"
    case tabVariants = "Tab Variants"
}

final class BetslipTypeTabItemViewSnapshotViewController: UIViewController {

    private let category: BetslipTypeTabItemSnapshotCategory

    init(category: BetslipTypeTabItemSnapshotCategory) {
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
        titleLabel.text = "BetslipTypeTabItemView - \(category.rawValue)"
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
        case .tabVariants:
            addTabVariants(to: stackView)
        }
    }

    // MARK: - Category Variants

    private func addBasicStatesVariants(to stackView: UIStackView) {
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Sports - Selected",
            view: createTabItemView(viewModel: MockBetslipTypeTabItemViewModel.sportsSelectedMock())
        ))
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Sports - Unselected",
            view: createTabItemView(viewModel: MockBetslipTypeTabItemViewModel.sportsUnselectedMock())
        ))
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Virtuals - Selected",
            view: createTabItemView(viewModel: MockBetslipTypeTabItemViewModel.virtualsSelectedMock())
        ))
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Virtuals - Unselected",
            view: createTabItemView(viewModel: MockBetslipTypeTabItemViewModel.virtualsUnselectedMock())
        ))
    }

    private func addTabVariants(to stackView: UIStackView) {
        // Side by side comparison - selected vs unselected
        let sportsRow = UIStackView()
        sportsRow.axis = .horizontal
        sportsRow.spacing = 12
        sportsRow.distribution = .fillEqually

        sportsRow.addArrangedSubview(createTabItemView(viewModel: MockBetslipTypeTabItemViewModel.sportsSelectedMock()))
        sportsRow.addArrangedSubview(createTabItemView(viewModel: MockBetslipTypeTabItemViewModel.sportsUnselectedMock()))

        stackView.addArrangedSubview(createLabeledVariant(
            label: "Sports: Selected vs Unselected",
            view: sportsRow
        ))

        let virtualsRow = UIStackView()
        virtualsRow.axis = .horizontal
        virtualsRow.spacing = 12
        virtualsRow.distribution = .fillEqually

        virtualsRow.addArrangedSubview(createTabItemView(viewModel: MockBetslipTypeTabItemViewModel.virtualsSelectedMock()))
        virtualsRow.addArrangedSubview(createTabItemView(viewModel: MockBetslipTypeTabItemViewModel.virtualsUnselectedMock()))

        stackView.addArrangedSubview(createLabeledVariant(
            label: "Virtuals: Selected vs Unselected",
            view: virtualsRow
        ))

        // Full tab bar simulation
        let tabBarRow = UIStackView()
        tabBarRow.axis = .horizontal
        tabBarRow.spacing = 0
        tabBarRow.distribution = .fillEqually

        tabBarRow.addArrangedSubview(createTabItemView(viewModel: MockBetslipTypeTabItemViewModel.sportsSelectedMock()))
        tabBarRow.addArrangedSubview(createTabItemView(viewModel: MockBetslipTypeTabItemViewModel.virtualsUnselectedMock()))

        stackView.addArrangedSubview(createLabeledVariant(
            label: "Tab Bar: Sports Active",
            view: tabBarRow
        ))

        let tabBarRow2 = UIStackView()
        tabBarRow2.axis = .horizontal
        tabBarRow2.spacing = 0
        tabBarRow2.distribution = .fillEqually

        tabBarRow2.addArrangedSubview(createTabItemView(viewModel: MockBetslipTypeTabItemViewModel.sportsUnselectedMock()))
        tabBarRow2.addArrangedSubview(createTabItemView(viewModel: MockBetslipTypeTabItemViewModel.virtualsSelectedMock()))

        stackView.addArrangedSubview(createLabeledVariant(
            label: "Tab Bar: Virtuals Active",
            view: tabBarRow2
        ))
    }

    // MARK: - Helper Methods

    private func createTabItemView(viewModel: MockBetslipTypeTabItemViewModel) -> BetslipTypeTabItemView {
        let view = BetslipTypeTabItemView(viewModel: viewModel)
        view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            view.heightAnchor.constraint(equalToConstant: 48)
        ])
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
    BetslipTypeTabItemViewSnapshotViewController(category: .basicStates)
}

@available(iOS 17.0, *)
#Preview("Tab Variants") {
    BetslipTypeTabItemViewSnapshotViewController(category: .tabVariants)
}
#endif

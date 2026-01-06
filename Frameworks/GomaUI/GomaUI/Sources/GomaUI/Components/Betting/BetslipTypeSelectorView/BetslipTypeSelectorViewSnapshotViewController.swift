import UIKit
import SwiftUI

// MARK: - Snapshot Category
enum BetslipTypeSelectorSnapshotCategory: String, CaseIterable {
    case selectionStates = "Selection States"
}

final class BetslipTypeSelectorViewSnapshotViewController: UIViewController {

    private let category: BetslipTypeSelectorSnapshotCategory

    init(category: BetslipTypeSelectorSnapshotCategory) {
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
        titleLabel.text = "BetslipTypeSelectorView - \(category.rawValue)"
        titleLabel.font = StyleProvider.fontWith(type: .bold, size: 16)
        titleLabel.textColor = StyleProvider.Color.textPrimary
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 24
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
        case .selectionStates:
            addSelectionStatesVariants(to: stackView)
        }
    }

    // MARK: - Category Variants

    private func addSelectionStatesVariants(to stackView: UIStackView) {
        // Sports selected
        let sportsSelectedView = BetslipTypeSelectorView(viewModel: MockBetslipTypeSelectorViewModel.sportsSelectedMock())
        sportsSelectedView.translatesAutoresizingMaskIntoConstraints = false
        sportsSelectedView.heightAnchor.constraint(equalToConstant: 44).isActive = true
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Sports Selected",
            view: sportsSelectedView
        ))

        // Virtuals selected
        let virtualsSelectedView = BetslipTypeSelectorView(viewModel: MockBetslipTypeSelectorViewModel.virtualsSelectedMock())
        virtualsSelectedView.translatesAutoresizingMaskIntoConstraints = false
        virtualsSelectedView.heightAnchor.constraint(equalToConstant: 44).isActive = true
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Virtuals Selected",
            view: virtualsSelectedView
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
#Preview("Selection States") {
    BetslipTypeSelectorViewSnapshotViewController(category: .selectionStates)
}
#endif

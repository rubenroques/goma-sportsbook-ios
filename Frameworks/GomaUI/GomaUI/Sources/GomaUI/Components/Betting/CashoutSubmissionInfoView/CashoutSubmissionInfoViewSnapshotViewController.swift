import UIKit
import SwiftUI

// MARK: - Snapshot Category
enum CashoutSubmissionInfoSnapshotCategory: String, CaseIterable {
    case basicStates = "Basic States"
}

final class CashoutSubmissionInfoViewSnapshotViewController: UIViewController {

    private let category: CashoutSubmissionInfoSnapshotCategory

    init(category: CashoutSubmissionInfoSnapshotCategory) {
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
        titleLabel.text = "CashoutSubmissionInfoView - \(category.rawValue)"
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
        case .basicStates:
            addBasicStatesVariants(to: stackView)
        }
    }

    // MARK: - Category Variants

    private func addBasicStatesVariants(to stackView: UIStackView) {
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Success State",
            view: createCashoutSubmissionInfoView(viewModel: MockCashoutSubmissionInfoViewModel.successMock())
        ))
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Error State",
            view: createCashoutSubmissionInfoView(viewModel: MockCashoutSubmissionInfoViewModel.errorMock())
        ))
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Custom Success Message",
            view: createCashoutSubmissionInfoView(viewModel: MockCashoutSubmissionInfoViewModel.customMock(
                state: .success,
                message: "Your cashout of XAF 500 has been processed successfully!"
            ))
        ))
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Custom Error Message",
            view: createCashoutSubmissionInfoView(viewModel: MockCashoutSubmissionInfoViewModel.customMock(
                state: .error,
                message: "Unable to process cashout. Please try again later."
            ))
        ))
    }

    // MARK: - Helper Methods

    private func createCashoutSubmissionInfoView(viewModel: MockCashoutSubmissionInfoViewModel) -> CashoutSubmissionInfoView {
        let view = CashoutSubmissionInfoView(viewModel: viewModel)
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
#Preview("Basic States") {
    CashoutSubmissionInfoViewSnapshotViewController(category: .basicStates)
}
#endif

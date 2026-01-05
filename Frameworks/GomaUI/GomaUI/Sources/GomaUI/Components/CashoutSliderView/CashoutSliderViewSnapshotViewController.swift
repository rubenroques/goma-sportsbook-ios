import UIKit
import SwiftUI

// MARK: - Snapshot Category
enum CashoutSliderSnapshotCategory: String, CaseIterable {
    case basicStates = "Basic States"
    case valueVariants = "Value Variants"
}

final class CashoutSliderViewSnapshotViewController: UIViewController {

    private let category: CashoutSliderSnapshotCategory

    init(category: CashoutSliderSnapshotCategory) {
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
        titleLabel.text = "CashoutSliderView - \(category.rawValue)"
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
        case .valueVariants:
            addValueVariants(to: stackView)
        }
    }

    // MARK: - Category Variants

    private func addBasicStatesVariants(to stackView: UIStackView) {
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Default (Max Value)",
            view: createCashoutSliderView(viewModel: MockCashoutSliderViewModel.defaultMock())
        ))
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Minimum Value",
            view: createCashoutSliderView(viewModel: MockCashoutSliderViewModel.minimumMock())
        ))

        // Disabled state
        let disabledViewModel = MockCashoutSliderViewModel.customMock(
            currentValue: 100.0
        )
        disabledViewModel.setEnabled(false)
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Disabled",
            view: createCashoutSliderView(viewModel: disabledViewModel)
        ))
    }

    private func addValueVariants(to stackView: UIStackView) {
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Maximum (200 XAF)",
            view: createCashoutSliderView(viewModel: MockCashoutSliderViewModel.maximumMock())
        ))
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Mid Value (100 XAF)",
            view: createCashoutSliderView(viewModel: MockCashoutSliderViewModel.customMock(currentValue: 100.0))
        ))
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Low Value (50 XAF)",
            view: createCashoutSliderView(viewModel: MockCashoutSliderViewModel.customMock(currentValue: 50.0))
        ))
        stackView.addArrangedSubview(createLabeledVariant(
            label: "High Range (1000 XAF max)",
            view: createCashoutSliderView(viewModel: MockCashoutSliderViewModel.customMock(
                minimumValue: 10.0,
                maximumValue: 1000.0,
                currentValue: 500.0
            ))
        ))
    }

    // MARK: - Helper Methods

    private func createCashoutSliderView(viewModel: MockCashoutSliderViewModel) -> CashoutSliderView {
        let view = CashoutSliderView(viewModel: viewModel)
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
    CashoutSliderViewSnapshotViewController(category: .basicStates)
}

@available(iOS 17.0, *)
#Preview("Value Variants") {
    CashoutSliderViewSnapshotViewController(category: .valueVariants)
}
#endif

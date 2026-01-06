import UIKit

// MARK: - Snapshot Category
enum PinDigitEntryViewSnapshotCategory: String, CaseIterable {
    case digitCount = "Digit Count"
    case fillStates = "Fill States"
}

final class PinDigitEntryViewSnapshotViewController: UIViewController {

    private let category: PinDigitEntryViewSnapshotCategory

    init(category: PinDigitEntryViewSnapshotCategory) {
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
        titleLabel.text = "PinDigitEntryView - \(category.rawValue)"
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
        case .digitCount:
            addDigitCountVariants(to: stackView)
        case .fillStates:
            addFillStatesVariants(to: stackView)
        }
    }

    // MARK: - Category Variants

    private func addDigitCountVariants(to stackView: UIStackView) {
        // 4-digit PIN (default)
        stackView.addArrangedSubview(createLabeledVariant(
            label: "4 Digits (Default)",
            view: createPinView(viewModel: MockPinDigitEntryViewModel.defaultMock)
        ))

        // 6-digit PIN
        let sixDigitData = PinDigitEntryData(digitCount: 6, currentPin: "")
        let sixDigitViewModel = MockPinDigitEntryViewModel(data: sixDigitData)
        stackView.addArrangedSubview(createLabeledVariant(
            label: "6 Digits",
            view: createPinView(viewModel: sixDigitViewModel)
        ))

        // 8-digit PIN
        stackView.addArrangedSubview(createLabeledVariant(
            label: "8 Digits",
            view: createPinView(viewModel: MockPinDigitEntryViewModel.eightDigitMock)
        ))
    }

    private func addFillStatesVariants(to stackView: UIStackView) {
        // Empty
        let emptyData = PinDigitEntryData(digitCount: 4, currentPin: "")
        let emptyViewModel = MockPinDigitEntryViewModel(data: emptyData)
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Empty",
            view: createPinView(viewModel: emptyViewModel)
        ))

        // Partially filled (1 digit)
        let oneDigitData = PinDigitEntryData(digitCount: 4, currentPin: "1")
        let oneDigitViewModel = MockPinDigitEntryViewModel(data: oneDigitData)
        stackView.addArrangedSubview(createLabeledVariant(
            label: "1 Digit Entered",
            view: createPinView(viewModel: oneDigitViewModel)
        ))

        // Partially filled (3 digits)
        stackView.addArrangedSubview(createLabeledVariant(
            label: "3 Digits Entered (6-digit PIN)",
            view: createPinView(viewModel: MockPinDigitEntryViewModel.sixDigitMock)
        ))

        // Fully filled
        let fullData = PinDigitEntryData(digitCount: 4, currentPin: "1234")
        let fullViewModel = MockPinDigitEntryViewModel(data: fullData)
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Fully Filled",
            view: createPinView(viewModel: fullViewModel)
        ))
    }

    // MARK: - Helper Methods

    private func createPinView(viewModel: MockPinDigitEntryViewModel) -> PinDigitEntryView {
        let pinView = PinDigitEntryView(viewModel: viewModel)
        pinView.translatesAutoresizingMaskIntoConstraints = false
        return pinView
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
#Preview("Digit Count") {
    PinDigitEntryViewSnapshotViewController(category: .digitCount)
}

@available(iOS 17.0, *)
#Preview("Fill States") {
    PinDigitEntryViewSnapshotViewController(category: .fillStates)
}
#endif

import UIKit

// MARK: - Snapshot Category
enum SeeMoreButtonViewSnapshotCategory: String, CaseIterable {
    case basicStates = "Basic States"
    case displayVariants = "Display Variants"
}

final class SeeMoreButtonViewSnapshotViewController: UIViewController {

    private let category: SeeMoreButtonViewSnapshotCategory

    init(category: SeeMoreButtonViewSnapshotCategory) {
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
        titleLabel.text = "SeeMoreButtonView - \(category.rawValue)"
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
        case .displayVariants:
            addDisplayVariants(to: stackView)
        }
    }

    // MARK: - Category Variants

    private func addBasicStatesVariants(to stackView: UIStackView) {
        // Default (enabled, no count)
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Default (Enabled)",
            view: createSeeMoreButton(viewModel: MockSeeMoreButtonViewModel.defaultMock)
        ))

        // Loading
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Loading",
            view: createSeeMoreButton(viewModel: MockSeeMoreButtonViewModel.loadingMock)
        ))

        // Disabled
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Disabled",
            view: createSeeMoreButton(viewModel: MockSeeMoreButtonViewModel.disabledMock)
        ))
    }

    private func addDisplayVariants(to stackView: UIStackView) {
        // Without count
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Without Count",
            view: createSeeMoreButton(viewModel: MockSeeMoreButtonViewModel.defaultMock)
        ))

        // With count (25)
        stackView.addArrangedSubview(createLabeledVariant(
            label: "With Count (25)",
            view: createSeeMoreButton(viewModel: MockSeeMoreButtonViewModel.withCountMock)
        ))

        // With high count (50)
        stackView.addArrangedSubview(createLabeledVariant(
            label: "With Count (50)",
            view: createSeeMoreButton(viewModel: MockSeeMoreButtonViewModel.interactiveMock)
        ))

        // Error/Retry state
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Retry State",
            view: createSeeMoreButton(viewModel: MockSeeMoreButtonViewModel.errorStateMock)
        ))
    }

    // MARK: - Helper Methods

    private func createSeeMoreButton(viewModel: MockSeeMoreButtonViewModel) -> SeeMoreButtonView {
        let buttonView = SeeMoreButtonView(viewModel: viewModel)
        buttonView.translatesAutoresizingMaskIntoConstraints = false
        buttonView.heightAnchor.constraint(equalToConstant: 60).isActive = true
        return buttonView
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
    SeeMoreButtonViewSnapshotViewController(category: .basicStates)
}

#Preview("Display Variants") {
    SeeMoreButtonViewSnapshotViewController(category: .displayVariants)
}
#endif

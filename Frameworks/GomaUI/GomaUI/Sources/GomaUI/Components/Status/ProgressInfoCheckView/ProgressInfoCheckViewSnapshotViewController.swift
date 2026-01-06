import UIKit

// MARK: - Snapshot Category
enum ProgressInfoCheckViewSnapshotCategory: String, CaseIterable {
    case progressStates = "Progress States"
    case enabledStates = "Enabled States"
}

final class ProgressInfoCheckViewSnapshotViewController: UIViewController {

    private let category: ProgressInfoCheckViewSnapshotCategory

    init(category: ProgressInfoCheckViewSnapshotCategory) {
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
        titleLabel.text = "ProgressInfoCheckView - \(category.rawValue)"
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
        case .progressStates:
            addProgressStatesVariants(to: stackView)
        case .enabledStates:
            addEnabledStatesVariants(to: stackView)
        }
    }

    // MARK: - Category Variants

    private func addProgressStatesVariants(to stackView: UIStackView) {
        // Incomplete - 1 of 3
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Incomplete (1/3)",
            view: createProgressView(viewModel: MockProgressInfoCheckViewModel.winBoostMock())
        ))

        // Incomplete - 0 of 3
        let zeroProgressViewModel = MockProgressInfoCheckViewModel(
            state: .incomplete(completedSegments: 0, totalSegments: 3),
            headerText: "Start your journey!",
            title: "Get a 5% Win Boost",
            subtitle: "Add 3 legs to your betslip to unlock.",
            icon: "star.fill"
        )
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Incomplete (0/3)",
            view: createProgressView(viewModel: zeroProgressViewModel)
        ))

        // Incomplete - 2 of 3
        let twoOfThreeViewModel = MockProgressInfoCheckViewModel(
            state: .incomplete(completedSegments: 2, totalSegments: 3),
            headerText: "Almost there!",
            title: "Get a 3% Win Boost",
            subtitle: "Just 1 more leg to go!",
            icon: "star.fill"
        )
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Incomplete (2/3)",
            view: createProgressView(viewModel: twoOfThreeViewModel)
        ))

        // Complete
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Complete",
            view: createProgressView(viewModel: MockProgressInfoCheckViewModel.completeMock())
        ))
    }

    private func addEnabledStatesVariants(to stackView: UIStackView) {
        // Enabled
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Enabled",
            view: createProgressView(viewModel: MockProgressInfoCheckViewModel.winBoostMock())
        ))

        // Disabled
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Disabled",
            view: createProgressView(viewModel: MockProgressInfoCheckViewModel.disabledMock())
        ))
    }

    // MARK: - Helper Methods

    private func createProgressView(viewModel: MockProgressInfoCheckViewModel) -> ProgressInfoCheckView {
        let progressView = ProgressInfoCheckView(viewModel: viewModel)
        progressView.translatesAutoresizingMaskIntoConstraints = false
        return progressView
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
#Preview("Progress States") {
    ProgressInfoCheckViewSnapshotViewController(category: .progressStates)
}

@available(iOS 17.0, *)
#Preview("Enabled States") {
    ProgressInfoCheckViewSnapshotViewController(category: .enabledStates)
}
#endif

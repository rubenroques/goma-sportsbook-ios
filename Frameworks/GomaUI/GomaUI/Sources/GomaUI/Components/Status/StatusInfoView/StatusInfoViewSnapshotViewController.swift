import UIKit

// MARK: - Snapshot Category
enum StatusInfoViewSnapshotCategory: String, CaseIterable {
    case basicStates = "Basic States"
}

final class StatusInfoViewSnapshotViewController: UIViewController {

    private let category: StatusInfoViewSnapshotCategory

    init(category: StatusInfoViewSnapshotCategory) {
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
        titleLabel.text = "StatusInfoView - \(category.rawValue)"
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
        // Success
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Success",
            view: createStatusInfoView(viewModel: MockStatusInfoViewModel.successMock)
        ))

        // Error
        let errorInfo = StatusInfo(
            icon: "xmark.circle.fill",
            title: "Something Went Wrong",
            message: "We couldn't process your request. Please try again later."
        )
        let errorViewModel = MockStatusInfoViewModel(statusInfo: errorInfo)
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Error",
            view: createStatusInfoView(viewModel: errorViewModel)
        ))

        // Warning
        let warningInfo = StatusInfo(
            icon: "exclamationmark.triangle.fill",
            title: "Account Verification Required",
            message: "Please verify your account to continue using all features."
        )
        let warningViewModel = MockStatusInfoViewModel(statusInfo: warningInfo)
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Warning",
            view: createStatusInfoView(viewModel: warningViewModel)
        ))

        // Info
        let infoData = StatusInfo(
            icon: "info.circle.fill",
            title: "System Maintenance",
            message: "The system will be under maintenance from 2:00 AM to 4:00 AM."
        )
        let infoViewModel = MockStatusInfoViewModel(statusInfo: infoData)
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Info",
            view: createStatusInfoView(viewModel: infoViewModel)
        ))
    }

    // MARK: - Helper Methods

    private func createStatusInfoView(viewModel: MockStatusInfoViewModel) -> StatusInfoView {
        let statusView = StatusInfoView(viewModel: viewModel)
        statusView.translatesAutoresizingMaskIntoConstraints = false
        return statusView
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
    StatusInfoViewSnapshotViewController(category: .basicStates)
}
#endif

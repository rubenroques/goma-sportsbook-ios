import UIKit

// MARK: - Snapshot Category
enum ResendCodeViewSnapshotCategory: String, CaseIterable {
    case countdownStates = "Countdown States"
}

final class ResendCodeViewSnapshotViewController: UIViewController {

    private let category: ResendCodeViewSnapshotCategory

    init(category: ResendCodeViewSnapshotCategory) {
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
        titleLabel.text = "ResendCodeView - \(category.rawValue)"
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
        case .countdownStates:
            addCountdownStatesVariants(to: stackView)
        }
    }

    // MARK: - Category Variants

    private func addCountdownStatesVariants(to stackView: UIStackView) {
        // Default (59 seconds)
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Default (59 seconds)",
            view: createResendCodeView(viewModel: MockResendCodeCountdownViewModel(startSeconds: 59))
        ))

        // Short countdown
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Short (15 seconds)",
            view: createResendCodeView(viewModel: MockResendCodeCountdownViewModel(startSeconds: 15))
        ))

        // Long countdown
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Long (120 seconds)",
            view: createResendCodeView(viewModel: MockResendCodeCountdownViewModel(startSeconds: 120))
        ))
    }

    // MARK: - Helper Methods

    private func createResendCodeView(viewModel: MockResendCodeCountdownViewModel) -> ResendCodeCountdownView {
        let resendView = ResendCodeCountdownView(viewModel: viewModel)
        resendView.translatesAutoresizingMaskIntoConstraints = false
        return resendView
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
#Preview("Countdown States") {
    ResendCodeViewSnapshotViewController(category: .countdownStates)
}
#endif

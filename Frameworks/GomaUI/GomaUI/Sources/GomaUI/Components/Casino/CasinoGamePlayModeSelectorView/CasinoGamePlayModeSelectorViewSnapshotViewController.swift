import UIKit
import SwiftUI

// MARK: - Snapshot Category
enum CasinoGamePlayModeSelectorSnapshotCategory: String, CaseIterable {
    case basicStates = "Basic States"
    case userStates = "User States"
}

final class CasinoGamePlayModeSelectorViewSnapshotViewController: UIViewController {

    private let category: CasinoGamePlayModeSelectorSnapshotCategory

    init(category: CasinoGamePlayModeSelectorSnapshotCategory) {
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
        titleLabel.text = "CasinoGamePlayModeSelectorView - \(category.rawValue)"
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

            scrollView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
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
        case .basicStates:
            addBasicStatesVariants(to: stackView)
        case .userStates:
            addUserStatesVariants(to: stackView)
        }
    }

    // MARK: - Category Variants

    private func addBasicStatesVariants(to stackView: UIStackView) {
        // Default state (logged out)
        let defaultView = CasinoGamePlayModeSelectorView(viewModel: MockCasinoGamePlayModeSelectorViewModel.defaultMock)
        defaultView.translatesAutoresizingMaskIntoConstraints = false
        defaultView.heightAnchor.constraint(equalToConstant: 350).isActive = true
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Default (Logged Out)",
            view: defaultView
        ))

        // Loading state
        let loadingView = CasinoGamePlayModeSelectorView(viewModel: MockCasinoGamePlayModeSelectorViewModel.loadingMock)
        loadingView.translatesAutoresizingMaskIntoConstraints = false
        loadingView.heightAnchor.constraint(equalToConstant: 350).isActive = true
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Loading",
            view: loadingView
        ))
    }

    private func addUserStatesVariants(to stackView: UIStackView) {
        // Logged in user
        let loggedInView = CasinoGamePlayModeSelectorView(viewModel: MockCasinoGamePlayModeSelectorViewModel.loggedInMock)
        loggedInView.translatesAutoresizingMaskIntoConstraints = false
        loggedInView.heightAnchor.constraint(equalToConstant: 350).isActive = true
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Logged In",
            view: loggedInView
        ))

        // Insufficient funds
        let insufficientView = CasinoGamePlayModeSelectorView(viewModel: MockCasinoGamePlayModeSelectorViewModel.insufficientFundsMock)
        insufficientView.translatesAutoresizingMaskIntoConstraints = false
        insufficientView.heightAnchor.constraint(equalToConstant: 350).isActive = true
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Insufficient Funds",
            view: insufficientView
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
#Preview("Basic States") {
    CasinoGamePlayModeSelectorViewSnapshotViewController(category: .basicStates)
}

#Preview("User States") {
    CasinoGamePlayModeSelectorViewSnapshotViewController(category: .userStates)
}
#endif

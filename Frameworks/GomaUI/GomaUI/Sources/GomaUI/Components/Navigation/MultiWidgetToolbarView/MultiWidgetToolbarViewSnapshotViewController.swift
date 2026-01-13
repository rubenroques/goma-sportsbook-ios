import UIKit
import SwiftUI

// MARK: - Snapshot Category
enum MultiWidgetToolbarSnapshotCategory: String, CaseIterable {
    case loggedInState = "Logged In State"
    case loggedOutState = "Logged Out State"
}

final class MultiWidgetToolbarViewSnapshotViewController: UIViewController {

    private let category: MultiWidgetToolbarSnapshotCategory

    init(category: MultiWidgetToolbarSnapshotCategory) {
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
        titleLabel.text = "MultiWidgetToolbarView - \(category.rawValue)"
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
        case .loggedInState:
            addLoggedInVariants(to: stackView)
        case .loggedOutState:
            addLoggedOutVariants(to: stackView)
        }
    }

    // MARK: - Category Variants

    private func addLoggedInVariants(to stackView: UIStackView) {
        // Default logged in state - single line with logo, wallet, avatar
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Default (Logo, Wallet, Avatar)",
            view: createToolbarView(layoutState: .loggedIn)
        ))
    }

    private func addLoggedOutVariants(to stackView: UIStackView) {
        // Default logged out state - two lines: logo/support/language + login/join buttons
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Default (Logo, Support, Language + Buttons)",
            view: createToolbarView(layoutState: .loggedOut)
        ))
    }

    // MARK: - Helper Methods

    private func createToolbarView(layoutState: LayoutState) -> MultiWidgetToolbarView {
        let viewModel = MockMultiWidgetToolbarViewModel.defaultMock
        viewModel.setLayoutState(layoutState)

        let toolbar = MultiWidgetToolbarView(viewModel: viewModel)
        toolbar.translatesAutoresizingMaskIntoConstraints = false

        // Set height based on layout state
        let height: CGFloat = (layoutState == .loggedIn) ? 70 : 130
        toolbar.heightAnchor.constraint(equalToConstant: height).isActive = true

        return toolbar
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
#Preview("Logged In State") {
    MultiWidgetToolbarViewSnapshotViewController(category: .loggedInState)
}

#Preview("Logged Out State") {
    MultiWidgetToolbarViewSnapshotViewController(category: .loggedOutState)
}
#endif

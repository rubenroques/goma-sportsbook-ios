import UIKit
import SwiftUI

// MARK: - Snapshot Category
enum SimpleNavigationBarSnapshotCategory: String, CaseIterable {
    case backButtonVariants = "Back Button Variants"
    case titleVariants = "Title Variants"
    case combinedLayouts = "Combined Layouts"
    case styleCustomization = "Style Customization"
}

final class SimpleNavigationBarViewSnapshotViewController: UIViewController {

    private let category: SimpleNavigationBarSnapshotCategory

    init(category: SimpleNavigationBarSnapshotCategory) {
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
        titleLabel.text = "SimpleNavigationBarView - \(category.rawValue)"
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
        case .backButtonVariants:
            addBackButtonVariants(to: stackView)
        case .titleVariants:
            addTitleVariants(to: stackView)
        case .combinedLayouts:
            addCombinedLayoutsVariants(to: stackView)
        case .styleCustomization:
            addStyleCustomizationVariants(to: stackView)
        }
    }

    // MARK: - Category Variants

    private func addBackButtonVariants(to stackView: UIStackView) {
        // Icon only
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Icon Only",
            view: createNavBarView(viewModel: MockSimpleNavigationBarViewModel.iconOnly)
        ))

        // Icon + "Back" text
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Icon + Back Text",
            view: createNavBarView(viewModel: MockSimpleNavigationBarViewModel.withBackText)
        ))

        // No back button (hidden)
        let noBackViewModel = MockSimpleNavigationBarViewModel(
            backButtonText: nil,
            title: nil,
            showBackButton: false
        )
        stackView.addArrangedSubview(createLabeledVariant(
            label: "No Back Button (Hidden)",
            view: createNavBarView(viewModel: noBackViewModel)
        ))
    }

    private func addTitleVariants(to stackView: UIStackView) {
        // No title (icon only)
        stackView.addArrangedSubview(createLabeledVariant(
            label: "No Title",
            view: createNavBarView(viewModel: MockSimpleNavigationBarViewModel.iconOnly)
        ))

        // Short title
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Short Title",
            view: createNavBarView(viewModel: MockSimpleNavigationBarViewModel.withTitle)
        ))

        // Long title (truncation test)
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Long Title (Truncation)",
            view: createNavBarView(viewModel: MockSimpleNavigationBarViewModel.longTitle)
        ))

        // Title only (no back button)
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Title Only (No Back)",
            view: createNavBarView(viewModel: MockSimpleNavigationBarViewModel.titleOnly)
        ))
    }

    private func addCombinedLayoutsVariants(to stackView: UIStackView) {
        // Icon + Back text + Title
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Icon + Back + Title",
            view: createNavBarView(viewModel: MockSimpleNavigationBarViewModel.withBackTextAndTitle)
        ))

        // Icon only + Title
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Icon Only + Title",
            view: createNavBarView(viewModel: MockSimpleNavigationBarViewModel.withTitle)
        ))

        // Icon + Back text only
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Icon + Back Text Only",
            view: createNavBarView(viewModel: MockSimpleNavigationBarViewModel.withBackText)
        ))

        // Long back text + Long title (edge case)
        let longEverythingViewModel = MockSimpleNavigationBarViewModel(
            backButtonText: "Go Back to Previous Screen",
            title: "Very Long Navigation Bar Title That Should Truncate"
        )
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Long Back Text + Long Title",
            view: createNavBarView(viewModel: longEverythingViewModel)
        ))
    }

    private func addStyleCustomizationVariants(to stackView: UIStackView) {
        // Default style
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Default Style",
            view: createNavBarView(viewModel: MockSimpleNavigationBarViewModel.withBackTextAndTitle)
        ))

        // Dark overlay style (simulates overlay on dark background)
        let darkOverlayNavBar = createNavBarView(viewModel: MockSimpleNavigationBarViewModel.withBackTextAndTitle)
        darkOverlayNavBar.setCustomization(.darkOverlay())

        // Wrap in dark container to show the dark overlay effect
        let darkContainer = UIView()
        darkContainer.backgroundColor = UIColor(white: 0.2, alpha: 1.0)
        darkContainer.layer.cornerRadius = 8
        darkContainer.translatesAutoresizingMaskIntoConstraints = false
        darkContainer.addSubview(darkOverlayNavBar)

        NSLayoutConstraint.activate([
            darkOverlayNavBar.topAnchor.constraint(equalTo: darkContainer.topAnchor, constant: 8),
            darkOverlayNavBar.leadingAnchor.constraint(equalTo: darkContainer.leadingAnchor),
            darkOverlayNavBar.trailingAnchor.constraint(equalTo: darkContainer.trailingAnchor),
            darkOverlayNavBar.bottomAnchor.constraint(equalTo: darkContainer.bottomAnchor, constant: -8)
        ])

        stackView.addArrangedSubview(createLabeledVariant(
            label: "Dark Overlay Style (on dark bg)",
            view: darkContainer
        ))

        // Custom colors style
        let customColorNavBar = createNavBarView(viewModel: MockSimpleNavigationBarViewModel.withBackTextAndTitle)
        let customStyle = SimpleNavigationBarStyle(
            backgroundColor: StyleProvider.Color.buttonBackgroundPrimary,
            textColor: .white,
            iconColor: .white,
            separatorColor: .white.withAlphaComponent(0.3)
        )
        customColorNavBar.setCustomization(customStyle)

        stackView.addArrangedSubview(createLabeledVariant(
            label: "Custom Brand Color Style",
            view: customColorNavBar
        ))
    }

    // MARK: - Helper Methods

    private func createNavBarView(viewModel: SimpleNavigationBarViewModelProtocol) -> SimpleNavigationBarView {
        let view = SimpleNavigationBarView(viewModel: viewModel)
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
#Preview("Back Button Variants") {
    SimpleNavigationBarViewSnapshotViewController(category: .backButtonVariants)
}

#Preview("Title Variants") {
    SimpleNavigationBarViewSnapshotViewController(category: .titleVariants)
}

#Preview("Combined Layouts") {
    SimpleNavigationBarViewSnapshotViewController(category: .combinedLayouts)
}

#Preview("Style Customization") {
    SimpleNavigationBarViewSnapshotViewController(category: .styleCustomization)
}
#endif

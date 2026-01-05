import UIKit
import SwiftUI

// MARK: - Snapshot Category
enum AdaptiveTabBarSnapshotCategory: String, CaseIterable {
    case backgroundModes = "Background Modes"
}

final class AdaptiveTabBarViewSnapshotViewController: UIViewController {

    private let category: AdaptiveTabBarSnapshotCategory

    init(category: AdaptiveTabBarSnapshotCategory) {
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
        titleLabel.text = "AdaptiveTabBarView - \(category.rawValue)"
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
        case .backgroundModes:
            addBackgroundModesVariants(to: stackView)
        }
    }

    // MARK: - Category Variants

    private func addBackgroundModesVariants(to stackView: UIStackView) {
        // Solid background
        let solidTabBar = AdaptiveTabBarView(viewModel: MockAdaptiveTabBarViewModel.defaultMock)
        solidTabBar.backgroundMode = .solid
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Solid Background",
            view: solidTabBar
        ))

        // Blur background
        let blurTabBar = AdaptiveTabBarView(viewModel: MockAdaptiveTabBarViewModel.defaultMock)
        blurTabBar.backgroundMode = .blur
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Blur Background",
            view: blurTabBar
        ))

        // Transparent background
        let transparentTabBar = AdaptiveTabBarView(viewModel: MockAdaptiveTabBarViewModel.defaultMock)
        transparentTabBar.backgroundMode = .transparent
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Transparent Background",
            view: transparentTabBar
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
@available(iOS 17.0, *)
#Preview("Background Modes") {
    AdaptiveTabBarViewSnapshotViewController(category: .backgroundModes)
}
#endif

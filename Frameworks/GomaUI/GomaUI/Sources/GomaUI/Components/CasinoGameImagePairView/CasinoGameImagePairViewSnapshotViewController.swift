import UIKit
import SwiftUI

// MARK: - Snapshot Category
enum CasinoGameImagePairSnapshotCategory: String, CaseIterable {
    case basicStates = "Basic States"
    case contentVariants = "Content Variants"
}

final class CasinoGameImagePairViewSnapshotViewController: UIViewController {

    private let category: CasinoGameImagePairSnapshotCategory

    init(category: CasinoGameImagePairSnapshotCategory) {
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
        titleLabel.text = "CasinoGameImagePairView - \(category.rawValue)"
        titleLabel.font = StyleProvider.fontWith(type: .bold, size: 16)
        titleLabel.textColor = StyleProvider.Color.textPrimary
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 24
        stackView.alignment = .top
        stackView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(titleLabel)
        view.addSubview(stackView)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),

            stackView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 24),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -16)
        ])

        addVariants(to: stackView)
    }

    private func addVariants(to stackView: UIStackView) {
        switch category {
        case .basicStates:
            addBasicStatesVariants(to: stackView)
        case .contentVariants:
            addContentVariants(to: stackView)
        }
    }

    // MARK: - Category Variants

    private func addBasicStatesVariants(to stackView: UIStackView) {
        // Full pair (both top and bottom games)
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Full Pair",
            view: CasinoGameImagePairView(viewModel: MockCasinoGameImagePairViewModel.fullPair)
        ))

        // Top only (odd number scenario)
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Top Only",
            view: CasinoGameImagePairView(viewModel: MockCasinoGameImagePairViewModel.topOnly)
        ))
    }

    private func addContentVariants(to stackView: UIStackView) {
        // No images (failure state)
        stackView.addArrangedSubview(createLabeledVariant(
            label: "No Images",
            view: CasinoGameImagePairView(viewModel: MockCasinoGameImagePairViewModel.noImages)
        ))

        // Placeholder state (no ViewModel)
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Placeholder",
            view: CasinoGameImagePairView()
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
        stack.alignment = .leading
        return stack
    }
}

// MARK: - Preview
#if DEBUG
@available(iOS 17.0, *)
#Preview("Basic States") {
    CasinoGameImagePairViewSnapshotViewController(category: .basicStates)
}

@available(iOS 17.0, *)
#Preview("Content Variants") {
    CasinoGameImagePairViewSnapshotViewController(category: .contentVariants)
}
#endif

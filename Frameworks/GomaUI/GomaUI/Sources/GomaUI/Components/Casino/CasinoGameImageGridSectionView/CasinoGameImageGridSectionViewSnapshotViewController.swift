import UIKit
import SwiftUI

// MARK: - Snapshot Category
enum CasinoGameImageGridSectionSnapshotCategory: String, CaseIterable {
    case basicStates = "Basic States"
    case contentVariants = "Content Variants"
}

final class CasinoGameImageGridSectionViewSnapshotViewController: UIViewController {

    private let category: CasinoGameImageGridSectionSnapshotCategory

    init(category: CasinoGameImageGridSectionSnapshotCategory) {
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
        titleLabel.text = "CasinoGameImageGridSectionView - \(category.rawValue)"
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
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
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
        // Lite Games section (8 games - 4 full pairs)
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Lite Games (8 games)",
            view: CasinoGameImageGridSectionView(viewModel: MockCasinoGameImageGridSectionViewModel.liteGamesSection)
        ))

        // Placeholder state (no ViewModel)
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Placeholder (No ViewModel)",
            view: CasinoGameImageGridSectionView()
        ))
    }

    private func addContentVariants(to stackView: UIStackView) {
        // Odd games section (7 games - last pair has only top)
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Odd Games (7 games)",
            view: CasinoGameImageGridSectionView(viewModel: MockCasinoGameImageGridSectionViewModel.oddGamesSection)
        ))

        // Few games section (2 games - 1 pair)
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Few Games (2 games)",
            view: CasinoGameImageGridSectionView(viewModel: MockCasinoGameImageGridSectionViewModel.fewGamesSection)
        ))
    }

    // MARK: - Helper Methods

    private func createLabeledVariant(label: String, view: UIView) -> UIStackView {
        let labelView = UILabel()
        labelView.text = label
        labelView.font = StyleProvider.fontWith(type: .medium, size: 12)
        labelView.textColor = StyleProvider.Color.textSecondary
        labelView.translatesAutoresizingMaskIntoConstraints = false

        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false

        let labelContainer = UIView()
        labelContainer.translatesAutoresizingMaskIntoConstraints = false
        labelContainer.addSubview(labelView)

        NSLayoutConstraint.activate([
            labelView.topAnchor.constraint(equalTo: labelContainer.topAnchor),
            labelView.leadingAnchor.constraint(equalTo: labelContainer.leadingAnchor, constant: 16),
            labelView.trailingAnchor.constraint(equalTo: labelContainer.trailingAnchor, constant: -16),
            labelView.bottomAnchor.constraint(equalTo: labelContainer.bottomAnchor)
        ])

        let stack = UIStackView(arrangedSubviews: [labelContainer, view])
        stack.axis = .vertical
        stack.spacing = 6
        stack.alignment = .fill
        return stack
    }
}

// MARK: - Preview
#if DEBUG
#Preview("Basic States") {
    CasinoGameImageGridSectionViewSnapshotViewController(category: .basicStates)
}

#Preview("Content Variants") {
    CasinoGameImageGridSectionViewSnapshotViewController(category: .contentVariants)
}
#endif

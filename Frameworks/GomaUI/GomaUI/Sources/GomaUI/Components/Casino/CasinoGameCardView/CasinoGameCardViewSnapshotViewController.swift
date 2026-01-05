import UIKit
import SwiftUI

// MARK: - Snapshot Category
enum CasinoGameCardSnapshotCategory: String, CaseIterable {
    case basicStates = "Basic States"
    case displayStates = "Display States"
    case ratingVariants = "Rating Variants"
    case contentVariants = "Content Variants"
}

final class CasinoGameCardViewSnapshotViewController: UIViewController {

    private let category: CasinoGameCardSnapshotCategory

    init(category: CasinoGameCardSnapshotCategory) {
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
        titleLabel.text = "CasinoGameCardView - \(category.rawValue)"
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
        case .basicStates:
            addBasicStatesVariants(to: stackView)
        case .displayStates:
            addDisplayStatesVariants(to: stackView)
        case .ratingVariants:
            addRatingVariants(to: stackView)
        case .contentVariants:
            addContentVariants(to: stackView)
        }
    }

    // MARK: - Category Variants

    private func addBasicStatesVariants(to stackView: UIStackView) {
        let horizontalStack = createHorizontalStack()

        horizontalStack.addArrangedSubview(createLabeledVariant(
            label: "Plink Goal",
            view: CasinoGameCardView(viewModel: MockCasinoGameCardViewModel.plinkGoal)
        ))
        horizontalStack.addArrangedSubview(createLabeledVariant(
            label: "Aviator",
            view: CasinoGameCardView(viewModel: MockCasinoGameCardViewModel.aviator)
        ))

        stackView.addArrangedSubview(horizontalStack)
    }

    private func addDisplayStatesVariants(to stackView: UIStackView) {
        let horizontalStack = createHorizontalStack()

        horizontalStack.addArrangedSubview(createLabeledVariant(
            label: "Loading",
            view: CasinoGameCardView(viewModel: MockCasinoGameCardViewModel.loadingGame)
        ))
        horizontalStack.addArrangedSubview(createLabeledVariant(
            label: "Image Failed",
            view: CasinoGameCardView(viewModel: MockCasinoGameCardViewModel.imageFailedGame)
        ))

        stackView.addArrangedSubview(horizontalStack)

        // Add placeholder state
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Placeholder (no ViewModel)",
            view: CasinoGameCardView()
        ))
    }

    private func addRatingVariants(to stackView: UIStackView) {
        let horizontalStack = createHorizontalStack()

        // 5 stars
        let fiveStarVM = MockCasinoGameCardViewModel.customGame(
            id: "5star",
            name: "5 Star Game",
            gameURL: "https://example.com",
            iconURL: "casinoGameDemo",
            rating: 5.0,
            provider: "Provider",
            minStake: "XAF 100"
        )
        horizontalStack.addArrangedSubview(createLabeledVariant(
            label: "5 Stars",
            view: CasinoGameCardView(viewModel: fiveStarVM)
        ))

        // 3 stars
        let threeStarVM = MockCasinoGameCardViewModel.customGame(
            id: "3star",
            name: "3 Star Game",
            gameURL: "https://example.com",
            iconURL: "casinoGameDemo",
            rating: 3.0,
            provider: "Provider",
            minStake: "XAF 50"
        )
        horizontalStack.addArrangedSubview(createLabeledVariant(
            label: "3 Stars",
            view: CasinoGameCardView(viewModel: threeStarVM)
        ))

        stackView.addArrangedSubview(horizontalStack)

        // Second row
        let horizontalStack2 = createHorizontalStack()

        // 1 star
        let oneStarVM = MockCasinoGameCardViewModel.customGame(
            id: "1star",
            name: "1 Star Game",
            gameURL: "https://example.com",
            iconURL: "casinoGameDemo",
            rating: 1.0,
            provider: "Provider",
            minStake: "XAF 25"
        )
        horizontalStack2.addArrangedSubview(createLabeledVariant(
            label: "1 Star",
            view: CasinoGameCardView(viewModel: oneStarVM)
        ))

        // 0 stars
        let zeroStarVM = MockCasinoGameCardViewModel.customGame(
            id: "0star",
            name: "0 Star Game",
            gameURL: "https://example.com",
            iconURL: "casinoGameDemo",
            rating: 0.0,
            provider: "Provider",
            minStake: "XAF 10"
        )
        horizontalStack2.addArrangedSubview(createLabeledVariant(
            label: "0 Stars",
            view: CasinoGameCardView(viewModel: zeroStarVM)
        ))

        stackView.addArrangedSubview(horizontalStack2)
    }

    private func addContentVariants(to stackView: UIStackView) {
        let horizontalStack = createHorizontalStack()

        // Long text variant
        horizontalStack.addArrangedSubview(createLabeledVariant(
            label: "Long Text",
            view: CasinoGameCardView(viewModel: MockCasinoGameCardViewModel.beastBelow)
        ))

        // Short text
        let shortTextVM = MockCasinoGameCardViewModel.customGame(
            id: "short",
            name: "Go",
            gameURL: "https://example.com",
            iconURL: "casinoGameDemo",
            rating: 4.0,
            provider: "AB",
            minStake: "XAF 1"
        )
        horizontalStack.addArrangedSubview(createLabeledVariant(
            label: "Short Text",
            view: CasinoGameCardView(viewModel: shortTextVM)
        ))

        stackView.addArrangedSubview(horizontalStack)
    }

    // MARK: - Helper Methods

    private func createHorizontalStack() -> UIStackView {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 16
        stack.alignment = .top
        stack.distribution = .fillEqually
        return stack
    }

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
    CasinoGameCardViewSnapshotViewController(category: .basicStates)
}

@available(iOS 17.0, *)
#Preview("Display States") {
    CasinoGameCardViewSnapshotViewController(category: .displayStates)
}

@available(iOS 17.0, *)
#Preview("Rating Variants") {
    CasinoGameCardViewSnapshotViewController(category: .ratingVariants)
}

@available(iOS 17.0, *)
#Preview("Content Variants") {
    CasinoGameCardViewSnapshotViewController(category: .contentVariants)
}
#endif

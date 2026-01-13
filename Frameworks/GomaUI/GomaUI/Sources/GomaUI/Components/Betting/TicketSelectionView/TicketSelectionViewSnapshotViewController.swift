import UIKit
import SwiftUI

// MARK: - Snapshot Category
enum TicketSelectionSnapshotCategory: String, CaseIterable {
    case preLiveStates = "PreLive States"
    case liveStates = "Live States"
    case contentVariants = "Content Variants"
    case resultTags = "Result Tags"
}

final class TicketSelectionViewSnapshotViewController: UIViewController {

    private let category: TicketSelectionSnapshotCategory

    init(category: TicketSelectionSnapshotCategory) {
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
        titleLabel.text = "TicketSelectionView - \(category.rawValue)"
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
        case .preLiveStates:
            addPreLiveStatesVariants(to: stackView)
        case .liveStates:
            addLiveStatesVariants(to: stackView)
        case .contentVariants:
            addContentVariants(to: stackView)
        case .resultTags:
            addResultTagVariants(to: stackView)
        }
    }

    // MARK: - Category Variants

    private func addPreLiveStatesVariants(to stackView: UIStackView) {
        stackView.addArrangedSubview(createLabeledVariant(
            label: "PreLive - Premier League",
            view: createTicketSelectionView(viewModel: MockTicketSelectionViewModel.preLiveMock)
        ))
        stackView.addArrangedSubview(createLabeledVariant(
            label: "PreLive - Champions League",
            view: createTicketSelectionView(viewModel: MockTicketSelectionViewModel.preLiveChampionsLeagueMock)
        ))
    }

    private func addLiveStatesVariants(to stackView: UIStackView) {
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Live - La Liga (2-1)",
            view: createTicketSelectionView(viewModel: MockTicketSelectionViewModel.liveMock)
        ))
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Live - Draw (1-1)",
            view: createTicketSelectionView(viewModel: MockTicketSelectionViewModel.liveDrawMock)
        ))
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Live - High Score (3-2)",
            view: createTicketSelectionView(viewModel: MockTicketSelectionViewModel.liveHighScoreMock)
        ))
    }

    private func addContentVariants(to stackView: UIStackView) {
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Long Team Names",
            view: createTicketSelectionView(viewModel: MockTicketSelectionViewModel.longTeamNamesMock)
        ))
        stackView.addArrangedSubview(createLabeledVariant(
            label: "No Icons",
            view: createTicketSelectionView(viewModel: MockTicketSelectionViewModel.noIconsMock)
        ))
    }

    private func addResultTagVariants(to stackView: UIStackView) {
        // Won result
        let wonViewModel = MockTicketSelectionViewModel.preLiveMock
        let wonView = createTicketSelectionView(viewModel: wonViewModel)
        wonView.updateResultTag(with: BetTicketStatusData(status: .won))
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Result: Won",
            view: wonView
        ))

        // Lost result
        let lostViewModel = MockTicketSelectionViewModel.preLiveMock
        let lostView = createTicketSelectionView(viewModel: lostViewModel)
        lostView.updateResultTag(with: BetTicketStatusData(status: .lost))
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Result: Lost",
            view: lostView
        ))

        // Draw result
        let drawViewModel = MockTicketSelectionViewModel.preLiveMock
        let drawView = createTicketSelectionView(viewModel: drawViewModel)
        drawView.updateResultTag(with: BetTicketStatusData(status: .draw))
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Result: Draw",
            view: drawView
        ))

        // Cashed Out result
        let cashedOutViewModel = MockTicketSelectionViewModel.preLiveMock
        let cashedOutView = createTicketSelectionView(viewModel: cashedOutViewModel)
        cashedOutView.updateResultTag(with: BetTicketStatusData(status: .cashedOut))
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Result: Cashed Out (Pending)",
            view: cashedOutView
        ))
    }

    // MARK: - Helper Methods

    private func createTicketSelectionView(viewModel: MockTicketSelectionViewModel) -> TicketSelectionView {
        let view = TicketSelectionView(viewModel: viewModel)
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
#Preview("PreLive States") {
    TicketSelectionViewSnapshotViewController(category: .preLiveStates)
}

#Preview("Live States") {
    TicketSelectionViewSnapshotViewController(category: .liveStates)
}

#Preview("Content Variants") {
    TicketSelectionViewSnapshotViewController(category: .contentVariants)
}

#Preview("Result Tags") {
    TicketSelectionViewSnapshotViewController(category: .resultTags)
}
#endif

import UIKit
import SwiftUI

// MARK: - Snapshot Category
enum CompactMatchHeaderSnapshotCategory: String, CaseIterable {
    case preLiveStates = "Pre-Live States"
    case liveStates = "Live States"
}

final class CompactMatchHeaderViewSnapshotViewController: UIViewController {

    private let category: CompactMatchHeaderSnapshotCategory

    init(category: CompactMatchHeaderSnapshotCategory) {
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
        titleLabel.text = "CompactMatchHeaderView - \(category.rawValue)"
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
        }
    }

    // MARK: - Category Variants

    private func addPreLiveStatesVariants(to stackView: UIStackView) {
        // Pre-live today
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Pre-live Today",
            view: CompactMatchHeaderView(viewModel: MockCompactMatchHeaderViewModel.preLiveToday)
        ))

        // Pre-live future date
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Pre-live Future Date",
            view: CompactMatchHeaderView(viewModel: MockCompactMatchHeaderViewModel.preLiveFutureDate)
        ))

        // Pre-live tomorrow
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Pre-live Tomorrow",
            view: CompactMatchHeaderView(viewModel: MockCompactMatchHeaderViewModel.preLiveTomorrow)
        ))

        // Pre-live no icons
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Pre-live No Icons",
            view: CompactMatchHeaderView(viewModel: MockCompactMatchHeaderViewModel.preLiveNoIcons)
        ))
    }

    private func addLiveStatesVariants(to stackView: UIStackView) {
        // Live tennis
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Live Tennis (2nd Set)",
            view: CompactMatchHeaderView(viewModel: MockCompactMatchHeaderViewModel.liveTennis)
        ))

        // Live football
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Live Football (45')",
            view: CompactMatchHeaderView(viewModel: MockCompactMatchHeaderViewModel.liveFootball)
        ))

        // Live halftime
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Live Halftime",
            view: CompactMatchHeaderView(viewModel: MockCompactMatchHeaderViewModel.liveHalftime)
        ))

        // Live no icons
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Live No Icons",
            view: CompactMatchHeaderView(viewModel: MockCompactMatchHeaderViewModel.liveNoIcons)
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
#Preview("Pre-Live States") {
    CompactMatchHeaderViewSnapshotViewController(category: .preLiveStates)
}

@available(iOS 17.0, *)
#Preview("Live States") {
    CompactMatchHeaderViewSnapshotViewController(category: .liveStates)
}
#endif

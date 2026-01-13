import UIKit
import SwiftUI

// MARK: - Snapshot Category
enum MatchDateNavigationBarSnapshotCategory: String, CaseIterable {
    case matchStatus = "Match Status"
    case liveVariants = "Live Variants"
    case backButtonVariants = "Back Button Variants"
}

final class MatchDateNavigationBarSnapshotViewController: UIViewController {

    private let category: MatchDateNavigationBarSnapshotCategory

    init(category: MatchDateNavigationBarSnapshotCategory) {
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
        titleLabel.text = "MatchDateNavigationBarView - \(category.rawValue)"
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
        case .matchStatus:
            addMatchStatusVariants(to: stackView)
        case .liveVariants:
            addLiveVariants(to: stackView)
        case .backButtonVariants:
            addBackButtonVariants(to: stackView)
        }
    }

    // MARK: - Category Variants

    private func addMatchStatusVariants(to stackView: UIStackView) {
        // Pre-match state
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Pre-Match",
            view: createNavigationBar(viewModel: MockMatchDateNavigationBarViewModel.defaultPreMatchMock)
        ))

        // Live state
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Live (1st Half)",
            view: createNavigationBar(viewModel: MockMatchDateNavigationBarViewModel.liveMock)
        ))
    }

    private func addLiveVariants(to stackView: UIStackView) {
        // First half
        stackView.addArrangedSubview(createLabeledVariant(
            label: "1st Half",
            view: createNavigationBar(viewModel: MockMatchDateNavigationBarViewModel.liveMock)
        ))

        // Second half
        stackView.addArrangedSubview(createLabeledVariant(
            label: "2nd Half",
            view: createNavigationBar(viewModel: MockMatchDateNavigationBarViewModel.secondHalfMock)
        ))

        // Half time
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Half Time",
            view: createNavigationBar(viewModel: MockMatchDateNavigationBarViewModel.halfTimeMock)
        ))

        // Extra time
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Extra Time",
            view: createNavigationBar(viewModel: MockMatchDateNavigationBarViewModel.extraTimeMock)
        ))
    }

    private func addBackButtonVariants(to stackView: UIStackView) {
        // With back button (default)
        stackView.addArrangedSubview(createLabeledVariant(
            label: "With Back Button",
            view: createNavigationBar(viewModel: MockMatchDateNavigationBarViewModel.liveMock)
        ))

        // Without back button
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Without Back Button",
            view: createNavigationBar(viewModel: MockMatchDateNavigationBarViewModel.noBackButtonMock)
        ))

        // Pre-match with custom date format
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Custom Date Format",
            view: createNavigationBar(viewModel: MockMatchDateNavigationBarViewModel.customDateFormatMock)
        ))
    }

    // MARK: - Helper Methods

    private func createNavigationBar(viewModel: MockMatchDateNavigationBarViewModel) -> MatchDateNavigationBarView {
        let view = MatchDateNavigationBarView(viewModel: viewModel)
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
#Preview("Match Status") {
    MatchDateNavigationBarSnapshotViewController(category: .matchStatus)
}

#Preview("Live Variants") {
    MatchDateNavigationBarSnapshotViewController(category: .liveVariants)
}

#Preview("Back Button Variants") {
    MatchDateNavigationBarSnapshotViewController(category: .backButtonVariants)
}
#endif

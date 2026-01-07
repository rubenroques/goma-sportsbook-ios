import UIKit
import SwiftUI

final class CapsuleViewSnapshotViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .backgroundTestColor
        setupUI()
    }

    private func setupUI() {
        let titleLabel = UILabel()
        titleLabel.text = "CapsuleView"
        titleLabel.font = .systemFont(ofSize: 16, weight: .bold)
        titleLabel.textColor = .darkGray
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.alignment = .leading
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

        // Live Badge
        let liveBadgeView = CapsuleView(viewModel: MockCapsuleViewModel.liveBadge)
        liveBadgeView.translatesAutoresizingMaskIntoConstraints = false
        stackView.addArrangedSubview(makeVariant("Live Badge", liveBadgeView))

        // Count Badge
        let countBadgeView = CapsuleView(viewModel: MockCapsuleViewModel.countBadge)
        countBadgeView.translatesAutoresizingMaskIntoConstraints = false
        stackView.addArrangedSubview(makeVariant("Count Badge", countBadgeView))

        // Tag Style
        let tagStyleView = CapsuleView(viewModel: MockCapsuleViewModel.tagStyle)
        tagStyleView.translatesAutoresizingMaskIntoConstraints = false
        stackView.addArrangedSubview(makeVariant("Tag Style", tagStyleView))

        // Status Pending
        let statusPendingView = CapsuleView(viewModel: MockCapsuleViewModel.statusPending)
        statusPendingView.translatesAutoresizingMaskIntoConstraints = false
        stackView.addArrangedSubview(makeVariant("Status Pending", statusPendingView))

        // Status Success
        let statusSuccessView = CapsuleView(viewModel: MockCapsuleViewModel.statusSuccess)
        statusSuccessView.translatesAutoresizingMaskIntoConstraints = false
        stackView.addArrangedSubview(makeVariant("Status Success", statusSuccessView))

        // Status Error
        let statusErrorView = CapsuleView(viewModel: MockCapsuleViewModel.statusError)
        statusErrorView.translatesAutoresizingMaskIntoConstraints = false
        stackView.addArrangedSubview(makeVariant("Status Error", statusErrorView))

        // Promotional New
        let promotionalNewView = CapsuleView(viewModel: MockCapsuleViewModel.promotionalNew)
        promotionalNewView.translatesAutoresizingMaskIntoConstraints = false
        stackView.addArrangedSubview(makeVariant("Promotional New", promotionalNewView))

        // Promotional Hot
        let promotionalHotView = CapsuleView(viewModel: MockCapsuleViewModel.promotionalHot)
        promotionalHotView.translatesAutoresizingMaskIntoConstraints = false
        stackView.addArrangedSubview(makeVariant("Promotional Hot", promotionalHotView))

        // Match Status Live
        let matchStatusLiveView = CapsuleView(viewModel: MockCapsuleViewModel.matchStatusLive)
        matchStatusLiveView.translatesAutoresizingMaskIntoConstraints = false
        stackView.addArrangedSubview(makeVariant("Match Status Live", matchStatusLiveView))

        // Match Status Half Time
        let matchStatusHalfTimeView = CapsuleView(viewModel: MockCapsuleViewModel.matchStatusHalfTime)
        matchStatusHalfTimeView.translatesAutoresizingMaskIntoConstraints = false
        stackView.addArrangedSubview(makeVariant("Match Status Half Time", matchStatusHalfTimeView))

        // Market Count
        let marketCountView = CapsuleView(viewModel: MockCapsuleViewModel.marketCount)
        marketCountView.translatesAutoresizingMaskIntoConstraints = false
        stackView.addArrangedSubview(makeVariant("Market Count", marketCountView))

        // Convenience Init - Custom Purple
        let customView = CapsuleView(
            text: "Custom",
            backgroundColor: .systemPurple,
            textColor: .white
        )
        customView.translatesAutoresizingMaskIntoConstraints = false
        stackView.addArrangedSubview(makeVariant("Custom (Convenience Init)", customView))
    }

    private func makeVariant(_ name: String, _ component: UIView) -> UIStackView {
        let label = UILabel()
        label.text = name
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .gray

        let stack = UIStackView(arrangedSubviews: [label, component])
        stack.axis = .vertical
        stack.spacing = 6
        stack.alignment = .leading
        return stack
    }
}

// MARK: - Preview
#if DEBUG
#Preview {
    CapsuleViewSnapshotViewController()
}
#endif

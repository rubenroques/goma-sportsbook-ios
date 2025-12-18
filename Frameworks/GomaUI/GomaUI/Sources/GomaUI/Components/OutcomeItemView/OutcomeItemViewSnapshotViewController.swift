import UIKit
import SwiftUI

final class OutcomeItemViewSnapshotViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .backgroundTestColor
        setupUI()
    }

    private func setupUI() {
        let titleLabel = UILabel()
        titleLabel.text = "OutcomeItemView"
        titleLabel.font = .systemFont(ofSize: 16, weight: .bold)
        titleLabel.textColor = .darkGray
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 16
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

        // Normal states
        stackView.addArrangedSubview(makeVariant("Normal (Unselected)", makeOutcome(.drawOutcome)))
        stackView.addArrangedSubview(makeVariant("Normal (Selected)", makeOutcome(.homeOutcome)))

        // Boosted states
        stackView.addArrangedSubview(makeVariant("Boosted (Unselected)", makeOutcome(.boostedOutcome)))
        stackView.addArrangedSubview(makeVariant("Boosted (Selected)", makeOutcome(.boostedOutcomeSelected)))

        // Odds change indicators
        stackView.addArrangedSubview(makeVariant("Odds Up", makeOutcome(.overOutcomeUp)))
        stackView.addArrangedSubview(makeVariant("Odds Down", makeOutcome(.underOutcomeDown)))

        // Special states
        stackView.addArrangedSubview(makeVariant("Loading", makeOutcome(.loadingOutcome)))
        stackView.addArrangedSubview(makeVariant("Locked", makeOutcome(.lockedOutcome)))
        stackView.addArrangedSubview(makeVariant("Unavailable", makeOutcome(.unavailableOutcome)))
    }

    private func makeOutcome(_ mock: MockOutcomeItemViewModel) -> OutcomeItemView {
        let view = OutcomeItemView(viewModel: mock)
        NSLayoutConstraint.activate([
            view.widthAnchor.constraint(equalToConstant: 100),
            view.heightAnchor.constraint(equalToConstant: 52)
        ])
        return view
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
@available(iOS 17.0, *)
#Preview {
    OutcomeItemViewSnapshotViewController()
}
#endif

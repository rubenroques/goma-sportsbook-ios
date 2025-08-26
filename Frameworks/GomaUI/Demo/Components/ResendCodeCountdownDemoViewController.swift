import Foundation
import UIKit
import GomaUI

class ResendCodeCountdownDemoViewController: UIViewController {
    private let viewModels: [(title: String, viewModel: ResendCodeCountdownViewModelProtocol)] = [
        ("Default (59s)", MockResendCodeCountdownViewModel(startSeconds: 60)),
        ("Short (5s)", MockResendCodeCountdownViewModel(startSeconds: 5))
    ]
    private let summaryLabel: UILabel = {
        let label = UILabel()
        label.text = "A label with a countdown, using ResendCodeCountdownView."
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = .label
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupSummaryLabel()
        setupCountdownViews()
    }

    private func setupSummaryLabel() {
        summaryLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(summaryLabel)
        NSLayoutConstraint.activate([
            summaryLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            summaryLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            summaryLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
    }

    private func setupCountdownViews() {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 24
        stackView.alignment = .fill
        stackView.distribution = .equalSpacing
        stackView.translatesAutoresizingMaskIntoConstraints = false

        for (title, viewModel) in viewModels {
            let label = UILabel()
            label.text = title
            label.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
            label.textColor = .secondaryLabel
            label.textAlignment = .left
            label.numberOfLines = 1

            let countdownView = ResendCodeCountdownView(viewModel: viewModel)
            countdownView.translatesAutoresizingMaskIntoConstraints = false
            countdownView.heightAnchor.constraint(equalToConstant: 30).isActive = true

            // Start the countdown
            if let mockVM = viewModel as? MockResendCodeCountdownViewModel {
                mockVM.startCountdown()
            }

            let container = UIStackView(arrangedSubviews: [label, countdownView])
            container.axis = .vertical
            container.spacing = 8
            container.alignment = .fill
            container.distribution = .fill

            stackView.addArrangedSubview(container)
        }

        view.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: summaryLabel.bottomAnchor, constant: 24),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
    }
}

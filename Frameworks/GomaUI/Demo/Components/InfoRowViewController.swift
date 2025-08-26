import Foundation
import UIKit
import GomaUI

class InfoRowViewController: UIViewController {
    private let viewModels: [(title: String, viewModel: InfoRowViewModelProtocol)] = [
        ("Default Mock", MockInfoRowViewModel.defaultMock),
        ("Balance Mock", MockInfoRowViewModel.balanceMock),
        ("Custom Background Mock", MockInfoRowViewModel.customBackgroundMock)
    ]
    private let summaryLabel: UILabel = {
        let label = UILabel()
        label.text = "A customizable info row component, using InfoRowView."
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
        setupInfoRowViews()
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

    private func setupInfoRowViews() {
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

            let infoRowView = InfoRowView(viewModel: viewModel)
            infoRowView.translatesAutoresizingMaskIntoConstraints = false
            infoRowView.heightAnchor.constraint(equalToConstant: 60).isActive = true

            let container = UIStackView(arrangedSubviews: [label, infoRowView])
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

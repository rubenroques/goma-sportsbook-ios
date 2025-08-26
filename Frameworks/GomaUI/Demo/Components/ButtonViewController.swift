import Foundation
import UIKit
import GomaUI

class ButtonViewController: UIViewController {
    private let buttonViewModels: [(title: String, viewModel: ButtonViewModelProtocol)] = [
        ("Solid Background", MockButtonViewModel.solidBackgroundMock),
        ("Solid Background Disabled", MockButtonViewModel.solidBackgroundDisabledMock),
        ("Bordered", MockButtonViewModel.borderedMock),
        ("Bordered Disabled", MockButtonViewModel.borderedDisabledMock),
        ("Transparent", MockButtonViewModel.transparentMock),
        ("Transparent Disabled", MockButtonViewModel.transparentDisabledMock)
    ]
    private var buttonViews: [ButtonView] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGray4
        setupButtonViews()
    }

    private func setupButtonViews() {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 24
        stackView.alignment = .fill
        stackView.distribution = .equalSpacing
        stackView.translatesAutoresizingMaskIntoConstraints = false

        for (title, viewModel) in buttonViewModels {
            let label = UILabel()
            label.text = title
            label.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
            label.textColor = .secondaryLabel
            label.textAlignment = .left
            label.numberOfLines = 1

            let buttonView = ButtonView(viewModel: viewModel)
            buttonView.translatesAutoresizingMaskIntoConstraints = false
            buttonView.heightAnchor.constraint(equalToConstant: 56).isActive = true
            buttonViews.append(buttonView)

            let container = UIStackView(arrangedSubviews: [label, buttonView])
            container.axis = .vertical
            container.spacing = 8
            container.alignment = .fill
            container.distribution = .fill

            stackView.addArrangedSubview(container)
        }

        view.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32)
        ])
    }
}

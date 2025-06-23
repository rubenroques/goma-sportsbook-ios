//
//  ButtonViewController.swift
//  Demo
//
//  Created by André Lascas on 23/06/2025.
//

import Foundation
import UIKit
import GomaUI

class ButtonViewController: UIViewController {
    private let buttonViewModels: [ButtonViewModelProtocol] = [
        MockButtonViewModel.solidBackgroundMock,
        MockButtonViewModel.solidBackgroundDisabledMock,
        MockButtonViewModel.borderedMock,
        MockButtonViewModel.borderedDisabledMock,
        MockButtonViewModel.transparentMock,
        MockButtonViewModel.transparentDisabledMock
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
        stackView.spacing = 20
        stackView.alignment = .fill
        stackView.distribution = .equalSpacing
        stackView.translatesAutoresizingMaskIntoConstraints = false

        for viewModel in buttonViewModels {
            let buttonView = ButtonView(viewModel: viewModel)
            buttonView.translatesAutoresizingMaskIntoConstraints = false
            buttonView.heightAnchor.constraint(equalToConstant: 56).isActive = true
            buttonViews.append(buttonView)
            stackView.addArrangedSubview(buttonView)
        }

        view.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32)
        ])
    }
}

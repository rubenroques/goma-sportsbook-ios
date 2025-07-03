//
//  PhoneForgotPasswordSuccessViewController.swift
//  Sportsbook
//
//  Created by André Lascas on 30/06/2025.
//

import Foundation
import UIKit
import GomaUI

class PhoneForgotPasswordSuccessViewController: UIViewController {
    private let viewModel: PhoneForgotPasswordSuccessViewModelProtocol

    private let closeButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "close_circle_icon"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let statusInfoView: StatusInfoView
    private let proceedButton: ButtonView

    init(viewModel: PhoneForgotPasswordSuccessViewModelProtocol = MockPasswordChangeSuccessScreenViewModel()) {
        self.viewModel = viewModel
        self.statusInfoView = StatusInfoView(viewModel: viewModel.statusInfoViewModel)
        self.proceedButton = ButtonView(viewModel: viewModel.buttonViewModel)
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = StyleProvider.Color.backgroundTertiary
        setupLayout()
        setupBindings()
        closeButton.addTarget(self, action: #selector(didTapClose), for: .touchUpInside)
    }

    private func setupLayout() {
        view.addSubview(closeButton)
        statusInfoView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(statusInfoView)
        proceedButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(proceedButton)

        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
            closeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            closeButton.widthAnchor.constraint(equalToConstant: 24),
            closeButton.heightAnchor.constraint(equalToConstant: 24),

            statusInfoView.topAnchor.constraint(equalTo: closeButton.bottomAnchor, constant: 100),
            statusInfoView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            statusInfoView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            proceedButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            proceedButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            proceedButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
    }
    
    private func setupBindings() {
        
        proceedButton.onButtonTapped = { [weak self] in
            self?.navigationController?.popToRootViewController(animated: true)
        }
    }

    @objc private func didTapClose() {
        self.dismiss(animated: true)
    }
}

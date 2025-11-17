//
//  LimitsSuccessViewController.swift
//  BetssonCameroonApp
//
//  Created by GPT-5 Codex on 11/11/2025.
//

import UIKit
import GomaUI

final class LimitsSuccessViewController: UIViewController {
    
    // MARK: - UI Components
    private lazy var containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = StyleProvider.Color.backgroundTertiary
        view.layer.cornerRadius = 8
        view.layer.masksToBounds = true
        return view
    }()
    
    private lazy var closeButton: UIButton = {
        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(named: "close_circle_icon"), for: .normal)
        return button
    }()
    
    private lazy var successActionRow: ActionRowView = {
        let actionRow = ActionRowView()
        actionRow.translatesAutoresizingMaskIntoConstraints = false
        actionRow.customBackgroundColor = StyleProvider.Color.alertSuccess
        actionRow.configure(with: viewModel.successActionItem) { _ in }
        return actionRow
    }()
    
    private lazy var contentStackView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.alignment = .fill
        stack.spacing = 10
        return stack
    }()
    
    private let infoRowViews: [InfoRowView]
    
    // MARK: - Properties
    private let viewModel: LimitsSuccessViewModelProtocol
    
    // MARK: - Navigation Closures
    var onContinueRequested: (() -> Void)?
    
    // MARK: - Initialization
    init(viewModel: LimitsSuccessViewModelProtocol) {
        self.viewModel = viewModel
        self.infoRowViews = viewModel.infoRowViewModels.map { InfoRowView(viewModel: $0) }
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .overFullScreen
        modalTransitionStyle = .crossDissolve
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        setupLayout()
        closeButton.addTarget(self, action: #selector(didTapClose), for: .touchUpInside)
    }
    
    // MARK: - Setup
    private func setupLayout() {
        view.addSubview(containerView)
        containerView.addSubview(closeButton)
        containerView.addSubview(contentStackView)
        
        contentStackView.addArrangedSubview(successActionRow)
        infoRowViews.forEach { view in
            view.translatesAutoresizingMaskIntoConstraints = false
            contentStackView.addArrangedSubview(view)
        }
        
        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            containerView.heightAnchor.constraint(lessThanOrEqualTo: view.heightAnchor, multiplier: 0.7),
            
            closeButton.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            closeButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            closeButton.widthAnchor.constraint(equalToConstant: 24),
            closeButton.heightAnchor.constraint(equalToConstant: 24),
            
            contentStackView.topAnchor.constraint(equalTo: closeButton.bottomAnchor, constant: 12),
            contentStackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            contentStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            contentStackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -20)
        ])
    }
    
    // MARK: - Actions
    @objc private func didTapClose() {
        onContinueRequested?()
    }
}





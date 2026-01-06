//
//  ActionButtonBlockView.swift
//  GomaUI
//
//  Created by André Lascas on 13/03/2025.
//

import UIKit

public class ActionButtonBlockView: UIView {
    
    // MARK: Private properties
    private lazy var actionButton: UIButton = Self.createActionButton()
    private let viewModel: ActionButtonBlockViewModelProtocol
    
    // MARK: - Lifetime and Cycle
    public init(viewModel: ActionButtonBlockViewModelProtocol) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        self.commonInit()
        self.setupWithTheme()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func commonInit() {
        self.setupSubviews()
        self.actionButton.addTarget(self, action: #selector(didTapActionButton), for: .primaryActionTriggered)
        self.configure()
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        self.actionButton.layer.cornerRadius = 8 // Using fixed corner radius for now
    }
    
    func setupWithTheme() {
        self.backgroundColor = .clear
        self.actionButton.backgroundColor = StyleProvider.Color.highlightPrimary
        self.actionButton.setTitleColor(StyleProvider.Color.buttonTextPrimary, for: .normal)
        self.actionButton.isEnabled = self.viewModel.isEnabled
    }
    
    // MARK: Functions
    private func configure() {
        self.actionButton.setTitle(self.viewModel.title, for: .normal)
    }
    
    // MARK: Actions
    @objc private func didTapActionButton() {
        self.viewModel.didTapActionButton()
    }
}

// MARK: - Subviews Initialization and Setup
extension ActionButtonBlockView {
    
    private static func createActionButton() -> UIButton {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(LocalizationProvider.string("promotions_welcome_bonus_section_2_item_1_cta_text"), for: .normal)
        button.titleLabel?.font = StyleProvider.fontWith(type: .semibold, size: 16)
        return button
    }
    
    private func setupSubviews() {
        self.addSubview(self.actionButton)
        self.initConstraints()
    }
    
    private func initConstraints() {
        NSLayoutConstraint.activate([
            self.actionButton.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 15),
            self.actionButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -15),
            self.actionButton.topAnchor.constraint(equalTo: self.topAnchor, constant: 5),
            self.actionButton.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -5),
            self.actionButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
}

// MARK: - SwiftUI Preview
#if DEBUG
import SwiftUI

#Preview("All States") {
    PreviewUIViewController {
        let vc = UIViewController()
        vc.view.backgroundColor = .backgroundTestColor

        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.alignment = .fill
        stackView.distribution = .equalSpacing
        stackView.translatesAutoresizingMaskIntoConstraints = false

        // Default enabled button
        let defaultView = ActionButtonBlockView(viewModel: MockActionButtonBlockViewModel.defaultMock)
        defaultView.translatesAutoresizingMaskIntoConstraints = false

        // Disabled button
        let disabledView = ActionButtonBlockView(viewModel: MockActionButtonBlockViewModel.disabledMock)
        disabledView.translatesAutoresizingMaskIntoConstraints = false

        // Long text button
        let longTextView = ActionButtonBlockView(viewModel: MockActionButtonBlockViewModel.longTextMock)
        longTextView.translatesAutoresizingMaskIntoConstraints = false

        stackView.addArrangedSubview(defaultView)
        stackView.addArrangedSubview(disabledView)
        stackView.addArrangedSubview(longTextView)

        vc.view.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.centerYAnchor.constraint(equalTo: vc.view.centerYAnchor),
            stackView.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor, constant: -16)
        ])

        return vc
    }
}

#endif

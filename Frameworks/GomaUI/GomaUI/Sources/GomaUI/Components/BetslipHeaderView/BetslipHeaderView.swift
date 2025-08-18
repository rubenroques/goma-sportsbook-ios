//
//  BetslipHeaderView.swift
//  GomaUI
//
//  Created by André Lascas on 06/08/2025.
//

import Foundation
import UIKit
import Combine
import SwiftUI

/// A header view for betslip that displays different content based on login state
public final class BetslipHeaderView: UIView {
    
    // MARK: - UI Components
    
    // Common components
    private lazy var containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = StyleProvider.Color.backgroundPrimary
        view.layer.cornerRadius = 8
        return view
    }()
    
    private lazy var mainStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.alignment = .center
        stackView.spacing = 12
        return stackView
    }()
    
    // Left side - Betslip icon and title
    private lazy var leftSectionView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var betslipIconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "betslip_icon")?.withRenderingMode(.alwaysTemplate) ?? UIImage(systemName: "ticket")
        imageView.tintColor = StyleProvider.Color.highlightPrimary
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private lazy var betslipTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Betslip"
        label.font = StyleProvider.fontWith(type: .bold, size: 14)
        label.textColor = StyleProvider.Color.contrastTextColor
        return label
    }()
    
    // Auth section - for not logged in state
    private lazy var authSectionView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var authStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.alignment = .center
        stackView.spacing = 4
        return stackView
    }()
    
    private lazy var joinNowButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Join Now", for: .normal)
        button.titleLabel?.font = StyleProvider.fontWith(type: .regular, size: 14)
        button.setTitleColor(StyleProvider.Color.contrastTextColor, for: .normal)
        button.addTarget(self, action: #selector(handleJoinNowTapped), for: .touchUpInside)
        
        // Add underline
        let attributes: [NSAttributedString.Key: Any] = [
            .underlineStyle: NSUnderlineStyle.single.rawValue,
            .font: StyleProvider.fontWith(type: .medium, size: 14),
            .foregroundColor: StyleProvider.Color.contrastTextColor
        ]
        let attributedTitle = NSAttributedString(string: "Join Now", attributes: attributes)
        button.setAttributedTitle(attributedTitle, for: .normal)
        
        return button
    }()
    
    private lazy var orLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "or"
        label.font = StyleProvider.fontWith(type: .regular, size: 14)
        label.textColor = StyleProvider.Color.contrastTextColor
        return label
    }()
    
    private lazy var logInButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Log In", for: .normal)
        button.titleLabel?.font = StyleProvider.fontWith(type: .regular, size: 14)
        button.setTitleColor(StyleProvider.Color.contrastTextColor, for: .normal)
        button.addTarget(self, action: #selector(handleLogInTapped), for: .touchUpInside)
        
        // Add underline
        let attributes: [NSAttributedString.Key: Any] = [
            .underlineStyle: NSUnderlineStyle.single.rawValue,
            .font: StyleProvider.fontWith(type: .medium, size: 14),
            .foregroundColor: StyleProvider.Color.contrastTextColor
        ]
        let attributedTitle = NSAttributedString(string: "Log In", attributes: attributes)
        button.setAttributedTitle(attributedTitle, for: .normal)
        
        return button
    }()
    
    // Balance section - for logged in state
    private lazy var balanceSectionView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var balanceStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.alignment = .center
        stackView.spacing = 4
        return stackView
    }()
    
    private lazy var balanceLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = StyleProvider.fontWith(type: .regular, size: 14)
        label.textColor = StyleProvider.Color.contrastTextColor
        return label
    }()
    
    private lazy var balanceValueLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = StyleProvider.fontWith(type: .bold, size: 14)
        label.textColor = StyleProvider.Color.contrastTextColor
        return label
    }()
    
    private lazy var closeButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "xmark"), for: .normal)
        button.tintColor = StyleProvider.Color.highlightPrimary
        button.addTarget(self, action: #selector(handleCloseTapped), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Properties
    private let viewModel: BetslipHeaderViewModelProtocol
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    public init(viewModel: BetslipHeaderViewModelProtocol) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        setupSubviews()
        setupBindings()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    private func setupSubviews() {
        addSubview(containerView)
        
        containerView.addSubview(mainStackView)
        
        // Left section
        mainStackView.addArrangedSubview(leftSectionView)
        leftSectionView.addSubview(betslipIconImageView)
        leftSectionView.addSubview(betslipTitleLabel)
        
        // Auth section
        mainStackView.addArrangedSubview(authSectionView)
        authSectionView.addSubview(authStackView)
        authStackView.addArrangedSubview(joinNowButton)
        authStackView.addArrangedSubview(orLabel)
        authStackView.addArrangedSubview(logInButton)
        
        // Balance section
        mainStackView.addArrangedSubview(balanceSectionView)
        balanceSectionView.addSubview(balanceStackView)
        balanceStackView.addArrangedSubview(balanceLabel)
        balanceStackView.addArrangedSubview(balanceValueLabel)
        
        // Close button (always visible)
        containerView.addSubview(closeButton)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Container
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            // Main stack view
            mainStackView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            mainStackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            mainStackView.trailingAnchor.constraint(equalTo: closeButton.leadingAnchor, constant: -8),
            mainStackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -12),
            
            // Left section
            betslipIconImageView.leadingAnchor.constraint(equalTo: leftSectionView.leadingAnchor),
            betslipIconImageView.centerYAnchor.constraint(equalTo: leftSectionView.centerYAnchor),
            betslipIconImageView.widthAnchor.constraint(equalToConstant: 20),
            betslipIconImageView.heightAnchor.constraint(equalToConstant: 20),
            
            betslipTitleLabel.leadingAnchor.constraint(equalTo: betslipIconImageView.trailingAnchor, constant: 8),
            betslipTitleLabel.trailingAnchor.constraint(equalTo: leftSectionView.trailingAnchor),
            betslipTitleLabel.centerYAnchor.constraint(equalTo: leftSectionView.centerYAnchor),
            
            // Auth section
            authStackView.topAnchor.constraint(equalTo: authSectionView.topAnchor),
            authStackView.leadingAnchor.constraint(equalTo: authSectionView.leadingAnchor),
            authStackView.trailingAnchor.constraint(equalTo: authSectionView.trailingAnchor),
            authStackView.bottomAnchor.constraint(equalTo: authSectionView.bottomAnchor),
            
            // Balance section
            balanceStackView.topAnchor.constraint(equalTo: balanceSectionView.topAnchor),
            balanceStackView.leadingAnchor.constraint(equalTo: balanceSectionView.leadingAnchor),
            balanceStackView.trailingAnchor.constraint(equalTo: balanceSectionView.trailingAnchor),
            balanceStackView.bottomAnchor.constraint(equalTo: balanceSectionView.bottomAnchor),
            
            closeButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            closeButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            closeButton.widthAnchor.constraint(equalToConstant: 24),
            closeButton.heightAnchor.constraint(equalToConstant: 24)
        ])
    }
    
    private func setupBindings() {
        viewModel.dataPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] data in
                self?.render(data: data)
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Rendering
    private func render(data: BetslipHeaderData) {
        switch data.state {
        case .notLoggedIn:
            renderNotLoggedInState()
        case .loggedIn(let balance):
            renderLoggedInState(balance: balance)
        }
        
        alpha = data.isEnabled ? 1.0 : 0.5
        isUserInteractionEnabled = data.isEnabled
    }
    
    private func renderNotLoggedInState() {
        // Show auth buttons, hide balance
        authSectionView.isHidden = false
        balanceSectionView.isHidden = true
        
        // Clear balance text for layout
        balanceLabel.text = ""
        balanceValueLabel.text = ""
    }
    
    private func renderLoggedInState(balance: String) {
        // Hide auth buttons, show balance
        authSectionView.isHidden = true
        balanceSectionView.isHidden = false
        
        // Update balance
        balanceLabel.text = "Balance:"
        balanceValueLabel.text = balance
    }
    
    // MARK: - Actions
    @objc private func handleJoinNowTapped() {
        viewModel.onJoinNowTapped?()
    }
    
    @objc private func handleLogInTapped() {
        viewModel.onLogInTapped?()
    }
    
    @objc private func handleCloseTapped() {
        viewModel.onCloseTapped?()
    }
}

// MARK: - Preview Provider
#if DEBUG

@available(iOS 17.0, *)
#Preview("Not Logged In") {
    PreviewUIView {
        BetslipHeaderView(viewModel: MockBetslipHeaderViewModel.notLoggedInMock())
    }
    .frame(height: 60)
}

@available(iOS 17.0, *)
#Preview("Logged In") {
    PreviewUIView {
        BetslipHeaderView(viewModel: MockBetslipHeaderViewModel.loggedInMock())
    }
    .frame(height: 60)
}

#endif 

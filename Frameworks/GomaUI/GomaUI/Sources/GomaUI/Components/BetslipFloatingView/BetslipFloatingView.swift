//
//  BetslipFloatingView.swift
//  GomaUI
//
//  Created by André Lascas on 05/08/2025.
//

import Foundation
import UIKit
import Combine
import SwiftUI

/// A floating view that displays betslip status with two states: no tickets (circular button) and with tickets (detailed view)
public final class BetslipFloatingView: UIView {
    
    // MARK: - UI Components
    
    // No tickets state - circular button
    private lazy var circularButton: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = StyleProvider.Color.highlightPrimary
        view.layer.cornerRadius = 28
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 4
        view.layer.shadowOpacity = 0.2
        return view
    }()
    
    private lazy var betslipIconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "betslip_icon", in: Bundle.module, with: nil) ?? UIImage(systemName: "ticket")
        imageView.tintColor = StyleProvider.Color.highlightSecondaryContrast
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private lazy var betslipLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Betslip"
        label.font = StyleProvider.fontWith(type: .bold, size: 10)
        label.textColor = StyleProvider.Color.highlightSecondaryContrast
        label.textAlignment = .center
        return label
    }()
    
    // With tickets state - detailed view
    private lazy var detailedContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = StyleProvider.Color.backgroundGradient2
        view.layer.cornerRadius = 12
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 4
        view.layer.shadowOpacity = 0.2
        return view
    }()
    
    // Top bar components
    private lazy var topBarStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.alignment = .center
        stackView.spacing = 8
        return stackView
    }()
    
    private lazy var selectionCountView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = StyleProvider.Color.backgroundTertiary
        view.layer.borderWidth = 1
        view.layer.borderColor = StyleProvider.Color.highlightPrimary.cgColor
        view.layer.cornerRadius = 12
        return view
    }()
    
    private lazy var selectionCountLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = StyleProvider.fontWith(type: .bold, size: 12)
        label.textColor = StyleProvider.Color.highlightPrimary
        label.textAlignment = .center
        return label
    }()
    
    private lazy var oddsCapsuleView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = StyleProvider.Color.highlightPrimary
        view.layer.cornerRadius = 12
        return view
    }()
    
    private lazy var oddsLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = StyleProvider.fontWith(type: .semibold, size: 10)
        label.textColor = StyleProvider.Color.buttonTextPrimary
        label.textAlignment = .center
        return label
    }()
    
    private lazy var oddsValueLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = StyleProvider.fontWith(type: .semibold, size: 14)
        label.textColor = StyleProvider.Color.buttonTextPrimary
        label.textAlignment = .center
        return label
    }()
    
    private lazy var winBoostCapsuleView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = StyleProvider.Color.highlightSecondary
        view.layer.cornerRadius = 12
        return view
    }()
    
    private lazy var winBoostLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = StyleProvider.fontWith(type: .semibold, size: 10)
        label.textColor = StyleProvider.Color.buttonTextPrimary
        label.textAlignment = .center
        return label
    }()
    
    private lazy var winBoostValueLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = StyleProvider.fontWith(type: .semibold, size: 14)
        label.textColor = StyleProvider.Color.buttonTextPrimary
        label.textAlignment = .center
        return label
    }()
    
    private lazy var openBetslipButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Open Betslip", for: .normal)
        button.setTitleColor(StyleProvider.Color.textPrimary, for: .normal)
        button.titleLabel?.font = StyleProvider.fontWith(type: .semibold, size: 12)
        button.setImage(UIImage(systemName: "chevron.up"), for: .normal)
        button.tintColor = StyleProvider.Color.highlightPrimary
        button.semanticContentAttribute = .forceRightToLeft
        return button
    }()
    
    // Bottom section components
    private lazy var bottomSectionView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = StyleProvider.Color.backgroundTertiary
        view.layer.cornerRadius = 8
        return view
    }()
    
    private lazy var callToActionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = StyleProvider.fontWith(type: .medium, size: 12)
        label.textColor = StyleProvider.Color.textPrimary
        label.numberOfLines = 0
        return label
    }()
    
    // Progress segments
    private lazy var progressSegmentsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.alignment = .center
        stackView.spacing = 4
        return stackView
    }()
    
    private var progressSegments: [UIView] = []
    
    // MARK: - Properties
    private let viewModel: BetslipFloatingViewModelProtocol
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Constraint Properties (for external access)
    private var circularButtonLeadingConstraint: NSLayoutConstraint?
    private var detailedContainerLeadingConstraint: NSLayoutConstraint?
    private var circularButtonTopConstraint: NSLayoutConstraint?
    private var circularButtonBottomConstraint: NSLayoutConstraint?
    
    // MARK: - Initialization
    public init(viewModel: BetslipFloatingViewModelProtocol) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        setupSubviews()
        setupBindings()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    public override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        // Create and apply width constraints when added to superview
        if let superview = superview {
            // Create leading constraints
            circularButtonLeadingConstraint = leadingAnchor.constraint(equalTo: superview.trailingAnchor, constant: -72) // 56 + 16 padding
            detailedContainerLeadingConstraint = leadingAnchor.constraint(equalTo: superview.leadingAnchor)
            
            // Create height constraints for circular button
            circularButtonTopConstraint = circularButton.topAnchor.constraint(equalTo: topAnchor)
            circularButtonBottomConstraint = circularButton.bottomAnchor.constraint(equalTo: bottomAnchor)
            
            // Apply constraints based on current state
            updateWidthConstraints(for: viewModel.currentData.state)
        }
    }
    
    // MARK: - Setup
    private func setupSubviews() {
        // Add circular button components
        addSubview(circularButton)
        circularButton.addSubview(betslipIconImageView)
        circularButton.addSubview(betslipLabel)
        
        // Add detailed view components
        addSubview(detailedContainerView)
        
        // Setup top bar
        detailedContainerView.addSubview(topBarStackView)
        topBarStackView.addArrangedSubview(selectionCountView)
        topBarStackView.addArrangedSubview(oddsCapsuleView)
        topBarStackView.addArrangedSubview(winBoostCapsuleView)
        topBarStackView.addArrangedSubview(UIView()) // Spacer
        topBarStackView.addArrangedSubview(openBetslipButton)
        
        selectionCountView.addSubview(selectionCountLabel)
        oddsCapsuleView.addSubview(oddsLabel)
        oddsCapsuleView.addSubview(oddsValueLabel)
        winBoostCapsuleView.addSubview(winBoostLabel)
        winBoostCapsuleView.addSubview(winBoostValueLabel)

        // Setup bottom section
        detailedContainerView.addSubview(bottomSectionView)
        bottomSectionView.addSubview(callToActionLabel)
        bottomSectionView.addSubview(progressSegmentsStackView)
        
        setupConstraints()
        setupGestures()
    }
    
    private func setupConstraints() {
        // Circular button constraints
        NSLayoutConstraint.activate([
            circularButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            
            circularButton.widthAnchor.constraint(equalToConstant: 56),
            circularButton.heightAnchor.constraint(equalToConstant: 56),
            
            betslipIconImageView.centerXAnchor.constraint(equalTo: circularButton.centerXAnchor),
            betslipIconImageView.centerYAnchor.constraint(equalTo: circularButton.centerYAnchor, constant: -8),
            betslipIconImageView.widthAnchor.constraint(equalToConstant: 20),
            betslipIconImageView.heightAnchor.constraint(equalToConstant: 20),
            
            betslipLabel.centerXAnchor.constraint(equalTo: circularButton.centerXAnchor),
            betslipLabel.topAnchor.constraint(equalTo: betslipIconImageView.bottomAnchor, constant: 2),
            betslipLabel.leadingAnchor.constraint(greaterThanOrEqualTo: circularButton.leadingAnchor, constant: 4),
            betslipLabel.trailingAnchor.constraint(lessThanOrEqualTo: circularButton.trailingAnchor, constant: -4)
        ])
        
        // Detailed view constraints
        NSLayoutConstraint.activate([
            detailedContainerView.topAnchor.constraint(equalTo: topAnchor),
            detailedContainerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            detailedContainerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            detailedContainerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            // Top bar
            topBarStackView.topAnchor.constraint(equalTo: detailedContainerView.topAnchor, constant: 12),
            topBarStackView.leadingAnchor.constraint(equalTo: detailedContainerView.leadingAnchor, constant: 12),
            topBarStackView.trailingAnchor.constraint(equalTo: detailedContainerView.trailingAnchor, constant: -12),
            
            // Selection count view
            selectionCountView.widthAnchor.constraint(equalToConstant: 24),
            selectionCountView.heightAnchor.constraint(equalToConstant: 24),
            
            selectionCountLabel.centerXAnchor.constraint(equalTo: selectionCountView.centerXAnchor),
            selectionCountLabel.centerYAnchor.constraint(equalTo: selectionCountView.centerYAnchor),
            
            // Odds capsule
            oddsCapsuleView.heightAnchor.constraint(equalToConstant: 24),
            
            oddsLabel.leadingAnchor.constraint(equalTo: oddsCapsuleView.leadingAnchor, constant: 8),
            oddsLabel.centerYAnchor.constraint(equalTo: oddsCapsuleView.centerYAnchor),
            
            oddsValueLabel.leadingAnchor.constraint(equalTo: oddsLabel.trailingAnchor, constant: 1),
            oddsValueLabel.trailingAnchor.constraint(equalTo: oddsCapsuleView.trailingAnchor, constant: -8),
            oddsValueLabel.centerYAnchor.constraint(equalTo: oddsCapsuleView.centerYAnchor),
            
            // Win boost capsule
            winBoostCapsuleView.heightAnchor.constraint(equalToConstant: 24),
            
            winBoostLabel.leadingAnchor.constraint(equalTo: winBoostCapsuleView.leadingAnchor, constant: 8),
//            winBoostLabel.trailingAnchor.constraint(equalTo: winBoostCapsuleView.trailingAnchor, constant: -8),
            winBoostLabel.centerYAnchor.constraint(equalTo: winBoostCapsuleView.centerYAnchor),
            
            winBoostValueLabel.leadingAnchor.constraint(equalTo: winBoostLabel.trailingAnchor, constant: 1),
            winBoostValueLabel.trailingAnchor.constraint(equalTo: winBoostCapsuleView.trailingAnchor, constant: -8),
            winBoostValueLabel.centerYAnchor.constraint(equalTo: winBoostCapsuleView.centerYAnchor),
            
            // Bottom section
            bottomSectionView.topAnchor.constraint(equalTo: topBarStackView.bottomAnchor, constant: 8),
            bottomSectionView.leadingAnchor.constraint(equalTo: detailedContainerView.leadingAnchor, constant: 12),
            bottomSectionView.trailingAnchor.constraint(equalTo: detailedContainerView.trailingAnchor, constant: -12),
            bottomSectionView.bottomAnchor.constraint(equalTo: detailedContainerView.bottomAnchor, constant: -12),
            
            callToActionLabel.topAnchor.constraint(equalTo: bottomSectionView.topAnchor, constant: 8),
            callToActionLabel.leadingAnchor.constraint(equalTo: bottomSectionView.leadingAnchor, constant: 8),
            callToActionLabel.trailingAnchor.constraint(equalTo: bottomSectionView.trailingAnchor, constant: -8),
            
            progressSegmentsStackView.topAnchor.constraint(equalTo: callToActionLabel.bottomAnchor, constant: 8),
            progressSegmentsStackView.leadingAnchor.constraint(equalTo: bottomSectionView.leadingAnchor, constant: 8),
            progressSegmentsStackView.trailingAnchor.constraint(equalTo: bottomSectionView.trailingAnchor, constant: -8),
            progressSegmentsStackView.bottomAnchor.constraint(equalTo: bottomSectionView.bottomAnchor, constant: -8),
            progressSegmentsStackView.heightAnchor.constraint(equalToConstant: 8)
        ])
    }

    private func setupProgressSegments(ticketSelection: Int, totalEligibleCount: Int) {
        
        progressSegments.forEach { $0.removeFromSuperview() }
        progressSegments.removeAll()
        
        for i in 0..<totalEligibleCount {
            let segment = UIView()
            segment.translatesAutoresizingMaskIntoConstraints = false
            
            if i < ticketSelection {
                segment.backgroundColor = StyleProvider.Color.highlightSecondary
            } else {
                segment.backgroundColor = StyleProvider.Color.backgroundBorder
            }
            
            segment.layer.cornerRadius = 4
            
            progressSegments.append(segment)
            progressSegmentsStackView.addArrangedSubview(segment)
            
            // Add height constraint to make segments visible
            NSLayoutConstraint.activate([
                segment.heightAnchor.constraint(equalToConstant: 8)
            ])
        }
    }
    
    private func setupGestures() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        addGestureRecognizer(tapGesture)
        
        openBetslipButton.addTarget(self, action: #selector(handleOpenBetslipTapped), for: .touchUpInside)
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
    private func render(data: BetslipFloatingData) {
        // Update width constraints based on state (only if view has superview)
        if superview != nil {
            updateWidthConstraints(for: data.state)
        }
        
        switch data.state {
        case .noTickets:
            circularButton.isHidden = false
            detailedContainerView.isHidden = true
        case .withTickets(let selectionCount, let odds, let winBoostPercentage, let totalEligibleCount):
            circularButton.isHidden = true
            detailedContainerView.isHidden = false
            
            selectionCountLabel.text = "\(selectionCount)"
            
            oddsLabel.text = "Odds:"
            oddsValueLabel.text = "\(odds)"
            
            if let winBoost = winBoostPercentage {
                winBoostLabel.text = "Win Boost:"
                winBoostValueLabel.text = winBoost
                winBoostCapsuleView.isHidden = false
            } else {
                winBoostLabel.text = "Win Boost:"
                winBoostValueLabel.text = "-"
                winBoostCapsuleView.isHidden = false
            }
            
            setupProgressSegments(ticketSelection: selectionCount, totalEligibleCount: totalEligibleCount)
            
            let remainingSelections = max(0, totalEligibleCount - selectionCount)
            if remainingSelections > 0 {
                callToActionLabel.text = "Add \(remainingSelections) more qualifying events to get a 11% win boost"
            } else {
                callToActionLabel.text = "Win boost activated!"
            }
        }
        
        alpha = data.isEnabled ? 1.0 : 0.5
        isUserInteractionEnabled = data.isEnabled
    }
    
    // MARK: - Public Methods
    public func updateWidthConstraints(for state: BetslipFloatingState) {
        guard let superview = superview else {
            // If no superview yet, store the state and apply when added to superview
            return
        }
        
        switch state {
        case .noTickets:
            detailedContainerLeadingConstraint?.isActive = false
            circularButtonLeadingConstraint?.isActive = true
            circularButtonTopConstraint?.isActive = true
            circularButtonBottomConstraint?.isActive = true
            
        case .withTickets:
            circularButtonLeadingConstraint?.isActive = false
            circularButtonTopConstraint?.isActive = false
            circularButtonBottomConstraint?.isActive = false
            detailedContainerLeadingConstraint?.isActive = true
        }
    }
    
    // MARK: - Actions
    @objc private func handleTap() {
        viewModel.onBetslipTapped?()
    }
    
    @objc private func handleOpenBetslipTapped() {
        viewModel.onBetslipTapped?()
    }
}

// MARK: - Preview Provider
#if DEBUG

@available(iOS 17.0, *)
#Preview("No Tickets") {
    PreviewUIView {
        BetslipFloatingView(viewModel: MockBetslipFloatingViewModel(state: .noTickets))
    }
    .frame(height: 56)
}

@available(iOS 17.0, *)
#Preview("With Tickets") {
    PreviewUIView {
        BetslipFloatingView(viewModel: MockBetslipFloatingViewModel(state: .withTickets(selectionCount: 3, odds: "1.55", winBoostPercentage: "3%", totalEligibleCount: 6)))
    }
    .frame(height: 120)
}

#endif

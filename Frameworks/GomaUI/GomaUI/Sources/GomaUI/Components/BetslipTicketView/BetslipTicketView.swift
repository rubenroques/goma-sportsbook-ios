import Foundation
import UIKit
import Combine
import SwiftUI

/// A view component that displays a betslip ticket with match information, selection details, and odds
public final class BetslipTicketView: UIView {
    
    // MARK: - Properties
    public var viewModel: BetslipTicketViewModelProtocol {
        didSet {
            // Clear old cancellables and re-setup bindings for new view model
            cancellables.removeAll()
            setupBindings()
        }
    }
    private var cancellables = Set<AnyCancellable>()
    private var oddsChangeTimer: Timer?
    
    // MARK: - UI Components
    
    // Container view
    private lazy var containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = StyleProvider.Color.backgroundSecondary
        return view
    }()
    
    // Left orange strip
    private lazy var leftStripView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = StyleProvider.Color.highlightPrimary.withAlphaComponent(0.2)
        return view
    }()
    
    // Close button
    private lazy var closeButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "xmark"), for: .normal)
        button.tintColor = StyleProvider.Color.highlightPrimary
        button.addTarget(self, action: #selector(handleCloseTapped), for: .touchUpInside)
        return button
    }()
    
    // League and date info label
    private lazy var leagueDateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = StyleProvider.fontWith(type: .regular, size: 12)
        label.textColor = StyleProvider.Color.textSecondary
        label.numberOfLines = 1
        return label
    }()
    
    // Home team label
    private lazy var homeTeamLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = StyleProvider.fontWith(type: .bold, size: 14)
        label.textColor = StyleProvider.Color.textPrimary
        label.numberOfLines = 1
        return label
    }()
    
    // Away team label
    private lazy var awayTeamLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = StyleProvider.fontWith(type: .bold, size: 14)
        label.textColor = StyleProvider.Color.textPrimary
        label.numberOfLines = 1
        return label
    }()
    
    // Selection label
    private lazy var selectionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = StyleProvider.fontWith(type: .medium, size: 10)
        label.textColor = StyleProvider.Color.textSecondary
        label.text = "YOUR SELECTION"
        label.numberOfLines = 1
        return label
    }()
    
    // Selected team label
    private lazy var outcomeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = StyleProvider.fontWith(type: .bold, size: 12)
        label.textColor = StyleProvider.Color.highlightPrimary
        label.numberOfLines = 1
        return label
    }()
    
    // Odds value label
    private lazy var oddsValueLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = StyleProvider.fontWith(type: .bold, size: 16)
        label.textColor = StyleProvider.Color.highlightPrimary
        label.textAlignment = .right
        label.numberOfLines = 1
        label.setContentHuggingPriority(.required, for: .horizontal)
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        return label
    }()
    
    // Up arrow (increased odds)
    private lazy var upArrowImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        if let customLogo = UIImage(named: "caret_up_icon") {
            imageView.image = customLogo.withRenderingMode(.alwaysTemplate)
            imageView.tintColor = StyleProvider.Color.alertSuccess
        }
        else {
            imageView.image = UIImage(systemName: "arrow.up")?.withTintColor(StyleProvider.Color.alertSuccess, renderingMode: .alwaysOriginal)
        }
        imageView.tintColor = StyleProvider.Color.alertSuccess
        imageView.contentMode = .scaleAspectFit
        imageView.isHidden = true
        return imageView
    }()
    
    // Down arrow (decreased odds)
    private lazy var downArrowImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        if let customLogo = UIImage(named: "caret_down_icon") {
            imageView.image = customLogo.withRenderingMode(.alwaysTemplate)
            imageView.tintColor = StyleProvider.Color.alertError
        }
        else {
            imageView.image = UIImage(systemName: "arrow.down")?.withTintColor(StyleProvider.Color.alertError, renderingMode: .alwaysOriginal)
        }
        imageView.tintColor = StyleProvider.Color.alertError
        imageView.contentMode = .scaleAspectFit
        imageView.isHidden = true
        return imageView
    }()
    
    // Disabled overlay view
    private lazy var disabledView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = StyleProvider.Color.backgroundSecondary.withAlphaComponent(0.7)
        view.isHidden = true
        return view
    }()
    
    // Disabled label
    private lazy var disabledLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = StyleProvider.fontWith(type: .semibold, size: 14)
        label.textColor = StyleProvider.Color.textPrimary
        label.text = "Invalid selection"
        label.textAlignment = .center
        label.numberOfLines = 1
        label.isHidden = true
        return label
    }()

    
    // MARK: - Initialization
    public init(viewModel: BetslipTicketViewModelProtocol) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        setupSubviews()
        setupConstraints()
        setupBindings()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    private func setupSubviews() {
        addSubview(containerView)
        
        // Add left strip and close button
        containerView.addSubview(leftStripView)
        leftStripView.addSubview(closeButton)
        
        // Add all labels directly to container
        containerView.addSubview(leagueDateLabel)
        containerView.addSubview(homeTeamLabel)
        containerView.addSubview(awayTeamLabel)
        containerView.addSubview(selectionLabel)
        containerView.addSubview(outcomeLabel)
        containerView.addSubview(oddsValueLabel)
        containerView.addSubview(upArrowImageView)
        containerView.addSubview(downArrowImageView)
        
        // Add disabled overlay
        containerView.addSubview(disabledView)
        disabledView.addSubview(disabledLabel)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Container
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            // Left strip
            leftStripView.topAnchor.constraint(equalTo: containerView.topAnchor),
            leftStripView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            leftStripView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            leftStripView.widthAnchor.constraint(equalToConstant: 24),
            
            // Close button
            closeButton.centerXAnchor.constraint(equalTo: leftStripView.centerXAnchor),
            closeButton.centerYAnchor.constraint(equalTo: leftStripView.centerYAnchor),
            closeButton.widthAnchor.constraint(equalToConstant: 12),
            closeButton.heightAnchor.constraint(equalToConstant: 12),
            
            // League and date label
            leagueDateLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            leagueDateLabel.leadingAnchor.constraint(equalTo: leftStripView.trailingAnchor, constant: 12),
            leagueDateLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            
            // Home team label
            homeTeamLabel.topAnchor.constraint(equalTo: leagueDateLabel.bottomAnchor, constant: 8),
            homeTeamLabel.leadingAnchor.constraint(equalTo: leftStripView.trailingAnchor, constant: 12),
            homeTeamLabel.trailingAnchor.constraint(equalTo: oddsValueLabel.leadingAnchor, constant: -30),

            // Away team label
            awayTeamLabel.topAnchor.constraint(equalTo: homeTeamLabel.bottomAnchor, constant: 2),
            awayTeamLabel.leadingAnchor.constraint(equalTo: leftStripView.trailingAnchor, constant: 12),
            awayTeamLabel.trailingAnchor.constraint(equalTo: oddsValueLabel.leadingAnchor, constant: -30),
            
            // Selection label
            selectionLabel.topAnchor.constraint(equalTo: awayTeamLabel.bottomAnchor, constant: 8),
            selectionLabel.leadingAnchor.constraint(equalTo: leftStripView.trailingAnchor, constant: 12),
            
            // Selected team label
            outcomeLabel.topAnchor.constraint(equalTo: selectionLabel.bottomAnchor, constant: 2),
            outcomeLabel.leadingAnchor.constraint(equalTo: leftStripView.trailingAnchor, constant: 12),
            outcomeLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -12),
            
            // Odds value label
            oddsValueLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            oddsValueLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            
            // Up arrow
            upArrowImageView.trailingAnchor.constraint(equalTo: oddsValueLabel.leadingAnchor, constant: -4),
            upArrowImageView.centerYAnchor.constraint(equalTo: oddsValueLabel.centerYAnchor),
            upArrowImageView.widthAnchor.constraint(equalToConstant: 12),
            upArrowImageView.heightAnchor.constraint(equalToConstant: 12),
            
            // Down arrow
            downArrowImageView.trailingAnchor.constraint(equalTo: oddsValueLabel.leadingAnchor, constant: -4),
            downArrowImageView.centerYAnchor.constraint(equalTo: oddsValueLabel.centerYAnchor),
            downArrowImageView.widthAnchor.constraint(equalToConstant: 12),
            downArrowImageView.heightAnchor.constraint(equalToConstant: 12),
            
            // Disabled overlay
            disabledView.leadingAnchor.constraint(equalTo: leftStripView.trailingAnchor),
            disabledView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            disabledView.topAnchor.constraint(equalTo: containerView.topAnchor),
            disabledView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            
            // Disabled label
            disabledLabel.centerXAnchor.constraint(equalTo: disabledView.centerXAnchor),
            disabledLabel.centerYAnchor.constraint(equalTo: disabledView.centerYAnchor)
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
    private func render(data: BetslipTicketData) {
        
        // Update league and date info
        leagueDateLabel.text = "\(data.leagueName) • \(data.startDate)"
        leagueDateLabel.isHidden = false
        
        // Update teams
        homeTeamLabel.text = data.homeTeam
        homeTeamLabel.isHidden = false
        awayTeamLabel.text = data.awayTeam
        awayTeamLabel.isHidden = false
        
        // Update selected team
        outcomeLabel.text = data.selectedTeam
        outcomeLabel.isHidden = false
        
        // Update odds value
        oddsValueLabel.text = data.oddsValue
        oddsValueLabel.isHidden = false
        
        // Update odds change state
        updateOddsChangeIndicator(data.oddsChangeState)
        
        // Update enabled state - show/hide disabled overlay
//        disabledView.isHidden = data.isEnabled
        containerView.alpha = data.isEnabled ? 1.0 : 0.5
        
        // Force layout update to ensure proper sizing
        setNeedsLayout()
        layoutIfNeeded()
        
    }
    
    private func updateOddsChangeIndicator(_ state: OddsChangeState) {
        // Cancel existing timer
        oddsChangeTimer?.invalidate()
        oddsChangeTimer = nil
        
        switch state {
        case .none:
            // Hide both arrows with fade animation
            if !upArrowImageView.isHidden {
                UIView.animate(withDuration: 0.3) {
                    self.upArrowImageView.alpha = 0
                } completion: { _ in
                    self.upArrowImageView.isHidden = true
                    self.upArrowImageView.alpha = 1
                }
            }
            if !downArrowImageView.isHidden {
                UIView.animate(withDuration: 0.3) {
                    self.downArrowImageView.alpha = 0
                } completion: { _ in
                    self.downArrowImageView.isHidden = true
                    self.downArrowImageView.alpha = 1
                }
            }
            
        case .increased:
            // Hide down arrow if visible
            if !downArrowImageView.isHidden {
                UIView.animate(withDuration: 0.3) {
                    self.downArrowImageView.alpha = 0
                } completion: { _ in
                    self.downArrowImageView.isHidden = true
                    self.downArrowImageView.alpha = 1
                }
            }
            
            // Show up arrow with fade animation
            upArrowImageView.isHidden = false
            upArrowImageView.alpha = 0
            UIView.animate(withDuration: 0.3) {
                self.upArrowImageView.alpha = 1
            }
            
            // Hide after 4 seconds
            oddsChangeTimer = Timer.scheduledTimer(withTimeInterval: 4.0, repeats: false) { [weak self] _ in
                DispatchQueue.main.async {
                    self?.hideUpArrow()
                }
            }
            
        case .decreased:
            // Hide up arrow if visible
            if !upArrowImageView.isHidden {
                UIView.animate(withDuration: 0.3) {
                    self.upArrowImageView.alpha = 0
                } completion: { _ in
                    self.upArrowImageView.isHidden = true
                    self.upArrowImageView.alpha = 1
                }
            }
            
            // Show down arrow with fade animation
            downArrowImageView.isHidden = false
            downArrowImageView.alpha = 0
            UIView.animate(withDuration: 0.3) {
                self.downArrowImageView.alpha = 1
            }
            
            // Hide after 4 seconds
            oddsChangeTimer = Timer.scheduledTimer(withTimeInterval: 4.0, repeats: false) { [weak self] _ in
                DispatchQueue.main.async {
                    self?.hideDownArrow()
                }
            }
        }
    }
    
    private func hideUpArrow() {
        UIView.animate(withDuration: 0.3) {
            self.upArrowImageView.alpha = 0
        } completion: { _ in
            self.upArrowImageView.isHidden = true
            self.upArrowImageView.alpha = 1
        }
    }
    
    private func hideDownArrow() {
        UIView.animate(withDuration: 0.3) {
            self.downArrowImageView.alpha = 0
        } completion: { _ in
            self.downArrowImageView.isHidden = true
            self.downArrowImageView.alpha = 1
        }
    }
    
    // MARK: - Actions
    @objc private func handleCloseTapped() {
        print("Close tapped!")
        viewModel.onCloseTapped?()
    }
    
    // MARK: - Deinit
    deinit {
        oddsChangeTimer?.invalidate()
    }
}

// MARK: - SwiftUI Preview
#if DEBUG

@available(iOS 17.0, *)
#Preview("Typical") {
    PreviewUIViewController {
        let vc = UIViewController()
        vc.view.backgroundColor = .backgroundTestColor

        let ticketView = BetslipTicketView(viewModel: MockBetslipTicketViewModel.typicalMock())
        ticketView.translatesAutoresizingMaskIntoConstraints = false
        vc.view.addSubview(ticketView)

        NSLayoutConstraint.activate([
            ticketView.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor, constant: 20),
            ticketView.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor, constant: -20),
            ticketView.centerYAnchor.constraint(equalTo: vc.view.centerYAnchor),
            ticketView.heightAnchor.constraint(equalToConstant: 120)
        ])

        return vc
    }
}

@available(iOS 17.0, *)
#Preview("Increased Odds") {
    PreviewUIViewController {
        let vc = UIViewController()
        vc.view.backgroundColor = .backgroundTestColor

        let ticketView = BetslipTicketView(viewModel: MockBetslipTicketViewModel.increasedOddsMock())
        ticketView.translatesAutoresizingMaskIntoConstraints = false
        vc.view.addSubview(ticketView)

        NSLayoutConstraint.activate([
            ticketView.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor, constant: 20),
            ticketView.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor, constant: -20),
            ticketView.centerYAnchor.constraint(equalTo: vc.view.centerYAnchor),
            ticketView.heightAnchor.constraint(equalToConstant: 120)
        ])

        return vc
    }
}

@available(iOS 17.0, *)
#Preview("Decreased Odds") {
    PreviewUIViewController {
        let vc = UIViewController()
        vc.view.backgroundColor = .backgroundTestColor

        let ticketView = BetslipTicketView(viewModel: MockBetslipTicketViewModel.decreasedOddsMock())
        ticketView.translatesAutoresizingMaskIntoConstraints = false
        vc.view.addSubview(ticketView)

        NSLayoutConstraint.activate([
            ticketView.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor, constant: 20),
            ticketView.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor, constant: -20),
            ticketView.centerYAnchor.constraint(equalTo: vc.view.centerYAnchor),
            ticketView.heightAnchor.constraint(equalToConstant: 120)
        ])

        return vc
    }
}

@available(iOS 17.0, *)
#Preview("Disabled") {
    PreviewUIViewController {
        let vc = UIViewController()
        vc.view.backgroundColor = .backgroundTestColor

        let ticketView = BetslipTicketView(viewModel: MockBetslipTicketViewModel.disabledMock())
        ticketView.translatesAutoresizingMaskIntoConstraints = false
        vc.view.addSubview(ticketView)

        NSLayoutConstraint.activate([
            ticketView.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor, constant: 20),
            ticketView.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor, constant: -20),
            ticketView.centerYAnchor.constraint(equalTo: vc.view.centerYAnchor),
            ticketView.heightAnchor.constraint(equalToConstant: 120)
        ])

        return vc
    }
}

#endif 

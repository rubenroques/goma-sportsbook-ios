//
//  BoostedBetConfirmationView.swift
//  Sportsbook
//
//  Created by Ruben Roques on 23/01/2024.
//

import Foundation
import UIKit
import ServicesProvider

class BoostedBetConfirmationView: UIView {
    
    private lazy var containerView: UIView = Self.createContainerView()
    private lazy var containerStackView: UIStackView = Self.createContainerStackView()
    
    private lazy var titleBaseView: UIView = Self.createSimpleBaseView()
    private lazy var titleLabel: UILabel = Self.createTitleLabel()
    
    private lazy var subtitleBaseView: UIView = Self.createSimpleBaseView()
    private lazy var subtitleLabel: UILabel = Self.createSubtitleLabel()
    
    private lazy var valuesStackView: UIStackView = Self.createValuesStackView()
    
    private lazy var topValuesStackView: UIStackView = Self.createTopValuesStackView()
    private lazy var simpleLineBaseView: UIView = Self.createSimpleBaseView()
    private lazy var bottomValuesView: UIView = Self.createBottomValuesView()
    
    private lazy var totalOddTitleLabel: UILabel = Self.createTotalOddTitleLabel()
    private lazy var totalOddValueLabel: UILabel = Self.createTotalOddValueLabel()
    private lazy var betAmountTitleLabel: UILabel = Self.createBetAmountTitleLabel()
    private lazy var betAmountValueLabel: UILabel = Self.createBetAmountValueLabel()
    private lazy var possibleWinningTitleLabel: UILabel = Self.createPossibleWinningTitleLabel()
    private lazy var possibleWinningValueLabel: UILabel = Self.createPossibleWinningValueLabel()
    
    private lazy var buttonsStackView: UIStackView = Self.createButtonsStackView()
    private lazy var rejectButton: UIButton = Self.createRejectButton()
    private lazy var acceptButton: UIButton = Self.createAcceptButton()
    
    private var betDetails: PlacedBetsResponse
    
    var didTapRejectBetAction: ((PlacedBetsResponse) -> Void) = { _ in }
    var didTapAcceptBetAction: ((PlacedBetsResponse) -> Void) = { _ in }
    var didDisappearAction: ((PlacedBetsResponse) -> Void) = { _ in }
    
    var countdownTimer: Timer?
    var totalTime: Int = 30
    
    init(betDetails: PlacedBetsResponse) {
        self.betDetails = betDetails
        
        super.init(frame: .zero)
        
        self.setupSubviews()
        self.commonInit()
        self.setupWithTheme()
    }
    
    // MARK: Lifetime and Cycle
    override init(frame: CGRect) {
        fatalError()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }

    func commonInit() {
        self.translatesAutoresizingMaskIntoConstraints = false
        
        self.rejectButton.addTarget(self, action: #selector(didTapRejectButton), for: .primaryActionTriggered)
        self.acceptButton.addTarget(self, action: #selector(didTapAcceptButton), for: .primaryActionTriggered)
        
        var betStake: Double = 5.0
       
        if
            self.betDetails.bets.count == 1,
            let firstBet = self.betDetails.bets.first,
            let firstBetLeg = firstBet.betLegs.first {
            
            self.valuesStackView.isHidden = false
            
            betStake = firstBet.totalStake
            
            let totalOddString = String(format: "%.2f", firstBetLeg.odd)
            self.totalOddValueLabel.text = totalOddString
            
            let potentialReturnString = String(format: "%.2f", firstBet.potentialReturn)
            self.possibleWinningValueLabel.text = "€" + potentialReturnString
            
            let betAmountString = String(format: "%.2f", firstBet.totalStake)
            self.betAmountValueLabel.text = "€" + betAmountString
        }
        else if let firstBet = self.betDetails.bets.first {
            betStake = firstBet.totalStake
            self.valuesStackView.isHidden = true
        }
        
        let betStakeString = String(format: "%.2f", betStake)
        
        let subtitleLabelTextFirst = localized("bet_confirmation_reoffer_limit_text")
            .replacingOccurrences(of: "{updatedAmountLimit}", with: "\(betStakeString)")
        let subtitleLabelTextSecond = localized("bet_confirmation_reoffer_timer_warning_text")
            .replacingOccurrences(of: "{timerInSeconds}", with: "\(totalTime)")
        
        let subtitleLabelText = subtitleLabelTextFirst + "\n" + subtitleLabelTextSecond
        self.subtitleLabel.text = subtitleLabelText
        
        let buttonTitle = localized("accept") + " (\(self.totalTime) \(localized("seconds"))"
        self.acceptButton.setTitle(buttonTitle, for: .normal)
        
    }

    func setupWithTheme() {
        self.backgroundColor = .clear

        self.containerView.backgroundColor = UIColor.App.backgroundSecondary
        self.containerStackView.backgroundColor = .clear
        
        self.titleLabel.textColor = UIColor.App.textPrimary
        self.subtitleLabel.textColor = UIColor.App.textPrimary
        
        self.simpleLineBaseView.backgroundColor = UIColor.App.textPrimary
        
        self.titleLabel.textColor = UIColor.App.textPrimary
        self.subtitleLabel.textColor = UIColor.App.textPrimary
        self.totalOddTitleLabel.textColor = UIColor.App.textPrimary
        self.totalOddValueLabel.textColor = UIColor.App.textPrimary
        self.betAmountTitleLabel.textColor = UIColor.App.textPrimary
        self.betAmountValueLabel.textColor = UIColor.App.textPrimary
        self.possibleWinningTitleLabel.textColor = UIColor.App.textPrimary
        self.possibleWinningValueLabel.textColor = UIColor.App.textPrimary
        
        self.acceptButton.setTitleColor(UIColor.App.buttonTextPrimary, for: .normal)
        self.acceptButton.setTitleColor(UIColor.App.buttonTextPrimary.withAlphaComponent(0.7), for: .highlighted)
        self.acceptButton.setTitleColor(UIColor.App.buttonTextPrimary.withAlphaComponent(0.4), for: .disabled)
        self.acceptButton.backgroundColor = .clear
        self.acceptButton.setBackgroundColor(UIColor.App.buttonBackgroundPrimary, for: .normal)
        self.acceptButton.setBackgroundColor(UIColor.App.buttonBackgroundPrimary, for: .highlighted)
        self.acceptButton.layer.cornerRadius = CornerRadius.button
        self.acceptButton.layer.masksToBounds = true

        self.rejectButton.setTitleColor(UIColor.App.buttonTextPrimary, for: .normal)
        self.rejectButton.setTitleColor(UIColor.App.buttonTextPrimary.withAlphaComponent(0.7), for: .highlighted)
        self.rejectButton.setTitleColor(UIColor.App.buttonTextPrimary.withAlphaComponent(0.4), for: .disabled)
        self.rejectButton.backgroundColor = .clear
        self.rejectButton.setBackgroundColor(UIColor.App.buttonBackgroundSecondary, for: .normal)
        self.rejectButton.setBackgroundColor(UIColor.App.buttonBackgroundSecondary, for: .highlighted)
        self.rejectButton.layer.cornerRadius = CornerRadius.button
        self.rejectButton.layer.masksToBounds = true
    }
    
    func startCountdown() {
        self.countdownTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
    }
    
    @objc private func updateTimer() {
        if totalTime > 0 {
            totalTime -= 1
            let title = localized("accept") + " (\(self.totalTime) \(localized("seconds")))"
            acceptButton.setTitle(title, for: .normal)
        } else {
            countdownTimer?.invalidate()
            countdownTimer = nil
            
            self.didDisappearAction(self.betDetails)
            // Handle what happens when the timer reaches 0
        }
    }
    
    @IBAction private func didTapRejectButton() {
        self.didTapRejectBetAction(self.betDetails)
    }
    
    @IBAction private func didTapAcceptButton() {
        self.didTapAcceptBetAction(self.betDetails)
    }
    
}

extension BoostedBetConfirmationView {
 
    private static func createSimpleBaseView() -> UIView {
        let view = UIView()
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
    
    private static func createContainerView() -> UIView {
        let view = UIView()
        view.layer.cornerRadius = 24
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
    
    private static func createContainerStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }
    
    private static func createTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = localized("bet_confirmation_reoffer_title")
        label.textAlignment = .center
        label.font = AppFont.with(type: .semibold, size: 18)
        label.numberOfLines = 1
        return label
    }
    
    private static func createSubtitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = ""
        label.textAlignment = .center
        label.font = AppFont.with(type: .semibold, size: 16)
        label.numberOfLines = 0
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        label.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        return label
    }
 
    private static func createValuesStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.spacing = 2
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }
    
    private static func createTopValuesStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }
    
    private static func createBottomValuesView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
    
    private static func createTotalOddTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = localized("total_odd")
        label.textAlignment = .center
        label.font = AppFont.with(type: .semibold, size: 12)
        label.numberOfLines = 1
        return label
    }
    
    private static func createTotalOddValueLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "-.--"
        label.textAlignment = .center
        label.font = AppFont.with(type: .semibold, size: 16)
        label.numberOfLines = 1
        return label
    }
    
    private static func createBetAmountTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = localized("bet_amount")
        label.textAlignment = .center
        label.font = AppFont.with(type: .semibold, size: 12)
        label.numberOfLines = 1
        return label
    }
    
    private static func createBetAmountValueLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "€-.--"
        label.textAlignment = .center
        label.font = AppFont.with(type: .semibold, size: 16)
        label.numberOfLines = 1
        return label
    }
    
    private static func createPossibleWinningTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = localized("possible_winnings")
        label.textAlignment = .center
        label.font = AppFont.with(type: .semibold, size: 12)
        label.numberOfLines = 1
        return label
    }
    
    private static func createPossibleWinningValueLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "€-.--"
        label.textAlignment = .center
        label.font = AppFont.with(type: .semibold, size: 16)
        label.numberOfLines = 1
        return label
    }
    
    private static func createButtonsStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillProportionally
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }
    
    private static func createRejectButton() -> UIButton {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(localized("reject"), for: .normal)
        button.titleLabel?.font = AppFont.with(type: .bold, size: 14)
        return button
    }
    
    private static func createAcceptButton() -> UIButton {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        let buttonTitle = localized("accept")
        button.setTitle(buttonTitle, for: .normal)
        button.titleLabel?.font = AppFont.with(type: .bold, size: 14)
        return button
    }
    
    //
    // ============================================================
    private func setupSubviews() {
        
        self.addSubview(self.containerView)
        
        self.containerView.addSubview(self.containerStackView)
        
        self.titleBaseView.addSubview(self.titleLabel)
        self.subtitleBaseView.addSubview(self.subtitleLabel)
        
        self.containerStackView.addArrangedSubview(self.titleBaseView)
        self.containerStackView.addArrangedSubview(self.subtitleBaseView)
        
        self.valuesStackView.addArrangedSubview(self.topValuesStackView)
        self.valuesStackView.addArrangedSubview(self.simpleLineBaseView)
        self.valuesStackView.addArrangedSubview(self.bottomValuesView)
        self.containerStackView.addArrangedSubview(self.valuesStackView)
        
        self.topValuesStackView.addArrangedSubview(self.totalOddTitleLabel)
        self.topValuesStackView.addArrangedSubview(self.betAmountTitleLabel)
        self.topValuesStackView.addArrangedSubview(self.possibleWinningTitleLabel)

        self.bottomValuesView.addSubview(self.totalOddValueLabel)
        self.bottomValuesView.addSubview(self.betAmountValueLabel)
        self.bottomValuesView.addSubview(self.possibleWinningValueLabel)
        
        self.containerStackView.addArrangedSubview(self.buttonsStackView)
        self.buttonsStackView.addArrangedSubview(self.rejectButton)
        self.buttonsStackView.addArrangedSubview(self.acceptButton)
        
        self.initConstraints()
    }

    private func initConstraints() {

        // Top bar
        NSLayoutConstraint.activate([
            self.containerView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.containerView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            self.containerView.topAnchor.constraint(equalTo: self.topAnchor),
            self.containerView.bottomAnchor.constraint(equalTo: self.bottomAnchor),

            self.containerStackView.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor, constant: 12),
            self.containerStackView.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: -12),
            self.containerStackView.topAnchor.constraint(equalTo: self.containerView.topAnchor, constant: 12),
            self.containerStackView.bottomAnchor.constraint(equalTo: self.containerView.bottomAnchor, constant: -12),
            
            self.titleLabel.leadingAnchor.constraint(equalTo: self.titleBaseView.leadingAnchor, constant: 2),
            self.titleLabel.topAnchor.constraint(equalTo: self.titleBaseView.topAnchor, constant: 4),
            self.titleLabel.centerXAnchor.constraint(equalTo: self.titleBaseView.centerXAnchor),
            self.titleLabel.centerYAnchor.constraint(equalTo: self.titleBaseView.centerYAnchor),

            self.subtitleLabel.leadingAnchor.constraint(equalTo: self.subtitleBaseView.leadingAnchor, constant: 2),
            self.subtitleLabel.topAnchor.constraint(equalTo: self.subtitleBaseView.topAnchor, constant: 4),
            self.subtitleLabel.centerXAnchor.constraint(equalTo: self.subtitleBaseView.centerXAnchor),
            self.subtitleLabel.centerYAnchor.constraint(equalTo: self.subtitleBaseView.centerYAnchor),
            
            self.topValuesStackView.heightAnchor.constraint(equalToConstant: 32),
            self.simpleLineBaseView.heightAnchor.constraint(equalToConstant: 1),
            self.bottomValuesView.heightAnchor.constraint(equalToConstant: 34),
            
            //
            self.totalOddValueLabel.centerXAnchor.constraint(equalTo: self.totalOddTitleLabel.centerXAnchor),
            self.betAmountValueLabel.centerXAnchor.constraint(equalTo: self.betAmountTitleLabel.centerXAnchor),
            self.possibleWinningValueLabel.centerXAnchor.constraint(equalTo: self.possibleWinningTitleLabel.centerXAnchor),
            
            //
            self.acceptButton.heightAnchor.constraint(equalToConstant: 30),
            self.rejectButton.heightAnchor.constraint(equalToConstant: 30),
        ])
    }
}

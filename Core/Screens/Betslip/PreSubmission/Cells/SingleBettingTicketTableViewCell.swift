//
//  SingleBettingTicketTableViewCell.swift
//  Sportsbook
//
//  Created by Ruben Roques on 03/11/2021.
//

import UIKit
import Combine

class SingleBettingTicketTableViewCell: UITableViewCell {

    //TODO: Code Review - A baseView é utilizada como a primeira view da cell, se precisarmos que editar as cells deixar a baseView como root se a mesma existir

    @IBOutlet private weak var stackView: UIStackView!

    @IBOutlet private weak var baseView: UIView!

    @IBOutlet private weak var topBaseView: UIView!
    @IBOutlet private weak var outcomeNameLabel: UILabel!
    @IBOutlet private weak var oddBaseView: UIView!
    @IBOutlet private weak var oddValueLabel: UILabel!

    @IBOutlet private weak var upChangeOddValueImage: UIImageView!
    @IBOutlet private weak var downChangeOddValueImage: UIImageView!

    @IBOutlet private weak var deleteBetButton: UIButton!

    @IBOutlet private weak var separatorView: UIView!

    @IBOutlet private weak var bottomBaseView: UIView!
    @IBOutlet private weak var marketNameLabel: UILabel!
    @IBOutlet private weak var matchDetailLabel: UILabel!
    @IBOutlet private weak var returnsValueLabel: UILabel!

    @IBOutlet private weak var amountBaseView: UIView!
    @IBOutlet private weak var amountTextfield: UITextField!

    @IBOutlet private weak var buttonsBaseView: UIView!
    @IBOutlet private weak var plusOneButtonView: UIButton!
    @IBOutlet private weak var plusFiveButtonView: UIButton!
    @IBOutlet private weak var maxValueButtonView: UIButton!

    @IBOutlet private weak var suspendedBettingOfferView: UIView!
    @IBOutlet private weak var suspendedBettingOfferLabel: UILabel!

    @IBOutlet private weak var errorView: UIView!
    @IBOutlet private weak var errorLabel: UILabel!
    @IBOutlet private weak var errorLogoImageView: UIImageView!

    @IBOutlet private weak var errorLateralTopView: UIView!
    @IBOutlet private weak var errorLateralBottomView: UIView!

    var currentOddValue: Double?
    var bettingTicket: BettingTicket?

    var oddSubscriber: AnyCancellable?
    var oddAvailabilitySubscriber: AnyCancellable?
    var marketPublisherSubscriber: AnyCancellable?
    var cancellables = Set<AnyCancellable>()

    var maxStake: Double?
    var userBalance: Double?

    var currentValue: Int = 0 {
        didSet {
            if let bettingTicket = bettingTicket {
                self.didUpdateBettingValueAction?(bettingTicket.id, self.realBetValue)
            }
        }
    }
    var realBetValue: Double {
        if currentValue == 0 {
            return 0
        }
        else {
            return Double(currentValue)/Double(100)
        }
    }

    var didUpdateBettingValueAction: ((String, Double) -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()

        self.suspendedBettingOfferView.isHidden = true

        self.upChangeOddValueImage.alpha = 0.0
        self.downChangeOddValueImage.alpha = 0.0

        self.amountTextfield.delegate = self
        self.addDoneAccessoryView()

        self.setupWithTheme()

        self.errorView.isHidden = true

    }

    override func layoutSubviews() {
        super.layoutSubviews()

        self.plusOneButtonView.layer.cornerRadius = CornerRadius.view
        self.plusOneButtonView.clipsToBounds = true
        self.plusFiveButtonView.layer.cornerRadius = CornerRadius.view
        self.plusFiveButtonView.clipsToBounds = true
        self.maxValueButtonView.layer.cornerRadius = CornerRadius.view
        self.maxValueButtonView.clipsToBounds = true

        // self.baseView.layer.cornerRadius = CornerRadius.view
        self.oddBaseView.layer.cornerRadius = 3
        self.amountBaseView.layer.cornerRadius = CornerRadius.view

        self.stackView.layer.cornerRadius = CornerRadius.view
        self.stackView.layer.masksToBounds = true
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        self.setupWithTheme()
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        self.currentOddValue = nil

        self.bettingTicket = nil

        self.oddSubscriber?.cancel()
        self.oddSubscriber = nil

        self.oddAvailabilitySubscriber?.cancel()
        self.oddAvailabilitySubscriber = nil

        self.marketPublisherSubscriber?.cancel()
        self.marketPublisherSubscriber = nil
        
        self.didUpdateBettingValueAction = nil
        
        self.currentValue = 0

        self.outcomeNameLabel.text = ""
        self.oddValueLabel.text = ""
        self.marketNameLabel.text = ""
        self.matchDetailLabel.text = ""

        self.amountTextfield.text = nil

        self.suspendedBettingOfferView.isHidden = true
        
        self.endEditing(true)

        self.maxStake = 0
        self.userBalance = 0
    }

    func setupWithTheme() {

        self.backgroundColor = UIColor.clear
        self.backgroundView?.backgroundColor = UIColor.clear
        self.contentView.backgroundColor = UIColor.clear

        self.baseView.backgroundColor = UIColor.App.backgroundSecondary
        
        self.suspendedBettingOfferLabel.textColor =  UIColor.App.textPrimary

        self.topBaseView.backgroundColor = UIColor.App.backgroundSecondary
        self.separatorView.backgroundColor = UIColor.App.separatorLine
        self.bottomBaseView.backgroundColor = UIColor.App.backgroundSecondary
        self.buttonsBaseView.backgroundColor = UIColor.App.backgroundSecondary
        
        self.outcomeNameLabel.textColor = UIColor.App.textPrimary
        self.marketNameLabel.textColor = UIColor.App.textPrimary
        self.matchDetailLabel.textColor = UIColor.App.textDisablePrimary
        self.returnsValueLabel.textColor = UIColor.App.textDisablePrimary
        
        self.oddBaseView.backgroundColor = UIColor.App.backgroundTertiary
        self.oddValueLabel.backgroundColor = UIColor.App.backgroundTertiary
        self.oddValueLabel.textColor = UIColor.App.textPrimary

        self.amountTextfield.font = AppFont.with(type: .semibold, size: 14)
        self.amountTextfield.textColor = UIColor.App.textPrimary
        self.amountTextfield.attributedPlaceholder = NSAttributedString(string: localized("amount"), attributes: [
            NSAttributedString.Key.font: AppFont.with(type: .semibold, size: 14),
            NSAttributedString.Key.foregroundColor: UIColor.App.textDisablePrimary
        ])

        self.amountBaseView.backgroundColor = UIColor.App.backgroundTertiary
        
        self.plusOneButtonView.setBackgroundColor(UIColor.App.backgroundTertiary, for: .normal)
        self.plusOneButtonView.setTitleColor(UIColor.App.textPrimary, for: .normal)
        self.plusOneButtonView.setTitleColor(UIColor.App.textPrimary.withAlphaComponent(0.7), for: .highlighted)

        self.plusFiveButtonView.setBackgroundColor(UIColor.App.backgroundTertiary, for: .normal)
        self.plusFiveButtonView.setTitleColor(UIColor.App.textPrimary, for: .normal)
        self.plusFiveButtonView.setTitleColor(UIColor.App.textPrimary.withAlphaComponent(0.7), for: .highlighted)

        self.maxValueButtonView.setBackgroundColor(UIColor.App.backgroundTertiary, for: .normal)
        self.maxValueButtonView.setTitleColor(UIColor.App.textPrimary, for: .normal)
        self.maxValueButtonView.setTitleColor(UIColor.App.textPrimary.withAlphaComponent(0.7), for: .highlighted)

        self.stackView.backgroundColor = .clear

        self.errorView.backgroundColor = UIColor.App.backgroundCards

        self.errorLabel.textColor = UIColor.App.textPrimary
        self.errorLabel.font = AppFont.with(type: .bold, size: 15)
        self.errorLabel.numberOfLines = 0

        self.errorLogoImageView.image = UIImage(named: "warning_alert_icon")
        self.errorLogoImageView.contentMode = .scaleAspectFit

        self.errorLateralTopView.backgroundColor = UIColor.App.backgroundSecondary
        self.errorLateralBottomView.backgroundColor = UIColor.App.backgroundCards
    }

    func addDoneAccessoryView() {
        let keyboardToolbar = UIToolbar()
        keyboardToolbar.sizeToFit()
        let flexBarButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneBarButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissKeyboard))
        keyboardToolbar.items = [flexBarButton, doneBarButton]
        self.amountTextfield.inputAccessoryView = keyboardToolbar
    }

    @objc func dismissKeyboard() {
        self.endEditing(true)
    }

    func highlightOddChangeUp(animated: Bool = true) {
        self.oddBaseView.layer.borderWidth = 1.5
        UIView.animate(withDuration: animated ? 0.4 : 0.0, delay: 0.0, options: .curveEaseIn, animations: {
            self.upChangeOddValueImage.alpha = 1.0
            self.animateBorderColor(view: self.oddBaseView, color: UIColor.App.alertSuccess, duration: animated ? 0.4 : 0.0)
        }, completion: nil)

        UIView.animate(withDuration: animated ? 0.4 : 0.0, delay: 3.0, options: [.curveEaseIn, .allowUserInteraction], animations: {
            self.upChangeOddValueImage.alpha = 0.0
            self.animateBorderColor(view: self.oddBaseView, color: UIColor.clear, duration: animated ? 0.4 : 0.0)
        }, completion: nil)
    }

    func highlightOddChangeDown(animated: Bool = true) {
        self.oddBaseView.layer.borderWidth = 1.5
        UIView.animate(withDuration: animated ? 0.4 : 0.0, delay: 0.0, options: .curveEaseIn, animations: {
            self.downChangeOddValueImage.alpha = 1.0
            self.animateBorderColor(view: self.oddBaseView, color: UIColor.App.alertError, duration: animated ? 0.4 : 0.0)
        }, completion: nil)

        UIView.animate(withDuration: animated ? 0.4 : 0.0, delay: 3.0, options: [.curveEaseIn, .allowUserInteraction], animations: {
            self.downChangeOddValueImage.alpha = 0.0
            self.animateBorderColor(view: self.oddBaseView, color: UIColor.clear, duration: animated ? 0.4 : 0.0)
        }, completion: nil)
    }

    func configureWithBettingTicket(_ bettingTicket: BettingTicket, previousBettingAmount: Double? = nil, errorBetting: String? = nil) {

        self.bettingTicket = bettingTicket
        self.outcomeNameLabel.text = bettingTicket.outcomeDescription
        self.oddValueLabel.text = "\(Double(floor(bettingTicket.value * 100)/100))"
        self.marketNameLabel.text = bettingTicket.marketDescription
        self.matchDetailLabel.text = bettingTicket.matchDescription

        self.returnsValueLabel.text = "--"

        self.currentOddValue = bettingTicket.value

        if let previousBettingAmount = previousBettingAmount {
            self.currentValue = 0
            self.addAmountValue(previousBettingAmount)
        }

        self.oddSubscriber = Env.everyMatrixStorage
            .oddPublisherForBettingOfferId(bettingTicket.id)?
            .map(\.oddsValue)
            .compactMap({ $0 })
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] newOddValue in

                if let currentOddValue = self?.currentOddValue {
                    if newOddValue > currentOddValue {
                        self?.highlightOddChangeUp()
                    }
                    else if newOddValue < currentOddValue {
                        self?.highlightOddChangeDown()
                    }
                }
                
                self?.currentOddValue = newOddValue
                self?.oddValueLabel.text = OddFormatter.formatOdd(withValue: newOddValue)
            })
        
        if let bettingOfferPublisher = Env.everyMatrixStorage.oddPublisherForBettingOfferId(bettingTicket.id),
           let marketPublisher = Env.everyMatrixStorage.marketsPublishers[bettingTicket.marketId] {
            
            self.oddAvailabilitySubscriber = Publishers.CombineLatest(bettingOfferPublisher, marketPublisher)
                .receive(on: DispatchQueue.main)
                .eraseToAnyPublisher()
                .map({ bettingOffer, market in
                    return (bettingOffer.isAvailable ?? true, market.isAvailable ?? true)
                })
                .sink(receiveValue: { [weak self] bettingOfferIsAvailable, marketIsAvailable in
                    self?.suspendedBettingOfferView.isHidden =  bettingOfferIsAvailable && marketIsAvailable
                })
        }
        
        if let errorBetting = errorBetting {
            self.errorLabel.text = errorBetting
            self.errorView.isHidden = false

            self.errorLateralTopView.backgroundColor = UIColor.App.alertError
            self.errorLateralBottomView.backgroundColor = UIColor.App.alertError

            // TODO: Code Review - se a errorView for nil a app crasha
            NSLayoutConstraint(item: self.errorView,
                               attribute: NSLayoutConstraint.Attribute.height,
                               relatedBy: NSLayoutConstraint.Relation.equal,
                               toItem: self.errorLabel,
                               attribute: NSLayoutConstraint.Attribute.height,
                               multiplier: 1,
                               constant: 24).isActive = true
        }
        else {
            self.errorLabel.text = ""
            self.errorView.isHidden = true

            self.errorLateralTopView.backgroundColor = UIColor.App.backgroundSecondary
            self.errorLateralBottomView.backgroundColor = UIColor.App.backgroundSecondary
        }

        Env.betslipManager.simpleBetslipSelectionStateList
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] betslipStateList in

                if let bettingTicketId = self?.bettingTicket?.bettingId, let betslipState = betslipStateList[bettingTicketId].value {
                    self?.maxStake = betslipState.maxStake

                }
            })
            .store(in: &cancellables)

        Env.userSessionStore.userBalanceWallet
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] wallet in
                self?.userBalance = wallet?.amount
            })
            .store(in: &cancellables)

    }

    @IBAction private func didTapDeleteButton() {
        if let bettingTicket = self.bettingTicket {
            Env.betslipManager.removeBettingTicket(bettingTicket)
            Env.betslipManager.removeAllPlacedDetailsError()
            Env.betslipManager.removeAllBetslipPlacedBetErrorResponse()
        }
    }

    @IBAction private func didTapPlusOneButton() {
        self.addAmountValue(1.0)
    }

    @IBAction private func didTapPlusFiveButton() {
        self.addAmountValue(5.0)
    }

    @IBAction private func didTapPlusMaxButton() {
        var maxAmountPossible = 0.0

        if let userBalance = self.userBalance,
           let maxStake = self.maxStake {
            if userBalance < maxStake {
                maxAmountPossible = userBalance
            }
            else {
                maxAmountPossible = maxStake
            }
        }

        self.addAmountValue(maxAmountPossible, isMax: true)
    }

}

extension SingleBettingTicketTableViewCell: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        self.updateAmountValue(string)
        return false
    }

    func addAmountValue(_ value: Double, isMax: Bool = false) {

        if !isMax {
            currentValue += Int(value * 100.0)
        }
        else {
            currentValue = Int(value * 100.0)
        }

//        if let maxStake = self.maxStake {
//            let maxStakeInt = Int(maxStake * 100.0)
//            if currentValue > maxStakeInt {
//                currentValue = maxStakeInt
//            }
//        }
//
//        if let maxUserBalance = self.userBalance {
//            let maxUserBalanceInt = Int(maxUserBalance * 100.0)
//            if currentValue > maxUserBalanceInt {
//                currentValue = maxUserBalanceInt
//            }
//        }

        let calculatedAmount = Double(currentValue/100) + Double(currentValue%100)/100
        amountTextfield.text = CurrencyFormater.defaultFormat.string(from: NSNumber(value: calculatedAmount))
    }

    func updateAmountValue(_ newValue: String) {
        if let insertedDigit = Int(newValue) {
            currentValue = currentValue * 10 + insertedDigit
        }
        if newValue == "" {
            currentValue /= 10
        }
        let calculatedAmount = Double(currentValue/100) + Double(currentValue%100)/100
        amountTextfield.text = CurrencyFormater.defaultFormat.string(from: NSNumber(value: calculatedAmount))
    }

}

extension SingleBettingTicketTableViewCell {
    private func animateBorderColor(view: UIView, color: UIColor, duration: Double) {
        let animation = CABasicAnimation(keyPath: "borderColor")
        animation.fromValue = layer.borderColor
        animation.toValue = color.cgColor
        animation.duration = duration
        view.layer.add(animation, forKey: "borderColor")
        view.layer.borderColor = color.cgColor
    }
}

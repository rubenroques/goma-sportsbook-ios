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

    @IBOutlet private weak var oddsStackView: UIStackView!

    private lazy var oldOddLabel: UILabel = Self.createOldOddLabel()

    private lazy var bonusStackView: UIStackView = Self.createBonusStackView()

    private lazy var freeBetView: BonusSwitchView = Self.createFreeBetView()

    private lazy var oddsBoostView: BonusSwitchView = Self.createOddsBoostView()

    private var currentBoostedOddPercentage: Double = 0

    var showBonusInfo: Bool = false {
        didSet {
            if showBonusInfo {
                self.bonusStackView.isHidden = false
            }
            else {
                self.bonusStackView.isHidden = true
            }
        }
    }

    var showFreeBetInfo: Bool = false {
        didSet {
            if showFreeBetInfo {
                self.freeBetView.isHidden = false
            }
            else {
                self.freeBetView.isHidden = true
            }
        }
    }

    var showOddsBoostInfo: Bool = false {
        didSet {
            if showOddsBoostInfo {
                self.oddsBoostView.isHidden = false
            }
            else {
                self.oddsBoostView.isHidden = true
            }
        }
    }

    var shouldHighlightTextfield: () -> Bool = { return false }

    var isFreeBetSelected: ((Bool) -> Void)?
    var isOddsBoostSelected: ((Bool) -> Void)?

    var currentOddValue: Double?
    var bettingTicket: BettingTicket?

    var oddSubscriber: AnyCancellable?
    var oddAvailabilitySubscriber: AnyCancellable?
    var marketPublisherSubscriber: AnyCancellable?
    var walletUpdatesSubscriber: AnyCancellable?

    private var userBalance: Double?

    private var maxBetValue: Double {
        if let userWallet = Env.userSessionStore.userWalletPublisher.value {
            return userWallet.total
        }
        else {
            return 0
        }
    }

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

        self.amountBaseView.backgroundColor = UIColor.App.backgroundPrimary

        self.amountBaseView.layer.cornerRadius = 10.0
        self.amountBaseView.layer.borderWidth = 2
        self.amountBaseView.layer.borderColor = UIColor.App.backgroundBorder.cgColor

        self.amountTextfield.delegate = self

        self.addDoneAccessoryView()

        self.setupWithTheme()

        self.errorView.isHidden = true

        self.showFreeBetInfo = false
        self.showBonusInfo = false

        self.oddsBoostView.isHidden = true

        self.plusOneButtonView.setTitle("+10", for: .normal)
        self.plusFiveButtonView.setTitle("+20", for: .normal)
        self.maxValueButtonView.setTitle("+50", for: .normal)

        self.suspendedBettingOfferLabel.text = localized("suspended")
        self.setupSubviews()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        self.plusOneButtonView.layer.cornerRadius = CornerRadius.view
        self.plusOneButtonView.clipsToBounds = true
        self.plusFiveButtonView.layer.cornerRadius = CornerRadius.view
        self.plusFiveButtonView.clipsToBounds = true
        self.maxValueButtonView.layer.cornerRadius = CornerRadius.view
        self.maxValueButtonView.clipsToBounds = true

        self.baseView.layer.cornerRadius = CornerRadius.view
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

        self.userBalance = 0

        self.freeBetView.isSwitchOn = false
        self.oddsBoostView.isSwitchOn = false

        self.oldOddLabel.text = ""
        self.currentBoostedOddPercentage = 0

        self.buttonsBaseView.isUserInteractionEnabled = true

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
        self.matchDetailLabel.textColor = UIColor.App.textSecondary
        self.returnsValueLabel.textColor = UIColor.App.textPrimary
        
        self.oddBaseView.backgroundColor = UIColor.App.backgroundPrimary
        self.oddValueLabel.backgroundColor = UIColor.App.backgroundPrimary
        self.oddValueLabel.textColor = UIColor.App.textPrimary

        self.amountTextfield.font = AppFont.with(type: .semibold, size: 14)
        self.amountTextfield.textColor = UIColor.App.textPrimary
        self.amountTextfield.attributedPlaceholder = NSAttributedString(string: localized("amount"), attributes: [
            NSAttributedString.Key.font: AppFont.with(type: .semibold, size: 14),
            NSAttributedString.Key.foregroundColor: UIColor.App.inputTextTitle
        ])

        self.amountBaseView.backgroundColor = UIColor.App.backgroundPrimary
        self.amountBaseView.layer.borderColor = UIColor.App.backgroundBorder.cgColor

        self.plusOneButtonView.setBackgroundColor(UIColor.App.backgroundBorder, for: .normal)
        self.plusOneButtonView.setTitleColor(UIColor.App.textPrimary, for: .normal)
        self.plusOneButtonView.setTitleColor(UIColor.App.textPrimary.withAlphaComponent(0.7), for: .highlighted)

        self.plusFiveButtonView.setBackgroundColor(UIColor.App.backgroundBorder, for: .normal)
        self.plusFiveButtonView.setTitleColor(UIColor.App.textPrimary, for: .normal)
        self.plusFiveButtonView.setTitleColor(UIColor.App.textPrimary.withAlphaComponent(0.7), for: .highlighted)

        self.maxValueButtonView.setBackgroundColor(UIColor.App.backgroundBorder, for: .normal)
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

        self.bonusStackView.backgroundColor = .clear

        self.oldOddLabel.textColor = UIColor.App.textPrimary
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

    func configureWithBettingTicket(_ bettingTicket: BettingTicket,
                                    previousBettingAmount: Double? = nil,
                                    errorBetting: String? = nil,
                                    shouldHighlightTextfield: Bool = false) {

        self.bettingTicket = bettingTicket
        self.outcomeNameLabel.text = bettingTicket.outcomeDescription

        let newOddValue = Double(round(bettingTicket.decimalOdd * 100)/100)
        self.oddValueLabel.text = OddFormatter.formatOdd(withValue: newOddValue)

        self.marketNameLabel.text = bettingTicket.marketDescription
        self.matchDetailLabel.text = bettingTicket.matchDescription

        self.returnsValueLabel.text = "--"

        self.currentOddValue = bettingTicket.decimalOdd

        if let previousBettingAmount = previousBettingAmount {
            self.currentValue = 0
            self.addAmountValue(previousBettingAmount)
        }

        self.oddAvailabilitySubscriber?.cancel()
        self.oddAvailabilitySubscriber = nil

        self.oddAvailabilitySubscriber = Env.betslipManager.bettingTicketPublisher(withId: bettingTicket.id)?
            .receive(on: DispatchQueue.main)
            .map({ bettingOfferValue in
                return bettingOfferValue.isAvailable
            })
            .removeDuplicates()
            .sink(receiveValue: { [weak self] isBetAvailable in
                self?.suspendedBettingOfferView.isHidden = isBetAvailable
            })

        self.oddSubscriber?.cancel()
        self.oddSubscriber = nil

        self.oddSubscriber = Env.betslipManager.bettingTicketPublisher(withId: bettingTicket.id)?
            .removeDuplicates(by: { lhs, rhs in
                return lhs.id == rhs.id && lhs.decimalOdd == rhs.decimalOdd
            })
            .map(\.decimalOdd)
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
                // self?.oddValueLabel.text = OddFormatter.formatOdd(withValue: newOddValue)

                if let currentBoostedOddPercentage = self?.currentBoostedOddPercentage, currentBoostedOddPercentage != 0 {
                    let boostedValue = newOddValue + (newOddValue * currentBoostedOddPercentage)

                    let possibleWinnings = boostedValue * (self?.realBetValue ?? 0)
                    let possibleWinningsString = CurrencyFormater.defaultFormat.string(from: NSNumber(value: possibleWinnings)) ?? "-.--€"
                    self?.returnsValueLabel.text = possibleWinningsString

                    //self?.oddValueLabel.text = OddConverter.stringForValue(boostedValue, format: UserDefaults.standard.userOddsFormat)
                    self?.oddValueLabel.text = OddFormatter.formatOdd(withValue: boostedValue)
                    self?.refreshPossibleWinnings()
                }
                else {
                    // self?.oddValueLabel.text = OddConverter.stringForValue(newOddValue, format: UserDefaults.standard.userOddsFormat)
                    self?.oddValueLabel.text = OddFormatter.formatOdd(withValue: newOddValue)
                    self?.refreshPossibleWinnings()
                }

            })

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

        self.walletUpdatesSubscriber?.cancel()
        self.walletUpdatesSubscriber = Env.userSessionStore.userWalletPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] wallet in
                self?.userBalance = wallet?.total
            })

        if shouldHighlightTextfield {
            self.amountBaseView.layer.borderColor = UIColor.App.highlightPrimary.cgColor
        }
        else {
            if self.amountTextfield.isFirstResponder {
                self.amountBaseView.layer.borderColor = UIColor.App.inputBorderActive.cgColor
            }
            else {
                self.amountBaseView.layer.borderColor = UIColor.App.backgroundBorder.cgColor
            }
        }

    }

    func setupFreeBetInfo(freeBet: BetslipFreebet, isSwitchOn: Bool = false) {
        self.freeBetView.setupBonusInfo(freeBet: freeBet, oddsBoost: nil, bonusType: .freeBet)

        if isSwitchOn {
            self.freeBetView.isSwitchOn = true
            self.buttonsBaseView.isUserInteractionEnabled = false
        }

        self.freeBetView.didTappedSwitch = { [weak self] isSwitchOn in
            if isSwitchOn {
                self?.currentValue = Int(freeBet.freeBetAmount * 100.0)
                self?.amountTextfield.text = CurrencyFormater.defaultFormat.string(from: NSNumber(value: freeBet.freeBetAmount))
                self?.buttonsBaseView.isUserInteractionEnabled = false
                self?.isFreeBetSelected?(true)
            }
            else {
                self?.currentValue = 0
                self?.amountTextfield.text = CurrencyFormater.defaultFormat.string(from: NSNumber(value: 0))
                self?.buttonsBaseView.isUserInteractionEnabled = true
                self?.isFreeBetSelected?(false)
            }
        }

        self.freeBetView.isHidden = false
    }

    func setupOddsBoostInfo(oddsBoost: BetslipOddsBoost, isSwitchOn: Bool = false) {
        self.oddsBoostView.setupBonusInfo(freeBet: nil, oddsBoost: oddsBoost, bonusType: .oddsBoost)

        self.oldOddLabel.isHidden = true

        self.currentBoostedOddPercentage = 0

        if isSwitchOn {
            self.oddsBoostView.isSwitchOn = true
            self.oldOddLabel.isHidden = false

            if let currentOddValue = self.currentOddValue {

                // Update current odd boost percentage
                self.currentBoostedOddPercentage = oddsBoost.oddsBoostPercent

                // Sets old odd value
                //let oldValueConverted = OddConverter.stringForValue(currentOddValue, format: UserDefaults.standard.userOddsFormat)
                let oldValueConverted = OddFormatter.formatOdd(withValue: currentOddValue)

                let attributeString: NSMutableAttributedString = NSMutableAttributedString(string: oldValueConverted)
                    attributeString.addAttribute(NSAttributedString.Key.strikethroughStyle,
                                                 value: 2,
                                                 range: NSRange(location: 0, length: attributeString.length))

                // Updates current odd value
                let boostedValue = currentOddValue + (currentOddValue * oddsBoost.oddsBoostPercent)

                // let boostedValueConverted = OddConverter.stringForValue(boostedValue, format: UserDefaults.standard.userOddsFormat)
                let boostedValueConverted = OddFormatter.formatOdd(withValue: boostedValue)

                self.oldOddLabel.attributedText = attributeString
                self.oddValueLabel.text = boostedValueConverted

                self.refreshPossibleWinnings()
            }

        }

        self.oddsBoostView.didTappedSwitch = { [weak self] isSwitchOn in
            if isSwitchOn {
                self?.isOddsBoostSelected?(true)
            }
            else {
                self?.isOddsBoostSelected?(false)
                self?.oldOddLabel.isHidden = true
            }
        }

        self.oddsBoostView.isHidden = false
    }

    @IBAction private func didTapDeleteButton() {
        if let bettingTicket = self.bettingTicket {
            Env.betslipManager.removeBettingTicket(bettingTicket)
        }
    }

    @IBAction private func didTapPlusOneButton() {
        self.addAmountValue(10.0)
    }

    @IBAction private func didTapPlusFiveButton() {
        self.addAmountValue(20.0)
    }

    @IBAction private func didTapPlusMaxButton() {
        self.addAmountValue(50.0)
    }

    func refreshPossibleWinnings() {

        if let currentOddValue = currentOddValue {

            let boostedValue = currentOddValue * (1 + self.currentBoostedOddPercentage)

            let possibleWinnings = boostedValue * self.realBetValue
            let possibleWinningsString = CurrencyFormater.defaultFormat.string(from: NSNumber(value: possibleWinnings)) ?? "-.--€"
            self.returnsValueLabel.text = possibleWinningsString
        }
        else {
            self.returnsValueLabel.text = localized("no_value")
        }
    }

}

extension SingleBettingTicketTableViewCell: UITextFieldDelegate {

    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if self.shouldHighlightTextfield() {
            self.amountBaseView.layer.borderColor = UIColor.App.highlightPrimary.cgColor
            return true // If the isFreebetEnabled the border should stay orange
        }

        if textField == self.amountTextfield {
            self.amountBaseView.layer.borderColor = UIColor.App.inputBorderActive.cgColor
        }
        return true
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        if self.shouldHighlightTextfield() {
            self.amountBaseView.layer.borderColor = UIColor.App.highlightPrimary.cgColor
            return // If the isFreebetEnabled the border should stay orange
        }
        if textField == self.amountTextfield {
            self.amountBaseView.layer.borderColor = UIColor.App.inputBorderActive.cgColor
        }
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        if self.shouldHighlightTextfield() {
            self.amountBaseView.layer.borderColor = UIColor.App.highlightPrimary.cgColor
            return // If the isFreebetEnabled the border should stay orange
        }
        if textField == self.amountTextfield {
            self.amountBaseView.layer.borderColor = UIColor.App.backgroundBorder.cgColor
        }
    }

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

        let calculatedAmount = Double(currentValue/100) + Double(currentValue%100)/100
        self.amountTextfield.text = CurrencyFormater.defaultFormat.string(from: NSNumber(value: calculatedAmount))

        self.refreshPossibleWinnings()
    }

    func updateAmountValue(_ newValue: String) {
        if let insertedDigit = Int(newValue) {
            currentValue = currentValue * 10 + insertedDigit
        }
        if newValue == "" {
            currentValue /= 10
        }
        let calculatedAmount = Double(currentValue/100) + Double(currentValue%100)/100
        self.amountTextfield.text = CurrencyFormater.defaultFormat.string(from: NSNumber(value: calculatedAmount))

        self.refreshPossibleWinnings()
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

//
// MARK: Subviews initialization and setup
//
extension SingleBettingTicketTableViewCell {

    private static func createBonusStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 4
        return stackView
    }

    private static func createFreeBetView() -> BonusSwitchView {
        let bonusSwitchView = BonusSwitchView()
        bonusSwitchView.translatesAutoresizingMaskIntoConstraints = false
        return bonusSwitchView
    }

    private static func createOddsBoostView() -> BonusSwitchView {
        let bonusSwitchView = BonusSwitchView()
        bonusSwitchView.translatesAutoresizingMaskIntoConstraints = false
        return bonusSwitchView
    }

    private static func createOldOddLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = ""
        label.font = AppFont.with(type: .bold, size: 11)
        return label
    }

    private func setupSubviews() {
        self.stackView.addArrangedSubview(self.bonusStackView)

        self.bonusStackView.addArrangedSubview(self.freeBetView)
        self.bonusStackView.addArrangedSubview(self.oddsBoostView)

        self.oddsStackView.addArrangedSubview(self.oldOddLabel)

        self.initConstraints()
    }

    private func initConstraints() {

        // Bonus stack view
        NSLayoutConstraint.activate([
            self.bonusStackView.leadingAnchor.constraint(equalTo: self.stackView.leadingAnchor),
            self.bonusStackView.trailingAnchor.constraint(equalTo: self.stackView.trailingAnchor)
        ])

    }

}

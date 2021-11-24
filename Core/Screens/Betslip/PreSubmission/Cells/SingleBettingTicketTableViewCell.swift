//
//  SingleBettingTicketTableViewCell.swift
//  Sportsbook
//
//  Created by Ruben Roques on 03/11/2021.
//

import UIKit
import Combine

class SingleBettingTicketTableViewCell: UITableViewCell {

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

    var currentOddValue: Double?
    var bettingTicket: BettingTicket?

    var oddSubscriber: AnyCancellable?

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

        self.upChangeOddValueImage.alpha = 0.0
        self.downChangeOddValueImage.alpha = 0.0

        self.amountTextfield.delegate = self
        self.addDoneAccessoryView()

        self.setupWithTheme()
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

        self.didUpdateBettingValueAction = nil
        
        self.currentValue = 0

        self.outcomeNameLabel.text = ""
        self.oddValueLabel.text = ""
        self.marketNameLabel.text = ""
        self.matchDetailLabel.text = ""

        self.amountTextfield.text = nil
        self.endEditing(true)
    }

    func setupWithTheme() {

        self.backgroundColor = UIColor.clear
        self.backgroundView?.backgroundColor = UIColor.clear
        self.contentView.backgroundColor = UIColor.clear

        self.baseView.backgroundColor = UIColor.App.secondaryBackground

        self.topBaseView.backgroundColor = UIColor.App.secondaryBackground
        self.separatorView.backgroundColor = UIColor.App.separatorLine
        self.bottomBaseView.backgroundColor = UIColor.App.secondaryBackground
        self.buttonsBaseView.backgroundColor = UIColor.App.secondaryBackground
        
        self.outcomeNameLabel.textColor = UIColor.App.headingMain
        self.oddValueLabel.textColor = UIColor.App.headingMain
        self.marketNameLabel.textColor = UIColor.App.headingMain
        self.matchDetailLabel.textColor = UIColor.App.headingDisabled
        self.returnsValueLabel.textColor = UIColor.App.headingDisabled

        self.amountTextfield.font = AppFont.with(type: .semibold, size: 14)
        self.amountTextfield.textColor = UIColor.App.headingMain
        self.amountTextfield.attributedPlaceholder = NSAttributedString(string: "Amount", attributes: [
            NSAttributedString.Key.font: AppFont.with(type: .semibold, size: 14),
            NSAttributedString.Key.foregroundColor: UIColor.App.headingDisabled
        ])

        self.amountBaseView.backgroundColor = UIColor.App.tertiaryBackground
        
        self.plusOneButtonView.setBackgroundColor(UIColor.App.tertiaryBackground, for: .normal)
        self.plusOneButtonView.setTitleColor(UIColor.App.headingMain, for: .normal)
        self.plusOneButtonView.setTitleColor(UIColor.App.headingMain.withAlphaComponent(0.7), for: .highlighted)

        self.plusFiveButtonView.setBackgroundColor(UIColor.App.tertiaryBackground, for: .normal)
        self.plusFiveButtonView.setTitleColor(UIColor.App.headingMain, for: .normal)
        self.plusFiveButtonView.setTitleColor(UIColor.App.headingMain.withAlphaComponent(0.7), for: .highlighted)

        self.maxValueButtonView.setBackgroundColor(UIColor.App.tertiaryBackground, for: .normal)
        self.maxValueButtonView.setTitleColor(UIColor.App.headingMain, for: .normal)
        self.maxValueButtonView.setTitleColor(UIColor.App.headingMain.withAlphaComponent(0.7), for: .highlighted)

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

    func configureWithBettingTicket(_ bettingTicket: BettingTicket, previousBettingAmount: Double? = nil) {
        self.bettingTicket = bettingTicket
        self.outcomeNameLabel.text = bettingTicket.outcomeDescription
        self.oddValueLabel.text = "\(Double(floor(bettingTicket.value * 100)/100))"
        self.marketNameLabel.text = bettingTicket.marketDescription
        self.matchDetailLabel.text = bettingTicket.matchDescription

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
                self?.oddValueLabel.text = "\(Double(floor(newOddValue * 100)/100))"
            })

    }

    @IBAction private func didTapDeleteButton() {
        if let bettingTicket = self.bettingTicket {
            Env.betslipManager.removeBettingTicket(bettingTicket)
        }
    }

    @IBAction private func didTapPlusOneButton() {
        self.addAmountValue(1.0)
    }

    @IBAction private func didTapPlusFiveButton() {
        self.addAmountValue(5.0)
    }

    @IBAction private func didTapPlusMaxButton() {
        self.addAmountValue(100.0)
    }

}

extension SingleBettingTicketTableViewCell: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        self.updateAmountValue(string)
        return false
    }

    func addAmountValue(_ value: Double) {
        currentValue += Int(value * 100.0)

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

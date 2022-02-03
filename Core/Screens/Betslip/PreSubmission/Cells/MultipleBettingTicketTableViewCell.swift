//
//  MultipleBettingTicketTableViewCell.swift
//  Sportsbook
//
//  Created by Ruben Roques on 04/11/2021.
//

import UIKit
import Combine

class MultipleBettingTicketTableViewCell: UITableViewCell {

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

    @IBOutlet private weak var stackView: UIStackView!

    @IBOutlet private weak var suspendedBettingOfferView: UIView!
    @IBOutlet private weak var suspendedBettingOfferLabel: UILabel!

    @IBOutlet private weak var errorView: UIView!
    @IBOutlet private weak var errorLabel: UILabel!

    @IBOutlet private weak var errorLateralTopView: UIView!
    @IBOutlet private weak var errorLateralBottomView: UIView!

    var currentOddValue: Double?
    var bettingTicket: BettingTicket?

    var oddSubscriber: AnyCancellable?
    var oddAvailabilitySubscriber: AnyCancellable?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code

        self.suspendedBettingOfferView.isHidden = true
        
        self.upChangeOddValueImage.alpha = 0.0
        self.downChangeOddValueImage.alpha = 0.0

        self.setupWithTheme()

        self.stackView.layer.cornerRadius = CornerRadius.view
        self.stackView.layer.masksToBounds = true

        self.errorView.isHidden = true

    }

    override func layoutSubviews() {
        super.layoutSubviews()

        self.oddBaseView.layer.cornerRadius = 3

        self.stackView.layer.cornerRadius = CornerRadius.view

    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        self.setupWithTheme()
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        self.oddSubscriber?.cancel()
        self.oddSubscriber = nil
        
        self.oddAvailabilitySubscriber?.cancel()
        self.oddAvailabilitySubscriber = nil
        
        self.suspendedBettingOfferView.isHidden = true
        self.bettingTicket = nil

        self.outcomeNameLabel.text = ""
        self.oddValueLabel.text = ""
        self.marketNameLabel.text = ""
        self.matchDetailLabel.text = ""
    }

    func setupWithTheme() {

        self.backgroundColor = UIColor.clear
        self.backgroundView?.backgroundColor = UIColor.clear
        self.contentView.backgroundColor = UIColor.clear

        self.baseView.backgroundColor = UIColor.App2.backgroundCards

        self.topBaseView.backgroundColor = UIColor.App2.backgroundSecondary
        self.separatorView.backgroundColor = UIColor.App2.separatorLine
        self.bottomBaseView.backgroundColor = UIColor.App2.backgroundSecondary

        self.outcomeNameLabel.textColor = UIColor.App2.textPrimary
        self.oddValueLabel.textColor = UIColor.App2.textPrimary
        self.marketNameLabel.textColor = UIColor.App2.textPrimary
        self.matchDetailLabel.textColor = UIColor.App2.textPrimary

        self.stackView.backgroundColor = UIColor.App2.backgroundSecondary

        self.errorView.backgroundColor = UIColor.App2.backgroundSecondary

        self.errorLabel.textColor = UIColor.App2.textPrimary
        self.errorLabel.font = AppFont.with(type: .bold, size: 15)

        self.errorLateralTopView.backgroundColor = UIColor.App2.backgroundSecondary
        self.errorLateralBottomView.backgroundColor = UIColor.App2.backgroundSecondary

    }

    func highlightOddChangeUp(animated: Bool = true) {
        self.oddBaseView.layer.borderWidth = 1.5
        UIView.animate(withDuration: animated ? 0.4 : 0.0, delay: 0.0, options: .curveEaseIn, animations: {
            self.upChangeOddValueImage.alpha = 1.0
            self.animateBorderColor(view: self.oddBaseView, color: UIColor.App2.alertSuccess, duration: animated ? 0.4 : 0.0)
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
            self.animateBorderColor(view: self.oddBaseView, color: UIColor.App2.alertError, duration: animated ? 0.4 : 0.0)
        }, completion: nil)

        UIView.animate(withDuration: animated ? 0.4 : 0.0, delay: 3.0, options: [.curveEaseIn, .allowUserInteraction], animations: {
            self.downChangeOddValueImage.alpha = 0.0
            self.animateBorderColor(view: self.oddBaseView, color: UIColor.clear, duration: animated ? 0.4 : 0.0)
        }, completion: nil)
    }

    func configureWithBettingTicket(_ bettingTicket: BettingTicket, errorBetting: String? = nil) {
        self.bettingTicket = bettingTicket
        self.outcomeNameLabel.text = bettingTicket.outcomeDescription
        self.oddValueLabel.text = "\(Double(floor(bettingTicket.value * 100)/100))"
        self.marketNameLabel.text = bettingTicket.marketDescription
        self.matchDetailLabel.text = bettingTicket.matchDescription

        self.currentOddValue = bettingTicket.value

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

        if errorBetting != nil {
            self.errorLateralTopView.backgroundColor = UIColor.App2.alertError
            self.errorLateralBottomView.backgroundColor = UIColor.App2.alertError
        }
        else {
            self.errorLateralTopView.backgroundColor = UIColor.App2.backgroundSecondary
            self.errorLateralBottomView.backgroundColor = UIColor.App2.backgroundSecondary
        }
    }

    @IBAction private func didTapDeleteButton() {
        if let bettingTicket = self.bettingTicket {
            Env.betslipManager.removeBettingTicket(bettingTicket)
            Env.betslipManager.removeAllPlacedDetailsError()
            Env.betslipManager.removeAllBetslipPlacedBetErrorResponse()
        }
    }

}

extension MultipleBettingTicketTableViewCell {
    private func animateBorderColor(view: UIView, color: UIColor, duration: Double) {
        let animation = CABasicAnimation(keyPath: "borderColor")
        animation.fromValue = layer.borderColor
        animation.toValue = color.cgColor
        animation.duration = duration
        view.layer.add(animation, forKey: "borderColor")
        view.layer.borderColor = color.cgColor
    }
}

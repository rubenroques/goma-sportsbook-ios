//
//  BannerMatchCollectionViewCell.swift
//  Sportsbook
//
//  Created by Ruben Roques on 12/10/2021.
//

import UIKit
import Combine
import ServicesProvider

class BannerMatchCollectionViewCell: UICollectionViewCell {

    @IBOutlet private weak var baseView: UIView!

    //
    @IBOutlet private weak var imageBaseView: UIView!
    @IBOutlet private weak var imageView: UIImageView!

    @IBOutlet private weak var matchBaseView: UIView!
    @IBOutlet private weak var matchOffuscationView: UIView!
    @IBOutlet private weak var matchGradientView: UIView!
    @IBOutlet private weak var centerView: UIView!

    @IBOutlet private weak var participantsBaseView: UIView!

    @IBOutlet private weak var homeParticipantNameLabel: UILabel!
    @IBOutlet private weak var awayParticipantNameLabel: UILabel!

    @IBOutlet private weak var dateLabel: UILabel!
    @IBOutlet private weak var timeLabel: UILabel!

    @IBOutlet private weak var oddsStackView: UIStackView!

    @IBOutlet private weak var homeBaseView: UIView!
    @IBOutlet private weak var homeOddTitleLabel: UILabel!
    @IBOutlet private weak var homeOddValueLabel: UILabel!

    @IBOutlet private weak var drawBaseView: UIView!
    @IBOutlet private weak var drawOddTitleLabel: UILabel!
    @IBOutlet private weak var drawOddValueLabel: UILabel!

    @IBOutlet private weak var awayBaseView: UIView!
    @IBOutlet private weak var awayOddTitleLabel: UILabel!
    @IBOutlet private weak var awayOddValueLabel: UILabel!

    var cancellables = Set<AnyCancellable>()

    var viewModel: BannerCellViewModel?

    var matchViewModel: MatchWidgetCellViewModel? {
        didSet {
            if let matchViewModelValue = self.matchViewModel {
                self.setupWithMatchViewModel(matchWidgetCellViewModel: matchViewModelValue)
            }
        }
    }

    var completeMatch: Match?

    var didTapBannerViewAction: ((BannerCellViewModel.PresentationType, BannerSpecialAction?) -> Void)?
    var didLongPressOdd: ((BettingTicket) -> Void)?

    private var leftOutcome: Outcome?
    private var middleOutcome: Outcome?
    private var rightOutcome: Outcome?

    private var leftOddButtonSubscriber: AnyCancellable?
    private var middleOddButtonSubscriber: AnyCancellable?
    private var rightOddButtonSubscriber: AnyCancellable?

    private var isLeftOutcomeButtonSelected: Bool = false {
        didSet {
            self.isLeftOutcomeButtonSelected ? self.selectLeftOddButton() : self.deselectLeftOddButton()
        }
    }
    private var isMiddleOutcomeButtonSelected: Bool = false {
        didSet {
            self.isMiddleOutcomeButtonSelected ? self.selectMiddleOddButton() : self.deselectMiddleOddButton()
        }
    }
    private var isRightOutcomeButtonSelected: Bool = false {
        didSet {
            self.isRightOutcomeButtonSelected ? self.selectRightOddButton() : self.deselectRightOddButton()
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        self.bringSubviewToFront(self.matchBaseView)
  
        // Setup fonts
        self.homeOddValueLabel.font = AppFont.with(type: .heavy, size: 13)
        self.homeOddTitleLabel.font = AppFont.with(type: .medium, size: 11)
        
        self.drawOddValueLabel.font = AppFont.with(type: .heavy, size: 13)
        self.drawOddTitleLabel.font = AppFont.with(type: .medium, size: 11)
        
        self.awayOddValueLabel.font = AppFont.with(type: .heavy, size: 13)
        self.awayOddTitleLabel.font = AppFont.with(type: .medium, size: 11)
        
        self.dateLabel.font = AppFont.with(type: .bold, size: 12)
        self.timeLabel.font = AppFont.with(type: .heavy, size: 16)
        
        self.awayParticipantNameLabel.font = AppFont.with(type: .heavy, size: 15)
        self.homeParticipantNameLabel.font = AppFont.with(type: .heavy, size: 15)
        
        self.backgroundView?.backgroundColor = .clear
        self.backgroundColor = .clear
        self.contentView.backgroundColor = .clear

        self.centerView.backgroundColor = .clear

        self.baseView.clipsToBounds = true
        self.baseView.alpha = 1.0
        self.baseView.isUserInteractionEnabled = true

        self.participantsBaseView.backgroundColor = .clear
        self.oddsStackView.backgroundColor = .clear
        self.homeBaseView.backgroundColor = .clear
        self.drawBaseView.backgroundColor = .clear
        self.awayBaseView.backgroundColor = .clear

        self.homeParticipantNameLabel.text = ""
        self.awayParticipantNameLabel.text = ""
        self.dateLabel.text = ""
        self.timeLabel.text = ""

        let tapLeftOddButton = UITapGestureRecognizer(target: self, action: #selector(didTapLeftOddButton))
        self.homeBaseView.addGestureRecognizer(tapLeftOddButton)

        let longPressLeftOddButton = UILongPressGestureRecognizer(target: self, action: #selector(didLongPressLeftOddButton))
        self.homeBaseView.addGestureRecognizer(longPressLeftOddButton)

        let tapMiddleOddButton = UITapGestureRecognizer(target: self, action: #selector(didTapMiddleOddButton))
        self.drawBaseView.addGestureRecognizer(tapMiddleOddButton)

        let longPressMiddleOddButton = UILongPressGestureRecognizer(target: self, action: #selector(didLongPressMiddleOddButton))
        self.drawBaseView.addGestureRecognizer(longPressMiddleOddButton)

        let tapRightOddButton = UITapGestureRecognizer(target: self, action: #selector(didTapRightOddButton))
        self.awayBaseView.addGestureRecognizer(tapRightOddButton)

        let longPressRightOddButton = UILongPressGestureRecognizer(target: self, action: #selector(didLongPressRightOddButton))
        self.awayBaseView.addGestureRecognizer(longPressRightOddButton)

//        let tapBannerBaseView = UITapGestureRecognizer(target: self, action: #selector(didTapBannerView))
//        self.participantsBaseView.addGestureRecognizer(tapBannerBaseView)

        self.setupWithTheme()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        self.setupWithTheme()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        self.homeBaseView.layer.cornerRadius = 4
        self.drawBaseView.layer.cornerRadius = 4
        self.awayBaseView.layer.cornerRadius = 4

        self.baseView.layer.cornerRadius = 8

        self.setupGradient()
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        self.dateLabel.isHidden = false
        self.matchBaseView.isHidden = true

        self.homeParticipantNameLabel.text = ""
        self.awayParticipantNameLabel.text = ""
        self.dateLabel.text = ""
        self.timeLabel.text = ""

        self.viewModel = nil
        self.completeMatch = nil
        self.matchViewModel = nil

        self.leftOutcome = nil
        self.middleOutcome = nil
        self.rightOutcome = nil

        self.leftOddButtonSubscriber?.cancel()
        self.leftOddButtonSubscriber = nil
        self.middleOddButtonSubscriber?.cancel()
        self.middleOddButtonSubscriber = nil
        self.rightOddButtonSubscriber?.cancel()
        self.rightOddButtonSubscriber = nil

        self.isLeftOutcomeButtonSelected = false
        self.isMiddleOutcomeButtonSelected = false
        self.isRightOutcomeButtonSelected = false

        self.homeOddValueLabel.text = ""
        self.drawOddValueLabel.text = ""
        self.awayOddValueLabel.text = ""
    }

    func setupWithTheme() {
        self.backgroundColor = .clear
        self.backgroundView?.backgroundColor = .clear

        self.matchBaseView.backgroundColor = .clear
        self.imageBaseView.backgroundColor = .clear

        self.baseView.backgroundColor = UIColor(hex: 0x2E333F)
        
        self.homeParticipantNameLabel.textColor = .white
        self.awayParticipantNameLabel.textColor = .white
        self.dateLabel.textColor = .white
        self.timeLabel.textColor = .white

        self.homeOddTitleLabel.textColor = .white
        self.homeOddValueLabel.textColor = .white
        self.drawOddTitleLabel.textColor = .white
        self.drawOddValueLabel.textColor = .white
        self.awayOddTitleLabel.textColor = .white
        self.awayOddValueLabel.textColor = .white

        self.matchOffuscationView.backgroundColor = UIColor(hex: 0x242830)
        self.matchOffuscationView.alpha = 0.66

        if isLeftOutcomeButtonSelected {
            self.homeBaseView.backgroundColor = UIColor.App.buttonBackgroundPrimary
            self.homeOddTitleLabel.textColor = UIColor.App.buttonTextPrimary
            self.homeOddValueLabel.textColor = UIColor.App.buttonTextPrimary
        }
        else {
            self.homeBaseView.backgroundColor = UIColor.App.backgroundOdds
            self.homeOddTitleLabel.textColor = UIColor.App.textPrimary
            self.homeOddValueLabel.textColor = UIColor.App.textPrimary
        }

        if isMiddleOutcomeButtonSelected {
            self.drawBaseView.backgroundColor = UIColor.App.buttonBackgroundPrimary
            self.drawOddTitleLabel.textColor = UIColor.App.buttonTextPrimary
            self.drawOddValueLabel.textColor = UIColor.App.buttonTextPrimary
        }
        else {
            self.drawBaseView.backgroundColor = UIColor.App.backgroundOdds
            self.drawOddTitleLabel.textColor = UIColor.App.textPrimary
            self.drawOddValueLabel.textColor = UIColor.App.textPrimary
        }

        if isRightOutcomeButtonSelected {
            self.awayBaseView.backgroundColor = UIColor.App.buttonBackgroundPrimary
            self.awayOddTitleLabel.textColor = UIColor.App.buttonTextPrimary
            self.awayOddValueLabel.textColor = UIColor.App.buttonTextPrimary
        }
        else {
            self.awayBaseView.backgroundColor = UIColor.App.backgroundOdds
            self.awayOddTitleLabel.textColor = UIColor.App.textPrimary
            self.awayOddValueLabel.textColor = UIColor.App.textPrimary
        }

        self.setupGradient()
    }

    func setupGradient() {
        self.matchGradientView.alpha = 1.0
        self.matchGradientView.backgroundColor = UIColor(hex: 0x242830)

        let rightGradientMaskLayer = CAGradientLayer()
        rightGradientMaskLayer.frame = matchGradientView.bounds
        rightGradientMaskLayer.colors = [UIColor.clear.cgColor, UIColor.clear.cgColor, UIColor.white.cgColor]
        rightGradientMaskLayer.locations = [0.0, 0.48, 1.0]
        rightGradientMaskLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
        rightGradientMaskLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
        
        self.matchGradientView.layer.mask = rightGradientMaskLayer
    }

    func setupWithViewModel(_ viewModel: BannerCellViewModel) {
        self.viewModel = viewModel

        self.matchBaseView.isHidden = true
        self.imageView.isHidden = true

        switch viewModel.presentationType {
        case .match:
            if let url = viewModel.imageURL {
                self.imageView.isHidden = false
                self.imageView.kf.setImage(with: url)
            }
            viewModel.match
                .receive(on: DispatchQueue.main)
                .compactMap({$0}).sink { [weak self] match in
                    if let matchViewModel = self?.matchViewModel {
                        self?.matchViewModel = matchViewModel
                    }
                    else {
                        self?.matchViewModel = MatchWidgetCellViewModel(match: match)
                    }
                }
                .store(in: &cancellables)

            viewModel.completeMatch
                .receive(on: DispatchQueue.main)
                .compactMap({$0}).sink { [weak self] completeMatch in
                    self?.completeMatch = completeMatch
                    self?.setupWithMatch(completeMatch)
                }
                .store(in: &cancellables)

            let tapBannerBaseView = UITapGestureRecognizer(target: self, action: #selector(didTapBannerView))
            self.matchBaseView.addGestureRecognizer(tapBannerBaseView)

        case .image:
            self.imageView.isHidden = false
            if let url = viewModel.imageURL {
                self.imageView.kf.setImage(with: url)
            }

            let tapBannerBaseView = UITapGestureRecognizer(target: self, action: #selector(didTapBannerView))
            self.baseView.addGestureRecognizer(tapBannerBaseView)
            
        case .externalStream:
            self.imageView.isHidden = false
            if let url = viewModel.imageURL {
                self.imageView.kf.setImage(with: url)
            }

            let tapBannerBaseView = UITapGestureRecognizer(target: self, action: #selector(didTapBannerView))
            self.baseView.addGestureRecognizer(tapBannerBaseView)

        case .externalLink:
            self.imageView.isHidden = false
            if let url = viewModel.imageURL {
                self.imageView.kf.setImage(with: url)
            }

            let tapBannerBaseView = UITapGestureRecognizer(target: self, action: #selector(didTapBannerView))
            self.baseView.addGestureRecognizer(tapBannerBaseView)

        case .externalMatch:
            self.imageView.isHidden = false
            if let url = viewModel.imageURL {
                self.imageView.kf.setImage(with: url)
            }
            viewModel.match
                .receive(on: DispatchQueue.main)
                .compactMap({$0}).sink { [weak self] match in
                    self?.matchViewModel = MatchWidgetCellViewModel(match: match)
                }
                .store(in: &cancellables)

            viewModel.completeMatch
                .receive(on: DispatchQueue.main)
                .compactMap({$0}).sink { [weak self] completeMatch in
                    self?.completeMatch = completeMatch
                    self?.setupWithMatch(completeMatch)
                }
                .store(in: &cancellables)

            let tapBannerBaseView = UITapGestureRecognizer(target: self, action: #selector(didTapBannerView))
            self.participantsBaseView.addGestureRecognizer(tapBannerBaseView)
        }

    }

    func setupWithMatchViewModel(matchWidgetCellViewModel viewModel: MatchWidgetCellViewModel) {
        
        viewModel.homeTeamNamePublisher
            .sink { [weak self] homeTeamName in
                self?.homeParticipantNameLabel.text = homeTeamName
            }
            .store(in: &self.cancellables)

        viewModel.awayTeamNamePublisher
            .sink { [weak self] awayTeamName in
                self?.awayParticipantNameLabel.text = awayTeamName
            }
            .store(in: &self.cancellables)
        
    
        viewModel.startDateStringPublisher
            .sink { [weak self] startDateString in
                self?.dateLabel.text = startDateString
            }
            .store(in: &self.cancellables)

        viewModel.startTimeStringPublisher
            .sink { [weak self] startTimeString in
                self?.timeLabel.text = startTimeString
            }
            .store(in: &self.cancellables)
        
        viewModel.isTodayPublisher
            .sink { [weak self] isToday in
                self?.dateLabel.isHidden = isToday
            }
            .store(in: &self.cancellables)
        
        self.matchBaseView.isHidden = false
        self.imageView.isHidden = false
    }
    
    func setupWithMatch(_ match: Match) {

        // let viewModel = MatchWidgetCellViewModel(match: match)
        guard let matchViewModel = self.matchViewModel else {
            return
        }

        guard let viewModel = self.viewModel else {
            return
        }

        self.setupWithMatchViewModel(matchWidgetCellViewModel: matchViewModel)
        
        if let market = match.markets.first {

            if market.outcomes.count == 2 {
                self.awayBaseView.isHidden = true
            }
            else {
                self.awayBaseView.isHidden = false
            }

            if let outcome = market.outcomes[safe: 0] {
                self.homeOddTitleLabel.text = outcome.translatedName.isNotEmpty ? outcome.translatedName : outcome.typeName
                self.homeOddValueLabel.text = "\(Double(round(outcome.bettingOffer.decimalOdd * 100)/100))"
                // self.currentHomeOddValue = outcome.bettingOffer.value
                self.leftOutcome = outcome

                self.isLeftOutcomeButtonSelected = Env.betslipManager.hasBettingTicket(withId: outcome.bettingOffer.id)

                self.leftOddButtonSubscriber = viewModel.oddPublisherForBettingOfferId(outcome.bettingOffer.id)?
                    .map(\.oddsValue)
                    .compactMap({ $0 })
                    .receive(on: DispatchQueue.main)
                    .sink(receiveValue: { [weak self] newOddValue in
                        guard let weakSelf = self else { return }
                        weakSelf.homeOddValueLabel.text = OddFormatter.formatOdd(withValue: newOddValue)
                    })

            }
            if let outcome = market.outcomes[safe: 1] {
                self.drawOddTitleLabel.text = outcome.translatedName.isNotEmpty ? outcome.translatedName : outcome.typeName
                self.drawOddValueLabel.text = "\(Double(round(outcome.bettingOffer.decimalOdd * 100)/100))"
                // self.currentDrawOddValue = outcome.bettingOffer.value
                self.middleOutcome = outcome

                self.isMiddleOutcomeButtonSelected = Env.betslipManager.hasBettingTicket(withId: outcome.bettingOffer.id)

                self.middleOddButtonSubscriber = viewModel.oddPublisherForBettingOfferId(outcome.bettingOffer.id)?
                    .map(\.oddsValue)
                    .compactMap({ $0 })
                    .receive(on: DispatchQueue.main)
                    .sink(receiveValue: { [weak self] newOddValue in
                        guard let weakSelf = self else { return }
                        weakSelf.drawOddValueLabel.text = OddFormatter.formatOdd(withValue: newOddValue)
                    })
            }
            if let outcome = market.outcomes[safe: 2] {
                self.awayOddTitleLabel.text = outcome.translatedName.isNotEmpty ? outcome.translatedName : outcome.typeName
                self.awayOddValueLabel.text = "\(Double(round(outcome.bettingOffer.decimalOdd * 100)/100))"
                self.rightOutcome = outcome

                self.isRightOutcomeButtonSelected = Env.betslipManager.hasBettingTicket(withId: outcome.bettingOffer.id)

                self.rightOddButtonSubscriber = viewModel.oddPublisherForBettingOfferId(outcome.bettingOffer.id)?
                    .map(\.oddsValue)
                    .compactMap({ $0 })
                    .receive(on: DispatchQueue.main)
                    .sink(receiveValue: { [weak self] newOddValue in
                        guard let weakSelf = self else { return }
                        weakSelf.awayOddValueLabel.text = OddFormatter.formatOdd(withValue: newOddValue)
                    })
            }
            
        }
        else {
            Logger.log("No markets found")
            oddsStackView.alpha = 0.2

            self.homeOddValueLabel.text = "-"
            self.drawOddValueLabel.text = "-"
            self.awayOddValueLabel.text = "-"
        }

        Env.betslipManager.bettingTicketsPublisher
            .receive(on: DispatchQueue.main)
            .sink{ [weak self] bettingTicket in

                self?.isLeftOutcomeButtonSelected = Env.betslipManager.hasBettingTicket(withId: match.markets[safe:0]?.outcomes[safe: 0]?.bettingOffer.id ?? "")

                self?.isMiddleOutcomeButtonSelected = Env.betslipManager.hasBettingTicket(withId: match.markets[safe:0]?.outcomes[safe: 1]?.bettingOffer.id ?? "")

                self?.isRightOutcomeButtonSelected = Env.betslipManager.hasBettingTicket(withId: match.markets[safe:0]?.outcomes[safe: 2]?.bettingOffer.id ?? "")

            }
            .store(in: &cancellables)

    }

    func selectLeftOddButton() {
        self.homeBaseView.backgroundColor = UIColor.App.buttonBackgroundPrimary
        self.homeOddValueLabel.textColor = UIColor.App.buttonTextPrimary
        self.homeOddTitleLabel.textColor = UIColor.App.buttonTextPrimary
    }
    func deselectLeftOddButton() {
        self.homeBaseView.backgroundColor = UIColor.App.backgroundOdds
        self.homeOddValueLabel.textColor = UIColor.App.textPrimary
        self.homeOddTitleLabel.textColor = UIColor.App.textPrimary
    }

    @objc func didTapLeftOddButton() {
        guard
            let match = self.completeMatch,
            let market = self.completeMatch?.markets.first,
            let outcome = self.leftOutcome
        else {
            return
        }

        let bettingTicket = BettingTicket(match: match, market: market, outcome: outcome)

        if Env.betslipManager.hasBettingTicket(bettingTicket) {
            Env.betslipManager.removeBettingTicket(bettingTicket)
            self.isLeftOutcomeButtonSelected = false
        }
        else {
            Env.betslipManager.addBettingTicket(bettingTicket)

            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)

            self.isLeftOutcomeButtonSelected = true
        }

    }

    @objc func didLongPressLeftOddButton(_ sender: UILongPressGestureRecognizer) {

        // Triggers function only once instead of rapid fire event
        if sender.state == .began {

            guard
                let match = self.completeMatch,
                let market = self.completeMatch?.markets.first,
                let outcome = self.leftOutcome
            else {
                return
            }

            let bettingTicket = BettingTicket(match: match, market: market, outcome: outcome)

            self.didLongPressOdd?(bettingTicket)
        }
    }

    func selectMiddleOddButton() {
        self.drawBaseView.backgroundColor = UIColor.App.buttonBackgroundPrimary
        self.drawOddValueLabel.textColor = UIColor.App.buttonTextPrimary
        self.drawOddTitleLabel.textColor = UIColor.App.buttonTextPrimary
    }
    func deselectMiddleOddButton() {
        self.drawBaseView.backgroundColor = UIColor.App.backgroundOdds
        self.drawOddTitleLabel.textColor = UIColor.App.textPrimary
        self.drawOddValueLabel.textColor = UIColor.App.textPrimary
    }

    @objc func didTapMiddleOddButton() {
        guard
            let match = self.completeMatch,
            let market = self.completeMatch?.markets.first,
            let outcome = self.middleOutcome
        else {
            return
        }

        let bettingTicket = BettingTicket(match: match, market: market, outcome: outcome)

        if Env.betslipManager.hasBettingTicket(bettingTicket) {
            Env.betslipManager.removeBettingTicket(bettingTicket)
            self.isMiddleOutcomeButtonSelected = false
        }
        else {
            Env.betslipManager.addBettingTicket(bettingTicket)

            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)

            self.isMiddleOutcomeButtonSelected = true
        }
    }

    @objc func didLongPressMiddleOddButton(_ sender: UILongPressGestureRecognizer) {

        // Triggers function only once instead of rapid fire event
        if sender.state == .began {

            guard
                let match = self.completeMatch,
                let market = self.completeMatch?.markets.first,
                let outcome = self.middleOutcome
            else {
                return
            }

            let bettingTicket = BettingTicket(match: match, market: market, outcome: outcome)

            self.didLongPressOdd?(bettingTicket)
        }
    }

    func selectRightOddButton() {
        self.awayBaseView.backgroundColor = UIColor.App.buttonBackgroundPrimary
        self.awayOddValueLabel.textColor = UIColor.App.buttonTextPrimary
        self.awayOddTitleLabel.textColor = UIColor.App.buttonTextPrimary
    }
    func deselectRightOddButton() {
        self.awayBaseView.backgroundColor = UIColor.App.backgroundOdds
        self.awayOddValueLabel.textColor = UIColor.App.textPrimary
        self.awayOddTitleLabel.textColor = UIColor.App.textPrimary
    }

    @objc func didTapRightOddButton() {
        guard
            let match = self.completeMatch,
            let market = self.completeMatch?.markets.first,
            let outcome = self.rightOutcome
        else {
            return
        }

        let bettingTicket = BettingTicket(match: match, market: market, outcome: outcome)

        if Env.betslipManager.hasBettingTicket(bettingTicket) {
            Env.betslipManager.removeBettingTicket(bettingTicket)
            self.isRightOutcomeButtonSelected = false
        }
        else {
            Env.betslipManager.addBettingTicket(bettingTicket)

            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
            
            self.isRightOutcomeButtonSelected = true
        }
    }

    @objc func didLongPressRightOddButton(_ sender: UILongPressGestureRecognizer) {

        // Triggers function only once instead of rapid fire event
        if sender.state == .began {

            guard
                let match = self.completeMatch,
                let market = self.completeMatch?.markets.first,
                let outcome = self.rightOutcome
            else {
                return
            }

            let bettingTicket = BettingTicket(match: match, market: market, outcome: outcome)

            self.didLongPressOdd?(bettingTicket)
        }
    }

    @objc func didTapBannerView() {
        if let presentationType = self.viewModel?.presentationType {
            if let specialAction = self.viewModel?.specialAction {
                self.didTapBannerViewAction?(presentationType, specialAction)
            }
            else {
                self.didTapBannerViewAction?(presentationType, nil)
            }

        }
    }

}

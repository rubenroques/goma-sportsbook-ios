//
//  ProChoiceHighlightCollectionViewCell.swift
//  GomaUI
//
//  Created by Ruben Roques on 15/10/2024.
//
import UIKit
import Kingfisher
import Combine

class ProChoiceHighlightCollectionViewCell: UICollectionViewCell {

    // MARK: - UI Components
    private lazy var containerView: UIView = self.createContainerView()

    private lazy var gradientBorderView: GradientBorderView = self.createGradientBorderView()

    private lazy var containerStackView: UIStackView = self.createContainerStackView()

    // New UI components
    private lazy var eventImageBaseView: UIView = self.createEventImageBaseView()
    private lazy var eventImageView: ScaleAspectFitImageView = self.createEventImageView()

    private lazy var leagueInfoContainerView: UIView = self.createLeagueInfoContainerView()
    private lazy var leagueInfoStackView: UIStackView = self.createLeagueInfoStackView()

    private lazy var favoriteButton: UIButton = self.createFavoriteButton()
    private lazy var favoriteImageView: UIImageView = self.createIconImageView()
    private lazy var sportImageView: UIImageView = self.createIconImageView()
    private lazy var countryImageView: UIImageView = self.createCountryIconImageView()
    private lazy var leagueNameLabel: UILabel = self.createLeagueNameLabel()
    private lazy var cashbackImageView: UIImageView = self.createIconImageView()

    private lazy var topSeparatorAlphaLineView: FadingView = self.createTopSeparatorAlphaLineView()

    private lazy var eventInfoContainerView: UIView = self.createEventInfoContainerView()
    private lazy var backgroundImageView: UIImageView = self.createBackgroundImageView()

    private lazy var eventDateLabel: UILabel = self.createEventDateLabel()
    private lazy var eventTimeLabel: UILabel = self.createEventTimeLabel()
    private lazy var marketNameLabel: UILabel = self.createMarketNameLabel()

    private lazy var teamPillContainerView: GradientBorderView = self.createTeamPillContainerView()
    private lazy var teamsLabel: UILabel = self.createTeamsLabel()

    private lazy var oddsStackView: UIStackView = self.createOddsStackView()

    private lazy var homeButton: UIView = self.createOutcomeBaseView()
    private lazy var homeOutcomeBaseView: UIView = self.createOutcomeContainerBaseView()
    private lazy var homeOutcomeNameLabel: UILabel = self.createOutcomeNameLabel()
    private lazy var homeOutcomeValueLabel: UILabel = self.createOutcomeValueLabel()

    private lazy var drawButton: UIView = self.createOutcomeBaseView()
    private lazy var drawOutcomeBaseView: UIView = self.createOutcomeContainerBaseView()
    private lazy var drawOutcomeNameLabel: UILabel = self.createOutcomeNameLabel()
    private lazy var drawOutcomeValueLabel: UILabel = self.createOutcomeValueLabel()

    private lazy var awayButton: UIView = self.createOutcomeBaseView()
    private lazy var awayOutcomeBaseView: UIView = self.createOutcomeContainerBaseView()
    private lazy var awayOutcomeNameLabel: UILabel = self.createOutcomeNameLabel()
    private lazy var awayOutcomeValueLabel: UILabel = self.createOutcomeValueLabel()

    private lazy var bottomButtonsContainerStackView: UIStackView = self.createBottomButtonsContainerStackView()
    private lazy var seeAllMarketsButton: UIButton = self.createSeeAllMarketsButton()
    
    private lazy var homeUpChangeOddValueImageView: UIImageView = self.createHomeUpChangeOddValueImageView()
    private lazy var homeDownChangeOddValueImageView: UIImageView = self.createHomeDownChangeOddValueImageView()
    private lazy var drawUpChangeOddValueImageView: UIImageView = self.createDrawUpChangeOddValueImageView()
    private lazy var drawDownChangeOddValueImageView: UIImageView = self.createDrawDownChangeOddValueImageView()
    private lazy var awayUpChangeOddValueImageView: UIImageView = self.createAwayUpChangeOddValueImageView()
    private lazy var awayDownChangeOddValueImageView: UIImageView = self.createAwayDownChangeOddValueImageView()
    
    // Mix match bottom bar
    private lazy var mixMatchContainerView: UIView = self.createMixMatchContainerView()
    
    private lazy var mixMatchBaseView: UIView = self.createMixMatchBaseView()
    
    private lazy var mixMatchBackgroundImageView: UIImageView = self.createMixMatchBackgroundImageView()
    
    private lazy var mixMatchIconImageView: UIImageView = self.createMixMatchIconImageView()
    
    lazy var mixMatchLabel: UILabel = self.createMixMatchLabel()
    
    lazy var mixMatchNavigationIconImageView: UIImageView = self.createMixMatchNavigationIconImageView()

    lazy var cashbackIconImageView: UIImageView = self.createCashbackIconImageView()

    private var viewModel: MarketWidgetCellViewModel?

    private var cancellables = Set<AnyCancellable>()
    
    private var leftOutcome: Outcome?
    private var middleOutcome: Outcome?
    private var rightOutcome: Outcome?
    
    private var currentHomeOddValue: Double?
    private var currentDrawOddValue: Double?
    private var currentAwayOddValue: Double?
    
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
    
    var isFavorite: Bool = false {
        didSet {
            if self.isFavorite {
                self.favoriteImageView.image = UIImage(named: "selected_favorite_icon")
            }
            else {
                self.favoriteImageView.image = UIImage(named: "unselected_favorite_icon")
            }
        }
    }

    var hasCashback: Bool = false {
        didSet {
            self.cashbackIconImageView.isHidden = !hasCashback
        }
    }

    var tappedMatchIdAction: ((String) -> Void) = { _ in }
    var didLongPressOdd: ((BettingTicket) -> Void) = { _ in }
    var tappedMixMatchAction: ((String) -> Void) = { _ in }

    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupSubviews()
        self.setupWithTheme()

        self.homeButton.isUserInteractionEnabled = true
        self.drawButton.isUserInteractionEnabled = true
        self.awayButton.isUserInteractionEnabled = true
        
        self.favoriteButton.addTarget(self, action: #selector(self.didTapFavoriteIcon), for: .primaryActionTriggered)
        
        let tapLeftOddButton = UITapGestureRecognizer(target: self, action: #selector(didTapLeftOddButton))
        self.homeButton.addGestureRecognizer(tapLeftOddButton)
        
        let longPressLeftOddButton = UILongPressGestureRecognizer(target: self, action: #selector(didLongPressLeftOddButton))
        self.homeButton.addGestureRecognizer(longPressLeftOddButton)
        
        let tapMiddleOddButton = UITapGestureRecognizer(target: self, action: #selector(didTapMiddleOddButton))
        self.drawButton.addGestureRecognizer(tapMiddleOddButton)
        
        let longPressMiddleOddButton = UILongPressGestureRecognizer(target: self, action: #selector(didLongPressMiddleOddButton))
        self.drawButton.addGestureRecognizer(longPressMiddleOddButton)
        
        let tapRightOddButton = UITapGestureRecognizer(target: self, action: #selector(didTapRightOddButton))
        self.awayButton.addGestureRecognizer(tapRightOddButton)
        
        let longPressRightOddButton = UILongPressGestureRecognizer(target: self, action: #selector(didLongPressRightOddButton))
        self.awayButton.addGestureRecognizer(longPressRightOddButton)
        
        let tapMatchView = UITapGestureRecognizer(target: self, action: #selector(didTapMatchView))
        self.addGestureRecognizer(tapMatchView)
        
        self.seeAllMarketsButton.addTarget(self, action: #selector(self.didTapMatchView), for: .primaryActionTriggered)
        
        let tapMixMatchView = UITapGestureRecognizer(target: self, action: #selector(didTapMixMatch))
        self.mixMatchContainerView.addGestureRecognizer(tapMixMatchView)
        
        self.mixMatchContainerView.isHidden = true

        self.hasCashback = false
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Reuse
    override func prepareForReuse() {
        super.prepareForReuse()

        self.favoriteImageView.image = UIImage(named: "unselected_favorite_icon")

        self.viewModel = nil

        self.homeButton.isHidden = false
        self.drawButton.isHidden = false
        self.awayButton.isHidden = false
        
        self.leftOutcome = nil
        self.middleOutcome = nil
        self.rightOutcome = nil
        
        self.isFavorite = false
        
        self.leftOddButtonSubscriber?.cancel()
        self.leftOddButtonSubscriber = nil
        
        self.middleOddButtonSubscriber?.cancel()
        self.middleOddButtonSubscriber = nil
        
        self.rightOddButtonSubscriber?.cancel()
        self.rightOddButtonSubscriber = nil
        
        self.mixMatchContainerView.isHidden = true

        self.hasCashback = false
    }

    // MARK: - Configuration
    private func setupWithTheme() {
        self.backgroundColor = .clear
        self.contentView.backgroundColor = .clear

        self.containerView.backgroundColor = UIColor.App.backgroundCards

        self.gradientBorderView.gradientColors = [UIColor.App.cardBorderLineGradient1,
                                                  UIColor.App.cardBorderLineGradient2,
                                                  UIColor.App.cardBorderLineGradient3]

        self.topSeparatorAlphaLineView.backgroundColor = UIColor.App.highlightPrimary
        
        self.containerStackView.backgroundColor = .clear

        self.leagueInfoStackView.backgroundColor = .clear
        
        self.favoriteButton.backgroundColor = .clear
        self.favoriteImageView.backgroundColor = .clear
        
        self.leagueNameLabel.textColor = UIColor.App.textSecondary
        self.eventDateLabel.textColor = UIColor.App.textSecondary
        self.eventTimeLabel.textColor = UIColor.App.textSecondary
        self.teamsLabel.textColor = UIColor.App.highlightPrimary
        
        self.bottomButtonsContainerStackView.backgroundColor = .clear
        
        self.seeAllMarketsButton.backgroundColor = UIColor.App.backgroundSecondary
        self.seeAllMarketsButton.tintColor = UIColor.App.textSecondary
        self.seeAllMarketsButton.titleLabel?.textColor = UIColor.App.textSecondary
        
        self.homeOutcomeBaseView.backgroundColor = .clear
        self.drawOutcomeBaseView.backgroundColor = .clear
        self.awayOutcomeBaseView.backgroundColor = .clear

        self.homeButton.backgroundColor = UIColor.App.backgroundOdds
        self.drawButton.backgroundColor = UIColor.App.backgroundOdds
        self.awayButton.backgroundColor = UIColor.App.backgroundOdds
        
        if isLeftOutcomeButtonSelected {
            self.homeButton.backgroundColor = UIColor.App.buttonBackgroundPrimary
            self.homeOutcomeNameLabel.textColor = UIColor.App.buttonTextPrimary
            self.homeOutcomeValueLabel.textColor = UIColor.App.buttonTextPrimary
        }
        else {
            self.homeButton.backgroundColor = UIColor.App.backgroundOdds
            self.homeOutcomeNameLabel.textColor = UIColor.App.textPrimary
            self.homeOutcomeValueLabel.textColor = UIColor.App.textPrimary
        }
        
        if isMiddleOutcomeButtonSelected {
            self.drawButton.backgroundColor = UIColor.App.buttonBackgroundPrimary
            self.drawOutcomeNameLabel.textColor = UIColor.App.buttonTextPrimary
            self.drawOutcomeValueLabel.textColor = UIColor.App.buttonTextPrimary
        }
        else {
            self.drawButton.backgroundColor = UIColor.App.backgroundOdds
            self.drawOutcomeNameLabel.textColor = UIColor.App.textPrimary
            self.drawOutcomeValueLabel.textColor = UIColor.App.textPrimary
        }
        
        if isRightOutcomeButtonSelected {
            self.awayButton.backgroundColor = UIColor.App.buttonBackgroundPrimary
            self.awayOutcomeNameLabel.textColor = UIColor.App.buttonTextPrimary
            self.awayOutcomeValueLabel.textColor = UIColor.App.buttonTextPrimary
        }
        else {
            self.awayButton.backgroundColor = UIColor.App.backgroundOdds
            self.awayOutcomeNameLabel.textColor = UIColor.App.textPrimary
            self.awayOutcomeValueLabel.textColor = UIColor.App.textPrimary
        }
    }

    func configure(with viewModel: MarketWidgetCellViewModel) {
        self.viewModel = viewModel
        
        if let customBetAvailable = viewModel.highlightedMarket.content.customBetAvailable,
           customBetAvailable {
            self.mixMatchContainerView.isHidden = false
            self.seeAllMarketsButton.isHidden = true
        }
        else {
            self.mixMatchContainerView.isHidden = true
            self.seeAllMarketsButton.isHidden = false
        }

        viewModel.eventImagePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] sportIconImage in
                if let imageUrl = URL(string: sportIconImage) {
                    self?.eventImageView.kf.setImage(with: imageUrl)

                }
            }
            .store(in: &self.cancellables)

        viewModel.sportIconImagePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] sportIconImage in
                self?.sportImageView.image = sportIconImage
            }
            .store(in: &self.cancellables)
        
        viewModel.countryFlagImagePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] countryFlagImage in
                self?.countryImageView.image = countryFlagImage
            }
            .store(in: &self.cancellables)
        
        viewModel.competitionName
            .receive(on: DispatchQueue.main)
            .sink { [weak self] competitionName in
                self?.leagueNameLabel.text = competitionName
            }
            .store(in: &self.cancellables)
        
        viewModel.eventName
            .receive(on: DispatchQueue.main)
            .sink { [weak self] eventName in
                self?.teamsLabel.text = eventName
            }
            .store(in: &self.cancellables)
        
        viewModel.marketName
            .receive(on: DispatchQueue.main)
            .sink { [weak self] marketName in
                self?.marketNameLabel.text = marketName
            }
            .store(in: &self.cancellables)
        
        viewModel.startDateStringPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] startDateString in
                self?.eventDateLabel.text = startDateString
            }
            .store(in: &self.cancellables)
        
        viewModel.startTimeStringPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] startTimeString in
                self?.eventTimeLabel.text = startTimeString
            }
            .store(in: &self.cancellables)
        
        viewModel.isFavoriteMatchPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isFavoriteMatch in
                self?.isFavorite = isFavoriteMatch
            }
            .store(in: &self.cancellables)

        viewModel.canHaveCashbackPublisher
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] canHaveCashback in
                self?.hasCashback = canHaveCashback
            }
            .store(in: &self.cancellables)
        
        self.configureOddsButtons()
        
    }
    
    private func configureOddsButtons() {

        self.homeButton.isHidden = true
        self.drawButton.isHidden = true
        self.awayButton.isHidden = true

        let availableOutcomes = (self.viewModel?.availableOutcomes ?? [])
        let market = self.viewModel?.highlightedMarket.content

        if let outcome = availableOutcomes[safe: 0] {

            if let nameDigit1 = market?.nameDigit1 {
                if outcome.typeName.contains("\(nameDigit1)") {
                    self.homeOutcomeNameLabel.text = outcome.typeName
                }
                else {
                    self.homeOutcomeNameLabel.text = "\(outcome.typeName) \(nameDigit1)"
                }
            }
            else {
                self.homeOutcomeNameLabel.text = outcome.typeName
            }

            self.homeButton.isHidden = false

            self.leftOutcome = outcome
            self.isLeftOutcomeButtonSelected = Env.betslipManager.hasBettingTicket(withId: outcome.bettingOffer.id)
            
            // Check for SportRadar invalid odd
            if !outcome.bettingOffer.decimalOdd.isNaN && outcome.bettingOffer.isAvailable {
                self.setHomeOddValueLabel(toText: OddFormatter.formatOdd(withValue: outcome.bettingOffer.decimalOdd))
            }
            else {
                self.homeButton.isUserInteractionEnabled = false
                self.homeButton.alpha = 0.5
                self.setHomeOddValueLabel(toText: "-")
            }
            
            self.leftOddButtonSubscriber = Env.servicesProvider
                .subscribeToEventOnListsOutcomeUpdates(withId: outcome.bettingOffer.id)
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { completion in

                }, receiveValue: { [weak self] serviceProviderOutcome in
                    
                    guard let weakSelf = self,
                    let serviceProviderOutcome = serviceProviderOutcome
                    else { return }
                    
                    let outcome = ServiceProviderModelMapper.outcome(fromServiceProviderOutcome: serviceProviderOutcome)
                    
                    let bettingOffer = outcome.bettingOffer
                    
                    if !bettingOffer.isAvailable || bettingOffer.decimalOdd.isNaN {
                        weakSelf.homeButton.isUserInteractionEnabled = false
                        weakSelf.homeButton.alpha = 0.5
                        weakSelf.setHomeOddValueLabel(toText: "-")
                    }
                    else {
                        weakSelf.homeButton.isUserInteractionEnabled = true
                        weakSelf.homeButton.alpha = 1.0
                        
                        let newOddValue = bettingOffer.decimalOdd
                        
                        if let currentOddValue = weakSelf.currentHomeOddValue {
                            if newOddValue > currentOddValue {
                                weakSelf.highlightOddChangeUp(animated: true,
                                                              upChangeOddValueImage: weakSelf.homeUpChangeOddValueImageView,
                                                              baseView: weakSelf.homeButton)
                            }
                            else if newOddValue < currentOddValue {
                                weakSelf.highlightOddChangeDown(animated: true,
                                                                downChangeOddValueImage: weakSelf.homeDownChangeOddValueImageView,
                                                                baseView: weakSelf.homeButton)
                            }
                        }
                        weakSelf.currentHomeOddValue = newOddValue
                        weakSelf.setHomeOddValueLabel(toText: OddFormatter.formatOdd(withValue: newOddValue))
                    }
                })
        }
        
        if let outcome = availableOutcomes[safe: 1] {

            if let nameDigit1 = market?.nameDigit1 {
                if outcome.typeName.contains("\(nameDigit1)") {
                    self.drawOutcomeNameLabel.text = outcome.typeName
                }
                else {
                    self.drawOutcomeNameLabel.text = "\(outcome.typeName) \(nameDigit1)"
                }
            }
            else {
                self.drawOutcomeNameLabel.text = outcome.typeName
            }

            self.drawButton.isHidden = false

            self.middleOutcome = outcome
            self.isMiddleOutcomeButtonSelected = Env.betslipManager.hasBettingTicket(withId: outcome.bettingOffer.id)
            
            // Check for SportRadar invalid odd
            if !outcome.bettingOffer.decimalOdd.isNaN && outcome.bettingOffer.isAvailable {
                self.setDrawOddValueLabel(toText: OddFormatter.formatOdd(withValue: outcome.bettingOffer.decimalOdd))
            }
            else {
                self.drawButton.isUserInteractionEnabled = false
                self.drawButton.alpha = 0.5
                self.setDrawOddValueLabel(toText: "-")
            }
            
            self.middleOddButtonSubscriber = Env.servicesProvider
                .subscribeToEventOnListsOutcomeUpdates(withId: outcome.bettingOffer.id)
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { completion in
                    
                }, receiveValue: { [weak self] serviceProviderOutcome in
                    
                    guard let weakSelf = self,
                    let serviceProviderOutcome = serviceProviderOutcome
                    else { return }
                    
                    let outcome = ServiceProviderModelMapper.outcome(fromServiceProviderOutcome: serviceProviderOutcome)
                    
                    let bettingOffer = outcome.bettingOffer
                    
                    if !bettingOffer.isAvailable || bettingOffer.decimalOdd.isNaN {
                        weakSelf.drawButton.isUserInteractionEnabled = false
                        weakSelf.drawButton.alpha = 0.5
                        weakSelf.setDrawOddValueLabel(toText: "-")
                    }
                    else {
                        weakSelf.drawButton.isUserInteractionEnabled = true
                        weakSelf.drawButton.alpha = 1.0
                        
                        let newOddValue = bettingOffer.decimalOdd
                        if let currentOddValue = weakSelf.currentDrawOddValue {
                            if newOddValue > currentOddValue {
                                weakSelf.highlightOddChangeUp(animated: true,
                                                              upChangeOddValueImage: weakSelf.drawUpChangeOddValueImageView,
                                                              baseView: weakSelf.drawButton)
                            }
                            else if newOddValue < currentOddValue {
                                weakSelf.highlightOddChangeDown(animated: true,
                                                                downChangeOddValueImage: weakSelf.drawDownChangeOddValueImageView,
                                                                baseView: weakSelf.drawButton)
                            }
                        }
                        weakSelf.currentDrawOddValue = newOddValue
                        weakSelf.setDrawOddValueLabel(toText: OddFormatter.formatOdd(withValue: newOddValue))
                    }
                })
        }
        
        if let outcome = availableOutcomes[safe: 2] {

            if let nameDigit1 = market?.nameDigit1 {
                if outcome.typeName.contains("\(nameDigit1)") {
                    self.awayOutcomeNameLabel.text = outcome.typeName
                }
                else {
                    self.awayOutcomeNameLabel.text = "\(outcome.typeName) \(nameDigit1)"
                }
            }
            else {
                self.awayOutcomeNameLabel.text = outcome.typeName
            }

            self.awayButton.isHidden = false

            self.rightOutcome = outcome
            self.isRightOutcomeButtonSelected = Env.betslipManager.hasBettingTicket(withId: outcome.bettingOffer.id)
            
            // Check for SportRadar invalid odd
            if !outcome.bettingOffer.decimalOdd.isNaN && outcome.bettingOffer.isAvailable {
                self.setAwayOddValueLabel(toText: OddFormatter.formatOdd(withValue: outcome.bettingOffer.decimalOdd))
            }
            else {
                self.awayButton.isUserInteractionEnabled = false
                self.awayButton.alpha = 0.5
                self.setAwayOddValueLabel(toText: "-")
            }
            
            self.rightOddButtonSubscriber = Env.servicesProvider
                .subscribeToEventOnListsOutcomeUpdates(withId: outcome.bettingOffer.id)
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { completion in
                    
                }, receiveValue: { [weak self] serviceProviderOutcome in
                    
                    guard let weakSelf = self,
                    let serviceProviderOutcome = serviceProviderOutcome
                    else { return }
                    
                    let outcome = ServiceProviderModelMapper.outcome(fromServiceProviderOutcome: serviceProviderOutcome)
                    
                    let bettingOffer = outcome.bettingOffer
                    
                    if !bettingOffer.isAvailable || bettingOffer.decimalOdd.isNaN {
                        weakSelf.awayButton.isUserInteractionEnabled = false
                        weakSelf.awayButton.alpha = 0.5
                        weakSelf.setAwayOddValueLabel(toText: "-")
                    }
                    else {
                        weakSelf.awayButton.isUserInteractionEnabled = true
                        weakSelf.awayButton.alpha = 1.0
                        
                        let newOddValue = bettingOffer.decimalOdd
                        if let currentOddValue = weakSelf.currentAwayOddValue {
                            if newOddValue > currentOddValue {
                                weakSelf.highlightOddChangeUp(animated: true,
                                                              upChangeOddValueImage: weakSelf.awayUpChangeOddValueImageView,
                                                              baseView: weakSelf.awayButton)
                            }
                            else if newOddValue < currentOddValue {
                                weakSelf.highlightOddChangeDown(animated: true,
                                                                downChangeOddValueImage: weakSelf.awayDownChangeOddValueImageView,
                                                                baseView: weakSelf.awayButton)
                            }
                        }
                        
                        weakSelf.currentAwayOddValue = newOddValue
                        weakSelf.setAwayOddValueLabel(toText: OddFormatter.formatOdd(withValue: newOddValue))
                    }
                })
        }
    }
    
    func selectLeftOddButton() {
        self.setupWithTheme()
    }

    func deselectLeftOddButton() {
        self.setupWithTheme()
    }
    
    @objc func didTapLeftOddButton() {

        guard
            let market = self.viewModel?.highlightedMarket.content,
            let outcome = self.leftOutcome
        else {
            return
        }

        let bettingTicket = BettingTicket(id: outcome.bettingOffer.id,
                                          outcomeId: outcome.id,
                                          marketId: market.id,
                                          matchId: market.eventId ?? "",
                                          decimalOdd: outcome.bettingOffer.decimalOdd,
                                          isAvailable: true,
                                          matchDescription: market.eventName ?? "",
                                          marketDescription: market.name,
                                          outcomeDescription: outcome.typeName,
                                          homeParticipantName: market.homeParticipant,
                                          awayParticipantName: market.awayParticipant,
                                          sportIdCode: market.sport?.id)

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
                let market = self.viewModel?.highlightedMarket.content,
                let outcome = self.leftOutcome
            else {
                return
            }
            
            let bettingTicket = BettingTicket(id: outcome.bettingOffer.id,
                                              outcomeId: outcome.id,
                                              marketId: market.id,
                                              matchId: market.eventId ?? "",
                                              decimalOdd: outcome.bettingOffer.decimalOdd,
                                              isAvailable: true,
                                              matchDescription: market.eventName ?? "",
                                              marketDescription: market.name,
                                              outcomeDescription: outcome.typeName,
                                              homeParticipantName: market.homeParticipant,
                                              awayParticipantName: market.awayParticipant,
                                              sportIdCode: market.sport?.id)

            self.didLongPressOdd(bettingTicket)
        }
    }

    //
    func selectMiddleOddButton() {
        self.setupWithTheme()
    }

    func deselectMiddleOddButton() {
        self.setupWithTheme()
    }

    @objc func didTapMiddleOddButton() {
        guard
            let market = self.viewModel?.highlightedMarket.content,
            let outcome = self.middleOutcome
        else {
            return
        }

        let bettingTicket = BettingTicket(id: outcome.bettingOffer.id,
                                          outcomeId: outcome.id,
                                          marketId: market.id,
                                          matchId: market.eventId ?? "",
                                          decimalOdd: outcome.bettingOffer.decimalOdd,
                                          isAvailable: true,
                                          matchDescription: market.eventName ?? "",
                                          marketDescription: market.name,
                                          outcomeDescription: outcome.typeName,
                                          homeParticipantName: market.homeParticipant,
                                          awayParticipantName: market.awayParticipant,
                                          sportIdCode: market.sport?.id)

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
                let market = self.viewModel?.highlightedMarket.content,
                let outcome = self.middleOutcome
            else {
                return
            }

            let bettingTicket = BettingTicket(id: outcome.bettingOffer.id,
                                              outcomeId: outcome.id,
                                              marketId: market.id,
                                              matchId: market.eventId ?? "",
                                              decimalOdd: outcome.bettingOffer.decimalOdd,
                                              isAvailable: true,
                                              matchDescription: market.eventName ?? "",
                                              marketDescription: market.name,
                                              outcomeDescription: outcome.typeName,
                                              homeParticipantName: market.homeParticipant,
                                              awayParticipantName: market.awayParticipant,
                                              sportIdCode: market.sport?.id)

            self.didLongPressOdd(bettingTicket)

        }
    }
    
    @objc private func didTapMatchView() {
        
        if let viewModel = self.viewModel,
           let matchId = viewModel.highlightedMarket.content.eventId {
            self.tappedMatchIdAction(matchId)
        }
        
    }

    //
    func selectRightOddButton() {
        self.setupWithTheme()
    }

    func deselectRightOddButton() {
        self.setupWithTheme()
    }

    @objc func didTapRightOddButton() {
        guard
            let market = self.viewModel?.highlightedMarket.content,
            let outcome = self.rightOutcome
        else {
            return
        }

        let bettingTicket = BettingTicket(id: outcome.bettingOffer.id,
                                          outcomeId: outcome.id,
                                          marketId: market.id,
                                          matchId: market.eventId ?? "",
                                          decimalOdd: outcome.bettingOffer.decimalOdd,
                                          isAvailable: true,
                                          matchDescription: market.eventName ?? "",
                                          marketDescription: market.name,
                                          outcomeDescription: outcome.typeName,
                                          homeParticipantName: market.homeParticipant,
                                          awayParticipantName: market.awayParticipant,
                                          sportIdCode: market.sport?.id)

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
                let market = self.viewModel?.highlightedMarket.content,
                let outcome = self.rightOutcome
            else {
                return
            }

            let bettingTicket = BettingTicket(id: outcome.bettingOffer.id,
                                              outcomeId: outcome.id,
                                              marketId: market.id,
                                              matchId: market.eventId ?? "",
                                              decimalOdd: outcome.bettingOffer.decimalOdd,
                                              isAvailable: true,
                                              matchDescription: market.eventName ?? "",
                                              marketDescription: market.name,
                                              outcomeDescription: outcome.typeName,
                                              homeParticipantName: market.homeParticipant,
                                              awayParticipantName: market.awayParticipant,
                                              sportIdCode: market.sport?.id)

            self.didLongPressOdd(bettingTicket)

        }
    }
    
    @objc func didTapFavoriteIcon() {
        if Env.userSessionStore.isUserLogged() {
            if let matchId = self.viewModel?.highlightedMarket.content.eventId {
                self.markAsFavorite(matchId: matchId)
            }
        }
        else {
            let loginViewController = Router.navigationController(with: LoginViewController())
            self.viewController?.present(loginViewController, animated: true, completion: nil)
        }
    }
    
    func markAsFavorite(matchId: String) {
        
        if Env.favoritesManager.isEventFavorite(eventId: matchId) {
            Env.favoritesManager.removeFavorite(eventId: matchId, favoriteType: .match)
            self.isFavorite = false
        }
        else {
            Env.favoritesManager.addFavorite(eventId: matchId, favoriteType: .match)
            self.isFavorite = true
        }
        
    }
    
    private func setHomeOddValueLabel(toText text: String) {
        self.homeOutcomeValueLabel.text = text
    }

    private func setDrawOddValueLabel(toText text: String) {
        self.drawOutcomeValueLabel.text = text
    }

    private func setAwayOddValueLabel(toText text: String) {
        self.awayOutcomeValueLabel.text = text
    }
    
    @objc private func didTapMixMatch() {
        if let viewModel = self.viewModel,
           let matchId = viewModel.highlightedMarket.content.eventId {
            self.tappedMixMatchAction(matchId)
        }
    }
    
    func highlightOddChangeUp(animated: Bool = true, upChangeOddValueImage: UIImageView, baseView: UIView) {
        baseView.layer.borderWidth = 1.5
        UIView.animate(withDuration: animated ? 0.4 : 0.0, delay: 0.0, options: .curveEaseIn, animations: {
            upChangeOddValueImage.alpha = 1.0
            self.animateBorderColor(view: baseView, color: UIColor.App.alertSuccess, duration: animated ? 0.4 : 0.0)
        }, completion: nil)

        UIView.animate(withDuration: animated ? 0.4 : 0.0, delay: 3.0, options: [.curveEaseIn, .allowUserInteraction], animations: {
            upChangeOddValueImage.alpha = 0.0
            self.animateBorderColor(view: baseView, color: UIColor.clear, duration: animated ? 0.4 : 0.0)
        }, completion: nil)
    }

    func highlightOddChangeDown(animated: Bool = true, downChangeOddValueImage: UIImageView, baseView: UIView) {
        baseView.layer.borderWidth = 1.5
        UIView.animate(withDuration: animated ? 0.4 : 0.0, delay: 0.0, options: .curveEaseIn, animations: {
            downChangeOddValueImage.alpha = 1.0
            self.animateBorderColor(view: baseView, color: UIColor.App.alertError, duration: animated ? 0.4 : 0.0)
        }, completion: nil)

        UIView.animate(withDuration: animated ? 0.4 : 0.0, delay: 3.0, options: [.curveEaseIn, .allowUserInteraction], animations: {
            downChangeOddValueImage.alpha = 0.0
            self.animateBorderColor(view: baseView, color: UIColor.clear, duration: animated ? 0.4 : 0.0)
        }, completion: nil)

    }
    
    private func animateBorderColor(view: UIView, color: UIColor, duration: Double) {
        let animation = CABasicAnimation(keyPath: "borderColor")
        animation.fromValue = layer.borderColor
        animation.toValue = color.cgColor
        animation.duration = duration
        view.layer.add(animation, forKey: "borderColor")
        view.layer.borderColor = color.cgColor
    }
    
    // MARK: - Layout
    override func layoutSubviews() {
        super.layoutSubviews()

        self.teamPillContainerView.layer.cornerRadius = self.teamPillContainerView.frame.height/2
        self.sportImageView.layer.cornerRadius = self.sportImageView.frame.height/2
        self.countryImageView.layer.cornerRadius = self.countryImageView.frame.height/2
        
    }

}

extension ProChoiceHighlightCollectionViewCell {

    // MARK: - UI Setup
    private func setupSubviews() {
        self.contentView.addSubview(self.containerView)

        self.containerView.addSubview(self.eventImageBaseView)
        self.containerView.addSubview(self.backgroundImageView)
        self.containerView.addSubview(self.gradientBorderView)
        self.containerView.addSubview(self.topSeparatorAlphaLineView)
        self.containerView.addSubview(self.containerStackView)
        self.containerView.addSubview(self.cashbackIconImageView)

        self.eventImageBaseView.addSubview(self.eventImageView)

        self.containerStackView.addArrangedSubview(self.leagueInfoContainerView)
        self.leagueInfoContainerView.addSubview(self.leagueInfoStackView)

        self.leagueInfoStackView.addArrangedSubview(self.favoriteImageView)

        self.leagueInfoStackView.addArrangedSubview(self.favoriteImageView)
        self.leagueInfoStackView.addArrangedSubview(self.sportImageView)
        self.leagueInfoStackView.addArrangedSubview(self.countryImageView)
        self.leagueInfoStackView.addArrangedSubview(self.leagueNameLabel)
        self.leagueInfoContainerView.addSubview(self.cashbackImageView)

        self.containerView.addSubview(self.favoriteButton)
        self.containerView.bringSubviewToFront(self.favoriteButton)

        self.containerStackView.addArrangedSubview(self.eventInfoContainerView)
                
        self.containerStackView.addArrangedSubview(self.oddsStackView)

        self.containerStackView.addArrangedSubview(self.bottomButtonsContainerStackView)
        self.bottomButtonsContainerStackView.addArrangedSubview(self.seeAllMarketsButton)
        
        self.bottomButtonsContainerStackView.addArrangedSubview(self.mixMatchContainerView)
        self.mixMatchContainerView.addSubview(self.mixMatchBaseView)
        self.mixMatchBaseView.addSubview(self.mixMatchBackgroundImageView)
        self.mixMatchBaseView.addSubview(self.mixMatchIconImageView)
        self.mixMatchBaseView.addSubview(self.mixMatchLabel)
        self.mixMatchBaseView.addSubview(self.mixMatchNavigationIconImageView)

        self.teamPillContainerView.addSubview(self.teamsLabel)
        self.eventInfoContainerView.addSubview(self.teamPillContainerView)
        self.eventInfoContainerView.addSubview(self.marketNameLabel)
        self.eventInfoContainerView.addSubview(self.eventDateLabel)
        self.eventInfoContainerView.addSubview(self.eventTimeLabel)

        self.homeButton.addSubview(self.homeOutcomeBaseView)
        self.homeOutcomeBaseView.addSubview(self.homeOutcomeNameLabel)
        self.homeOutcomeBaseView.addSubview(self.homeOutcomeValueLabel)
        
        self.homeButton.addSubview(self.homeUpChangeOddValueImageView)
        self.homeButton.addSubview(self.homeDownChangeOddValueImageView)
        
        self.drawButton.addSubview(self.drawOutcomeBaseView)
        self.drawOutcomeBaseView.addSubview(self.drawOutcomeNameLabel)
        self.drawOutcomeBaseView.addSubview(self.drawOutcomeValueLabel)
        
        self.drawButton.addSubview(self.drawUpChangeOddValueImageView)
        self.drawButton.addSubview(self.drawDownChangeOddValueImageView)
        
        self.awayButton.addSubview(self.awayOutcomeBaseView)
        self.awayOutcomeBaseView.addSubview(self.awayOutcomeNameLabel)
        self.awayOutcomeBaseView.addSubview(self.awayOutcomeValueLabel)
        
        self.awayButton.addSubview(self.awayUpChangeOddValueImageView)
        self.awayButton.addSubview(self.awayDownChangeOddValueImageView)
        
        self.oddsStackView.addArrangedSubview(self.homeButton)
        self.oddsStackView.addArrangedSubview(self.drawButton)
        self.oddsStackView.addArrangedSubview(self.awayButton)

        //

        self.oddsStackView.layoutMargins = UIEdgeInsets(top: 6, left: 16, bottom: 6, right: 16)

        self.bottomButtonsContainerStackView.isLayoutMarginsRelativeArrangement = true
        self.bottomButtonsContainerStackView.layoutMargins = UIEdgeInsets(top: 7, left: 16, bottom: 2, right: 16)
        //
        
        self.initConstraints()
        
        self.leagueInfoStackView.setNeedsLayout()
        self.leagueInfoStackView.layoutIfNeeded()
        
        self.setNeedsLayout()
        self.layoutIfNeeded()
    }
    
    private func initConstraints() {


        NSLayoutConstraint.activate([
            self.containerView.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 0),
            self.containerView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 0),
            self.containerView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: 0),
            self.containerView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: 0),

            self.containerView.leadingAnchor.constraint(equalTo: self.gradientBorderView.leadingAnchor),
            self.containerView.trailingAnchor.constraint(equalTo: self.gradientBorderView.trailingAnchor),
            self.containerView.topAnchor.constraint(equalTo: self.gradientBorderView.topAnchor),
            self.containerView.bottomAnchor.constraint(equalTo: self.gradientBorderView.bottomAnchor),

            self.eventImageBaseView.topAnchor.constraint(equalTo: self.containerView.topAnchor),
            self.eventImageBaseView.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor),
            self.eventImageBaseView.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor),
            self.eventImageBaseView.heightAnchor.constraint(equalToConstant: 100),

            self.eventImageView.leadingAnchor.constraint(equalTo: self.eventImageBaseView.leadingAnchor),
            self.eventImageView.trailingAnchor.constraint(equalTo: self.eventImageBaseView.trailingAnchor),
            self.eventImageView.topAnchor.constraint(equalTo: self.eventImageBaseView.topAnchor),

            self.containerStackView.topAnchor.constraint(equalTo: self.eventImageBaseView.bottomAnchor),
            self.containerStackView.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor),
            self.containerStackView.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor),
            self.containerStackView.bottomAnchor.constraint(equalTo: self.containerView.bottomAnchor, constant: -8),

            self.leagueInfoStackView.heightAnchor.constraint(equalToConstant: 13),
            self.leagueInfoStackView.leadingAnchor.constraint(equalTo: self.leagueInfoContainerView.leadingAnchor, constant: 16),
            self.leagueInfoStackView.trailingAnchor.constraint(equalTo: self.leagueInfoContainerView.trailingAnchor, constant: -16),
            self.leagueInfoStackView.topAnchor.constraint(equalTo: self.leagueInfoContainerView.topAnchor, constant: 8),
            self.leagueInfoStackView.bottomAnchor.constraint(equalTo: self.leagueInfoContainerView.bottomAnchor, constant: -8),

            self.cashbackIconImageView.widthAnchor.constraint(equalToConstant: 18),
            self.cashbackIconImageView.heightAnchor.constraint(equalTo: self.cashbackIconImageView.widthAnchor),
            self.cashbackIconImageView.centerYAnchor.constraint(equalTo: self.leagueInfoStackView.centerYAnchor),
            self.cashbackIconImageView.trailingAnchor.constraint(equalTo: self.leagueInfoStackView.trailingAnchor, constant: -4),

            self.topSeparatorAlphaLineView.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor, constant: 0),
            self.topSeparatorAlphaLineView.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: 0),
            self.topSeparatorAlphaLineView.heightAnchor.constraint(equalToConstant: 1),
            self.topSeparatorAlphaLineView.bottomAnchor.constraint(equalTo: self.eventInfoContainerView.topAnchor, constant: 2),

            self.favoriteImageView.widthAnchor.constraint(equalTo: self.favoriteImageView.heightAnchor),
            self.sportImageView.widthAnchor.constraint(equalTo: self.sportImageView.heightAnchor),
            self.countryImageView.widthAnchor.constraint(equalTo: self.countryImageView.heightAnchor),

            self.cashbackImageView.centerYAnchor.constraint(equalTo: self.leagueInfoContainerView.centerYAnchor),
            self.cashbackImageView.trailingAnchor.constraint(equalTo: self.leagueInfoContainerView.trailingAnchor),
            self.cashbackImageView.widthAnchor.constraint(equalToConstant: 14),
            self.cashbackImageView.widthAnchor.constraint(equalTo: self.cashbackImageView.heightAnchor),
            
            self.favoriteButton.centerXAnchor.constraint(equalTo: self.favoriteImageView.centerXAnchor),
            self.favoriteButton.centerYAnchor.constraint(equalTo: self.favoriteImageView.centerYAnchor),
            self.favoriteButton.widthAnchor.constraint(equalToConstant: 40),
            self.favoriteButton.heightAnchor.constraint(equalTo: self.favoriteButton.widthAnchor),

            self.eventInfoContainerView.heightAnchor.constraint(equalToConstant: 60),

            self.backgroundImageView.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor),
            self.backgroundImageView.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor),
            self.backgroundImageView.topAnchor.constraint(equalTo: self.eventImageBaseView.bottomAnchor),
            self.backgroundImageView.bottomAnchor.constraint(equalTo: self.containerView.bottomAnchor),

            self.marketNameLabel.leadingAnchor.constraint(equalTo: self.eventInfoContainerView.leadingAnchor, constant: 16),
            self.marketNameLabel.topAnchor.constraint(equalTo: self.eventInfoContainerView.topAnchor, constant: 6),

            self.teamsLabel.topAnchor.constraint(equalTo: self.teamPillContainerView.topAnchor, constant: 5),
            self.teamsLabel.bottomAnchor.constraint(equalTo: self.teamPillContainerView.bottomAnchor, constant: -5),
            self.teamsLabel.trailingAnchor.constraint(equalTo: self.teamPillContainerView.trailingAnchor, constant: -9),
            self.teamsLabel.leadingAnchor.constraint(equalTo: self.teamPillContainerView.leadingAnchor, constant: 40),

            self.teamsLabel.leadingAnchor.constraint(equalTo: self.eventInfoContainerView.leadingAnchor, constant: 16),
            self.teamPillContainerView.bottomAnchor.constraint(equalTo: self.eventInfoContainerView.bottomAnchor, constant: -6),

            self.eventDateLabel.centerYAnchor.constraint(equalTo: self.marketNameLabel.centerYAnchor),
            self.eventDateLabel.trailingAnchor.constraint(equalTo: self.eventInfoContainerView.trailingAnchor, constant: -16),
            self.eventDateLabel.leadingAnchor.constraint(greaterThanOrEqualTo: self.marketNameLabel.trailingAnchor, constant: 5),
            self.eventTimeLabel.topAnchor.constraint(equalTo: self.teamPillContainerView.topAnchor),
            self.eventTimeLabel.trailingAnchor.constraint(equalTo: self.eventInfoContainerView.trailingAnchor, constant: -16),

            self.homeButton.heightAnchor.constraint(equalToConstant: 40),
            self.drawButton.heightAnchor.constraint(equalTo: self.homeButton.heightAnchor),
            self.awayButton.heightAnchor.constraint(equalTo: self.homeButton.heightAnchor),

            self.seeAllMarketsButton.heightAnchor.constraint(equalToConstant: 27),

            self.oddsStackView.heightAnchor.constraint(equalToConstant: 52),
        ])

        NSLayoutConstraint.activate([
            self.homeOutcomeBaseView.leadingAnchor.constraint(equalTo: self.homeButton.leadingAnchor, constant: 2),
            self.homeOutcomeBaseView.trailingAnchor.constraint(equalTo: self.homeButton.trailingAnchor, constant: -2),
            self.homeOutcomeBaseView.centerYAnchor.constraint(equalTo: self.homeButton.centerYAnchor),
            
            self.homeOutcomeNameLabel.centerXAnchor.constraint(equalTo: self.homeOutcomeBaseView.centerXAnchor),
            self.homeOutcomeNameLabel.topAnchor.constraint(equalTo: self.homeOutcomeBaseView.topAnchor, constant: 1),
            self.homeOutcomeNameLabel.leadingAnchor.constraint(equalTo: self.homeOutcomeNameLabel.leadingAnchor, constant: 1),
            
            self.homeOutcomeValueLabel.topAnchor.constraint(equalTo: self.homeOutcomeNameLabel.bottomAnchor, constant: 4),
            self.homeOutcomeValueLabel.centerXAnchor.constraint(equalTo: self.homeOutcomeBaseView.centerXAnchor),
            self.homeOutcomeValueLabel.bottomAnchor.constraint(equalTo: self.homeOutcomeBaseView.bottomAnchor, constant: -1),
            
            self.homeUpChangeOddValueImageView.widthAnchor.constraint(equalToConstant: 11),
            self.homeUpChangeOddValueImageView.heightAnchor.constraint(equalToConstant: 9),
            self.homeUpChangeOddValueImageView.centerYAnchor.constraint(equalTo: self.homeButton.centerYAnchor),
            self.homeUpChangeOddValueImageView.trailingAnchor.constraint(equalTo: self.homeButton.trailingAnchor, constant: -5),
            
            self.homeDownChangeOddValueImageView.widthAnchor.constraint(equalToConstant: 11),
            self.homeDownChangeOddValueImageView.heightAnchor.constraint(equalToConstant: 9),
            self.homeDownChangeOddValueImageView.centerYAnchor.constraint(equalTo: self.homeButton.centerYAnchor),
            self.homeDownChangeOddValueImageView.trailingAnchor.constraint(equalTo: self.homeButton.trailingAnchor, constant: -5),
            
            self.drawOutcomeBaseView.leadingAnchor.constraint(equalTo: self.drawButton.leadingAnchor, constant: 2),
            self.drawOutcomeBaseView.trailingAnchor.constraint(equalTo: self.drawButton.trailingAnchor, constant: -2),
            self.drawOutcomeBaseView.centerYAnchor.constraint(equalTo: self.drawButton.centerYAnchor),

            self.drawOutcomeNameLabel.centerXAnchor.constraint(equalTo: self.drawOutcomeBaseView.centerXAnchor),
            self.drawOutcomeNameLabel.topAnchor.constraint(equalTo: self.drawOutcomeBaseView.topAnchor, constant: 1),
            self.drawOutcomeNameLabel.leadingAnchor.constraint(equalTo: self.drawOutcomeBaseView.leadingAnchor, constant: 1),
            
            self.drawOutcomeValueLabel.topAnchor.constraint(equalTo: self.drawOutcomeNameLabel.bottomAnchor, constant: 4),
            self.drawOutcomeValueLabel.centerXAnchor.constraint(equalTo: self.drawOutcomeBaseView.centerXAnchor),
            self.drawOutcomeValueLabel.bottomAnchor.constraint(equalTo: self.drawOutcomeBaseView.bottomAnchor, constant: -1),
            
            self.drawUpChangeOddValueImageView.widthAnchor.constraint(equalToConstant: 11),
            self.drawUpChangeOddValueImageView.heightAnchor.constraint(equalToConstant: 9),
            self.drawUpChangeOddValueImageView.centerYAnchor.constraint(equalTo: self.drawButton.centerYAnchor),
            self.drawUpChangeOddValueImageView.trailingAnchor.constraint(equalTo: self.drawButton.trailingAnchor, constant: -5),
            
            self.drawDownChangeOddValueImageView.widthAnchor.constraint(equalToConstant: 11),
            self.drawDownChangeOddValueImageView.heightAnchor.constraint(equalToConstant: 9),
            self.drawDownChangeOddValueImageView.centerYAnchor.constraint(equalTo: self.drawButton.centerYAnchor),
            self.drawDownChangeOddValueImageView.trailingAnchor.constraint(equalTo: self.drawButton.trailingAnchor, constant: -5),

            self.awayOutcomeBaseView.leadingAnchor.constraint(equalTo: self.awayButton.leadingAnchor, constant: 2),
            self.awayOutcomeBaseView.trailingAnchor.constraint(equalTo: self.awayButton.trailingAnchor, constant: -2),
            self.awayOutcomeBaseView.centerYAnchor.constraint(equalTo: self.awayButton.centerYAnchor),
            
            self.awayOutcomeNameLabel.centerXAnchor.constraint(equalTo: self.awayOutcomeBaseView.centerXAnchor),
            self.awayOutcomeNameLabel.topAnchor.constraint(equalTo: self.awayOutcomeBaseView.topAnchor, constant: 1),
            self.awayOutcomeNameLabel.leadingAnchor.constraint(equalTo: self.awayOutcomeBaseView.leadingAnchor, constant: 1),
            
            self.awayOutcomeValueLabel.topAnchor.constraint(equalTo: self.awayOutcomeNameLabel.bottomAnchor, constant: 4),
            self.awayOutcomeValueLabel.centerXAnchor.constraint(equalTo: self.awayOutcomeBaseView.centerXAnchor),
            self.awayOutcomeValueLabel.bottomAnchor.constraint(equalTo: self.awayOutcomeBaseView.bottomAnchor, constant: -1),
            
            self.awayUpChangeOddValueImageView.widthAnchor.constraint(equalToConstant: 11),
            self.awayUpChangeOddValueImageView.heightAnchor.constraint(equalToConstant: 9),
            self.awayUpChangeOddValueImageView.centerYAnchor.constraint(equalTo: self.awayButton.centerYAnchor),
            self.awayUpChangeOddValueImageView.trailingAnchor.constraint(equalTo: self.awayButton.trailingAnchor, constant: -5),
            
            self.awayDownChangeOddValueImageView.widthAnchor.constraint(equalToConstant: 11),
            self.awayDownChangeOddValueImageView.heightAnchor.constraint(equalToConstant: 9),
            self.awayDownChangeOddValueImageView.centerYAnchor.constraint(equalTo: self.awayButton.centerYAnchor),
            self.awayDownChangeOddValueImageView.trailingAnchor.constraint(equalTo: self.awayButton.trailingAnchor, constant: -5)
        ])
        
        NSLayoutConstraint.activate([
            self.mixMatchContainerView.heightAnchor.constraint(equalToConstant: 27),

            self.mixMatchBaseView.heightAnchor.constraint(equalToConstant: 27),
            self.mixMatchBaseView.leadingAnchor.constraint(equalTo: self.mixMatchContainerView.leadingAnchor, constant: 0),
            self.mixMatchBaseView.trailingAnchor.constraint(equalTo: self.mixMatchContainerView.trailingAnchor, constant: 0),
            self.mixMatchBaseView.topAnchor.constraint(equalTo: self.mixMatchContainerView.topAnchor),
            
            self.mixMatchBackgroundImageView.leadingAnchor.constraint(equalTo: self.mixMatchBaseView.leadingAnchor),
            self.mixMatchBackgroundImageView.trailingAnchor.constraint(equalTo: self.mixMatchBaseView.trailingAnchor),
            self.mixMatchBackgroundImageView.topAnchor.constraint(equalTo: self.mixMatchBaseView.topAnchor),
            self.mixMatchBackgroundImageView.bottomAnchor.constraint(equalTo: self.mixMatchBaseView.bottomAnchor),
        
            self.mixMatchLabel.centerXAnchor.constraint(equalTo: self.mixMatchBaseView.centerXAnchor),
            self.mixMatchLabel.centerYAnchor.constraint(equalTo: self.mixMatchBaseView.centerYAnchor),
            
            self.mixMatchIconImageView.widthAnchor.constraint(equalToConstant: 21),
            self.mixMatchIconImageView.heightAnchor.constraint(equalToConstant: 25),
            self.mixMatchIconImageView.trailingAnchor.constraint(equalTo: self.mixMatchLabel.leadingAnchor, constant: -2),
            self.mixMatchIconImageView.centerYAnchor.constraint(equalTo: self.mixMatchLabel.centerYAnchor),
            
            self.mixMatchNavigationIconImageView.widthAnchor.constraint(equalToConstant: 11),
            self.mixMatchNavigationIconImageView.heightAnchor.constraint(equalToConstant: 13),
            self.mixMatchNavigationIconImageView.leadingAnchor.constraint(equalTo: self.mixMatchLabel.trailingAnchor, constant: 6),
            self.mixMatchNavigationIconImageView.centerYAnchor.constraint(equalTo: self.mixMatchLabel.centerYAnchor),

        ])
    }

    // MARK: - UI Creation    
    private func createContainerView() -> UIView {
        let view = UIView()
        view.backgroundColor = UIColor.App.backgroundPrimary
        view.layer.cornerRadius = 8
        view.translatesAutoresizingMaskIntoConstraints = false
        view.clipsToBounds = true
        return view
    }

    private func createGradientBorderView() -> GradientBorderView {
        let gradientBorderView = GradientBorderView()
        gradientBorderView.translatesAutoresizingMaskIntoConstraints = false
        gradientBorderView.gradientBorderWidth = 1.2
        gradientBorderView.gradientCornerRadius = 9

        gradientBorderView.gradientColors = [UIColor.App.cardBorderLineGradient1,
                                             UIColor.App.cardBorderLineGradient2,
                                             UIColor.App.cardBorderLineGradient3]
        gradientBorderView.clipsToBounds = true
        return gradientBorderView
    }

    private func createContainerStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.spacing = 0
        stackView.translatesAutoresizingMaskIntoConstraints = false

        stackView.backgroundColor = .green

        return stackView
    }

    private func createEventImageBaseView() -> UIView {
        let view = UIView()
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private func createEventImageView() -> ScaleAspectFitImageView {
        let imageView = ScaleAspectFitImageView()
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }

    private func createLeagueInfoContainerView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private func createLeagueInfoStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false

        stackView.backgroundColor = .red

        return stackView
    }
    
    private func createFavoriteButton() -> UIButton {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("", for: .normal)
        button.setImage(nil, for: .normal)
        return button
    }

    private func createIconImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }
    
    private func createCountryIconImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }

    private func createLeagueNameLabel() -> UILabel {
        let label = UILabel()
        label.font = AppFont.with(type: .semibold, size: 11)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "createLeagueNameLabel"
        return label
    }
    
    private func createEventInfoContainerView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
    
    private func createBackgroundImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "pro_choices_background")
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }
    
    private func createEventDateLabel() -> UILabel {
        let label = UILabel()
        label.font = AppFont.with(type: .bold, size: 11)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "createEventDateLabel"
        label.setContentHuggingPriority(.required, for: .horizontal)
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        return label
    }
    
    private func createEventTimeLabel() -> UILabel {
        let label = UILabel()
        label.font = AppFont.with(type: .bold, size: 11)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "createEventTimeLabel"

        return label
    }

    private func createMarketNameLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFont.with(type: .bold, size: 16)
        label.textAlignment = .center
        label.text = "Market Name Label"
        label.setContentHuggingPriority(.defaultLow, for: .horizontal)
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return label
    }
    
    private func createTeamPillContainerView() -> GradientBorderView {
        var gradientBorderView = GradientBorderView()
        gradientBorderView.translatesAutoresizingMaskIntoConstraints = false
        gradientBorderView.gradientBorderWidth = 1
        gradientBorderView.gradientCornerRadius = 8
        
        gradientBorderView.gradientColors = [UIColor.App.highlightSecondary,
                                             UIColor.App.highlightPrimary]
        
        gradientBorderView.gradientStartPoint = CGPoint(x: 0, y: 0.5)
        gradientBorderView.gradientEndPoint = CGPoint(x: 2, y: 0.5)

        return gradientBorderView
    }

    private func createTeamsLabel() -> UILabel {
        let label = UILabel()
        label.font = AppFont.with(type: .semibold, size: 11)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "createTeamsLabel"

        return label
    }
    
    private func createOddsStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.isLayoutMarginsRelativeArrangement = true
        return stackView
    }
    
    private func createOutcomeBaseView() -> UIView {
        let outcomeBaseView = UIView()
        outcomeBaseView.translatesAutoresizingMaskIntoConstraints = false
        outcomeBaseView.layer.cornerRadius = 4.5
        return outcomeBaseView
    }
    
    private func createOutcomeContainerBaseView() -> UIView {
        let outcomeBaseView = UIView()
        outcomeBaseView.translatesAutoresizingMaskIntoConstraints = false
        return outcomeBaseView
    }

    private func createOutcomeNameLabel() -> UILabel {
        let outcomeNameLabel = UILabel()
        outcomeNameLabel.translatesAutoresizingMaskIntoConstraints = false
        outcomeNameLabel.text = "Outcome"
        outcomeNameLabel.textAlignment = .center
        outcomeNameLabel.font = AppFont.with(type: .medium, size: 10)
        return outcomeNameLabel
    }

    private func createOutcomeValueLabel() -> UILabel {
        let outcomeValueLabel = UILabel()
        outcomeValueLabel.translatesAutoresizingMaskIntoConstraints = false
        outcomeValueLabel.text = "1.29"
        outcomeValueLabel.textAlignment = .center
        outcomeValueLabel.font = AppFont.with(type: .bold, size: 14)
        return outcomeValueLabel
    }

    private func createBottomButtonsContainerStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false

        stackView.backgroundColor = .green

        return stackView
    }

    private func createSeeAllMarketsButton() -> UIButton {
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor.App.buttonBackgroundPrimary
        button.setTitle(localized("see_game_details"), for: .normal)
        button.titleLabel?.font = AppFont.with(type: .semibold, size: 14)
        button.layer.cornerRadius = CornerRadius.view
        button.setImage(UIImage(named: "arrow_right_icon"), for: .normal)
        
//        button.setInsets(forContentPadding: UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5), imageTitlePadding: 5)
        button.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
        button.titleLabel?.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
        button.imageView?.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
        button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
        button.imageEdgeInsets = UIEdgeInsets(top: 2, left: -10, bottom: 0, right: 0)

        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }

    private func createTopSeparatorAlphaLineView() -> FadingView {
        let fadingView = FadingView()
        fadingView.translatesAutoresizingMaskIntoConstraints = false
        fadingView.colors = [.clear, .black, .black, .clear]
        fadingView.startPoint = CGPoint(x: 0.0, y: 0.5)
        fadingView.endPoint = CGPoint(x: 1.0, y: 0.5)
        fadingView.fadeLocations = [0.0, 0.42, 0.58, 1.0]
        return fadingView
    }
    
    private func createHomeUpChangeOddValueImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "odd_up_icon")
        imageView.alpha = 0
        return imageView
    }
    
    private func createHomeDownChangeOddValueImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "odd_down_icon")
        imageView.alpha = 0
        return imageView
    }
    
    private func createDrawUpChangeOddValueImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "odd_up_icon")
        imageView.alpha = 0
        return imageView
    }
    
    private func createDrawDownChangeOddValueImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "odd_down_icon")
        imageView.alpha = 0
        return imageView
    }
    
    private func createAwayUpChangeOddValueImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "odd_up_icon")
        imageView.alpha = 0
        return imageView
    }
    
    private func createAwayDownChangeOddValueImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "odd_down_icon")
        imageView.alpha = 0
        return imageView
    }
    
    private func createMixMatchContainerView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.clipsToBounds = true
        return view
    }
    
    private func createMixMatchBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = CornerRadius.view
        view.clipsToBounds = true
        return view
    }

    private func createMixMatchBackgroundImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "mix_match_highlight")
        imageView.contentMode = .scaleAspectFill
        return imageView
    }
    
    private func createMixMatchIconImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "mix_match_icon")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }
    
    private func createMixMatchLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "\(localized("mix_match_or_bet_with_string")) \(localized("mix_match_mix_string"))\("mix_match_match_string")"
        label.font = AppFont.with(type: .bold, size: 14)
        label.textAlignment = .center
        
        let text = "\(localized("mix_match_or_bet_with_string")) \(localized("mix_match_mix_string"))\(localized("mix_match_match_string"))"
        
        let attributedString = NSMutableAttributedString(string: text)
        let fullRange = (text as NSString).range(of: text)
        var range = (text as NSString).range(of: localized("mix_match_mix_string"))
        
        attributedString.addAttribute(.foregroundColor, value: UIColor.App.buttonTextPrimary, range: fullRange)
        attributedString.addAttribute(.font, value: AppFont.with(type: .bold, size: 14), range: fullRange)
        
        attributedString.addAttribute(.foregroundColor, value: UIColor.App.highlightPrimary, range: range)
        
        label.attributedText = attributedString
        
        return label
    }
    
    private func createMixMatchNavigationIconImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "arrow_right_icon")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }

    private func createCashbackIconImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "cashback_small_blue_icon")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }
}

//
//@available(iOS 17, *)
//#Preview("ProChoiceHighlightCollectionViewCell Preview") {
//    let vc = PreviewTableViewController()
//    return vc
//}

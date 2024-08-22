//
//  BetSubmissionSuccessViewController.swift
//  Sportsbook
//
//  Created by Ruben Roques on 07/11/2021.
//

import UIKit
import Combine
import ServicesProvider
import Lottie

class BetSubmissionSuccessViewController: UIViewController {

    @IBOutlet private weak var scrollView: UIView!
    @IBOutlet private weak var scrollContentView: UIView!

    @IBOutlet private weak var bottomView: UIView!
    @IBOutlet private weak var bottomSeparatorView: UIView!
    @IBOutlet private weak var continueButton: UIButton!

    @IBOutlet private weak var safeAreaBottomView: UIView!

    @IBOutlet private weak var checkboxView: UIView!
    @IBOutlet private weak var checkboxImage: UIImageView!
    @IBOutlet private weak var checkboxLabel: UILabel!

    @IBOutlet private weak var betCardsStackView: UIStackView!

    @IBOutlet private weak var loadingBaseView: UIView!

    @IBOutlet private weak var topBackgroundView: GradientView!
    @IBOutlet private weak var bottomBackgroundView: UIView!
    @IBOutlet private weak var topImageView: UIImageView!
    @IBOutlet private weak var shapeView: UIView!

    @IBOutlet private weak var navigationView: UIView!
    @IBOutlet private weak var backButton: UIButton!
    
    // Constraints
    @IBOutlet private weak var topGradientViewCenterConstraint: NSLayoutConstraint!
    @IBOutlet private weak var topGradientViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var scrollViewTopConstraint: NSLayoutConstraint!
    
    lazy var betSuccessAnimationView: LottieAnimationView = {
        let animationView = LottieAnimationView()
        animationView.translatesAutoresizingMaskIntoConstraints = false
        animationView.contentMode = .scaleAspectFit

        let startAnimation = LottieAnimation.named("replay_sucess_3")

        animationView.animation = startAnimation
        animationView.loopMode = .playOnce
        
        return animationView
    }()

    private var totalOddsValue: String
    private var possibleEarningsValue: String
    private var numberOfBets: Int
    private var isChecked: Bool = false
    private var betPlacedDetailsArray: [BetPlacedDetails]
    private var betHistoryEntry: [BetHistoryEntry] = []
    private var sharedBetToken: String?
    private var ticketSnapshot: UIImage?
    private var ticketSnapshots: [String: UIImage] = [:]
    private var sharedBetHistory: BetHistoryEntry?
    private var locationsCodesDictionary: [String: String] = [:]
    private var cashbackResultValue: Double?
    private var usedCashback: Bool = false
    private var bettingTickets: [BettingTicket]?

    private var aspectRatio: CGFloat = 1.0

    private var cancellables = Set<AnyCancellable>()

    var willDismissAction: (() -> Void)?

    var isLoading: Bool = false {
        didSet {
            self.loadingBaseView.isHidden = !isLoading
        }
    }
    

    init(betPlacedDetailsArray: [BetPlacedDetails], cashbackResultValue: Double? = nil, usedCashback: Bool = false, bettingTickets: [BettingTicket]? = nil) {
        
        self.bettingTickets = bettingTickets

        self.betPlacedDetailsArray = betPlacedDetailsArray

        self.cashbackResultValue = cashbackResultValue

        self.usedCashback = usedCashback

        //
        // Possible Earnings
        var possibleEarningsDouble = betPlacedDetailsArray
            .map({ betPlacedDetails in
                betPlacedDetails.response.maxWinning ?? 0.0
            })
            .reduce(0.0, +)

        possibleEarningsDouble = Double(round(possibleEarningsDouble * 100)/100)
        self.possibleEarningsValue = CurrencyFormater.defaultFormat.string(from: NSNumber(value: possibleEarningsDouble)) ?? "-.--€"

        //
        // Total Odd
        let totalOddDouble = betPlacedDetailsArray
            .map({ betPlacedDetails in
                betPlacedDetails.response.totalPriceValue ?? 1.0
            })
            .reduce(1.0, *)
//        self.totalOddsValue = OddConverter.stringForValue(totalOddDouble, format: UserDefaults.standard.userOddsFormat)
        self.totalOddsValue = OddFormatter.formatOdd(withValue: totalOddDouble)

        //
        // Number Of Bets
        self.numberOfBets = betPlacedDetailsArray.count

        super.init(nibName: "BetSubmissionSuccessViewController", bundle: nil)
    }

    @available(iOS, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        StyleHelper.styleButton(button: self.continueButton)
        self.continueButton.setTitle(localized("continue_"), for: .normal)

        self.checkboxImage.image = UIImage(named: "checkbox_unselected_icon")
        self.checkboxLabel.text = localized("keep_bet")
        self.checkboxLabel.font = AppFont.with(type: .semibold, size: 14)

        let checkboxTap = UITapGestureRecognizer(target: self, action: #selector(didTapCheckbox))
        self.checkboxView.addGestureRecognizer(checkboxTap)
        
        self.configureBetEntries()

        self.setupWithTheme()

        Env.userSessionStore.refreshUserWallet()

        self.getBackgroundImage()

        self.backButton.setTitle("", for: .normal)
        self.backButton.setImage(UIImage(named: "arrow_back_icon"), for: .normal)
    
        self.topBackgroundView.addSubview(self.betSuccessAnimationView)

        NSLayoutConstraint.activate([
            self.betSuccessAnimationView.leadingAnchor.constraint(equalTo: self.topBackgroundView.leadingAnchor),
            self.betSuccessAnimationView.trailingAnchor.constraint(equalTo: self.topBackgroundView.trailingAnchor),
            self.betSuccessAnimationView.topAnchor.constraint(equalTo: self.topBackgroundView.topAnchor),
            self.betSuccessAnimationView.bottomAnchor.constraint(equalTo: self.topBackgroundView.bottomAnchor, constant: 0)

        ])
        
        self.topBackgroundView.bringSubviewToFront(self.shapeView)
        
        if self.usedCashback {
            self.resizeTopViewAndAnimate()
        }
        else {
            self.topImageView.isHidden = false
            self.betSuccessAnimationView.isHidden = true
            
            self.topGradientViewHeightConstraint.isActive = false
            self.topGradientViewCenterConstraint.isActive = true
        }

    }
    
    private func resizeTopViewAndAnimate() {

        self.topImageView.isHidden = true
        self.betSuccessAnimationView.isHidden = false
        
        if let animationView = self.betSuccessAnimationView.animation?.size {

            self.aspectRatio = animationView.width/animationView.height

            self.topGradientViewHeightConstraint =
            NSLayoutConstraint(item: self.topBackgroundView,
                               attribute: .height,
                               relatedBy: .equal,
                               toItem: self.topBackgroundView,
                               attribute: .width,
                               multiplier: 1/self.aspectRatio,
                               constant: 0)

            self.topGradientViewHeightConstraint.isActive = true
            self.topGradientViewCenterConstraint.isActive = false
            
            self.scrollViewTopConstraint.constant = 0
        }
        
        self.betSuccessAnimationView.play()

    }

    override func viewDidLayoutSubviews() {
        self.betCardsStackView.layoutIfNeeded()
        self.betCardsStackView.layoutSubviews()

        let startPoint = CGPoint(x: 0, y: 1)
        let endPoint = CGPoint.bottomToTopPointForAngle(50)

        self.topBackgroundView.startPoint = startPoint
        self.topBackgroundView.endPoint = endPoint

        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0.0, y: self.shapeView.frame.size.height))
        path.addCurve(to: CGPoint(x: self.shapeView.frame.size.width, y: self.shapeView.frame.size.height),
                      controlPoint1: CGPoint(x: self.shapeView.frame.size.width*0.40, y: 0),
                      controlPoint2: CGPoint(x: self.shapeView.frame.size.width*0.60, y: 20))
        path.addLine(to: CGPoint(x: self.shapeView.frame.size.width, y: self.shapeView.frame.size.height))
        path.addLine(to: CGPoint(x: 0.0, y: self.shapeView.frame.size.height))
        path.close()

        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path.cgPath
        shapeLayer.fillColor = UIColor.App.backgroundPrimary.cgColor

        self.shapeView.layer.mask = shapeLayer
        self.shapeView.layer.masksToBounds = true

        self.view.layoutIfNeeded()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        self.setupWithTheme()
    }

    func setupWithTheme() {

        self.view.backgroundColor = UIColor.App.backgroundPrimary
        self.scrollView.backgroundColor = .clear
        self.bottomView.backgroundColor = UIColor.App.backgroundPrimary
        self.bottomSeparatorView.backgroundColor = UIColor.App.separatorLine
        self.safeAreaBottomView.backgroundColor = UIColor.App.backgroundPrimary

        self.checkboxLabel.backgroundColor = .clear
        self.checkboxLabel.textColor = UIColor.App.textSecondary

        self.scrollContentView.backgroundColor = .clear

        self.betCardsStackView.backgroundColor = .clear

        self.loadingBaseView.backgroundColor = .clear

        // Background views

        self.topBackgroundView.colors = [(UIColor.App.backgroundHeaderGradient1, NSNumber(0.0)), (UIColor.App.backgroundHeaderGradient2, NSNumber(1.0))]
        
        if self.usedCashback {
            self.topBackgroundView.colors = [(UIColor.App.backgroundHeaderGradient1, NSNumber(0.0)), (UIColor.App.backgroundHeaderGradient1, NSNumber(1.0))]
        }

        self.bottomBackgroundView.backgroundColor = UIColor.App.backgroundPrimary

        self.shapeView.backgroundColor = UIColor.App.backgroundPrimary

        self.navigationView.backgroundColor = .clear

        self.backButton.backgroundColor = .clear

        self.betSuccessAnimationView.backgroundColor = .clear
    }
    
    private func configureBetEntries() {
        
        self.isLoading = true
        var betHistoryEntries = [BetHistoryEntry]()
        
        if let bettingTickets = self.bettingTickets {
            for betPlacedDetails in self.betPlacedDetailsArray {
                if let betPlacedSelections = betPlacedDetails.response.selections {
                    
                    let selectionIds = Set(betPlacedSelections.map { $0.id })
                    
                    let filteredBettingTickets = bettingTickets.filter { selectionIds.contains($0.id) }

                    let mappedBetHistoryEntrySelection = filteredBettingTickets.map { localTicket in
                        var betHistoryEntrySelection = ServiceProviderModelMapper.betHistoryEntrySelection(fromBettingTicket: localTicket)
                        if let matchingServerSelection = betPlacedSelections.first(where: { betslipPlaceEntry in
                            betslipPlaceEntry.id == localTicket.id
                        }) {
                            betHistoryEntrySelection.priceValue = matchingServerSelection.priceValue
                        }
                        // We need to use the odd that the server return for each selection in the ticket
                        return betHistoryEntrySelection
                    }
                    
                    var betslipId: Int?
                    
                    if let placedBetslipId = betPlacedDetails.response.betslipId {
                        betslipId = Int(placedBetslipId)
                    }
                    
                    let uniqueEventIds = Set(mappedBetHistoryEntrySelection.map(\.eventId).compactMap({ $0 }))
                    
                    var betType = betPlacedDetails.response.type ?? ""
                    if betType == "A" {
                        betType = "accumulator"
                    }
                    
                    if mappedBetHistoryEntrySelection.count >= 2, betType == "accumulator", uniqueEventIds.count == 1 {
                        betType = "mix_match"
                    }

                    let bettingTicketHistory = BetHistoryEntry(betId: betPlacedDetails.response.betId ?? "",
                                                               selections: mappedBetHistoryEntrySelection,
                                                               type: betType.lowercased(),
                                                               systemBetType: betType.lowercased(),
                                                               amount: betPlacedDetails.response.amount,
                                                               totalBetAmount: betPlacedDetails.response.amount,
                                                               freeBetAmount: nil,
                                                               bonusBetAmount: nil,
                                                               currency: "EUR",
                                                               maxWinning: betPlacedDetails.response.maxWinning,
                                                               totalPriceValue: betPlacedDetails.response.totalPriceValue,
                                                               overallBetReturns: nil,
                                                               numberOfSelections: mappedBetHistoryEntrySelection.count,
                                                               status: "Open",
                                                               placedDate: Date(),
                                                               settledDate: nil,
                                                               freeBet: nil,
                                                               partialCashoutReturn: nil,
                                                               partialCashoutStake: nil,
                                                               betShareToken: nil,
                                                               betslipId: betslipId,
                                                               cashbackReturn: nil,
                                                               freebetReturn: nil,
                                                               potentialCashbackReturn: nil,
                                                               potentialFreebetReturn: nil)
                    
                    betHistoryEntries.append(bettingTicketHistory)
                }
            }
        }
        
        self.configureBetCards(withBetHistoryEntries: betHistoryEntries)
        self.isLoading = false
    }

    private func getBackgroundImage() {

        Env.servicesProvider.getCashbackSuccessBanner()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .finished:
                    ()
                case .failure(let error):
                    self?.setupDefaultBackgroundImage()
                }
            }, receiveValue: { [weak self] bannersResponse in
                let bannersInfo = bannersResponse

                if let bannerUrl = bannersInfo.bannerItems.first {

                    let backgroundImageUrl = URL(string: "\(bannerUrl.imageUrl)")
                    self?.topImageView.kf.setImage(with: backgroundImageUrl)
                }
                else {
                    self?.setupDefaultBackgroundImage()
                }
            })
            .store(in: &cancellables)

    }

    private func setupDefaultBackgroundImage() {

        self.topImageView.image = UIImage(named: "bet_placed_banner")
        self.topImageView.contentMode = .scaleAspectFill
        //self.topImageView.alpha = 1

    }

    private func showBetShareScreen() {

        if let betHistoryEntry = self.sharedBetHistory,
           let sharedBetToken = self.sharedBetToken,
           let ticketSnapshot = self.ticketSnapshots[betHistoryEntry.betId] {
            let clickedShareTicketInfo = ClickedShareTicketInfo(snapshot: ticketSnapshot,
                                                                betId: betHistoryEntry.betId,
                                                                betStatus: betHistoryEntry.status ?? "",
                                                                betToken: sharedBetToken,
                                                                ticket: betHistoryEntry)

            let shareTicketChoiceViewModel = ShareTicketChoiceViewModel(clickedShareTicketInfo: clickedShareTicketInfo)

            let shareTicketChoiceViewController = ShareTicketChoiceViewController(viewModel: shareTicketChoiceViewModel)

            self.present(shareTicketChoiceViewController, animated: true, completion: nil)
        }
    }

    private func loadBetTicket(withId id: String) -> AnyPublisher<BetHistoryEntry, ServiceProviderError> {
        return Env.servicesProvider.getBetDetails(identifier: id)
            .map { (bet: ServicesProvider.Bet) -> BetHistoryEntry in
                return ServiceProviderModelMapper.betHistoryEntry(fromServiceProviderBet: bet)
            }.eraseToAnyPublisher()
    }

    private func configureBetCards(withBetHistoryEntries betHistoryEntries: [BetHistoryEntry]) {
        self.clearBetCard()

        for betHistoryEntry in betHistoryEntries {
            self.configureBetCard(betHistory: betHistoryEntry)
        }
    }

    private func clearBetCard() {
        self.betCardsStackView.removeAllArrangedSubviews()
    }

    private func configureBetCard(betHistory: BetHistoryEntry) {

        let sharedTicketCardView = SharedTicketCardView()

        let betCardViewModel = MyTicketCellViewModel(ticket: betHistory)

        sharedTicketCardView.configure(withBetHistoryEntry: betHistory,
                                       countryCodes: [],
                                       viewModel: betCardViewModel,
                                       cashbackValue: self.cashbackResultValue,
                                       usedCashback: self.usedCashback)

        sharedTicketCardView.didTappedSharebet = { [weak self] snapshot in
            self?.ticketSnapshots[betHistory.betId] = snapshot
            self?.sharedBetHistory = betHistory
            self?.sharedBetToken = "\(betHistory.betslipId ?? 0)"
            self?.showBetShareScreen()
        }

        sharedTicketCardView.didTapLearnMore = { [weak self] in

            let cashbackInfoViewController = CashbackInfoViewController()

            self?.navigationController?.pushViewController(cashbackInfoViewController, animated: true)
        }

        self.betCardsStackView.addArrangedSubview(sharedTicketCardView)

    }

    @IBAction private func didTapContinueButton() {

        if !isChecked {
            Env.betslipManager.clearAllBettingTickets()
            self.willDismissAction?()
            self.dismiss(animated: true, completion: nil)
        }
        else {
            self.navigationController?.popViewController(animated: true)
        }
        
//        if self.isModal {
//            self.willDismissAction?()
//            self.dismiss(animated: true, completion: nil)
//        }
    }

    @IBAction private func didTapBackButton() {

        if !isChecked {
            Env.betslipManager.clearAllBettingTickets()
        }
        
        self.navigationController?.popViewController(animated: true)
    }

    @IBAction private func didTapCheckbox() {
        if self.isChecked {
            self.checkboxImage.image = UIImage(named: "checkbox_unselected_icon")
        }
        else {
            self.checkboxImage.image = UIImage(named: "checkbox_selected_icon")
        }
        self.isChecked = !isChecked
    }

}

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
    
    @IBOutlet private weak var spinWheelBaseView: UIView!
    @IBOutlet private weak var spinWheelButton: UIButton!
    
    // Constraints
    @IBOutlet private weak var topGradientViewCenterConstraint: NSLayoutConstraint!
    @IBOutlet private weak var topGradientViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var scrollViewTopConstraint: NSLayoutConstraint!
    
    lazy var betSuccessAnimationView: LottieAnimationView = {
        let animationView = LottieAnimationView()
        animationView.translatesAutoresizingMaskIntoConstraints = false
        animationView.contentMode = .scaleAspectFit

        let startAnimation = LottieAnimation.named("replay_sucess")

        animationView.animation = startAnimation
        animationView.loopMode = .playOnce
        
        return animationView
    }()
    
    lazy var spinWheelDisabledView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isUserInteractionEnabled = true
        return view
    }()
    
    lazy var spinWheelLoadingBaseView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var spinWheelActivityIndicatorView: UIActivityIndicatorView = {
        let activityIndicatorView = UIActivityIndicatorView.init(style: .medium)
        activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        activityIndicatorView.hidesWhenStopped = true
        activityIndicatorView.startAnimating()
        return activityIndicatorView
    }()
    
    lazy var spinWheelTooltipView: InfoActionDialogView = {
        let view = InfoActionDialogView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.alpha = 0
        return view
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
    
    private lazy var shareLoadingOverlayView: UIView = {
        let overlayView = UIView()
        overlayView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        overlayView.translatesAutoresizingMaskIntoConstraints = false
        overlayView.isHidden = true
        return overlayView
    }()
    
    private lazy var shareLoadingActivityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.color = .white
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.hidesWhenStopped = true
        return activityIndicator
    }()

    var willDismissAction: (() -> Void)?

    var isLoading: Bool = false {
        didSet {
            self.loadingBaseView.isHidden = !isLoading
        }
    }
    
    var isSpinWheelEnabled: Bool = false {
        didSet {
            self.spinWheelDisabledView.isHidden = isSpinWheelEnabled
            self.spinWheelButton.isEnabled = isSpinWheelEnabled
        }
    }
    
    var isLoadingSpinWheel: Bool = false {
        didSet {
            self.spinWheelLoadingBaseView.isHidden = !isLoadingSpinWheel
        }
    }
    
    var boostMultiplierPublisher: CurrentValueSubject<Double, Never> = .init(0.0)
    
    var wheelBetStatus: WheelBetStatus = .pending {
        didSet {
            if wheelBetStatus == .eligible {
                self.configureSpinWheelButton(isEnabled: true)
            }
            else {
                self.configureSpinWheelButton(isEnabled: false)
            }
        }
    }
    
    var betHistoryEntries = [BetHistoryEntry]()
    
    var eligibleBetWheelInfo: BetWheelInfo?
    var wheelAwardedTier: WheelAwardedTier?
    
    init(betPlacedDetailsArray: [BetPlacedDetails], cashbackResultValue: Double? = nil, usedCashback: Bool = false, bettingTickets: [BettingTicket]? = nil) {
        
        self.bettingTickets = bettingTickets

        self.betPlacedDetailsArray = betPlacedDetailsArray

        self.cashbackResultValue = cashbackResultValue

        self.usedCashback = usedCashback

        //
        // Possible Earnings
        var possibleEarningsDouble = betPlacedDetailsArray
            .map({ betPlacedDetails in
                var maxWinnings = betPlacedDetails.response.maxWinning ?? 0.0
                
                if usedCashback {
                    maxWinnings -= betPlacedDetails.response.amount ?? 0.0
                }
                
                return maxWinnings
                
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
        
        StyleHelper.styleButtonWithTheme(button: self.spinWheelButton,
                                         titleColor: UIColor.App.buttonTextPrimary,
                                         titleDisabledColor: UIColor.App.buttonTextDisableSecondary,
                                         backgroundColor: UIColor.App.buttonBackgroundSecondary,
                                         backgroundDisabledColor: UIColor.App.buttonBackgroundSecondary.withAlphaComponent(0.5),
                                         backgroundHighlightedColor: UIColor.App.buttonBackgroundSecondary)
        self.spinWheelButton.setTitle(localized("coup_boost"), for: .normal)

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
        
//        if self.usedCashback {
//            self.resizeTopViewAndAnimate()
//        }
//        else {
//            self.topImageView.isHidden = false
//            self.betSuccessAnimationView.isHidden = true
//            
//            self.topGradientViewHeightConstraint.isActive = false
//            self.topGradientViewCenterConstraint.isActive = true
//        }
        
        self.topImageView.isHidden = false
        self.betSuccessAnimationView.isHidden = true
        
        self.topGradientViewHeightConstraint.isActive = false
        self.topGradientViewCenterConstraint.isActive = true
        
        if TargetVariables.features.contains(.spinWheel) {
            self.spinWheelBaseView.isHidden = false
        }
        else {
            self.spinWheelBaseView.isHidden = true
        }
        
        self.spinWheelBaseView.addSubview(self.spinWheelDisabledView)
        self.spinWheelBaseView.bringSubviewToFront(self.spinWheelDisabledView)

        NSLayoutConstraint.activate([
            self.spinWheelDisabledView.leadingAnchor.constraint(equalTo: self.spinWheelButton.leadingAnchor),
            self.spinWheelDisabledView.trailingAnchor.constraint(equalTo: self.spinWheelButton.trailingAnchor),
            self.spinWheelDisabledView.topAnchor.constraint(equalTo: self.spinWheelButton.topAnchor),
            self.spinWheelDisabledView.bottomAnchor.constraint(equalTo: self.spinWheelButton.bottomAnchor)
        ])
        
        self.spinWheelDisabledView.addSubview(self.spinWheelLoadingBaseView)
        
        self.spinWheelLoadingBaseView.addSubview(self.spinWheelActivityIndicatorView)
        
        self.spinWheelDisabledView.bringSubviewToFront(self.spinWheelLoadingBaseView)
        
        // Loading Screen
        NSLayoutConstraint.activate([
            self.spinWheelLoadingBaseView.topAnchor.constraint(equalTo: self.spinWheelDisabledView.topAnchor),
            self.spinWheelLoadingBaseView.leadingAnchor.constraint(equalTo: self.spinWheelDisabledView.leadingAnchor),
            self.spinWheelLoadingBaseView.trailingAnchor.constraint(equalTo: self.spinWheelDisabledView.trailingAnchor),
            self.spinWheelLoadingBaseView.bottomAnchor.constraint(equalTo: self.spinWheelDisabledView.bottomAnchor),

            self.spinWheelActivityIndicatorView.centerXAnchor.constraint(equalTo: self.spinWheelLoadingBaseView.centerXAnchor),
            self.spinWheelActivityIndicatorView.centerYAnchor.constraint(equalTo: self.spinWheelLoadingBaseView.centerYAnchor)
        ])
        
        // Add tap gesture to the disabled view
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapDisabledSpinWheel))
        self.spinWheelDisabledView.addGestureRecognizer(tapGesture)
                
        self.isSpinWheelEnabled = false
        
        if TargetVariables.features.contains(.spinWheel) {
            self.getWheelEligibility()
        }
        else {
            self.wheelBetStatus = .notEligible
        }
        
        // Spin Wheel Tooltip
        self.spinWheelTooltipView.configure(title: localized("spin_wheel_tooltip_title"),
                                            description: "\(localized("spin_wheel_tooltip_description_title"))\n\(localized("spin_wheel_tooltip_description_text"))",
                                            linkText: localized("spin_wheel_tooltip_link_text"),
                                            actionLink: localized("spin_wheel_tooltip_info_link_url"))
        
        self.view.addSubview(self.spinWheelTooltipView)
        self.view.bringSubviewToFront(self.spinWheelTooltipView)
        
        NSLayoutConstraint.activate([
            self.spinWheelTooltipView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -16),
            self.spinWheelTooltipView.bottomAnchor.constraint(equalTo: self.spinWheelButton.topAnchor, constant: -10)
        ])
        
        self.spinWheelTooltipView.shouldOpenActionLink = { [weak self] actionLink in
            self?.openExternalUrl(actionLink: actionLink)
        }
        
        self.spinWheelTooltipView.shouldCloseDialog = { [weak self] in
            
            UIView.animate(withDuration: 0.5, animations: {
                self?.spinWheelTooltipView.alpha = 0
            })
        }
        
        let mainViewTapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapMainView))
           mainViewTapGesture.cancelsTouchesInView = false
           self.view.addGestureRecognizer(mainViewTapGesture)
        
        // Setup share loading overlay
        self.setupShareLoadingOverlay()
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
                
        self.spinWheelDisabledView.layer.cornerRadius = CornerRadius.button
        self.spinWheelDisabledView.layer.masksToBounds = true

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
        
//        if self.usedCashback {
//            self.topBackgroundView.colors = [(UIColor.App.backgroundHeaderGradient1, NSNumber(0.0)), (UIColor.App.backgroundHeaderGradient1, NSNumber(1.0))]
//        }

        self.bottomBackgroundView.backgroundColor = UIColor.App.backgroundPrimary

        self.shapeView.backgroundColor = UIColor.App.backgroundPrimary

        self.navigationView.backgroundColor = .clear

        self.backButton.backgroundColor = .clear

        self.betSuccessAnimationView.backgroundColor = .clear
        
        self.spinWheelBaseView.backgroundColor = .clear
        
        self.spinWheelDisabledView.backgroundColor = .clear
        
        self.spinWheelLoadingBaseView.backgroundColor = UIColor.App.backgroundPrimary.withAlphaComponent(0.7)
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
                            if let newValue = matchingServerSelection.priceValue {
                                betHistoryEntrySelection.priceValue = newValue
                            }
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
                    
                    var maxWinnings = betPlacedDetails.response.maxWinning ?? 0.0
                    
                    if usedCashback {
                        maxWinnings -= betPlacedDetails.response.amount ?? 0
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
                                                               maxWinning: maxWinnings,
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
        
        self.betHistoryEntries = betHistoryEntries
        
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
        guard let betHistoryEntry = self.sharedBetHistory else { return }
        
        self.showShareLoadingOverlay()
        
        let brandedShareView = BrandedTicketShareView()
        self.view.insertSubview(brandedShareView, at: 0)
        
        NSLayoutConstraint.activate([
            brandedShareView.trailingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: -10),
            brandedShareView.widthAnchor.constraint(equalTo: self.view.widthAnchor),
            brandedShareView.topAnchor.constraint(equalTo: self.view.topAnchor)
        ])
        
        // Configure with bet data
        let viewModel = MyTicketCellViewModel(ticket: betHistoryEntry, allowedCashback: false)
        brandedShareView.configure(withBetHistoryEntry: betHistoryEntry,
                                   countryCodes: [],
                                   viewModel: viewModel,
                                   grantedWinBoost: nil,
                                   betShareToken: "\(betHistoryEntry.betslipId ?? 0)")
        
        brandedShareView.setNeedsLayout()
        brandedShareView.layoutIfNeeded()

        brandedShareView.setOnViewReady { [weak self] in
            self?.hideShareLoadingOverlay()
            
            brandedShareView.setNeedsLayout()
            brandedShareView.layoutIfNeeded()
            
            if let shareContent = brandedShareView.generateShareContent() {
                self?.presentShareActivityViewController(with: shareContent)
            }

            brandedShareView.removeFromSuperview()
        }
    }
    
    private func setupShareLoadingOverlay() {
        self.shareLoadingOverlayView.addSubview(self.shareLoadingActivityIndicator)
        self.view.addSubview(self.shareLoadingOverlayView)
        
        NSLayoutConstraint.activate([
            self.shareLoadingOverlayView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.shareLoadingOverlayView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.shareLoadingOverlayView.topAnchor.constraint(equalTo: self.view.topAnchor),
            self.shareLoadingOverlayView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            
            self.shareLoadingActivityIndicator.centerXAnchor.constraint(equalTo: self.shareLoadingOverlayView.centerXAnchor),
            self.shareLoadingActivityIndicator.centerYAnchor.constraint(equalTo: self.shareLoadingOverlayView.centerYAnchor)
        ])
    }
    
    private func showShareLoadingOverlay() {
        self.shareLoadingOverlayView.isHidden = false
        self.shareLoadingActivityIndicator.startAnimating()
    }
    
    private func hideShareLoadingOverlay() {
        self.shareLoadingOverlayView.isHidden = true
        self.shareLoadingActivityIndicator.stopAnimating()
    }
    
    private func presentShareActivityViewController(with shareContent: ShareContent) {
        let activityViewController = UIActivityViewController(activityItems: shareContent.activityItems, applicationActivities: nil)
        
        // Configure for iPad
        if let popoverController = activityViewController.popoverPresentationController {
            popoverController.sourceView = self.view
            popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
            popoverController.permittedArrowDirections = []
        }
        
        self.present(activityViewController, animated: true, completion: nil)
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

        let betCardViewModel = MyTicketCellViewModel(ticket: betHistory, allowedCashback: false)
        
        var betWheelInfo: BetWheelInfo?
        var wheelAwardedTier: WheelAwardedTier?
        
        if let eligibleBetWheelInfo = self.eligibleBetWheelInfo,
           let currentWheelAwardedTier = self.wheelAwardedTier {
            
            if betHistory.betId == eligibleBetWheelInfo.betId {
                
                betWheelInfo = eligibleBetWheelInfo
                wheelAwardedTier = currentWheelAwardedTier
            }
        }

        sharedTicketCardView.configure(withBetHistoryEntry: betHistory,
                                       countryCodes: [],
                                       viewModel: betCardViewModel,
                                       cashbackValue: self.cashbackResultValue,
                                       usedCashback: self.usedCashback,
                                       betWheelInfo: betWheelInfo,
                                       wheelAwardedTier: wheelAwardedTier)

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
    
    private func getWheelEligibility() {
        print("getWheelEligibility function started")
        
        // Create array to store retry subjects
        var retrySubjects: [PassthroughSubject<Int, Never>] = []
        
        // Create publishers for each bet
        let publishers = self.betPlacedDetailsArray.map { betPlacedDetail -> AnyPublisher<BetWheelInfo, Never> in
            let betslipId = betPlacedDetail.response.betslipId ?? ""
            let betId = betPlacedDetail.response.betId ?? ""
            
            print("Setting up publisher for bet - betslipId: \(betslipId), betId: \(betId)")
            
            // Skip if missing required IDs
            guard !betslipId.isEmpty, !betId.isEmpty else {
                return Just(BetWheelInfo(betId: betId, gameTranId: "", wheelBetStatus: .notEligible, winBoostId: nil)).eraseToAnyPublisher()
            }
            
            // Split the betId at the decimal point
            let betIdComponents = betId.split(separator: ".")
            let betIdBase = betIdComponents[0]
            let betIdDecimal = betIdComponents.count > 1 ? betIdComponents[1] : ""
            
            // Remove trailing zeros from the decimal part
            let trimmedDecimal = betIdDecimal.replacingOccurrences(of: "0+$", with: "", options: .regularExpression)
            
            // Construct the final ID
            let gameTransId: String
            if trimmedDecimal.isEmpty {
                gameTransId = "\(betslipId)_\(betIdBase)"
            }
            else {
                gameTransId = "\(betslipId)_\(betIdBase).\(trimmedDecimal)"
            }
            
            print("Generated gameTransId: \(gameTransId)")
            
            // Create a subject for retries
            let retrySubject = PassthroughSubject<Int, Never>()
            retrySubjects.append(retrySubject)
            
            var attempt = 1
            
            return retrySubject
                .flatMap { attempt -> AnyPublisher<BetWheelInfo, Never> in
                    print("Attempt #\(attempt) for \(gameTransId)")
                    
                    return Env.servicesProvider.getWheelEligibility(gameTransId: gameTransId)
                        .map { wheelEligibility -> BetWheelInfo in
                            if let winBoost = wheelEligibility.winBoosts.first {
                                switch winBoost.status {
                                case "ELIGIBLE":
                                    print("Found eligible boost for \(gameTransId)")
                                    return BetWheelInfo(betId: betId, gameTranId: gameTransId, wheelBetStatus: .eligible, winBoostId: wheelEligibility.winBoosts.first?.winBoostId)
                                    
                                case "NOT_ELIGIBLE":
                                    print("Bet is not eligible for \(gameTransId)")
                                    return BetWheelInfo(betId: betId, gameTranId: gameTransId, wheelBetStatus: .notEligible, winBoostId: nil)
                                case "TIMED_OUT":
                                    print("Bet timed out for \(gameTransId)")
                                    return BetWheelInfo(betId: betId, gameTranId: gameTransId, wheelBetStatus: .notEligible, winBoostId: nil)
                                default:
                                    return BetWheelInfo(betId: betId, gameTranId: gameTransId, wheelBetStatus: .pending, winBoostId: nil)
                                }
                            }
                            return BetWheelInfo(betId: betId, gameTranId: gameTransId, wheelBetStatus: .pending, winBoostId: nil)
                        }
                        .catch { error -> AnyPublisher<BetWheelInfo, Never> in
                            print("Error for \(gameTransId): \(error)")
                            return Just(BetWheelInfo(betId: betId, gameTranId: gameTransId, wheelBetStatus: .notEligible, winBoostId: nil)).eraseToAnyPublisher()
                        }
                        .eraseToAnyPublisher()
                }
                .timeout(.seconds(30), scheduler: DispatchQueue.main) // Total timeout for all attempts
                .handleEvents(receiveOutput: { result in
                    // Only continue retrying if we haven't found an eligible or not_eligible status
                    if result.wheelBetStatus == .pending {
                        // Schedule next attempt after 3 seconds if no definitive status found
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                            attempt += 1
                            retrySubject.send(attempt)
                        }
                    }
                })
                .first(where: { result in
                    // Stop if we found an eligible boost or if the bet is not eligible
                    return result.wheelBetStatus != .pending
                })
                .replaceError(with: BetWheelInfo(betId: betId, gameTranId: gameTransId, wheelBetStatus: .notEligible, winBoostId: nil))
                .eraseToAnyPublisher()
        }
        
        // Merge all publishers and collect results
        Publishers.MergeMany(publishers)
            .collect()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] results in
                print("All eligibility checks completed. Results: \(results)")
                
                let hasEligibleBet = results.contains { result in
                    return result.wheelBetStatus == .eligible
                }
                
                if hasEligibleBet {
                    
                    self?.wheelBetStatus = .eligible
                    
                    // Find the highest boost multiplier if needed
                    if let eligibleBet = results.first(where: { $0.wheelBetStatus == .eligible }) {
                        
                        self?.eligibleBetWheelInfo = eligibleBet
                    }
                } else {
                    
                    self?.wheelBetStatus = .notEligible
                    self?.boostMultiplierPublisher.send(0.0)
                    
                }
                
                self?.isLoadingSpinWheel = false
                                
            }
            .store(in: &cancellables)
        
        // Start all retry subjects
        retrySubjects.forEach { subject in
            subject.send(1)
        }
        
        print("getWheelEligibility setup complete")
    }
    
    private func getBoostMultiplier(betWheelInfo: BetWheelInfo) {
        
        if let winBoostId = betWheelInfo.winBoostId {
            
            Env.servicesProvider.wheelOptIn(winBoostId: winBoostId, optInOption: "true")
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { [weak self] completion in
                    
                    switch completion {
                    case .finished:
                        print("FINISHED WHEEL OPTIN")
                    case .failure(let error):
                        print("WHEEL OPTIN ERROR: \(error)")
                    }
                }, receiveValue: { [weak self] wheelOptInData in
                    
                    if let wheelAwardedTier = wheelOptInData.awardedTier {
                        
                        self?.wheelAwardedTier = wheelAwardedTier
                        
                        self?.openSpinWheel(boostMultiplier: wheelAwardedTier.boostMultiplier)
                    }
                })
                .store(in: &cancellables)
        }

    }
    
    private func winBoostOptOut() {
        
        if let eligibleBetWheelInfo = self.eligibleBetWheelInfo,
           let winBoostId = eligibleBetWheelInfo.winBoostId {
            
            Env.servicesProvider.wheelOptIn(winBoostId: winBoostId, optInOption: "false")
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { [weak self] completion in
                    
                    switch completion {
                    case .finished:
                        print("FINISHED WHEEL OPTOUT")
                    case .failure(let error):
                        print("WHEEL OPTOUT ERROR: \(error)")
                    }
                }, receiveValue: { [weak self] wheelOptInData in
                    
                    print("WHEEL OPTOUT RESPONSE: \(wheelOptInData)")
                    
                    self?.continueBetFlow()
                })
                .store(in: &cancellables)
        }
    }
    
    private func openSpinWheel(boostMultiplier: Double) {
        
//        self.configureWinBoostLayout()
        self.wheelBetStatus = .awarded
        
        let prize = String(format: "%.0f%%", boostMultiplier * 100)
        
        let urlString = TargetVariables.clientBaseUrl + "/odds-boost-spinner/index.html"
        if let url = URL(string: urlString) {
            let spinWheelWebViewModel = SpinWheelViewModel(url: url, prize: prize)
            let spinWheelWebViewController = SpinWheelViewController(viewModel: spinWheelWebViewModel)
            spinWheelWebViewController.modalPresentationStyle = .fullScreen
            spinWheelWebViewController.shouldUpdateLayout = { [weak self] in
                self?.configureWinBoostLayout()
            }
            self.present(spinWheelWebViewController, animated: true)
        }
        
    }
    
    private func configureWinBoostLayout() {
        self.configureBetCards(withBetHistoryEntries: self.betHistoryEntries)
        
        self.topImageView.image = UIImage(named: "sucess_wheel_banner")
        
        self.spinWheelBaseView.isHidden = true
        
        self.view.setNeedsLayout()
        self.view.layoutIfNeeded()
    }
    
    private func showSpinWheelAlert() {
        
        let alert = UIAlertController(title: localized("spin_wheel_dialog_title"),
                                      message: localized("spin_wheel_dialog_message"),
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: localized("cancel"), style: .cancel, handler: nil))

        alert.addAction(UIAlertAction(title: localized("confirm"), style: .default, handler: { [weak self] _ in
            if self?.wheelBetStatus == .eligible {
                self?.winBoostOptOut()
            }
            else {
                self?.continueBetFlow()
            }
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    private func showWheelAwardedTierErrorAlert() {
        
        let alert = UIAlertController(title: localized("error"),
                                      message: localized("error"),
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: localized("ok"), style: .default, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    private func continueBetFlow() {
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
    
    private func openExternalUrl(actionLink: String) {
        
        if let url = URL(string: actionLink) {
            UIApplication.shared.open(url)
        }
    }
    
    private func configureSpinWheelButton(isEnabled: Bool) {
        
        self.isSpinWheelEnabled = isEnabled
        
        if isEnabled {
            self.spinWheelButton.setImage(UIImage(named: "rocket_wheel_icon"), for: .normal)
        }
        else {
            self.spinWheelButton.setImage(UIImage(named: "question_wheel_icon"), for: .normal)
        }
    }

    @IBAction private func didTapContinueButton() {

        switch self.wheelBetStatus {
        case .pending, .eligible:
            self.showSpinWheelAlert()
        case .notEligible, .awarded:
            self.continueBetFlow()
        }
        
    }
    
    @IBAction func didTapSpinWheelButton() {
        
        if let eligibleBetWheelInfo = self.eligibleBetWheelInfo {
            self.getBoostMultiplier(betWheelInfo: eligibleBetWheelInfo)
        }
        
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

    @objc private func didTapMainView() {
        
        if self.spinWheelTooltipView.alpha > 0 {
            UIView.animate(withDuration: 0.5) {
                self.spinWheelTooltipView.alpha = 0
            }
        }
    }
    
    @objc private func didTapDisabledSpinWheel() {
                
        UIView.animate(withDuration: 0.5, animations: {
            self.spinWheelTooltipView.alpha = 1
        })
    }
}

enum WheelBetStatus {
    case pending
    case notEligible
    case eligible
    case awarded
}

struct BetWheelInfo {
    let betId: String
    let gameTranId: String
    let wheelBetStatus: WheelBetStatus
    let winBoostId: String?
}

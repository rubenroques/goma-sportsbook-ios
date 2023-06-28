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

    @IBOutlet private weak var betSuccessView: UIView!
    @IBOutlet private weak var animationBaseView: UIView!
    @IBOutlet private weak var messageTitleLabel: UILabel!
    @IBOutlet private weak var messageSubtitleLabel: UILabel!

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

    private var cancellables = Set<AnyCancellable>()

    var willDismissAction: (() -> Void)?

    var isLoading: Bool = false {
        didSet {
            self.loadingBaseView.isHidden = !isLoading
        }
    }

    init(betPlacedDetailsArray: [BetPlacedDetails]) {

        self.betPlacedDetailsArray = betPlacedDetailsArray
        
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

        self.messageTitleLabel.text = localized("bet_registered_success")
        self.messageTitleLabel.font = AppFont.with(type: .bold, size: 16)

        self.messageSubtitleLabel.text = localized("good_luck")
        self.messageSubtitleLabel.font = AppFont.with(type: .bold, size: 14)

        StyleHelper.styleButton(button: self.continueButton)

        self.checkboxImage.image = UIImage(named: "checkbox_unselected_icon")
        self.checkboxLabel.text = localized("keep_bet")
        self.checkboxLabel.font = AppFont.with(type: .semibold, size: 14)

        let checkboxTap = UITapGestureRecognizer(target: self, action: #selector(didTapCheckbox))
        self.checkboxView.addGestureRecognizer(checkboxTap)

        self.loadBetTickets()

        self.setupWithTheme()

        Env.userSessionStore.refreshUserWallet()

        self.setupAnimationView()
        self.getBackgroundImage()
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
                      controlPoint2: CGPoint(x:self.shapeView.frame.size.width*0.60, y: 20))
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

        self.betSuccessView.backgroundColor = .clear

        self.animationBaseView.backgroundColor = .clear
        
        self.messageTitleLabel.textColor = UIColor.App.buttonTextPrimary
        self.messageSubtitleLabel.textColor = UIColor.App.buttonTextPrimary

        self.checkboxLabel.backgroundColor = .clear
        self.checkboxLabel.textColor = UIColor.App.textSecondary

        self.scrollContentView.backgroundColor = .clear

        self.betCardsStackView.backgroundColor = .clear

        self.loadingBaseView.backgroundColor = .clear

        // Background views

        self.topBackgroundView.colors = [(UIColor.App.backgroundHeaderGradient1, NSNumber(0.0)), (UIColor.App.backgroundHeaderGradient2, NSNumber(1.0))]

        self.bottomBackgroundView.backgroundColor = UIColor.App.backgroundPrimary

        self.shapeView.backgroundColor = UIColor.App.backgroundPrimary

        self.animationBaseView.backgroundColor = .clear
    }

    private func setupAnimationView() {
        
        let animationView = LottieAnimationView()

        animationView.translatesAutoresizingMaskIntoConstraints = false
        animationView.contentMode = .scaleAspectFill

        self.animationBaseView.addSubview(animationView)

        let starAnimation = LottieAnimation.named("success_thumbs_up")

        animationView.animation = starAnimation
        animationView.loopMode = .playOnce

        NSLayoutConstraint.activate([
            animationView.leadingAnchor.constraint(equalTo: self.animationBaseView.leadingAnchor),
            animationView.trailingAnchor.constraint(equalTo: self.animationBaseView.trailingAnchor),
            animationView.topAnchor.constraint(equalTo: self.animationBaseView.topAnchor),
            animationView.bottomAnchor.constraint(equalTo: self.animationBaseView.bottomAnchor)
        ])

        animationView.play()
    }

    private func getBackgroundImage() {

        Env.servicesProvider.getCashbackSuccessBanner()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .finished:
                    ()
                case .failure(let error):
                    print("CASHBACK BANNERS ERROR: \(error)")

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

        self.topImageView.image = UIImage(named: "success_default_banner")
        self.topImageView.contentMode = .scaleAspectFill
        self.topImageView.alpha = 0.26

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

    private func loadBetTickets() {

        self.isLoading = true

        Env.servicesProvider.getOpenBetsHistory(pageIndex: 0)
            .map(ServiceProviderModelMapper.bettingHistory(fromServiceProviderBettingHistory:))
            .map({ [weak self] betHistoryResponse -> [BetHistoryEntry] in
                var betHistoryEntriesToShow: [BetHistoryEntry] = []

                let submitedBetsIds: [String] = (self?.betPlacedDetailsArray ?? []).compactMap(\.response.betId)
                let openBetsArray: [BetHistoryEntry] = betHistoryResponse.betList ?? []
                for openBet in openBetsArray {
                    if submitedBetsIds.contains(openBet.betId) {
                        betHistoryEntriesToShow.append(openBet)
                    }
                }

                return betHistoryEntriesToShow
            })
            .receive(on: DispatchQueue.main)
            .sink { _ in

            } receiveValue: { [weak self] betHistoryEntries in
                self?.configureBetCards(withBetHistoryEntries: betHistoryEntries)
                self?.isLoading = false
            }
            .store(in: &self.cancellables)

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

        sharedTicketCardView.configure(withBetHistoryEntry: betHistory, countryCodes: [], viewModel: betCardViewModel)

        sharedTicketCardView.didTappedSharebet = { [weak self] snapshot in
            // self?.getSharedBetToken(betHistoryEntry: betHistory)
            // self?.ticketSnapshots[betHistory.betId] = snapshot
        }

        self.betCardsStackView.addArrangedSubview(sharedTicketCardView)

    }

    @IBAction private func didTapContinueButton() {

        if !isChecked {
            Env.betslipManager.clearAllBettingTickets()
        }
        
        if self.isModal {
            self.willDismissAction?()
            self.dismiss(animated: true, completion: nil)
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

}

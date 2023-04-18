//
//  BetSubmissionSuccessViewController.swift
//  Sportsbook
//
//  Created by Ruben Roques on 07/11/2021.
//

import UIKit
import Combine
import ServicesProvider

class BetSubmissionSuccessViewController: UIViewController {

    @IBOutlet private weak var navigationView: UIView!
    @IBOutlet private weak var backButton: UIButton!
    @IBOutlet private weak var scrollView: UIView!
    @IBOutlet private weak var scrollContentView: UIView!

    @IBOutlet private weak var betSuccessView: UIView!
    @IBOutlet private weak var checkmarkImageView: UIImageView!
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

        self.checkmarkImageView.image = UIImage(named: "like_success_icon")

        self.messageTitleLabel.text = localized("bet_registered_success")
        self.messageTitleLabel.font = AppFont.with(type: .semibold, size: 14)

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
    }

    override func viewDidLayoutSubviews() {
        self.betCardsStackView.layoutIfNeeded()
        self.betCardsStackView.layoutSubviews()

        self.view.layoutIfNeeded()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        self.setupWithTheme()
    }

    func setupWithTheme() {

        self.view.backgroundColor = UIColor.App.backgroundPrimary
        self.scrollView.backgroundColor = UIColor.App.backgroundPrimary
        self.bottomView.backgroundColor = UIColor.App.backgroundPrimary
        self.bottomSeparatorView.backgroundColor = UIColor.App.separatorLine
        self.safeAreaBottomView.backgroundColor = UIColor.App.backgroundPrimary

        self.navigationView.backgroundColor = UIColor.App.backgroundPrimary

        self.betSuccessView.backgroundColor = UIColor.App.backgroundPrimary

        self.messageTitleLabel.textColor = UIColor.App.textPrimary
        self.messageSubtitleLabel.textColor = UIColor.App.textPrimary

        self.checkboxLabel.backgroundColor = .clear
        self.checkboxLabel.textColor = UIColor.App.textSecondary

        self.scrollContentView.backgroundColor = .clear
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
            .sink { completion in

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

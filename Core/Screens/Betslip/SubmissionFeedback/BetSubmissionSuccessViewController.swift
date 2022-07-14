//
//  BetSubmissionSuccessViewController.swift
//  Sportsbook
//
//  Created by Ruben Roques on 07/11/2021.
//

import UIKit
import Combine

class BetSubmissionSuccessViewController: UIViewController {

    @IBOutlet private weak var navigationView: UIView!
    @IBOutlet private weak var backButton: UIButton!
    @IBOutlet private weak var scrollView: UIView!
    @IBOutlet private weak var scrollContentView: UIView!

    @IBOutlet private weak var betSuccessView: UIView!
    @IBOutlet private weak var checkmarkImageView: UIImageView!
    @IBOutlet private weak var messageTitleLabel: UILabel!
    @IBOutlet private weak var messageSubtitleLabel: UILabel!
    @IBOutlet private weak var shareButton: UIButton!

    @IBOutlet private weak var bottomView: UIView!
    @IBOutlet private weak var bottomSeparatorView: UIView!
    @IBOutlet private weak var continueButton: UIButton!

    @IBOutlet private weak var safeAreaBottomView: UIView!

    @IBOutlet private weak var checkboxView: UIView!
    @IBOutlet private weak var checkboxImage: UIImageView!
    @IBOutlet private weak var checkboxLabel: UILabel!

    @IBOutlet private weak var sharedTicketCardView: SharedTicketCardView!

    @IBOutlet private weak var loadingBaseView: UIView!

    private var totalOddsValue: String
    private var possibleEarningsValue: String
    private var numberOfBets: Int
    private var isChecked: Bool = false
    private var betPlacedDetailsArray: [BetPlacedDetails]
    private var betHistoryEntry: BetHistoryEntry?
    private var sharedBetToken: String?
    private var ticketSnapshot: UIImage?
    private var locationsCodesDictionary: [String: String] = [:]
    private var cancellables = Set<AnyCancellable>()

    private var canShareTicket: Bool = false

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

        possibleEarningsDouble = Double(floor(possibleEarningsDouble * 100)/100)
        self.possibleEarningsValue = CurrencyFormater.defaultFormat.string(from: NSNumber(value: possibleEarningsDouble)) ?? "-.--€"

        //
        // Total Odd
        let totalOddDouble = betPlacedDetailsArray
            .map({ betPlacedDetails in
                betPlacedDetails.response.totalPriceValue ?? 1.0
            })
            .reduce(1.0, *)
        self.totalOddsValue = OddConverter.stringForValue(totalOddDouble, format: UserDefaults.standard.userOddsFormat)

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

        self.shareButton.setTitle(localized("share_bet_now"), for: .normal)
        self.shareButton.titleLabel?.font = AppFont.with(type: .bold, size: 14)
        self.shareButton.setImage(UIImage(named: "share_bet_icon"), for: .normal)
        self.shareButton.layer.cornerRadius = CornerRadius.button
        self.shareButton.layer.masksToBounds = true
        self.shareButton.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
        self.shareButton.titleLabel?.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
        self.shareButton.imageView?.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
        self.shareButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 10)
        self.shareButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: -10, bottom: 0, right: 0)

        StyleHelper.styleButton(button: self.continueButton)

        self.checkboxImage.image = UIImage(named: "checkbox_unselected_icon")
        self.checkboxLabel.text = localized("keep_bet_checkbox")
        self.checkboxLabel.font = AppFont.with(type: .semibold, size: 14)

        let checkboxTap = UITapGestureRecognizer(target: self, action: #selector(didTapCheckbox))
        self.checkboxView.addGestureRecognizer(checkboxTap)

        self.loadLocations()

        self.setupWithTheme()
    }

    override func viewDidLayoutSubviews() {
        self.sharedTicketCardView.layoutIfNeeded()
        self.sharedTicketCardView.layoutSubviews()

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

        self.shareButton.setBackgroundColor(UIColor.App.buttonBackgroundSecondary, for: .normal)
        self.shareButton.backgroundColor = UIColor.App.buttonBackgroundSecondary

        self.shareButton.setTitleColor(UIColor.App.buttonTextPrimary, for: .normal)

        self.scrollContentView.backgroundColor = .clear
    }

    private func loadLocations() {
        self.isLoading = true

        let resolvedRoute = TSRouter.getLocations(language: "en", sortByPopularity: false)
        Env.everyMatrixClient.manager.getModel(router: resolvedRoute, decodingType: EveryMatrixSocketResponse<EveryMatrix.Location>.self)
            .sink(receiveCompletion: { _ in

            },
            receiveValue: { [weak self] response in
                self?.locationsCodesDictionary = [:]
                (response.records ?? []).forEach { location in
                    if let code = location.code {
                        self?.locationsCodesDictionary[location.id] = code
                        self?.loadOpenedTickets()
                    }
                }
            })
            .store(in: &cancellables)
    }

    private func loadOpenedTickets(page: Int = 0) {

        let openedRoute = TSRouter.getMyTickets(language: "en", ticketsType: EveryMatrix.MyTicketsType.opened, records: 10, page: page)
        Env.everyMatrixClient.manager.getModel(router: openedRoute, decodingType: BetHistoryResponse.self)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .failure(let apiError):
                    switch apiError {
                    case .requestError(let value) where value.lowercased().contains("you must be logged in to perform this action"):
                        ()
                        //self?.clearData()
                    case .notConnected:
                        //self?.clearData()
                        ()
                    default:
                        ()
                    }
                case .finished:
                    ()
                }
                self?.isLoading = false
            },
            receiveValue: { [weak self] betHistoryResponse in
                if let betHistory = betHistoryResponse.betList?.first,
                   let betPlacedDetails = self?.betPlacedDetailsArray {
                    if betPlacedDetails[safe: 0]?.response.betId == betHistory.betId {
                        self?.betHistoryEntry = betHistoryResponse.betList?.first
                        self?.configureBetCards()
                        self?.getSharedBetToken()

                    }
                }

            })
            .store(in: &cancellables)
    }

    private func getSharedBetToken() {
        if let betHistoryEntry = self.betHistoryEntry {

            let betTokenRoute = TSRouter.getSharedBetTokens(betId: betHistoryEntry.betId)

            Env.everyMatrixClient.manager.getModel(router: betTokenRoute, decodingType: SharedBetToken.self)
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { completion in
                    switch completion {
                    case .failure(let apiError):
                        switch apiError {
                        case .requestError(let value):
                            print("Bet token request error: \(value)")
                        case .notConnected:
                            ()
                        default:
                            ()
                        }
                    case .finished:
                        ()
                    }
                },
                receiveValue: { [weak self] betTokens in
                    let betToken = betTokens.sharedBetTokens.betTokenWithAllInfo
                    self?.sharedBetToken = betToken
                    self?.canShareTicket = true

                })
                .store(in: &cancellables)
        }
    }

    private func configureBetCards() {

        if let betHistoryEntry = self.betHistoryEntry {

            let locationsCodes = (betHistoryEntry.selections ?? [])
                .map({ event -> String in
                    let id = event.venueId ?? ""
                    return self.locationsCodesDictionary[id] ?? ""
                })

            let betCardViewModel = MyTicketCellViewModel(ticket: betHistoryEntry)

            self.sharedTicketCardView.configure(withBetHistoryEntry: betHistoryEntry, countryCodes: locationsCodes, viewModel: betCardViewModel)
        }

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

    @IBAction func didTapShareButton() {

        let renderer = UIGraphicsImageRenderer(size: self.scrollView.bounds.size)
        let image = renderer.image { _ in
            self.scrollView.drawHierarchy(in: self.scrollView.bounds, afterScreenUpdates: true)
        }
        self.ticketSnapshot = image

        if self.canShareTicket,
           let betHistoryEntry = self.betHistoryEntry,
           let sharedBetToken = self.sharedBetToken,
           let ticketSnapshot = self.ticketSnapshot {
            let clickedShareTicketInfo = ClickedShareTicketInfo(snapshot: ticketSnapshot,
                                                                betId: betHistoryEntry.betId,
                                                                betStatus: betHistoryEntry.status ?? "",
                                                                betToken: sharedBetToken,
                                                                ticket: betHistoryEntry)

            let shareTicketChoiceViewModel = ShareTicketChoiceViewModel(clickedShareTicketInfo: clickedShareTicketInfo)
            //shareTicketChoiceViewModel.clickedShareTicketInfo = clickedShareTicketInfo

            let shareTicketChoiceViewController = ShareTicketChoiceViewController(viewModel: shareTicketChoiceViewModel)

            self.present(shareTicketChoiceViewController, animated: true, completion: nil)
        }
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

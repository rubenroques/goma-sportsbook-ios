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
    private var loadedTicketInfoPublisher: CurrentValueSubject<[String: BetHistoryEntry], Never> = .init([:])
    private var cancellables = Set<AnyCancellable>()

    private var canShareTicketPublisher: CurrentValueSubject<Bool, Never> = .init(false)

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

        self.setupPublishers()

        self.checkmarkImageView.image = UIImage(named: "like_success_icon")

        self.messageTitleLabel.text = localized("bet_registered_success")
        self.messageTitleLabel.font = AppFont.with(type: .semibold, size: 14)

        self.messageSubtitleLabel.text = localized("good_luck")
        self.messageSubtitleLabel.font = AppFont.with(type: .bold, size: 14)

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

    private func setupPublishers() {

        self.loadedTicketInfoPublisher
            .receive(on: DispatchQueue.main)
            .dropFirst()
            .sink(receiveValue: { [weak self] loadedTicketInfo in
                guard let self = self else {return}
                if loadedTicketInfo.count == self.betPlacedDetailsArray.count {
                    self.isLoading = false
                }
            })
            .store(in: &cancellables)

        self.canShareTicketPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] canShare in
                if canShare {
                    self?.showBetShareScreen()
                    self?.canShareTicketPublisher.send(false)
                }
            })
            .store(in: &cancellables)
    }

    private func showBetShareScreen() {
//        let renderer = UIGraphicsImageRenderer(size: self.scrollView.bounds.size)
//        let image = renderer.image { _ in
//            self.scrollView.drawHierarchy(in: self.scrollView.bounds, afterScreenUpdates: true)
//        }
//        self.ticketSnapshot = image

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
                        self?.loadBetTickets()
                    }
                }
            })
            .store(in: &cancellables)
    }

    private func loadBetTickets() {

        for betPlaced in self.betPlacedDetailsArray {

            if let betId = betPlaced.response.betId {

                let ticketRoute = TSRouter.getTicket(betId: betId)
                Env.everyMatrixClient.manager.getModel(router: ticketRoute, decodingType: BetHistoryResponse.self)
                    .receive(on: DispatchQueue.main)
                    .sink(receiveCompletion: { [weak self] completion in
                        switch completion {
                        case .failure(let apiError):
                            switch apiError {
                            case .requestError(let value) where value.lowercased().contains("you must be logged in to perform this action"):
                                ()
                            case .notConnected:
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

                        if let betHistory = betHistoryResponse.betList?.first {

                            if let betHistoryEntryArray = self?.betHistoryEntry,
                               !betHistoryEntryArray.contains(where: {$0.betId == betHistory.betId}) {
                            self?.betHistoryEntry.append(betHistory)
                            self?.configureBetCard(betHistory: betHistory)
                            }
                        }

                    })
                    .store(in: &cancellables)
            }
        }
    }

    private func getSharedBetToken(betHistoryEntry: BetHistoryEntry) {

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
                self?.sharedBetHistory = betHistoryEntry
                self?.canShareTicketPublisher.send(true)

            })
            .store(in: &cancellables)

    }

    private func configureBetCard(betHistory: BetHistoryEntry) {

        let locationsCodes = (betHistory.selections ?? [])
            .map({ event -> String in
                let id = event.venueId ?? ""
                return self.locationsCodesDictionary[id] ?? ""
            })

        let sharedTicketCardView = SharedTicketCardView()

        let betCardViewModel = MyTicketCellViewModel(ticket: betHistory)

        sharedTicketCardView.configure(withBetHistoryEntry: betHistory, countryCodes: locationsCodes, viewModel: betCardViewModel)

        sharedTicketCardView.didTappedSharebet = { [weak self] snapshot in
            self?.getSharedBetToken(betHistoryEntry: betHistory)
            self?.ticketSnapshots[betHistory.betId] = snapshot
        }

        self.betCardsStackView.addArrangedSubview(sharedTicketCardView)

        self.loadedTicketInfoPublisher.value[betHistory.betId] = betHistory

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

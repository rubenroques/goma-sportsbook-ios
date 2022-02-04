//
//  PreSubmissionBetslipViewController.swift
//  Sportsbook
//
//  Created by Ruben Roques on 03/11/2021.
//

import UIKit
import Combine
import OrderedCollections

class PreSubmissionBetslipViewController: UIViewController {
  
    @IBOutlet private weak var topSafeArea: UIView!
    @IBOutlet private weak var bottomSafeArea: UIView!

    @IBOutlet private weak var betTypeSegmentControlBaseView: UIView!
    @IBOutlet private weak var betTypeSegmentControl: UISegmentedControl!

    @IBOutlet private weak var clearBaseView: UIView!
    @IBOutlet private weak var clearButton: UIButton!
    
    @IBOutlet private weak var settingsButton: UIButton!
    
    @IBOutlet private weak var tableView: UITableView!

    @IBOutlet private weak var systemBetBaseView: UIView!
    @IBOutlet private weak var systemBetSeparatorView: UIView!
    @IBOutlet private weak var systemBetInteriorView: UIView!
    @IBOutlet private weak var systemBetIconImageView: UIImageView!
    @IBOutlet private weak var systemBetTypeTitleLabel: UILabel!
    @IBOutlet private weak var systemBetTypeLabel: UILabel!
    @IBOutlet private weak var systemBetTypeLoadingView: UIActivityIndicatorView!

    @IBOutlet private weak var systemBetTypeSelectorBaseView: UIView!
    @IBOutlet private weak var systemBetTypeSelectorContainerView: UIView!
    @IBOutlet private weak var systemBetTypePickerView: UIPickerView!
    @IBOutlet private weak var selectSystemBetTypeButton: UIButton!

    @IBOutlet private weak var simpleWinningsBaseView: UIView!
    @IBOutlet private weak var simpleWinningsSeparatorView: UIView!
    @IBOutlet private weak var simpleWinningsTitleLabel: UILabel!
    @IBOutlet private weak var simpleWinningsValueLabel: UILabel!
    @IBOutlet private weak var simpleOddsTitleLabel: UILabel!
    @IBOutlet private weak var simpleOddsValueLabel: UILabel!

    @IBOutlet private weak var multipleWinningsBaseView: UIView!
    @IBOutlet private weak var multipleWinningsSeparatorView: UIView!
    @IBOutlet private weak var multipleWinningsTitleLabel: UILabel!
    @IBOutlet private weak var multipleWinningsValueLabel: UILabel!
    @IBOutlet private weak var multipleOddsTitleLabel: UILabel!
    @IBOutlet private weak var multipleOddsValueLabel: UILabel!

    @IBOutlet private weak var systemWinningsBaseView: UIView!
    @IBOutlet private weak var systemWinningsSeparatorView: UIView!
    @IBOutlet private weak var systemWinningsTitleLabel: UILabel!
    @IBOutlet private weak var systemWinningsValueLabel: UILabel!
    @IBOutlet private weak var systemOddsTitleLabel: UILabel!
    @IBOutlet private weak var systemOddsValueLabel: UILabel!

    @IBOutlet private weak var placeBetBaseView: UIView!
    @IBOutlet private weak var placeBetButtonsBaseView: UIView!
    @IBOutlet private weak var placeBetButtonsSeparatorView: UIView!
    @IBOutlet private weak var amountBaseView: UIView!
    @IBOutlet private weak var amountTextfield: UITextField!
    @IBOutlet private weak var plusOneButtonView: UIButton!
    @IBOutlet private weak var plusFiveButtonView: UIButton!
    @IBOutlet private weak var maxValueButtonView: UIButton!

    @IBOutlet private weak var placeBetSendButtonBaseView: UIView!
    @IBOutlet private weak var placeBetButton: UIButton!

    @IBOutlet private weak var placeBetBottomConstraint: NSLayoutConstraint!

    @IBOutlet private weak var secondaryPlaceBetBaseView: UIView!
    
    @IBOutlet private weak var secondaryPlaceBetButtonsBaseView: UIView!
    @IBOutlet private weak var secondaryPlaceBetButtonsSeparatorView: UIView!
    @IBOutlet private weak var secondaryAmountBaseView: UIView!
    @IBOutlet private weak var secondaryAmountTextfield: UITextField!
    
    @IBOutlet private weak var secondaryPlaceBetButton: UIButton!
    
    @IBOutlet private weak var secondaryPlusOneButtonView: UIButton!
    @IBOutlet private weak var secondaryPlusFiveButtonView: UIButton!
    @IBOutlet private weak var secondaryMaxButtonView: UIButton!
    
    @IBOutlet private weak var secondaryMultipleWinningsBaseView: UIView!
    @IBOutlet private weak var secondaryMultipleWinningsValueLabel: UILabel!
    @IBOutlet private weak var secondaryMultipleWinningsTitleLabel: UILabel!
    @IBOutlet private weak var secondaryMultipleOddsTitleLabel: UILabel!
    @IBOutlet private weak var secondaryMultipleOddsValueLabel: UILabel!
    @IBOutlet private weak var secondaryMultipleWinningsSeparatorView: UIView!

    @IBOutlet private weak var secondarySystemWinningsBaseView: UIView!
    @IBOutlet private weak var secondarySystemWinningsValueLabel: UILabel!
    @IBOutlet private weak var secondarySystemOddsTitleLabel: UILabel!
    @IBOutlet private weak var secondarySystemWinningsTitleLabel: UILabel!
    @IBOutlet private weak var secondarySystemOddsValueLabel: UILabel!
    @IBOutlet private weak var secondarySystemWinningsSeparatorView: UIView!

    @IBOutlet private weak var dontHaveSelectionsBetslipInfoLabel: UILabel!
    @IBOutlet private weak var hereAreYourSuggestedBetLabel: UILabel!
    
    @IBOutlet private weak var emptyBetsBaseView: UIView!

    @IBOutlet private weak var loadingBaseView: UIView!
    @IBOutlet private weak var loadingView: UIActivityIndicatorView!

    @IBOutlet private weak var betSuggestedCollectionView: UICollectionView!
    @IBOutlet private weak var suggestedBetsActivityIndicator: UIActivityIndicatorView!
    
    @IBOutlet private weak var secondPlaceBetBaseViewConstraint: NSLayoutConstraint!

    private var singleBettingTicketDataSource = SingleBettingTicketDataSource.init(bettingTickets: [])
    private var multipleBettingTicketDataSource = MultipleBettingTicketDataSource.init(bettingTickets: [])
    private var systemBettingTicketDataSource = SystemBettingTicketDataSource(bettingTickets: [])

    var cancellables = Set<AnyCancellable>()
    var isSuggestedMultiple: Bool = false

    enum BetslipType {
        case simple
        case multiple
        case system
    }

    private var listTypePublisher: CurrentValueSubject<BetslipType, Never> = .init(.simple)

    // System Bets vars
    var selectedSystemBet: SystemBetType? {
        didSet {
            if let systemBetType = self.selectedSystemBet {
                self.systemBetTypeLabel.text = systemBetType.name ?? localized("system_bet")
            }
        }
    }
    var systemBetOptions: [SystemBetType] = []
    var showingSystemBetOptionsSelector: Bool = false {
        didSet {
            if showingSystemBetOptionsSelector {
                self.systemBetTypeSelectorBaseView.alpha = 1.0
            }
            else {
                self.systemBetTypeSelectorBaseView.alpha = 0.0
            }
        }
    }

    // Multiple Bets values
     var displayBetValue: Int = 0 {
        didSet {
            self.realBetValuePublisher.send(self.realBetValue)
        }
    }
     var realBetValue: Double {
        if displayBetValue == 0 {
            return 0
        }
        else {
            return Double(displayBetValue)/Double(100)
        }
    }

    // Simple Bets values
    private var simpleBetsBettingValues: CurrentValueSubject<[String: Double], Never> = .init([:])

    private var maxBetValue: Double = Double.greatestFiniteMagnitude

    private var realBetValuePublisher: CurrentValueSubject<Double, Never> = .init(0.0)
    private var multiplierPublisher: CurrentValueSubject<Double, Never> = .init(0.0)
    
    private var isKeyboardShowingPublisher: CurrentValueSubject<Bool, Never> = .init(false)

    private var isLoading = false {
        didSet {
            if isLoading {
                self.loadingBaseView.alpha = 1.0
            }
            else {
                self.loadingBaseView.alpha = 0.0
            }
        }
    }

    var betPlacedAction: (([BetPlacedDetails]) -> Void)?

    var gomaSuggestedBetsResponse: [[GomaSuggestedBets]] = []

    var suggestedBetsRegisters: [EndpointPublisherIdentifiable] = []
    var suggestedCancellables = Set<AnyCancellable>()
    var isSuggestedBetsLoading: Bool = false {
        didSet {
            self.suggestedBetsActivityIndicator.isHidden = !isSuggestedBetsLoading
        }
    }
    var cachedBetSuggestedCollectionViewCellViewModels: [Int: BetSuggestedCollectionViewCellViewModel] = [:]
    var suggestedCellLoadedPublisher: AnyCancellable?

    var maxStakeMultiple: Double?
    var maxStakeSystem: Double?
    var userBalance: Double?

    // Suggested Aggregator Variables
    var matches: [String: EveryMatrix.Match] = [:]
    var match: EveryMatrix.Match?
    var marketsForMatch: [String: Set<String>] = [:]
    var betOutcomes: [String: EveryMatrix.BetOutcome] = [:]
    var bettingOffers: [String: EveryMatrix.BettingOffer] = [:]
    var marketOutcomeRelations: [String: EveryMatrix.MarketOutcomeRelation] = [:]
    var tournaments: [String: EveryMatrix.Tournament] = [:]
    var mainMarkets: OrderedDictionary<String, EveryMatrix.Market> = [:]
    var mainMarketsOrder: OrderedSet<String> = []
    var bettingOutcomesForMarket: [String: Set<String>] = [:]

    // Publishers
    var marketsPublishers: [String: CurrentValueSubject<EveryMatrix.Market, Never>] = [:]
    var bettingOfferPublishers: [String: CurrentValueSubject<EveryMatrix.BettingOffer, Never>] = [:]

    init() {
        super.init(nibName: "PreSubmissionBetslipViewController", bundle: nil)

        self.title = "Betslip"
    }

    @available(iOS, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        cachedBetSuggestedCollectionViewCellViewModels = [:]
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.commonInit()
        
        self.systemBetTypeSelectorBaseView.alpha = 0.0
        self.loadingBaseView.alpha = 0.0

        self.suggestedBetsActivityIndicator.isHidden = true

        self.view.bringSubviewToFront(systemBetTypeSelectorBaseView)
        self.view.bringSubviewToFront(emptyBetsBaseView)
        self.view.bringSubviewToFront(loadingBaseView)

        self.betSuggestedCollectionView.register(BetSuggestedCollectionViewCell.nib,
                                       forCellWithReuseIdentifier: BetSuggestedCollectionViewCell.identifier)
        self.betSuggestedCollectionView.delegate = self
        self.betSuggestedCollectionView.dataSource = self
        self.betSuggestedCollectionView.showsVerticalScrollIndicator = false
        self.betSuggestedCollectionView.showsHorizontalScrollIndicator = false

        self.systemBetTypePickerView.delegate = self
        self.systemBetTypePickerView.dataSource = self

        self.placeBetButtonsBaseView.isHidden = true
        self.placeBetButtonsSeparatorView.alpha = 0.5
        
        self.secondaryPlaceBetButtonsSeparatorView.alpha = 0.5

        self.simpleWinningsValueLabel.text = "-.--€"
        self.simpleOddsValueLabel.isHidden = true
        self.simpleOddsTitleLabel.isHidden = true

        self.multipleWinningsValueLabel.text = "-.--€"
        self.multipleOddsValueLabel.text = "-.--"

        self.secondaryMultipleWinningsValueLabel.text = "-.--€"
        self.secondaryMultipleOddsValueLabel.text = "-.--"
        
        self.systemWinningsValueLabel.text = "-.--€"
        self.systemOddsTitleLabel.text = localized("total_bet_amount")
        self.systemOddsValueLabel.text = "-.--€"
        
        self.secondarySystemWinningsValueLabel.text = "-.--€"
        self.secondarySystemOddsTitleLabel.text = localized("total_bet_amount")
        self.secondarySystemOddsValueLabel.text = "-.--€"
        
        self.tableView.separatorStyle = .none
        self.tableView.allowsSelection = false

        self.tableView.register(SingleBettingTicketTableViewCell.nib, forCellReuseIdentifier: SingleBettingTicketTableViewCell.identifier)
        self.tableView.register(MultipleBettingTicketTableViewCell.nib, forCellReuseIdentifier: MultipleBettingTicketTableViewCell.identifier)

        self.tableView.dataSource = self
        self.tableView.delegate = self

        self.amountTextfield.delegate = self
        
        self.secondaryAmountTextfield.delegate = self

        self.systemBetInteriorView.layer.cornerRadius = 8
        self.systemBetInteriorView.layer.borderWidth = 2
        self.systemBetInteriorView.layer.borderColor = UIColor.App.backgroundTertiary.cgColor

        self.systemBetTypeLoadingView.hidesWhenStopped = true
        self.systemBetTypeLoadingView.stopAnimating()

        self.systemBetTypeLabel.text = ""

        let tapSystemBetTypeSelector = UITapGestureRecognizer(target: self, action: #selector(didTapSystemBetTypeSelector))
        self.systemBetInteriorView.addGestureRecognizer(tapSystemBetTypeSelector)

        let amountBaseViewTapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapAmountBaseView))
        self.amountBaseView.addGestureRecognizer(amountBaseViewTapGesture)
        self.amountTextfield.isUserInteractionEnabled = false
        
        if Env.betslipManager.bettingTicketsPublisher.value.count > 1 {
            self.betTypeSegmentControl.selectedSegmentIndex = 1
            self.didChangeSegmentValue(self.betTypeSegmentControl)
        }

        singleBettingTicketDataSource.didUpdateBettingValueAction = { [weak self] id, value in
            if value == 0 {
                self?.simpleBetsBettingValues.value[id] = nil
            }
            else {
                self?.simpleBetsBettingValues.value[id] = value
            }
        }
        singleBettingTicketDataSource.bettingValueForId = { [weak self] id in
            self?.simpleBetsBettingValues.value[id]
        }

        Env.betslipManager.bettingTicketsPublisher
            .receive(on: DispatchQueue.main)
            .map(Array.init)
            .sink { [weak self] tickets in
                self?.singleBettingTicketDataSource.bettingTickets = tickets
                self?.multipleBettingTicketDataSource.bettingTickets = tickets
                self?.systemBettingTicketDataSource.bettingTickets = tickets

                self?.systemBetOptions = []
                self?.selectedSystemBet = nil

                self?.systemBetTypePickerView.reloadAllComponents()

                if tickets.count < 3 {
                    if self?.betTypeSegmentControl.selectedSegmentIndex == 2 {
                        self?.betTypeSegmentControl.selectedSegmentIndex = 1
                    }

                    self?.betTypeSegmentControl.setEnabled(false, forSegmentAt: 2)
                }
                else {
                    self?.betTypeSegmentControl.setEnabled(true, forSegmentAt: 2)
                    self?.requestSystemBetsTypes()
                }

                if tickets.count == 1 {
                    if self?.betTypeSegmentControl.selectedSegmentIndex == 1 {
                        self?.betTypeSegmentControl.selectedSegmentIndex = 0
                    }
                    self?.betTypeSegmentControl.setEnabled(false, forSegmentAt: 1)
                }
                else {
                    self?.betTypeSegmentControl.setEnabled(true, forSegmentAt: 1)
                }

                if tickets.count > 1 && self?.isSuggestedMultiple == true {
                    self?.betTypeSegmentControl.selectedSegmentIndex = 1
                }

                if let segmentControl = self?.betTypeSegmentControl {
                    self?.didChangeSegmentValue(segmentControl)
                }

                self?.tableView.reloadData()
            }
            .store(in: &cancellables)

        Env.betslipManager.bettingTicketsPublisher
            .receive(on: DispatchQueue.main)
            .map({ orderedSet -> Double in
                let newArray = orderedSet.map { $0.value }
                let multiple: Double = newArray.reduce(1.0, *)
                return multiple
            })
            .sink(receiveValue: { [weak self] multiplier in
                self?.multiplierPublisher.send(multiplier)
            })
            .store(in: &cancellables)

        self.multiplierPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] multiplier in
                self?.multipleOddsValueLabel.text = OddFormatter.formatOdd(withValue: multiplier)
                self?.secondaryMultipleOddsValueLabel.text = OddFormatter.formatOdd(withValue: multiplier)
            })
            .store(in: &cancellables)

        Env.betslipManager.bettingTicketsPublisher
            .receive(on: DispatchQueue.main)
            .map(\.isEmpty)
            .sink(receiveValue: { [weak self] isEmpty in
                self?.emptyBetsBaseView.isHidden = !isEmpty

                if isEmpty {
                    self?.getSuggestedBets()
                }
            })
            .store(in: &cancellables)

        self.listTypePublisher
            .receive(on: DispatchQueue.main)
            .map({ $0 == .simple })
            .sink(receiveValue: { [weak self] isSimpleBet in
                self?.placeBetButtonsBaseView.isHidden = isSimpleBet
                self?.secondaryPlaceBetButtonsBaseView.isHidden = isSimpleBet
            })
            .store(in: &cancellables)

        self.listTypePublisher
            .receive(on: DispatchQueue.main)
            .map({ $0 == .system })
            .sink(receiveValue: { [weak self] isSystemBet in
                self?.systemBetBaseView.isHidden = !isSystemBet
            })
            .store(in: &cancellables)

        self.listTypePublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] betType in

                switch betType {
                case .simple:
                    self?.simpleWinningsBaseView.isHidden = false
                    self?.multipleWinningsBaseView.isHidden = true
                    self?.systemWinningsBaseView.isHidden = true
                case .multiple:
                    self?.simpleWinningsBaseView.isHidden = true
                    self?.multipleWinningsBaseView.isHidden = false
                    self?.systemWinningsBaseView.isHidden = true
                    self?.checkMaxAmountTransition()
                case .system:
                    self?.simpleWinningsBaseView.isHidden = true
                    self?.multipleWinningsBaseView.isHidden = true
                    self?.systemWinningsBaseView.isHidden = false
                    self?.checkMaxAmountTransition()
                }
            })
            .store(in: &cancellables)

        Publishers.CombineLatest(self.listTypePublisher, self.realBetValuePublisher)
            .receive(on: DispatchQueue.main)
            .filter { [weak self] betslipType, _ in
                betslipType == .system && self?.selectedSystemBet != nil
            }
            .map({ [weak self] _, bettingValue in
                return bettingValue > 0 && bettingValue < (self?.maxBetValue ?? 0)
            })
            .sink(receiveValue: { [weak self] hasValidBettingValue in
                if hasValidBettingValue {
                    self?.requestSystemBetInfo()
                }
                
                self?.placeBetButton.isEnabled = hasValidBettingValue
            })
            .store(in: &cancellables)

        Publishers.CombineLatest(self.listTypePublisher, self.realBetValuePublisher)
            .receive(on: DispatchQueue.main)
            .filter { betslipType, _ in
                betslipType == .multiple
            }
            .map({ [weak self] _, bettingValue in
                return bettingValue > 0 && bettingValue < (self?.maxBetValue ?? 0)
            })
            .sink(receiveValue: { [weak self] hasValidBettingValue in
                self?.placeBetButton.isEnabled = hasValidBettingValue
            })
            .store(in: &cancellables)

        Publishers.CombineLatest(self.multiplierPublisher, self.realBetValuePublisher)
            .receive(on: DispatchQueue.main)
            .map({ multiplier, betValue -> String in
                if multiplier >= 1 && betValue > 0 {
                    var totalValue = multiplier * betValue
                    totalValue = Double(floor(totalValue * 100)/100)
                    return CurrencyFormater.defaultFormat.string(from: NSNumber(value: totalValue)) ?? "-.--€"
                }
                else {
                    return "-.--€"
                }
            })
            .sink(receiveValue: { [weak self] possibleEarnings in
                self?.secondaryMultipleWinningsValueLabel.text = possibleEarnings
                self?.multipleWinningsValueLabel.text = possibleEarnings
            })
            .store(in: &cancellables)
        
        Publishers.CombineLatest3(self.listTypePublisher, self.simpleBetsBettingValues, Env.betslipManager.bettingTicketsPublisher)
            .receive(on: DispatchQueue.main)
            .filter { betslipType, _, _ in
                betslipType == .simple
            }
            .map({ _, simpleBetsBettingValues, tickets -> String in
                var expectedReturn = 0.0
                
                for ticket in tickets {
                    if let betValue = simpleBetsBettingValues[ticket.id] {
                        let expectedTicketReturn = ticket.value * betValue
                          expectedReturn += expectedTicketReturn
                    }
                }
                if expectedReturn == 0 {
                    return "-.--€"
                }
                else {
                    expectedReturn = Double(floor(expectedReturn * 100)/100)
                    return  CurrencyFormater.defaultFormat.string(from: NSNumber(value: expectedReturn)) ?? "-.--€"
                }
            })
            .sink(receiveValue: { [weak self] possibleEarningsString in
                self?.simpleWinningsValueLabel.text = possibleEarningsString
            })
            .store(in: &cancellables)

        Publishers.CombineLatest3(self.listTypePublisher, self.simpleBetsBettingValues, Env.betslipManager.bettingTicketsPublisher)
            .receive(on: DispatchQueue.main)
            .filter { betslipType, _, _ in
                betslipType == .simple
            }
            .map({ _, simpleBetsBettingValues, tickets -> Bool in
                var hasValidAmounts = true
                
                for ticket in tickets where simpleBetsBettingValues[ticket.id] == nil {
                    hasValidAmounts = false
                    break
                }
                
                let allTicketsAvailable = tickets.map(\.isAvailable).allSatisfy({ $0 == true })
                    
                return hasValidAmounts && allTicketsAvailable
            })
            .sink(receiveValue: { [weak self] hasValidBettingValue in
                self?.placeBetButton.isEnabled = hasValidBettingValue
            })
            .store(in: &cancellables)
        
        Publishers.CombineLatest(self.listTypePublisher, self.isKeyboardShowingPublisher)
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] listType, isKeyboardShowing in
                switch (listType, isKeyboardShowing) {
                case (.simple, _):
                    self?.secondaryPlaceBetBaseView.isHidden = true
                    self?.secondaryAmountTextfield.resignFirstResponder()
                    self?.amountTextfield.resignFirstResponder()
                case (.multiple, true):
                    self?.secondaryPlaceBetBaseView.isHidden = false
                    self?.secondaryMultipleWinningsBaseView.isHidden = false
                    self?.secondarySystemWinningsBaseView.isHidden = true
                case (.system, true):
                    self?.secondaryPlaceBetBaseView.isHidden = false
                    self?.secondaryMultipleWinningsBaseView.isHidden = true
                    self?.secondarySystemWinningsBaseView.isHidden = false
                default :
                    self?.secondaryPlaceBetBaseView.isHidden = true
                }
            })
            .store(in: &cancellables)

        Env.betslipManager.removeAllPlacedDetailsError()
        Env.betslipManager.removeAllBetslipPlacedBetErrorResponse()

        Env.betslipManager.betPlacedDetailsErrorsPublisher
            .receive(on: DispatchQueue.main)
            .sink { _ in
                
            } receiveValue: { [weak self] betPlacedDetails in
                if !betPlacedDetails.isEmpty {
                    let errorMessage = betPlacedDetails[0].response.errorMessage
                    let response = betPlacedDetails[0].response
                    self?.showErrorView(errorMessage: errorMessage)

                    Env.betslipManager.addBetslipPlacedBetErrorResponse(betPlacedError: [response])
                }
            }
            .store(in: &cancellables)

        Env.betslipManager.betslipPlaceBetResponseErrorsPublisher
            .receive(on: DispatchQueue.main)
            .sink { _ in
                // self.isLoading = false
            } receiveValue: { [weak self] _ in
                self?.tableView.reloadData()
            }
            .store(in: &cancellables)

        Env.betslipManager.multipleBetslipSelectionState
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] betslipState in
                self?.maxStakeMultiple = betslipState?.maxStake
            })
            .store(in: &cancellables)

        Env.userSessionStore.userBalanceWallet
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] wallet in
                self?.userBalance = wallet?.amount
            })
            .store(in: &cancellables)

        self.setupWithTheme()

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        self.placeBetButton.isEnabled = false

        Env.everyMatrixClient.manager.swampSession?.printMemoryLogs()

    }

//    override func viewDidDisappear(_ animated: Bool) {
//        super.viewDidDisappear(animated)
//        for cachedBetSuggestedViewModel in self.cachedBetSuggestedCollectionViewCellViewModels.values {
//
//            cachedBetSuggestedViewModel.unregisterSuggestedBets()
//        }
//        cachedBetSuggestedCollectionViewCellViewModels = [:]
//    }

    func getSuggestedBets() {

        self.isSuggestedBetsLoading = true

        for suggestedBetRegister in self.suggestedBetsRegisters {
            Env.everyMatrixClient.manager.unregisterFromEndpoint(endpointPublisherIdentifiable: suggestedBetRegister)
        }

        Env.gomaNetworkClient.requestSuggestedBets(deviceId: Env.deviceId)
            .sink(receiveCompletion: { _ in
            },
            receiveValue: { [weak self] gomaBetsArray in

                guard let betsArray = gomaBetsArray else {return}

                self?.gomaSuggestedBetsResponse = betsArray

                DispatchQueue.main.async {
                    self?.betSuggestedCollectionView.reloadData()
                }
            })
            .store(in: &cancellables)

    }

    func showErrorView(errorMessage: String?) {

        let errorView = BetslipErrorView()
        errorView.alpha = 0
        errorView.setDescription(description: errorMessage ?? localized("error"))
        errorView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(errorView)

        NSLayoutConstraint.activate([
            errorView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
            errorView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor),
            errorView.bottomAnchor.constraint(equalTo: self.placeBetBaseView.safeAreaLayoutGuide.topAnchor, constant: -10)
        ])

        UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseIn, animations: {
            errorView.alpha = 1.0
            UIView.animate(withDuration: 0.2, delay: 5.0, options: .curveEaseOut, animations: {
                errorView.alpha = 0
            }, completion: { _ in
                errorView.removeFromSuperview()
            })
        }, completion: nil)

    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        self.plusOneButtonView.layer.cornerRadius = CornerRadius.view
        self.plusOneButtonView.clipsToBounds = true
        self.plusFiveButtonView.layer.cornerRadius = CornerRadius.view
        self.plusFiveButtonView.clipsToBounds = true
        self.maxValueButtonView.layer.cornerRadius = CornerRadius.view
        self.maxValueButtonView.clipsToBounds = true

        self.amountBaseView.layer.cornerRadius = CornerRadius.view
        
        self.secondaryPlusOneButtonView.layer.cornerRadius = CornerRadius.view
        self.secondaryPlusOneButtonView.clipsToBounds = true
        self.secondaryPlusFiveButtonView.layer.cornerRadius = CornerRadius.view
        self.secondaryPlusFiveButtonView.clipsToBounds = true
        self.secondaryMaxButtonView.layer.cornerRadius = CornerRadius.view
        self.secondaryMaxButtonView.clipsToBounds = true

        self.secondaryAmountBaseView.layer.cornerRadius = CornerRadius.view
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        self.setupWithTheme()
    }

    private func commonInit() {

        betSuggestedCollectionView.showsVerticalScrollIndicator = false
        betSuggestedCollectionView.showsHorizontalScrollIndicator = true
        betSuggestedCollectionView.register(BetSuggestedCollectionViewCell.nib,
                                       forCellWithReuseIdentifier: BetSuggestedCollectionViewCell.identifier)
        betSuggestedCollectionView.delegate = self
        betSuggestedCollectionView.dataSource = self

    }

    func setupWithTheme() {

        self.view.backgroundColor = UIColor.App.backgroundPrimary

        self.secondaryPlaceBetButtonsBaseView.backgroundColor = UIColor.App.backgroundSecondary
        
        self.systemBetTypePickerView.backgroundColor = UIColor.App.backgroundSecondary

        self.clearBaseView.backgroundColor = UIColor.App.backgroundPrimary

        self.systemBetTypeLabel.textColor = UIColor.App.textPrimary
        self.systemBetTypeTitleLabel.textColor = UIColor.App.textSecond
        self.systemBetTypeSelectorBaseView.backgroundColor = UIColor.App.backgroundTertiary

        self.betTypeSegmentControl.setTitleTextAttributes([
            NSAttributedString.Key.font: AppFont.with(type: .bold, size: 13),
            NSAttributedString.Key.foregroundColor: UIColor.App.buttonTextPrimary
        ], for: .selected)
        self.betTypeSegmentControl.setTitleTextAttributes([
            NSAttributedString.Key.font: AppFont.with(type: .bold, size: 13),
            NSAttributedString.Key.foregroundColor: UIColor.App.buttonTextPrimary
        ], for: .normal)
        self.betTypeSegmentControl.setTitleTextAttributes([
            NSAttributedString.Key.font: AppFont.with(type: .bold, size: 13),
            NSAttributedString.Key.foregroundColor: UIColor.App.buttonTextPrimary.withAlphaComponent(0.5)
        ], for: .disabled)

        self.betTypeSegmentControl.selectedSegmentTintColor = UIColor.App.highlightPrimary

        self.topSafeArea.backgroundColor = UIColor.App.backgroundSecondary
        self.bottomSafeArea.backgroundColor = UIColor.App.backgroundSecondary

        self.betTypeSegmentControlBaseView.backgroundColor = UIColor.App.backgroundPrimary

        self.amountTextfield.font = AppFont.with(type: .semibold, size: 14)
        self.amountTextfield.textColor = UIColor.App.textPrimary
        self.amountTextfield.attributedPlaceholder = NSAttributedString(string: localized("amount"), attributes: [
            NSAttributedString.Key.font: AppFont.with(type: .semibold, size: 14),
            NSAttributedString.Key.foregroundColor: UIColor.App.textDisablePrimary
        ])

        self.clearButton.titleLabel?.textColor = UIColor.App.textPrimary
        self.secondaryAmountTextfield.font = AppFont.with(type: .semibold, size: 14)
        self.secondaryAmountTextfield.textColor = UIColor.App.textPrimary
        self.secondaryAmountTextfield.attributedPlaceholder = NSAttributedString(string: localized("amount"), attributes: [
            NSAttributedString.Key.font: AppFont.with(type: .semibold, size: 14),
            NSAttributedString.Key.foregroundColor: UIColor.App.textDisablePrimary
        ])

        self.dontHaveSelectionsBetslipInfoLabel.textColor = UIColor.App.textPrimary
        self.hereAreYourSuggestedBetLabel.textColor = UIColor.App.textPrimary
        self.amountBaseView.backgroundColor = UIColor.App.backgroundSecondary

        self.tableView.backgroundView?.backgroundColor = UIColor.App.backgroundPrimary
        self.tableView.backgroundColor = UIColor.App.backgroundPrimary
        self.tableView.contentInset.bottom = 12

        self.systemBetSeparatorView.backgroundColor = UIColor.App.separatorLine
        self.systemBetBaseView.backgroundColor = UIColor.App.backgroundSecondary
        self.systemBetInteriorView.layer.borderColor = UIColor.App.backgroundSecondary.cgColor
        self.systemBetInteriorView.backgroundColor = UIColor.App.backgroundTertiary

        self.placeBetBaseView.backgroundColor = UIColor.App.backgroundSecondary
        self.placeBetButtonsBaseView.backgroundColor = UIColor.App.backgroundSecondary
        self.placeBetButtonsSeparatorView.backgroundColor = UIColor.App.separatorLine
        self.placeBetSendButtonBaseView.backgroundColor = UIColor.App.backgroundSecondary

        self.secondaryPlaceBetButtonsSeparatorView.backgroundColor = UIColor.App.separatorLine

        self.placeBetButton.backgroundColor = UIColor.App.buttonBackgroundPrimary

        self.plusOneButtonView.setBackgroundColor(UIColor.App.backgroundTertiary, for: .normal)
        self.plusOneButtonView.setTitleColor(UIColor.App.textPrimary, for: .normal)
        self.plusOneButtonView.setTitleColor(UIColor.App.textPrimary.withAlphaComponent(0.7), for: .highlighted)

        self.plusFiveButtonView.setBackgroundColor(UIColor.App.backgroundTertiary, for: .normal)
        self.plusFiveButtonView.setTitleColor(UIColor.App.textPrimary, for: .normal)
        self.plusFiveButtonView.setTitleColor(UIColor.App.textPrimary.withAlphaComponent(0.7), for: .highlighted)

        self.maxValueButtonView.setBackgroundColor(UIColor.App.backgroundTertiary, for: .normal)
        self.maxValueButtonView.setTitleColor(UIColor.App.textPrimary, for: .normal)
        self.maxValueButtonView.setTitleColor(UIColor.App.textPrimary.withAlphaComponent(0.7), for: .highlighted)

        self.secondaryPlusOneButtonView.setBackgroundColor(UIColor.App.backgroundTertiary, for: .normal)
        self.secondaryPlusOneButtonView.setTitleColor(UIColor.App.textPrimary, for: .normal)
        self.secondaryPlusOneButtonView.setTitleColor(UIColor.App.textPrimary.withAlphaComponent(0.7), for: .highlighted)

        self.secondaryPlusFiveButtonView.setBackgroundColor(UIColor.App.backgroundTertiary, for: .normal)
        self.secondaryPlusFiveButtonView.setTitleColor(UIColor.App.textPrimary, for: .normal)
        self.secondaryPlusFiveButtonView.setTitleColor(UIColor.App.textPrimary.withAlphaComponent(0.7), for: .highlighted)

        self.secondaryMaxButtonView.setBackgroundColor(UIColor.App.backgroundTertiary, for: .normal)
        self.secondaryMaxButtonView.setTitleColor(UIColor.App.textPrimary, for: .normal)
        self.secondaryMaxButtonView.setTitleColor(UIColor.App.textPrimary.withAlphaComponent(0.7), for: .highlighted)

        self.emptyBetsBaseView.backgroundColor = UIColor.App.backgroundPrimary

        self.simpleWinningsSeparatorView.backgroundColor = UIColor.App.separatorLine
        self.multipleWinningsSeparatorView.backgroundColor = UIColor.App.separatorLine
        self.secondaryMultipleWinningsSeparatorView.backgroundColor = UIColor.App.separatorLine
        self.systemWinningsSeparatorView.backgroundColor = UIColor.App.separatorLine
        self.secondarySystemWinningsSeparatorView.backgroundColor = UIColor.App.separatorLine

        self.simpleWinningsBaseView.backgroundColor = UIColor.App.backgroundCards
        self.simpleWinningsTitleLabel.textColor = UIColor.App.textDisablePrimary
        self.simpleWinningsValueLabel.textColor = UIColor.App.textPrimary
        self.simpleOddsTitleLabel.textColor = UIColor.App.textDisablePrimary
        self.simpleOddsValueLabel.textColor = UIColor.App.textPrimary

        self.multipleWinningsBaseView.backgroundColor = UIColor.App.backgroundSecondary
        self.multipleWinningsTitleLabel.textColor = UIColor.App.textPrimary
        self.multipleWinningsValueLabel.textColor = UIColor.App.textPrimary

        self.secondaryMultipleWinningsBaseView.backgroundColor = UIColor.App.backgroundSecondary
        self.secondaryAmountBaseView.backgroundColor = UIColor.App.backgroundSecondary
        // self.secondarySystemWinningsBaseView.backgroundColor = UIColor.App2.backgroundSecondary

        self.secondaryMultipleWinningsTitleLabel.textColor = UIColor.App.textSecond
        self.secondaryMultipleWinningsValueLabel.textColor = UIColor.App.textPrimary

        self.secondaryMultipleOddsTitleLabel.textColor = UIColor.App.textDisablePrimary
        self.secondaryMultipleOddsValueLabel.textColor = UIColor.App.textPrimary

        self.multipleOddsTitleLabel.textColor = UIColor.App.textDisablePrimary
        self.multipleOddsValueLabel.textColor = UIColor.App.textPrimary

        self.systemWinningsBaseView.backgroundColor = UIColor.App.backgroundCards
        self.systemWinningsTitleLabel.textColor = UIColor.App.textDisablePrimary
        self.systemWinningsValueLabel.textColor = UIColor.App.textPrimary
        self.systemOddsTitleLabel.textColor = UIColor.App.textDisablePrimary
        self.systemOddsValueLabel.textColor = UIColor.App.textPrimary

        self.secondarySystemWinningsBaseView.backgroundColor = UIColor.App.backgroundCards
        self.secondarySystemWinningsTitleLabel.textColor = UIColor.App.textDisablePrimary
        self.secondarySystemWinningsValueLabel.textColor = UIColor.App.textPrimary
        self.secondarySystemOddsTitleLabel.textColor = UIColor.App.textDisablePrimary
        self.secondarySystemOddsValueLabel.textColor = UIColor.App.textPrimary

        self.selectSystemBetTypeButton.backgroundColor = UIColor.App.highlightPrimary
        
        self.betTypeSegmentControl.backgroundColor = UIColor.App.backgroundTertiary
        
        
        
        StyleHelper.styleButton(button: self.selectSystemBetTypeButton)
        StyleHelper.styleButton(button: self.placeBetButton)
        StyleHelper.styleButton(button: self.secondaryPlaceBetButton)

        self.settingsButton.setTitleColor(UIColor.App.textPrimary, for: .normal)
        self.clearButton.setTitleColor(UIColor.App.textPrimary, for: .normal)
    }

    @objc func dismissKeyboard() {
        self.amountTextfield.resignFirstResponder()
        self.secondaryAmountTextfield.resignFirstResponder()
    }

    @IBAction private func didTapClearButton() {
        Env.betslipManager.clearAllBettingTickets()

        self.gomaSuggestedBetsResponse = []

        for cachedBetSuggestedViewModel in self.cachedBetSuggestedCollectionViewCellViewModels.values {

            cachedBetSuggestedViewModel.unregisterSuggestedBets()
        }

        self.cachedBetSuggestedCollectionViewCellViewModels = [:]

        self.betSuggestedCollectionView.reloadData()
    }

    @IBAction private func didChangeSegmentValue(_ segmentControl: UISegmentedControl) {

        switch segmentControl.selectedSegmentIndex {
        case 0:
            self.listTypePublisher.value = .simple
 
        case 1:
            self.listTypePublisher.value = .multiple
        case 2:
            self.listTypePublisher.value = .system
        default:
            ()
        }

        self.tableView.reloadData()
        self.tableView.layoutIfNeeded()
        self.tableView.setContentOffset(.zero, animated: true)
    }

    @objc func didTapSystemBetTypeSelector() {
        self.showingSystemBetOptionsSelector = true
    }
    
    @objc func didTapAmountBaseView() {
        self.secondaryAmountTextfield.becomeFirstResponder()
    }

    @IBAction private func didTapSystemBetTypeSelectButton() {
        self.showingSystemBetOptionsSelector = false
        self.requestSystemBetInfo()
    }

    func requestSystemBetsTypes() {

        self.systemBetTypeLabel.text = ""

        self.systemBetTypeLoadingView.startAnimating()

        let tickets = self.systemBettingTicketDataSource.bettingTickets
        let ticketSelections = tickets
            .map({ EveryMatrix.BetslipTicketSelection(id: $0.id, currentOdd: $0.value) })

        let route = TSRouter.getSystemBetTypes(tickets: ticketSelections)

        Env.everyMatrixClient.manager.getModel(router: route, decodingType: SystemBetResponse.self)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] _ in
                self?.systemBetTypeLoadingView.stopAnimating()
            }, receiveValue: { [weak self] systemBetResponse in
                self?.systemBetOptions = systemBetResponse.systemBets
                self?.systemBetTypePickerView.reloadAllComponents()
                self?.selectedSystemBet = self?.systemBetOptions.first
                self?.requestSystemBetInfo()
            })
            .store(in: &cancellables)
    }

    func requestSystemBetInfo() {

        guard
            // self.realBetValue != 0, NOTA: Tive de desactivar esta opção para conseguir ter o maxAmount da system bet e colocar 1 por default na chamada, como se faz na multipla
            let selectedSystemBet = self.selectedSystemBet
        else {
            return
        }
        
        self.systemOddsValueLabel.text = "-.--€"
        self.systemWinningsValueLabel.text = "-.--€"
        
        self.secondarySystemOddsValueLabel.text = "-.--€"
        self.secondarySystemWinningsValueLabel.text = "-.--€"

        Env.betslipManager
            .requestSystemBetslipSelectionState(systemBetType: selectedSystemBet)
            .receive(on: DispatchQueue.main)
            .sink { _ in

            } receiveValue: { [weak self] betDetails in
               
                self?.configureWithSystemBetInfo(systemBetInfo: betDetails)
            }
            .store(in: &cancellables)

    }

    func configureWithSystemBetInfo(systemBetInfo: BetslipSelectionState) {

        guard let selectedSystemBetWinnings = systemBetInfo.winnings else {
            return
        }

        if let totalBetAmountNetto = selectedSystemBetWinnings.totalBetAmountNetto, totalBetAmountNetto != 0 {
            
            self.systemOddsValueLabel.text = CurrencyFormater.defaultFormat.string(from: NSNumber(value: totalBetAmountNetto)) ?? "-.--€"
            self.secondarySystemOddsValueLabel.text = CurrencyFormater.defaultFormat.string(from: NSNumber(value: totalBetAmountNetto)) ?? "-.--€"
        }
    
        else {
            self.systemOddsValueLabel.text = "-.--€"
            self.secondarySystemOddsValueLabel.text = "-.--€"
        }

        if let maxWinningNetto = selectedSystemBetWinnings.maxWinningNetto, maxWinningNetto != 0 {
            self.systemWinningsValueLabel.text = CurrencyFormater.defaultFormat.string(from: NSNumber(value: maxWinningNetto)) ?? "-.--€"
            self.secondarySystemWinningsValueLabel.text = CurrencyFormater.defaultFormat.string(from: NSNumber(value: maxWinningNetto)) ?? "-.--€"
        }
        else {
            self.systemWinningsValueLabel.text = "-.--€"
            self.secondarySystemWinningsValueLabel.text = "-.--€"
        }

        self.maxStakeSystem = systemBetInfo.maxStake

    }

    func checkMaxAmountTransition() {
        if let maxStakeMultiple = self.maxStakeMultiple, let maxStakeSystem = self.maxStakeSystem {
            if self.listTypePublisher.value == .multiple {
                if realBetValue > maxStakeMultiple {
                    self.addAmountValue(maxStakeMultiple)
                }
            }
            else if self.listTypePublisher.value == .system {
                if realBetValue > maxStakeSystem {
                    self.addAmountValue(maxStakeSystem)
                }
            }

        }

    }

    @IBAction private func didTapDoneButton() {
        self.dismissKeyboard()
    }

    @IBAction private func didTapPlaceBetButton() {

        self.isLoading = true

        if self.listTypePublisher.value == .simple {

            Env.betslipManager.placeAllSingleBets(withSkateAmount: self.simpleBetsBettingValues.value)
                .receive(on: DispatchQueue.main)
                .sink { completion in
                    switch completion {
                    case .failure(let error):
                        Logger.log("Place AllSingleBets error \(error)")
                    default: ()
                    }
                    self.isLoading = false
                } receiveValue: { [weak self] betPlacedDetailsArray in
                    
                    self?.betPlacedAction?(betPlacedDetailsArray)

                }
                .store(in: &cancellables)

        }
        else if self.listTypePublisher.value == .multiple {
            Env.betslipManager.placeMultipleBet(withSkateAmount: self.realBetValue)
                .receive(on: DispatchQueue.main)
                .sink { [weak self] _ in
                    self?.isLoading = false
                } receiveValue: { [weak self] betPlacedDetails in
                    self?.isLoading = false
                    self?.betPlacedAction?([betPlacedDetails])
                }
                .store(in: &cancellables)
        }

        else if self.listTypePublisher.value == .system, let selectedSystemBet = self.selectedSystemBet {
            Env.betslipManager.placeSystemBet(withSkateAmount: self.realBetValue, systemBetType: selectedSystemBet)
                .receive(on: DispatchQueue.main)
                .sink { [weak self] _ in
                    self?.isLoading = false
                } receiveValue: { [weak self] betPlacedDetails in
                    self?.isLoading = false
                    self?.betPlacedAction?([betPlacedDetails])
                }
                .store(in: &cancellables)
        }

    }

    func currentDataSource() -> UITableViewDelegateDataSource {
        switch self.listTypePublisher.value {
        case .simple:
            return self.singleBettingTicketDataSource
        case .multiple:
            return self.multipleBettingTicketDataSource
        case .system:
            return self.systemBettingTicketDataSource
        }
    }

    @objc func keyboardWillShow(notification: NSNotification) {
    
        self.isKeyboardShowingPublisher.send(true)
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            self.tableView.contentInset.bottom = (keyboardSize.height - placeBetBaseView.frame.size.height)

            if
                let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double,
                let curve = notification.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt {

                UIView.animate(withDuration: duration, delay: 0.0, options: UIView.AnimationOptions(rawValue: curve)) { [weak self] in
                    self?.secondPlaceBetBaseViewConstraint.constant = keyboardSize.height
                    self?.view.layoutIfNeeded()
                }
            }
            else {
                self.secondPlaceBetBaseViewConstraint.constant = keyboardSize.height
            }

        }
        
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        
        self.isKeyboardShowingPublisher.send(false)
        self.tableView.contentInset.bottom = 12

        if
            let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double,
            let curve = notification.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt {

            UIView.animate(withDuration: duration, delay: 0.0, options: UIView.AnimationOptions(rawValue: curve)) { [weak self] in
                self?.secondPlaceBetBaseViewConstraint.constant = 0
                self?.view.layoutIfNeeded()
            }
        }
        else {
            self.secondPlaceBetBaseViewConstraint.constant = 0
        }
    }

    @IBAction private func didTapPlusOneButton() {
        self.addAmountValue(1)
    }

    @IBAction private func didTapPlusFiveButton() {
        self.addAmountValue(5)
    }

    @IBAction private func didTapPlusMaxButton() {
        var maxAmountPossible = 0.0

        if self.listTypePublisher.value == .multiple {
            if let userBalance = self.userBalance,
               let maxStake = self.maxStakeMultiple {
                if userBalance < maxStake {
                    maxAmountPossible = userBalance
                }
                else {
                    maxAmountPossible = maxStake
                }
            }
        }
        else if self.listTypePublisher.value == .system {
            if let userBalance = self.userBalance,
               let maxStake = self.maxStakeSystem {
                if userBalance < maxStake {
                    maxAmountPossible = userBalance
                }
                else {
                    maxAmountPossible = maxStake
                }
            }

        }

        self.addAmountValue(maxAmountPossible, isMax: true)
    }

}

extension PreSubmissionBetslipViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        self.updateAmountValue(string)
      
        return false
    }

    func addAmountValue(_ value: Double, isMax: Bool = false) {
        if !isMax {
            displayBetValue += Int(value * 100.0)
        }
        else {
            displayBetValue = Int(value * 100.0)
        }

        if listTypePublisher.value == .multiple {
            if let maxStake = self.maxStakeMultiple {
                let maxStakeInt = Int(maxStake * 100.0)
                if displayBetValue > maxStakeInt {
                    displayBetValue = maxStakeInt
                }
            }
        }
        else if listTypePublisher.value == .system {
            if let maxStake = self.maxStakeSystem {
                let maxStakeInt = Int(maxStake * 100.0)
                if displayBetValue > maxStakeInt {
                    displayBetValue = maxStakeInt
                }
            }
        }

        if let maxUserBalance = self.userBalance {
            let maxUserBalanceInt = Int(maxUserBalance * 100.0)
            if displayBetValue > maxUserBalanceInt {
                displayBetValue = maxUserBalanceInt
            }
        }

        let calculatedAmount = Double(displayBetValue/100) + Double(displayBetValue%100)/100
        amountTextfield.text = CurrencyFormater.defaultFormat.string(from: NSNumber(value: calculatedAmount))
        secondaryAmountTextfield.text = CurrencyFormater.defaultFormat.string(from: NSNumber(value: calculatedAmount))
    }

    func updateAmountValue(_ newValue: String) {
        if let insertedDigit = Int(newValue) {
            displayBetValue = displayBetValue * 10 + insertedDigit
        }
        if newValue == "" {
            displayBetValue /= 10
        }
        let calculatedAmount = Double(displayBetValue/100) + Double(displayBetValue%100)/100
        amountTextfield.text = CurrencyFormater.defaultFormat.string(from: NSNumber(value: calculatedAmount))
        
        secondaryAmountTextfield.text = CurrencyFormater.defaultFormat.string(from: NSNumber(value: calculatedAmount))

    }

}

extension PreSubmissionBetslipViewController: UIPickerViewDelegate, UIPickerViewDataSource {

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.systemBetOptions.count
    }

    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        return NSAttributedString(string: self.systemBetOptions[row].name ?? "--",
                                  attributes: [NSAttributedString.Key.foregroundColor: UIColor.App.textPrimary])
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.selectedSystemBet = self.systemBetOptions[safe: row]
    }

}

typealias UITableViewDelegateDataSource = UITableViewDelegate & UITableViewDataSource

extension PreSubmissionBetslipViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.currentDataSource().tableView(tableView, numberOfRowsInSection: section)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return self.currentDataSource().tableView(tableView, cellForRowAt: indexPath)
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        self.currentDataSource().tableView?(tableView, willDisplay: cell, forRowAt: indexPath)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.currentDataSource().tableView?(tableView, heightForRowAt: indexPath) ?? 0.0
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.currentDataSource().tableView?(tableView, heightForRowAt: indexPath) ?? 0.0
    }
}

extension PreSubmissionBetslipViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.gomaSuggestedBetsResponse.count
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 16
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 16
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard
            let cell = collectionView.dequeueCellType(BetSuggestedCollectionViewCell.self, indexPath: indexPath)
                
        else {
            fatalError()
        }

        if let cachedViewModel = self.cachedBetSuggestedCollectionViewCellViewModels[indexPath.row].value {

            cell.setupWithViewModel(viewModel: cachedViewModel)

        }
        else {
            let viewModel = BetSuggestedCollectionViewCellViewModel(gomaArray: gomaSuggestedBetsResponse[indexPath.row])

            self.cachedBetSuggestedCollectionViewCellViewModels[indexPath.row] = viewModel

            cell.setupWithViewModel(viewModel: viewModel)

        }

        cell.betNowCallbackAction = { [weak self] in
            self?.isSuggestedMultiple = true
        }

        cell.needsReload
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] _ in
                print("NEED RELOAD")
                self?.isSuggestedBetsLoading = false
                cell.setReloadedState(reloaded: true)
                collectionView.reloadData()
            })
            .store(in: &cancellables)

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        let bottomBarHeigth = 60.0
        var size = CGSize(width: Double(collectionView.frame.size.width)*0.85, height: bottomBarHeigth + 1 * 40)
        if !self.gomaSuggestedBetsResponse[indexPath.row].isEmpty {
//            if arrayValues.count == 3 {
//                size = CGSize(width: Double(collectionView.frame.size.width)*0.85, height: bottomBarHeigth + 3 * 60)
//            }else{
            size = CGSize(width: Double(collectionView.frame.size.width)*0.85, height: bottomBarHeigth + 4 * 60)
           // }
        }
        return size
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.betSuggestedCollectionView.reloadData()
        self.betSuggestedCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
    }

}

class SingleBettingTicketDataSource: NSObject, UITableViewDelegate, UITableViewDataSource {

    var bettingTickets: [BettingTicket] = []

    var didUpdateBettingValueAction: ((String, Double) -> Void)?
    var bettingValueForId: ((String) -> (Double?))?

    init(bettingTickets: [BettingTicket]) {
        self.bettingTickets = bettingTickets
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return bettingTickets.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard
            let cell = tableView.dequeueCellType(SingleBettingTicketTableViewCell.self),
            let bettingTicket = self.bettingTickets[safe: indexPath.row]
        else {
            fatalError()
        }

        let storedValue = self.bettingValueForId?(bettingTicket.id)

        if !Env.betslipManager.betslipPlaceBetResponseErrorsPublisher.value.isEmpty {

            let bettingTicketErrors = Env.betslipManager.betslipPlaceBetResponseErrorsPublisher.value
            var hasFoundCorrespondingId = false
            var errorMessage = localized("error")

            for bettingError in bettingTicketErrors {
                if let bettingSelections = bettingError.selections {
                    for selection in bettingSelections {
                        if selection.id == bettingTicket.bettingId {
                            hasFoundCorrespondingId = true
                            errorMessage = bettingError.errorMessage ?? localized("error")
                        }
                    }
                }
            }

            if hasFoundCorrespondingId {
                cell.configureWithBettingTicket(bettingTicket, previousBettingAmount: storedValue, errorBetting: errorMessage)
            }
            else {
                cell.configureWithBettingTicket(bettingTicket, previousBettingAmount: storedValue)
            }
        }
        else {
            cell.configureWithBettingTicket(bettingTicket, previousBettingAmount: storedValue)
        }

        cell.didUpdateBettingValueAction = self.didUpdateBettingValueAction
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 160
    }
}

class MultipleBettingTicketDataSource: NSObject, UITableViewDelegate, UITableViewDataSource {

    var bettingTickets: [BettingTicket] = []

    init(bettingTickets: [BettingTicket]) {
        self.bettingTickets = bettingTickets
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return bettingTickets.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard
            let cell = tableView.dequeueCellType(MultipleBettingTicketTableViewCell.self),
            let bettingTicket = self.bettingTickets[safe: indexPath.row]
        else {
            fatalError()
        }
        if !Env.betslipManager.betslipPlaceBetResponseErrorsPublisher.value.isEmpty {
            let bettingTicketErrors = Env.betslipManager.betslipPlaceBetResponseErrorsPublisher.value
            var hasFoundCorrespondingId = false
            var errorMessage = ""
            for bettingError in bettingTicketErrors {
                if let bettingErrorCode = bettingError.errorCode {
                    // Error code with corresponding id
                    if bettingErrorCode == "107" {
                        if let bettingErrorMessage = bettingError.errorMessage {
                            if bettingErrorMessage.contains(bettingTicket.bettingId) {
                                hasFoundCorrespondingId = true
                                errorMessage = bettingError.errorMessage ?? localized("error")
                                break
                            }

                        }
                    }
                    else {
                        if let bettingSelections = bettingError.selections {
                            for selection in bettingSelections {

                                if selection.id == bettingTicket.bettingId {
                                    hasFoundCorrespondingId = true
                                    errorMessage = bettingError.errorMessage ?? localized("error")
                                    break
                                }

                            }
                        }
                    }
                }
            }

            if hasFoundCorrespondingId {
                cell.configureWithBettingTicket(bettingTicket, errorBetting: errorMessage)
            }
            else {
                cell.configureWithBettingTicket(bettingTicket)
            }

        }
        else {
            cell.configureWithBettingTicket(bettingTicket)
        }

        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 99
    }
}

class SystemBettingTicketDataSource: NSObject, UITableViewDelegate, UITableViewDataSource {

    var bettingTickets: [BettingTicket] = []

    init(bettingTickets: [BettingTicket]) {
        self.bettingTickets = bettingTickets
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return bettingTickets.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard
            let cell = tableView.dequeueCellType(MultipleBettingTicketTableViewCell.self),
            let bettingTicket = self.bettingTickets[safe: indexPath.row]
        else {
            fatalError()
        }
        cell.configureWithBettingTicket(bettingTicket)
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 99
    }
    
}

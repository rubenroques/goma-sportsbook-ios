//
//  PreSubmissionBetslipViewController.swift
//  Sportsbook
//
//  Created by Ruben Roques on 03/11/2021.
//

import UIKit
import Combine

class PreSubmissionBetslipViewController: UIViewController {
  

    @IBOutlet private weak var topSafeArea: UIView!
    @IBOutlet private weak var bottomSafeArea: UIView!

    @IBOutlet private weak var betTypeSegmentControlBaseView: UIView!
    @IBOutlet private weak var betTypeSegmentControl: UISegmentedControl!

    @IBOutlet private weak var clearBaseView: UIView!
    @IBOutlet private weak var clearButton: UIButton!

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
    @IBOutlet private weak var emptyBetsBaseView: UIView!

    @IBOutlet private weak var loadingBaseView: UIView!
    @IBOutlet private weak var loadingView: UIActivityIndicatorView!

    @IBOutlet weak var betSuggestedCollectionView: UICollectionView!
    @IBOutlet var suggestedBetsActivityIndicator: UIActivityIndicatorView!
    
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
    var betInfo: [[String]] = [["teste 1", "teste 2", "teste 3"], ["a", "b", "c"], ["1", "2", "3"]]


    private var listTypePublisher: CurrentValueSubject<BetslipType, Never> = .init(.simple)

    // System Bets vars
    var selectedSystemBet: SystemBetType? = nil {
        didSet {
            if let systemBetType = self.selectedSystemBet {
                self.systemBetTypeLabel.text = systemBetType.name ?? "System bet"
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
    var numberOfBets: Int = 1
    var totalPossibleEarnings : Double = 0.0
    var totalBetOdds : Double = 0.0
    
 
    // Simple Bets values
    private var simpleBetsBettingValues: CurrentValueSubject<[String: Double], Never> = .init([:])
    private var simpleBetPlacedDetails: [String: LoadableContent<BetPlacedDetails>] = [:]

    private var maxBetValue: Double = Double.greatestFiniteMagnitude

    private var realBetValuePublisher: CurrentValueSubject<Double, Never> = .init(0.0)
    private var multiplierPublisher: CurrentValueSubject<Double, Never> = .init(0.0)

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

    private var suggestedBetsRegister: EndpointPublisherIdentifiable?
    private var suggestedBetsPublisher: AnyCancellable?

    var gomaSuggestedBetsResponse: [[GomaSuggestedBets]] = []
    var suggestedBetsArray: [Int: [Match]] = [:]

    init() {
        super.init(nibName: "PreSubmissionBetslipViewController", bundle: nil)

        self.title = "Betslip"
    }

    @available(iOS, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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

        self.systemBetTypePickerView.delegate = self
        self.systemBetTypePickerView.dataSource = self

        self.placeBetButtonsBaseView.isHidden = true
        self.placeBetButtonsSeparatorView.alpha = 0.5

        self.simpleWinningsValueLabel.text = "-.--€"
        self.simpleOddsValueLabel.isHidden = true
        self.simpleOddsTitleLabel.isHidden = true

        self.multipleWinningsValueLabel.text = "-.--€"
        self.multipleOddsValueLabel.text = "-.--"

        self.systemWinningsValueLabel.text = "-.--€"
        self.systemOddsTitleLabel.text = "Total bet amount"
        self.systemOddsValueLabel.text = "-.--€"

        self.tableView.separatorStyle = .none
        self.tableView.allowsSelection = false

        self.tableView.register(SingleBettingTicketTableViewCell.nib, forCellReuseIdentifier: SingleBettingTicketTableViewCell.identifier)
        self.tableView.register(MultipleBettingTicketTableViewCell.nib, forCellReuseIdentifier: MultipleBettingTicketTableViewCell.identifier)

        self.tableView.dataSource = self
        self.tableView.delegate = self

        self.amountTextfield.delegate = self

        self.systemBetInteriorView.layer.cornerRadius = 8
        self.systemBetInteriorView.layer.borderWidth = 2
        self.systemBetInteriorView.layer.borderColor = UIColor.App.tertiaryBackground.cgColor

        self.systemBetTypeLoadingView.hidesWhenStopped = true
        self.systemBetTypeLoadingView.stopAnimating()

        self.systemBetTypeLabel.text = ""

        let tapSystemBetTypeSelector = UITapGestureRecognizer(target: self, action: #selector(didTapSystemBetTypeSelector))
        self.systemBetInteriorView.addGestureRecognizer(tapSystemBetTypeSelector)

        if Env.betslipManager.bettingTicketsPublisher.value.count > 1 {
            self.betTypeSegmentControl.selectedSegmentIndex = 1
            self.didChangeSegmentValue(self.betTypeSegmentControl)
        }

        singleBettingTicketDataSource.didUpdateBettingValueAction = { id, value in
            if value == 0 {
                self.simpleBetsBettingValues.value[id] = nil
            }
            else {
                self.simpleBetsBettingValues.value[id] = value
            }
        }
        singleBettingTicketDataSource.bettingValueForId = { id in
            self.simpleBetsBettingValues.value[id]
        }

        Env.betslipManager.bettingTicketsPublisher
            .receive(on: DispatchQueue.main)
            .map(Array.init)
            .sink { [weak self] tickets in
                self?.singleBettingTicketDataSource.bettingTickets = tickets
                self?.multipleBettingTicketDataSource.bettingTickets = tickets
                self?.systemBettingTicketDataSource.bettingTickets = tickets

                self?.simpleBetPlacedDetails = [:]

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

                if tickets.count > 1 && self?.isSuggestedMultiple == true{
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
            .sink(receiveValue: { multiplier in
                self.multiplierPublisher.send(multiplier)
            })
            .store(in: &cancellables)

        self.multiplierPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] multiplier in
                self?.multipleOddsValueLabel.text = OddFormatter.formatOdd(withValue: multiplier)
            })
            .store(in: &cancellables)

        Env.betslipManager.bettingTicketsPublisher
            .receive(on: DispatchQueue.main)
            .map(\.isEmpty)
            .sink(receiveValue: { isEmpty in
                self.emptyBetsBaseView.isHidden = !isEmpty

                if isEmpty {
                    self.isSuggestedBetsLoading(true)
                    self.getSuggestedBets()
                }
            })
            .store(in: &cancellables)

        self.listTypePublisher
            .receive(on: DispatchQueue.main)
            .map({ $0 == .simple })
            .sink(receiveValue: { [weak self] isSimpleBet in
                self?.placeBetButtonsBaseView.isHidden = isSimpleBet
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
                case .system:
                    self?.simpleWinningsBaseView.isHidden = true
                    self?.multipleWinningsBaseView.isHidden = true
                    self?.systemWinningsBaseView.isHidden = false
                }
            })
            .store(in: &cancellables)

        Publishers.CombineLatest(self.listTypePublisher, self.realBetValuePublisher)
            .receive(on: DispatchQueue.main)
            .filter { [weak self] (betslipType, _) in
                betslipType == .system && self?.selectedSystemBet != nil
            }
            .map({ [weak self] (_, bettingValue) in
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
                    let totalValue = multiplier * betValue
                    self.totalBetOdds = betValue
                    self.totalPossibleEarnings =  totalValue
                    return CurrencyFormater.defaultFormat.string(from: NSNumber(value: totalValue)) ?? "-.--€"
                }
                else {
                    return "-.--€"
                }
            })
            .sink(receiveValue: { [weak self] possibleEarnings in
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
                    
                    self.totalPossibleEarnings = expectedReturn
                    return CurrencyFormater.defaultFormat.string(from: NSNumber(value: expectedReturn)) ?? "-.--€"
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
                
                for ticket in tickets {
                    if simpleBetsBettingValues[ticket.id] == nil {
                        hasValidAmounts = false
                        break
                    }
                }
                return hasValidAmounts
            })
            .sink(receiveValue: { [weak self] hasValidBettingValue in
                self?.placeBetButton.isEnabled = hasValidBettingValue
            })
            .store(in: &cancellables)

        Env.betslipManager.removeAllPlacedDetailsError()
        Env.betslipManager.removeAllBetslipPlacedBetErrorResponse()

        Env.betslipManager.betPlacedDetailsErrorsPublisher
            .receive(on: DispatchQueue.main)
            .sink { completion in
                print(completion)
                //self.isLoading = false
            } receiveValue: { betPlacedDetails in
                //self.isLoading = false
                //print("BET PLACED DETAILS: \(betPlacedDetails)")
                if !betPlacedDetails.isEmpty {
                    let errorMessage = betPlacedDetails[0].response.errorMessage
                    let response = betPlacedDetails[0].response
                    self.showErrorView(errorMessage: errorMessage)

                    Env.betslipManager.addBetslipPlacedBetErrorResponse(betPlacedError: [response])

                }

            }
            .store(in: &cancellables)

        Env.betslipManager.betslipPlaceBetResponseErrorsPublisher
            .receive(on: DispatchQueue.main)
            .sink { completion in
                print(completion)
                //self.isLoading = false
            } receiveValue: { betslipPlaceBetResponse in
                self.tableView.reloadData()
            }
            .store(in: &cancellables)

        self.addDoneAccessoryView()
        self.setupWithTheme()

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)

        self.placeBetButton.isEnabled = false
    }

    func isSuggestedBetsLoading(_ loading: Bool) {
        if loading {
            self.suggestedBetsActivityIndicator.isHidden = false
        }
        else {
            self.suggestedBetsActivityIndicator.isHidden = true
        }
    }

    func getSuggestedBets() {
        Env.gomaNetworkClient.requestSuggestedBets(deviceId: Env.deviceId)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure:
                    print("Error retrieving suggested bets!")

                case .finished:
                    print("Suggested bets retrieved!")
                }

                print("Received suggested bets completion: \(completion).")

            },
            receiveValue: { gomaBetsArray in

                guard let betsArray = gomaBetsArray else {return}
                print("GOMA SUGGESTED BETS: \(betsArray)")
                self.gomaSuggestedBetsResponse = betsArray

                for (index, betArray) in betsArray.enumerated() {
                    self.subscribeSuggestedBet(betArray: betArray, index: index)
                }

            })
            .store(in: &cancellables)

        // Needs to be changed
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.betSuggestedCollectionView.reloadData()
            self.isSuggestedBetsLoading(false)
        }
    }

    func subscribeSuggestedBet(betArray: [GomaSuggestedBets], index: Int) {

        for bet in betArray {

            if let suggestedBetsRegister = suggestedBetsRegister {
                TSManager.shared.unregisterFromEndpoint(endpointPublisherIdentifiable: suggestedBetsRegister)
            }

            let endpoint = TSRouter.matchMarketOdds(operatorId: Env.appSession.operatorId, language: "en", matchId: "\(bet.matchId)", bettingType: "\(bet.bettingType)", eventPartId: "\(bet.eventPartId)")

            TSManager.shared
                .registerOnEndpoint(endpoint, decodingType: EveryMatrix.Aggregator.self)
                .sink(receiveCompletion: { [weak self] completion in
                    switch completion {
                    case .failure:
                        print("Error retrieving data!")
                    case .finished:
                        print("Data retrieved!")
                    }
                }, receiveValue: { [weak self] state in
                    switch state {
                    case .connect(let publisherIdentifiable):
                        print("MyBets suggestedBets connect")
                        self?.suggestedBetsRegister = publisherIdentifiable
                    case .initialContent(let aggregator):
                        print("MyBets suggestedBets initialContent")
                        self?.setupSuggestedMatchesAggregatorProcessor(aggregator: aggregator, index: index)
                    case .updatedContent(let aggregatorUpdates):
                        print("MyBets suggestedBets updatedContent")
                    case .disconnect:
                        print("MyBets suggestedBets disconnect")
                    }
                })
                .store(in: &cancellables)
        }

    }

    private func setupSuggestedMatchesAggregatorProcessor(aggregator: EveryMatrix.Aggregator, index: Int) {
        Env.everyMatrixStorage.processAggregator(aggregator, withListType: .suggestedMatches,
                                                 shouldClear: true)
        let suggestedMatchArray = Env.everyMatrixStorage.matchesForListType(.suggestedMatches)

        if let suggestedMatch = suggestedMatchArray[safe: 0] {

            if self.suggestedBetsArray[index] != nil {
                self.suggestedBetsArray[index]?.append(suggestedMatch)
            }
            else {
                self.suggestedBetsArray[index] = [suggestedMatch]
            }
        }

    }

    func showErrorView(errorMessage: String?) {
        let errorView = BetslipErrorView()
        errorView.setDescription(description: errorMessage ?? "Error")
        errorView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(errorView)

        NSLayoutConstraint.activate([
            errorView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
            errorView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor),
            errorView.bottomAnchor.constraint(equalTo: self.placeBetBaseView.safeAreaLayoutGuide.topAnchor, constant: -10)
        ])

        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            errorView.removeFromSuperview()
        }
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
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        self.setupWithTheme()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    private func commonInit(){
        //let flowLayout = UICollectionViewFlowLayout()
        //flowLayout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        //flowLayout.scrollDirection = .horizontal
       // betSuggestedCollectionView.collectionViewLayout = flowLayout
        //betSuggestedCollectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        betSuggestedCollectionView.showsVerticalScrollIndicator = false
        betSuggestedCollectionView.showsHorizontalScrollIndicator = true
        betSuggestedCollectionView.register(BetSuggestedCollectionViewCell.nib,
                                       forCellWithReuseIdentifier: BetSuggestedCollectionViewCell.identifier)
        betSuggestedCollectionView.delegate = self
        betSuggestedCollectionView.dataSource = self

    }

    func setupWithTheme() {

        self.betTypeSegmentControl.setTitleTextAttributes([
            NSAttributedString.Key.font: AppFont.with(type: .bold, size: 13),
            NSAttributedString.Key.foregroundColor: UIColor.App.headingMain
        ], for: .selected)
        self.betTypeSegmentControl.setTitleTextAttributes([
            NSAttributedString.Key.font: AppFont.with(type: .bold, size: 13),
            NSAttributedString.Key.foregroundColor: UIColor.App.headingMain
        ], for: .normal)
        self.betTypeSegmentControl.setTitleTextAttributes([
            NSAttributedString.Key.font: AppFont.with(type: .bold, size: 13),
            NSAttributedString.Key.foregroundColor: UIColor.App.headingMain.withAlphaComponent(0.5)
        ], for: .disabled)

        self.topSafeArea.backgroundColor = UIColor.App.mainBackground
        self.bottomSafeArea.backgroundColor = UIColor.App.mainBackground
        self.betTypeSegmentControlBaseView.backgroundColor = UIColor.App.mainBackground

        self.amountTextfield.font = AppFont.with(type: .semibold, size: 14)
        self.amountTextfield.textColor = UIColor.App.headingMain
        self.amountTextfield.attributedPlaceholder = NSAttributedString(string: "Amount", attributes: [
            NSAttributedString.Key.font: AppFont.with(type: .semibold, size: 14),
            NSAttributedString.Key.foregroundColor: UIColor.App.headingDisabled
        ])
        self.amountBaseView.backgroundColor = UIColor.App.tertiaryBackground

        self.tableView.backgroundView?.backgroundColor = UIColor.App.mainBackground
        self.tableView.backgroundColor = UIColor.App.mainBackground
        self.tableView.contentInset.bottom = 12

        self.systemBetSeparatorView.backgroundColor = UIColor.App.separatorLine
        self.systemBetBaseView.backgroundColor = UIColor.App.mainBackground
        self.systemBetInteriorView.layer.borderColor = UIColor.App.tertiaryBackground.cgColor

        self.placeBetBaseView.backgroundColor = UIColor.App.mainBackground
        self.placeBetButtonsBaseView.backgroundColor = UIColor.App.mainBackground
        self.placeBetButtonsSeparatorView.backgroundColor = UIColor.App.separatorLine
        self.placeBetSendButtonBaseView.backgroundColor = UIColor.App.mainBackground

        self.amountBaseView.backgroundColor = UIColor.App.tertiaryBackground

        self.plusOneButtonView.setBackgroundColor(UIColor.App.tertiaryBackground, for: .normal)
        self.plusOneButtonView.setTitleColor(UIColor.App.headingMain, for: .normal)
        self.plusOneButtonView.setTitleColor(UIColor.App.headingMain.withAlphaComponent(0.7), for: .highlighted)

        self.plusFiveButtonView.setBackgroundColor(UIColor.App.tertiaryBackground, for: .normal)
        self.plusFiveButtonView.setTitleColor(UIColor.App.headingMain, for: .normal)
        self.plusFiveButtonView.setTitleColor(UIColor.App.headingMain.withAlphaComponent(0.7), for: .highlighted)

        self.maxValueButtonView.setBackgroundColor(UIColor.App.tertiaryBackground, for: .normal)
        self.maxValueButtonView.setTitleColor(UIColor.App.headingMain, for: .normal)
        self.maxValueButtonView.setTitleColor(UIColor.App.headingMain.withAlphaComponent(0.7), for: .highlighted)

        self.emptyBetsBaseView.backgroundColor = UIColor.App.mainBackground


        self.simpleWinningsSeparatorView.backgroundColor = UIColor.App.separatorLine
        self.multipleWinningsSeparatorView.backgroundColor = UIColor.App.separatorLine
        self.systemWinningsSeparatorView.backgroundColor = UIColor.App.separatorLine

        self.simpleWinningsBaseView.backgroundColor = UIColor.App.mainBackground
        self.simpleWinningsTitleLabel.textColor = UIColor.App.headingDisabled
        self.simpleWinningsValueLabel.textColor = UIColor.App.headingMain
        self.simpleOddsTitleLabel.textColor = UIColor.App.headingDisabled
        self.simpleOddsValueLabel.textColor = UIColor.App.headingMain

        self.multipleWinningsBaseView.backgroundColor = UIColor.App.mainBackground
        self.multipleWinningsTitleLabel.textColor = UIColor.App.headingDisabled
        self.multipleWinningsValueLabel.textColor = UIColor.App.headingMain
        self.multipleOddsTitleLabel.textColor = UIColor.App.headingDisabled
        self.multipleOddsValueLabel.textColor = UIColor.App.headingMain

        self.systemWinningsBaseView.backgroundColor = UIColor.App.mainBackground
        self.systemWinningsTitleLabel.textColor = UIColor.App.headingDisabled
        self.systemWinningsValueLabel.textColor = UIColor.App.headingMain
        self.systemOddsTitleLabel.textColor = UIColor.App.headingDisabled
        self.systemOddsValueLabel.textColor = UIColor.App.headingMain

        StyleHelper.styleButton(button: self.selectSystemBetTypeButton)
        StyleHelper.styleButton(button: self.placeBetButton)
    }

    func addDoneAccessoryView() {
        let keyboardToolbar = UIToolbar()
        keyboardToolbar.sizeToFit()
        let flexBarButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneBarButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissKeyboard))
        keyboardToolbar.items = [flexBarButton, doneBarButton]
        self.amountTextfield.inputAccessoryView = keyboardToolbar
    }

    @objc func dismissKeyboard() {
        self.view.endEditing(true)
    }

    @IBAction private func didTapClearButton() {
        Env.betslipManager.clearAllBettingTickets()
        self.gomaSuggestedBetsResponse = []
        self.suggestedBetsArray = [:]
        self.betSuggestedCollectionView.reloadData()
    }

    @IBAction private func didChangeSegmentValue(_ segmentControl: UISegmentedControl) {

        switch segmentControl.selectedSegmentIndex {
        case 0:
            self.listTypePublisher.value = .simple
 
        case 1:
            self.listTypePublisher.value = .multiple
            self.numberOfBets = 1
        case 2:
            self.listTypePublisher.value = .system
            self.numberOfBets = 1
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

    @IBAction func didTapSystemBetTypeSelectButton() {
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

        TSManager.shared.getModel(router: route, decodingType: SystemBetResponse.self)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                self.systemBetTypeLoadingView.stopAnimating()
            }, receiveValue: { systemBetResponse in
                self.systemBetOptions = systemBetResponse.systemBets
                self.systemBetTypePickerView.reloadAllComponents()
                self.selectedSystemBet = self.systemBetOptions.first
                self.requestSystemBetInfo()
            })
            .store(in: &cancellables)
    }

    func requestSystemBetInfo() {

        guard
            self.realBetValue != 0,
            let selectedSystemBet = self.selectedSystemBet
        else {
            return
        }

        self.systemOddsValueLabel.text = "-.--€"
        self.systemWinningsValueLabel.text = "-.--€"

        Env.betslipManager
            .requestSystemBetslipSelectionState(withSkateAmount: self.realBetValue, systemBetType: selectedSystemBet)
            .receive(on: DispatchQueue.main)
            .sink { completion in
                print(completion)
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
        }
        else {
            self.systemOddsValueLabel.text = "-.--€"
        }

        if let maxWinningNetto = selectedSystemBetWinnings.maxWinningNetto, maxWinningNetto != 0 {
            self.totalPossibleEarnings = maxWinningNetto
            self.systemWinningsValueLabel.text = CurrencyFormater.defaultFormat.string(from: NSNumber(value: maxWinningNetto)) ?? "-.--€"
        }
        else {
            self.systemWinningsValueLabel.text = "-.--€"
        }
    }

    @IBAction private func didTapPlaceBetButton() {

        self.isLoading = true

        if self.listTypePublisher.value == .simple {

            self.numberOfBets = self.simpleBetsBettingValues.value.count
            Env.betslipManager.placeAllSingleBets(withSkateAmount: self.simpleBetsBettingValues.value)
                .receive(on: DispatchQueue.main)
                .sink { completion in
                    switch completion {
                    case .failure(let error):
                        print(error)
                    default: ()
                    }
                    self.isLoading = false
                } receiveValue: { betPlacedDetailsArray in
                    for betPlacedDetails in betPlacedDetailsArray {
                        for bet in betPlacedDetails.tickets {
                            self.totalBetOdds += bet.value
                        }
                    }
                    self.betPlacedAction?(betPlacedDetailsArray)
                }
                .store(in: &cancellables)

        }
        else if self.listTypePublisher.value == .multiple {
            Env.betslipManager.placeMultipleBet(withSkateAmount: self.realBetValue)
                .receive(on: DispatchQueue.main)
                .sink { completion in
                    print(completion)
                    self.isLoading = false
                } receiveValue: { betPlacedDetails in
                    self.isLoading = false
                    self.betPlacedAction?([betPlacedDetails])
                }
                .store(in: &cancellables)
        }

        else if self.listTypePublisher.value == .system, let selectedSystemBet = self.selectedSystemBet {
            Env.betslipManager.placeSystemBet(withSkateAmount: self.realBetValue, systemBetType: selectedSystemBet)
                .receive(on: DispatchQueue.main)
                .sink { completion in
                    print(completion)
                    self.isLoading = false
                } receiveValue: { betPlacedDetails in
                    self.isLoading = false
                    self.betPlacedAction?([betPlacedDetails])
                }
                .store(in: &cancellables)
        }

    }

    func checkSubmitedSingles() {

        var betPlacedDetailsArray: [BetPlacedDetails] = []
        var canProceedToNextScreen = true
        var stillLoading = false

        if self.simpleBetsBettingValues.value.count != self.simpleBetPlacedDetails.values.count {
            // Still loading requests
            return
        }
        for value in self.simpleBetPlacedDetails.values {
            switch value {
            case .loaded(let betPlacedDetails):
                if !(betPlacedDetails.response.betSucceed ?? false) {
                    canProceedToNextScreen = false

                    Env.betslipManager.addBetslipPlacedBetErrorResponse(betPlacedError: [betPlacedDetails.response])

                    break
                }
                else {
                    betPlacedDetailsArray.append(betPlacedDetails)
                }
            case .loading:
                stillLoading = true
                // break
            case .idle:
                stillLoading = true
                // break
            }
        }

        if canProceedToNextScreen && !stillLoading {
            self.isLoading = false
            self.betPlacedAction?(betPlacedDetailsArray)
        }
        else if !canProceedToNextScreen {
            self.isLoading = false
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
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            self.tableView.contentInset.bottom = (keyboardSize.height - placeBetBaseView.frame.size.height)
        }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        self.tableView.contentInset.bottom = 12
    }

    @IBAction private func didTapPlusOneButton() {
        self.addAmountValue(1)
    }

    @IBAction private func didTapPlusFiveButton() {
        self.addAmountValue(5)
    }

    @IBAction private func didTapPlusMaxButton() {
        self.addAmountValue(100)
    }

}

extension PreSubmissionBetslipViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        self.updateAmountValue(string)
        return false
    }

    func addAmountValue(_ value: Int) {
        displayBetValue += (value * 100)

        let calculatedAmount = Double(displayBetValue/100) + Double(displayBetValue%100)/100
        amountTextfield.text = CurrencyFormater.defaultFormat.string(from: NSNumber(value: calculatedAmount))
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
                                  attributes: [NSAttributedString.Key.foregroundColor: UIColor.App.headingMain])
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
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat{
        return 16
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat{
        return 16
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard
            let cell = collectionView.dequeueCellType(BetSuggestedCollectionViewCell.self, indexPath: indexPath)
                
        else {
            fatalError()
        }
       
        if let suggestedBetCard = self.suggestedBetsArray[indexPath.row] {
            cell.setupStackBetView(betValues: suggestedBetCard, gomaValues: self.gomaSuggestedBetsResponse[indexPath.row])
            // cell.setupInfoBetValues(betValues: betInfo)
            cell.betNowCallbackAction = {
                self.isSuggestedMultiple = true
            }

        }

        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        let bottomBarHeigth = 60.0
        var size = CGSize(width: Double(collectionView.frame.size.width)*0.85, height: bottomBarHeigth + 1 * 40)
        if let a = self.suggestedBetsArray[indexPath.row] {

            size = CGSize(width: Double(collectionView.frame.size.width)*0.85, height: bottomBarHeigth + Double(a.count) * 60)
        }
        return size
        
        }
 
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
   
        self.betSuggestedCollectionView.reloadData()
       // self.betSuggestedCollectionView.layoutIfNeeded()
        self.betSuggestedCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        // let rect = self.betSuggestedCollectionView.layoutAttributesForItem(at:IndexPath(row: indexPath.row, section: 0))?.frame
        //    self.betSuggestedCollectionView.scrollRectToVisible(rect!, animated: true)

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
            var errorMessage = "Error"
            for bettingError in bettingTicketErrors {
                if let bettingSelections = bettingError.selections {
                    for selection in bettingSelections {
                        if selection.id == bettingTicket.bettingId {
                            hasFoundCorrespondingId = true
                            errorMessage = bettingError.errorMessage ?? "Error"
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

        } else {
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
                                errorMessage = bettingError.errorMessage ?? "Error"
                                break
                            }

                        }
                    }
                    else {
                        if let bettingSelections = bettingError.selections {
                            for selection in bettingSelections {

                                if selection.id == bettingTicket.bettingId {
                                    hasFoundCorrespondingId = true
                                    errorMessage = bettingError.errorMessage ?? "Error"
                                    break
                                }

                            }
                        }
                    }
                }
            }

            if hasFoundCorrespondingId{
                cell.configureWithBettingTicket(bettingTicket, errorBetting: errorMessage)
            }
            else {
                cell.configureWithBettingTicket(bettingTicket)
            }

        } else {
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

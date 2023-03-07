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
    private var betTypeSegmentControlView: SegmentControlView?

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

    @IBOutlet private weak var settingsPickerBaseView: UIView!
    @IBOutlet private weak var settingsPickerContainerView: UIView!
    @IBOutlet private weak var settingsPickerView: UIPickerView!
    @IBOutlet private weak var settingsPickerButton: UIButton!

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

    @IBOutlet private weak var emptyBetsBaseView: UIView!
    @IBOutlet private weak var emptyBetslipLabel: UILabel!

    @IBOutlet private weak var loadingBaseView: UIView!
    @IBOutlet private weak var loadingView: UIActivityIndicatorView!

    @IBOutlet private weak var secondPlaceBetBaseViewConstraint: NSLayoutConstraint!

    private var suggestedBetsListViewController: SuggestedBetsListViewController?

    private var singleBettingTicketDataSource = SingleBettingTicketDataSource.init(bettingTickets: [])
    private var multipleBettingTicketDataSource = MultipleBettingTicketDataSource.init(bettingTickets: [])
    private var systemBettingTicketDataSource = SystemBettingTicketDataSource(bettingTickets: [])

    private var freeBetSelected: BetslipFreebet?
    private var oddsBoostSelected: BetslipOddsBoost?
    private var selectedSingleFreebet: SingleBetslipFreebet?
    private var selectedSingleOddsBoost: SingleBetslipOddsBoost?

    private var userSelectedSystemBet: Bool = false
    private var isBetBuilderSelection: Bool = false
    
    private var cancellables = Set<AnyCancellable>()

    var viewModel: PreSubmissionBetslipViewModel

    enum BetslipType {
        case simple
        case multiple
        case system
    }

    private var listTypePublisher: CurrentValueSubject<BetslipType, Never> = .init(.simple)

    // System Bets vars
    private var selectedSystemBetType: SystemBetType? {
        didSet {
            if let systemBetType = self.selectedSystemBetType {
                self.systemBetTypeLabel.text = "\(systemBetType.name ?? localized("system_bet")) x\(systemBetType.numberOfBets ?? 0)"
            }
        }
    }

    private var systemBetOptions: [SystemBetType] = [] {
        didSet {
            var containsOldSelection = false
            var componentsIndex = 0
            if let currentSelection = self.selectedSystemBetType {
                for (index, item) in self.systemBetOptions.enumerated() {
                    if currentSelection.id == item.id {
                        containsOldSelection = true
                        componentsIndex = index
                        break
                    }
                }
            }

            if self.selectedSystemBetType == nil || !containsOldSelection {
                self.selectedSystemBetType = self.systemBetOptions.first
            }

            self.systemBetTypePickerView.reloadAllComponents()
            self.systemBetTypePickerView.selectRow(componentsIndex, inComponent: 0, animated: false)
        }
    }

    private var showingSystemBetOptionsSelector: Bool = false {
        didSet {
            if showingSystemBetOptionsSelector {
                self.systemBetTypeSelectorBaseView.alpha = 1.0
            }
            else {
                self.systemBetTypeSelectorBaseView.alpha = 0.0
            }
        }
    }

    private var showingSettingsSelector: Bool = false {
        didSet {
            if showingSettingsSelector {
                self.settingsPickerBaseView.alpha = 1.0
            }
            else {
                self.settingsPickerBaseView.alpha = 0.0
            }
        }
    }

    private var selectedBetslipSetting: String?

    // Multiple Bets values
    private var displayBetValue: Int = 0 {
        didSet {
            self.realBetValuePublisher.send(self.realBetValue)
        }
    }

    private var realBetValue: Double {
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

    var maxStakeMultiple: Double?
    var maxStakeSystem: Double?
    var userBalance: Double?

    // Publishers
    var tableReloadDebouncePublisher: PassthroughSubject<Void, Never> = .init()

    init(viewModel: PreSubmissionBetslipViewModel) {
        self.viewModel = viewModel

        if TargetVariables.hasFeatureEnabled(feature: .suggestedBets) {
            self.suggestedBetsListViewController = SuggestedBetsListViewController(viewModel: SuggestedBetsListViewModel())
        }

        super.init(nibName: "PreSubmissionBetslipViewController", bundle: nil)

        self.title = localized("betslip")
    }

    @available(iOS, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        print("PreSubmissionBetslipViewController deinit")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.systemBetTypeSelectorBaseView.alpha = 0.0
        self.loadingBaseView.alpha = 0.0
        self.settingsPickerBaseView.alpha = 0.0

        self.view.bringSubviewToFront(systemBetTypeSelectorBaseView)
        self.view.bringSubviewToFront(settingsPickerBaseView)
        self.view.bringSubviewToFront(emptyBetsBaseView)
        self.view.bringSubviewToFront(loadingBaseView)

        self.betTypeSegmentControlView = SegmentControlView(options: [localized("single"), localized("multiple"), localized("system")])
        self.betTypeSegmentControlView?.translatesAutoresizingMaskIntoConstraints = false
        self.betTypeSegmentControlView?.didSelectItemAtIndexAction = self.didChangeSelectedSegmentItem

        self.betTypeSegmentControlBaseView.addSubview(self.betTypeSegmentControlView!)
        NSLayoutConstraint.activate([
            self.betTypeSegmentControlView!.centerXAnchor.constraint(equalTo: self.betTypeSegmentControlBaseView.centerXAnchor),
            self.betTypeSegmentControlView!.centerYAnchor.constraint(equalTo: self.betTypeSegmentControlBaseView.centerYAnchor),
        ])

        if let suggestedBetsListViewController = self.suggestedBetsListViewController {
            self.addChildViewController(suggestedBetsListViewController, toView: self.emptyBetsBaseView)
        }

        self.emptyBetsBaseView.isHidden = true

        self.systemBetTypePickerView.delegate = self
        self.systemBetTypePickerView.dataSource = self
        self.systemBetTypePickerView.tag = 1

        self.settingsPickerView.delegate = self
        self.settingsPickerView.delegate = self
        self.settingsPickerView.tag = 2

        self.placeBetButtonsBaseView.isHidden = true
        self.placeBetButtonsSeparatorView.alpha = 0.5
        
        self.secondaryPlaceBetButtonsSeparatorView.alpha = 0.5

        self.simpleWinningsValueLabel.text = localized("no_value")
        self.simpleOddsTitleLabel.text = localized("bets") + ":"
        self.simpleOddsValueLabel.text = "1"
        
        self.multipleOddsTitleLabel.text = localized("total_odd")
        self.secondaryMultipleOddsTitleLabel.text = localized("total_odd")
        
        self.simpleOddsValueLabel.isHidden = false
        self.simpleOddsTitleLabel.isHidden = false

        self.multipleWinningsValueLabel.text = localized("no_value")
        self.multipleOddsValueLabel.text = "-.--"

        self.secondaryMultipleWinningsValueLabel.text = localized("no_value")
        self.secondaryMultipleOddsValueLabel.text = "-.--"
        
        self.systemWinningsValueLabel.text = localized("no_value")
        self.systemOddsTitleLabel.text = localized("total_bet_amount")
        self.systemOddsValueLabel.text = localized("no_value")
        
        self.secondarySystemWinningsValueLabel.text = localized("no_value")
        self.secondarySystemOddsTitleLabel.text = localized("total_bet_amount")
        self.secondarySystemOddsValueLabel.text = localized("no_value")

        self.emptyBetslipLabel.text = localized("not_bets_tickets_section_yet")
        self.emptyBetslipLabel.textAlignment = .center
        self.emptyBetslipLabel.font = AppFont.with(type: .semibold, size: 18)

        self.tableView.separatorStyle = .none
        self.tableView.allowsSelection = false

        self.tableView.register(SingleBettingTicketTableViewCell.nib, forCellReuseIdentifier: SingleBettingTicketTableViewCell.identifier)
        self.tableView.register(MultipleBettingTicketTableViewCell.nib, forCellReuseIdentifier: MultipleBettingTicketTableViewCell.identifier)
        self.tableView.register(BonusSwitchTableViewCell.self, forCellReuseIdentifier: BonusSwitchTableViewCell.identifier)
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

        //
        //
        singleBettingTicketDataSource.didUpdateBettingValueAction = { [weak self] id, value in
            if value == 0 {
                self?.simpleBetsBettingValues.value[id] = nil
            }
            else {
                self?.simpleBetsBettingValues.value[id] = value
            }
        }

        //
        singleBettingTicketDataSource.bettingValueForId = { [weak self] id in
            self?.simpleBetsBettingValues.value[id]
        }

        Env.betslipManager.bettingTicketsPublisher
            .receive(on: DispatchQueue.main)
            .map(Array.init)
            .removeDuplicates(by: { previous, current in
                let result = previous.map(\.id).elementsEqual(current.map(\.id))
                return result
            })
            .sink { [weak self] tickets in
                self?.singleBettingTicketDataSource.bettingTickets = tickets
                self?.multipleBettingTicketDataSource.bettingTickets = tickets
                
                self?.simpleOddsValueLabel.text = "\(tickets.count)"
                
                self?.tableView.reloadData()
            }
            .store(in: &cancellables)

        // Refresh System bet odds
        Env.betslipManager.bettingTicketsPublisher
            .receive(on: DispatchQueue.main)
            .map(Array.init)
            .filter({ tickets in
                tickets.count >= 3
            })
            .sink { [weak self] tickets in
                self?.systemBettingTicketDataSource.bettingTickets = tickets
            }
            .store(in: &cancellables)

        Publishers.CombineLatest(Env.betslipManager.bettingTicketsPublisher, Env.betslipManager.allowedBetTypesPublisher)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] betTickets, betTypes in
                let oldSegmentIndex = self?.betTypeSegmentControlView?.selectedItemIndex
                let userDidSelectedSystemBet = self?.userSelectedSystemBet ?? false

                let containsSingle = betTypes.first(where: { betType in
                    if case .single = betType {
                        return true
                    }
                    return false
                }) != nil
                let containsMultiple = betTypes.first(where: { betType in
                    if case .multiple = betType {
                        return true
                    }
                    return false
                }) != nil
                let containsSystem = betTypes.first(where: { betType in
                    if case .system(_) = betType {
                        return true
                    }
                    return false
                }) != nil


                if betTickets.count == 1 {
                    self?.betTypeSegmentControlView?.setSelectedItem(atIndex: 0, animated: true)
                }
                else if containsMultiple, betTickets.count > 1, !userDidSelectedSystemBet {
                    self?.betTypeSegmentControlView?.setSelectedItem(atIndex: 1, animated: true)
                }
                else if oldSegmentIndex == 1, !containsMultiple {
                    self?.betTypeSegmentControlView?.setSelectedItem(atIndex: 0, animated: true)
                }
                else if userDidSelectedSystemBet, oldSegmentIndex == 2, !containsSystem {
                    self?.betTypeSegmentControlView?.setSelectedItem(atIndex: 1, animated: true)
                }

                if let newSegmentIndex = self?.betTypeSegmentControlView?.selectedItemIndex, newSegmentIndex != oldSegmentIndex {
                    self?.didChangeSelectedSegmentItem(toIndex: newSegmentIndex)
                }

            }
            .store(in: &cancellables)

        Env.betslipManager.allowedBetTypesPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] betTypes in
                let containsSingle = betTypes.first(where: { betType in
                    if case .single = betType {
                        return true
                    }
                    return false
                }) != nil
                let containsMultiple = betTypes.first(where: { betType in
                    if case .multiple = betType {
                        return true
                    }
                    return false
                }) != nil
                let containsSystem = betTypes.first(where: { betType in
                    if case .system(_) = betType {
                        return true
                    }
                    return false
                }) != nil

                self?.betTypeSegmentControlView?.setEnabledItem(atIndex: 0, isEnabled: containsSingle)
                self?.betTypeSegmentControlView?.setEnabledItem(atIndex: 1, isEnabled: containsMultiple)
                self?.betTypeSegmentControlView?.setEnabledItem(atIndex: 2, isEnabled: containsSystem)
            }
            .store(in: &cancellables)

        Env.betslipManager.systemTypesAvailablePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] systemBetType in
                self?.systemBetOptions = systemBetType
            }
            .store(in: &cancellables)


        Env.betslipManager.bettingTicketsPublisher
            .receive(on: DispatchQueue.main)
            .map({ orderedSet -> Double in
                let newArray = orderedSet.map { $0.decimalOdd }
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
                guard let self = self else {return}
                if !self.isBetBuilderSelection {
                    if let oddsBoostSelected = self.oddsBoostSelected {
                        let oddsBoostMultiplier = multiplier + (multiplier * oddsBoostSelected.oddsBoostPercent)
                        self.multipleOddsValueLabel.text = OddConverter.stringForValue(oddsBoostMultiplier, format: UserDefaults.standard.userOddsFormat)
                        self.secondaryMultipleOddsValueLabel.text = OddConverter.stringForValue(oddsBoostMultiplier, format: UserDefaults.standard.userOddsFormat)
                    }
                    else {
                        self.multipleOddsValueLabel.text = OddConverter.stringForValue(multiplier, format: UserDefaults.standard.userOddsFormat)
                        self.secondaryMultipleOddsValueLabel.text = OddConverter.stringForValue(multiplier, format: UserDefaults.standard.userOddsFormat)
                    }
                }
            })
            .store(in: &cancellables)

        //
        self.viewModel.sharedBetsPublisher
            .receive(on: DispatchQueue.main)
            .sink { _ in

            } receiveValue: { [weak self] sharedBetsLoadableContent in
                switch sharedBetsLoadableContent {
                case .idle:
                    ()
                case .loading:
                    self?.isLoading = true
                case .loaded:
                    self?.isLoading = false
                case .failed:
                    self?.isLoading = false
                }
            }
            .store(in: &cancellables)

        Publishers.CombineLatest(Env.betslipManager.bettingTicketsPublisher, self.viewModel.sharedBetsPublisher)
            .filter { _, sharedBetsLoadableContent in

                switch sharedBetsLoadableContent {
                case .idle, .failed:
                    return true
                case .loading, .loaded:
                    return false
                }
            }
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] bettingTickets, _ in
                self?.emptyBetsBaseView.isHidden = !bettingTickets.isEmpty
            })
            .store(in: &cancellables)

        self.viewModel.isUnavailableBetSelection
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] isUnavailable in
                self?.suggestedBetsListViewController?.isEmptySharedBet = isUnavailable
                self?.suggestedBetsListViewController?.reloadTableView()
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

        Env.userSessionStore.userSessionPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] userInfo in
                
                if userInfo != nil {
                    self?.placeBetBaseView.isHidden = false
                    self?.tableView.isHidden = false
                    self?.clearBaseView.isHidden = false
                    self?.betTypeSegmentControlBaseView.isHidden = false
                
                }
            }).store(in: &cancellables)

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
                betslipType == .system && self?.selectedSystemBetType != nil
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
            .map({ [weak self] multiplier, betValue -> String in
                if multiplier >= 1 && betValue > 0 {
                    var oddMultiplier = multiplier

                    if let oddsBoostSelected = self?.oddsBoostSelected {
                        oddMultiplier += (oddMultiplier * oddsBoostSelected.oddsBoostPercent)
                    }

                    let totalValue = oddMultiplier * betValue
                    // totalValue = Double(floor(totalValue * 100)/100)
                    return CurrencyFormater.defaultFormat.string(from: NSNumber(value: totalValue)) ?? localized("no_value")
                }
                else {
                    return localized("no_value")
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
            .map({ [weak self] _, simpleBetsBettingValues, tickets -> String in
                var expectedReturn = 0.0
                let currentOddsBoost = self?.singleBettingTicketDataSource.currentTicketOddsBoostSelected

                for ticket in tickets {
                    if let betValue = simpleBetsBettingValues[ticket.id] {
                        if ticket.bettingId == currentOddsBoost?.bettingId {
                            let oddsBoost = currentOddsBoost?.oddsBoost.oddsBoostPercent ?? 0
                            let boostedValue = ticket.decimalOdd + (ticket.decimalOdd * oddsBoost)
                            let expectedTicketReturn = boostedValue * betValue
                            expectedReturn += expectedTicketReturn

                        }
                        else {
                            let expectedTicketReturn = ticket.decimalOdd * betValue
                            expectedReturn += expectedTicketReturn
                        }
                    }
                }
                if expectedReturn == 0 {
                    return localized("no_value")
                }
                else {
                    // expectedReturn = Double(floor(expectedReturn * 100)/100)
                    return  CurrencyFormater.defaultFormat.string(from: NSNumber(value: expectedReturn)) ?? localized("no_value")
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
            .compactMap({ $0 })
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] multipleBetslipState in
                if let maxStakeSystem = multipleBetslipState.maxStake {
                    self?.maxStakeMultiple = floor(maxStakeSystem)
                }
                else {
                    self?.maxStakeMultiple = nil
                }
                
                self?.checkForbiddenCombinationErrors(multipleBetslipState: multipleBetslipState)
                self?.multipleBettingTicketDataSource.bonusMultiple = []
                
                for freeBet in multipleBetslipState.freeBets {
                    if freeBet.validForSelectionOdds {
                        let bonusMultiple = BonusMultipleBetslip(freeBet: freeBet, oddsBoost: nil)
                        self?.multipleBettingTicketDataSource.bonusMultiple.append(bonusMultiple)
                        // Only one freeBet to use at a time
                        break
                    }
                }
                
                for oddsBoost in multipleBetslipState.oddsBoosts {
                    if oddsBoost.validForSelectionOdds {
                        let bonusMultiple = BonusMultipleBetslip(freeBet: nil, oddsBoost: oddsBoost)
                        self?.multipleBettingTicketDataSource.bonusMultiple.append(bonusMultiple)
                        // Only one oddsBoost to use at a time
                        break
                    }
                }
                
                self?.tableView.reloadData()
            })
            .store(in: &cancellables)

        Env.betslipManager.simpleBetslipSelectionStateList
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] _ in
                self?.tableView.reloadData()
            })
            .store(in: &cancellables)

        Env.userSessionStore.userWalletPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] wallet in
                self?.userBalance = wallet?.total
            })
            .store(in: &cancellables)
        
//        Env.userSessionStore.userBalanceWallet
//            .receive(on: DispatchQueue.main)
//            .sink(receiveValue: { [weak self] wallet in
//                self?.userBalance = wallet?.amount
//            })
//            .store(in: &cancellables)

        Env.everyMatrixClient.serviceStatusPublisher
            .filter({ $0 == .connected })
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] _ in
                self?.tableView.reloadData()
            })
            .store(in: &cancellables)

        self.multipleBettingTicketDataSource.changedFreebetSelectionState = { [weak self] freeBetMultiple in

            guard let self = self else { return }

            if let freeBet = freeBetMultiple {
                self.freeBetSelected = freeBet
                self.displayBetValue = Int(freeBet.freeBetAmount * 100.0)
                self.amountTextfield.text = CurrencyFormater.defaultFormat.string(from: NSNumber(value: freeBet.freeBetAmount))
                self.secondaryAmountTextfield.text = CurrencyFormater.defaultFormat.string(from: NSNumber(value: freeBet.freeBetAmount))
                self.placeBetButtonsBaseView.isUserInteractionEnabled = false
            }
            else {
                self.freeBetSelected = nil
                self.displayBetValue = 0
                self.amountTextfield.text = CurrencyFormater.defaultFormat.string(from: NSNumber(value: self.realBetValue))
                self.secondaryAmountTextfield.text = CurrencyFormater.defaultFormat.string(from: NSNumber(value: self.realBetValue))
                self.placeBetButtonsBaseView.isUserInteractionEnabled = true
            }
        }

        self.multipleBettingTicketDataSource.changedOddsBoostSelectionState = { [weak self] oddsBoostMultiple in

            guard let self = self else { return }

            if let oddsBoost = oddsBoostMultiple {
                self.oddsBoostSelected = oddsBoost
                self.multiplierPublisher.send(self.multiplierPublisher.value)
            }
            else {
                self.oddsBoostSelected = nil
                self.multiplierPublisher.send(self.multiplierPublisher.value)
            }

        }

        self.singleBettingTicketDataSource.changedFreebetSelectionState = { [weak self] singleBetslipFreebet in

            if let singleFreebet = singleBetslipFreebet {
                self?.selectedSingleFreebet = singleFreebet
            }
            else {
                self?.selectedSingleFreebet = nil
            }
        }

        self.singleBettingTicketDataSource.changedOddsBoostSelectionState = { [weak self] singleBetslipOddsBoost in
            if let simpleBetsValues = self?.simpleBetsBettingValues.value {
                self?.simpleBetsBettingValues.send(simpleBetsValues)
                self?.selectedSingleOddsBoost = singleBetslipOddsBoost
            }
            else {
                self?.selectedSingleOddsBoost = nil
            }

        }

        // NOTE: Debounce table reload so the switches can fully animate
        self.singleBettingTicketDataSource.tableNeedsDebouncedReload = { [weak self] in
            self?.tableReloadDebouncePublisher.send()
        }

        self.tableReloadDebouncePublisher
            .debounce(for: .seconds(0.5), scheduler: DispatchQueue.main)
            .sink(receiveValue: { [weak self] _ in
                self?.tableView.reloadData()
            })
            .store(in: &cancellables)

        Publishers.CombineLatest(self.viewModel.sharedBetsPublisher, self.viewModel.isPartialBetSelection)
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] sharedBets, isPartialBetSelection in
                switch sharedBets {
                case .loaded:
                    if isPartialBetSelection {
                        self?.showErrorView(errorMessage: localized("bet_suffered_alterations"), isAlertLayout: true)
                    }
                case .idle:
                    ()
                case .loading:
                    ()
                case .failed:
                    ()
                }
            })
            .store(in: &cancellables)

        Env.betslipManager.betBuilderOddPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] betBuilderOdd in
                if let betBuilderOdd = betBuilderOdd {
                    self?.updateOddsWithBetBuilder(betBuilderOdds: betBuilderOdd)
                }
                else {
                    self?.updateOddsWithBetBuilder()
                }
            })
            .store(in: &cancellables)

        self.setupWithTheme()

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)

        self.placeBetButton.isEnabled = false

        self.getUserSettings()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        Env.betslipManager.refreshAllowedBetTypes()
        self.isKeyboardShowingPublisher.send(false) 
    }

    func getUserSettings() {

        if let userSetting = UserDefaults.standard.string(forKey: "betslipOddValidationType"),
           let userSettingIndex = Env.userBetslipSettingsSelectorList.firstIndex(where: { $0.key == userSetting }) {

            self.settingsPickerView.selectRow(userSettingIndex, inComponent: 0, animated: true)
            self.selectedBetslipSetting = userSetting
        }

    }
    
    func setUserSettings() {
        UserDefaults.standard.set(self.selectedBetslipSetting, forKey: "betslipOddValidationType")
    }

    func checkForbiddenCombinationErrors(multipleBetslipState: BetslipSelectionState) {

        if !multipleBetslipState.forbiddenCombinations.isEmpty {
            self.showErrorView(errorMessage: localized("selections_not_combinable"))
        }
        self.tableView.reloadData()
    }

    private func updateOddsWithBetBuilder(betBuilderOdds: Double? = nil) {

        if let betBuilderOdds = betBuilderOdds {
            self.isBetBuilderSelection = true

            self.multiplierPublisher.send(betBuilderOdds)

            self.multipleBettingTicketDataSource.isBetBuilderActive = true

            self.multipleOddsValueLabel.text = "\(OddConverter.stringForValue(betBuilderOdds, format: UserDefaults.standard.userOddsFormat)) (\(localized("betbuilder_enabled")))"

            self.secondaryMultipleOddsValueLabel.text = "\(OddConverter.stringForValue(betBuilderOdds, format: UserDefaults.standard.userOddsFormat)) (\(localized("betbuilder_enabled")))"

            self.tableView.reloadData()
        }
        else {
            self.isBetBuilderSelection = false

            self.multipleBettingTicketDataSource.isBetBuilderActive = false

            let multiplierValue = self.multiplierPublisher.value

            self.multiplierPublisher.send(multiplierValue)

            self.tableView.reloadData()
        }

    }

    func showErrorView(errorMessage: String?, isAlertLayout: Bool = false) {

        let errorView = BetslipErrorView()
        errorView.alpha = 0
        errorView.setDescription(description: errorMessage ?? localized("error"))

        if isAlertLayout {
            errorView.setAlertLayout()
        }

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

    func setupWithTheme() {

        self.view.backgroundColor = UIColor.App.backgroundPrimary

        //
        self.betTypeSegmentControlBaseView.backgroundColor = UIColor.App.backgroundSecondary

        self.betTypeSegmentControlView?.backgroundContainerColor = UIColor.App.backgroundPrimary
        self.betTypeSegmentControlView?.textColor = UIColor.App.buttonTextPrimary
        self.betTypeSegmentControlView?.textIdleColor = UIColor.App.textPrimary
        self.betTypeSegmentControlView?.sliderColor = UIColor.App.highlightPrimary

        //
        self.secondaryPlaceBetButtonsBaseView.backgroundColor = UIColor.App.backgroundPrimary
        
        self.systemBetTypePickerView.backgroundColor = UIColor.App.backgroundPrimary

        self.clearBaseView.backgroundColor = UIColor.App.backgroundPrimary

        self.systemBetTypeLabel.textColor = UIColor.App.textPrimary
        self.systemBetTypeTitleLabel.textColor = UIColor.App.textSecondary
        self.systemBetTypeSelectorBaseView.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        self.systemBetTypeSelectorContainerView.backgroundColor = UIColor.App.backgroundPrimary

        self.settingsPickerBaseView.backgroundColor = UIColor.black.withAlphaComponent(0.8)

        self.topSafeArea.backgroundColor = UIColor.App.backgroundPrimary
        self.bottomSafeArea.backgroundColor = UIColor.App.backgroundPrimary

        self.amountTextfield.font = AppFont.with(type: .semibold, size: 14)
        self.amountTextfield.textColor = UIColor.App.inputTextTitle
        self.amountTextfield.attributedPlaceholder = NSAttributedString(string: localized("amount"), attributes: [
            NSAttributedString.Key.font: AppFont.with(type: .semibold, size: 14),
            NSAttributedString.Key.foregroundColor: UIColor.App.textDisablePrimary
        ])
        self.amountBaseView.backgroundColor = UIColor.App.inputBackground

        self.clearButton.setTitleColor(UIColor.App.highlightPrimary, for: .normal)

        self.settingsButton.setTitleColor(UIColor.App.highlightPrimary, for: .normal)
        self.settingsButton.setTitle(localized("settings"), for: .normal)
        
        self.clearButton.setTitle(localized("clear_all"), for: .normal)

        self.secondaryAmountTextfield.font = AppFont.with(type: .semibold, size: 14)
        self.secondaryAmountTextfield.textColor = UIColor.App.textPrimary
        self.secondaryAmountTextfield.attributedPlaceholder = NSAttributedString(string: localized("amount"), attributes: [
            NSAttributedString.Key.font: AppFont.with(type: .semibold, size: 14),
            NSAttributedString.Key.foregroundColor: UIColor.App.textDisablePrimary
        ])

        self.secondaryAmountBaseView.backgroundColor = UIColor.App.backgroundTertiary

        self.tableView.backgroundView?.backgroundColor = UIColor.App.backgroundPrimary
        self.tableView.backgroundColor = UIColor.App.backgroundPrimary
        self.tableView.contentInset.bottom = 12

        self.systemBetSeparatorView.backgroundColor = UIColor.App.separatorLine
        self.systemBetBaseView.backgroundColor = UIColor.App.backgroundPrimary
        self.systemBetInteriorView.layer.borderColor = UIColor.App.backgroundPrimary.cgColor
        self.systemBetInteriorView.backgroundColor = UIColor.App.backgroundDrop
        self.systemBetInteriorView.layer.borderColor = UIColor.App.borderDrop.cgColor
        self.systemBetInteriorView.layer.borderWidth = 2

        self.placeBetBaseView.backgroundColor = UIColor.App.backgroundPrimary
        self.placeBetButtonsBaseView.backgroundColor = UIColor.App.backgroundPrimary
        self.placeBetButtonsSeparatorView.backgroundColor = UIColor.App.separatorLine
        self.placeBetSendButtonBaseView.backgroundColor = UIColor.App.backgroundPrimary

        self.secondaryPlaceBetButtonsSeparatorView.backgroundColor = UIColor.App.separatorLine

        self.placeBetButton.setBackgroundColor(UIColor.App.buttonBackgroundPrimary, for: .normal)
        self.placeBetButton.setTitleColor(UIColor.App.buttonTextPrimary, for: .normal)
        self.placeBetButton.setTitle(localized("place_bet"), for: .normal)

        self.placeBetButton.setBackgroundColor(UIColor.App.buttonDisablePrimary, for: .disabled)
        self.placeBetButton.setTitleColor(UIColor.App.buttonTextDisablePrimary, for: .disabled)
        self.placeBetButton.setTitle(localized("place_bet"), for: .disabled)

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

        self.emptyBetslipLabel.textColor = UIColor.App.textPrimary

        self.simpleWinningsSeparatorView.backgroundColor = UIColor.App.separatorLine
        self.multipleWinningsSeparatorView.backgroundColor = UIColor.App.separatorLine
        self.secondaryMultipleWinningsSeparatorView.backgroundColor = UIColor.App.separatorLine
        self.systemWinningsSeparatorView.backgroundColor = UIColor.App.separatorLine
        self.secondarySystemWinningsSeparatorView.backgroundColor = UIColor.App.separatorLine

        self.simpleWinningsBaseView.backgroundColor = UIColor.App.backgroundPrimary
        self.simpleWinningsTitleLabel.textColor = UIColor.App.textSecondary
        
        self.simpleWinningsTitleLabel.text = localized("possible_winnings")
        self.systemWinningsTitleLabel.text = localized("possible_winnings")
        self.multipleWinningsTitleLabel.text = localized("possible_winnings")
        self.secondaryMultipleWinningsTitleLabel.text = localized("possible_winnings")
        self.secondarySystemWinningsTitleLabel.text = localized("possible_winnings")
        
        
        
        self.simpleWinningsValueLabel.textColor = UIColor.App.textPrimary
        self.simpleOddsTitleLabel.textColor = UIColor.App.textSecondary
        self.simpleOddsValueLabel.textColor = UIColor.App.textPrimary

        self.multipleWinningsBaseView.backgroundColor = UIColor.App.backgroundPrimary
        self.multipleWinningsTitleLabel.textColor = UIColor.App.textSecondary
        self.multipleWinningsValueLabel.textColor = UIColor.App.textPrimary
        
        self.secondaryMultipleWinningsBaseView.backgroundColor = UIColor.App.backgroundPrimary
        self.secondaryMultipleWinningsTitleLabel.textColor = UIColor.App.textSecondary
        self.secondaryMultipleWinningsValueLabel.textColor = UIColor.App.textPrimary

        self.secondaryMultipleOddsTitleLabel.textColor = UIColor.App.textDisablePrimary
        self.secondaryMultipleOddsValueLabel.textColor = UIColor.App.textPrimary

        self.multipleOddsTitleLabel.textColor = UIColor.App.textSecondary
        self.multipleOddsValueLabel.textColor = UIColor.App.textPrimary

        self.systemWinningsBaseView.backgroundColor = UIColor.App.backgroundPrimary
        self.systemWinningsTitleLabel.textColor = UIColor.App.textSecondary
        self.systemWinningsValueLabel.textColor = UIColor.App.textPrimary
        self.systemOddsTitleLabel.textColor = UIColor.App.textSecondary
        self.systemOddsValueLabel.textColor = UIColor.App.textPrimary

        self.secondarySystemWinningsBaseView.backgroundColor = UIColor.App.backgroundPrimary
        self.secondarySystemWinningsTitleLabel.textColor = UIColor.App.textDisablePrimary
        self.secondarySystemWinningsValueLabel.textColor = UIColor.App.textPrimary
        self.secondarySystemOddsTitleLabel.textColor = UIColor.App.textDisablePrimary
        self.secondarySystemOddsValueLabel.textColor = UIColor.App.textPrimary

        self.selectSystemBetTypeButton.backgroundColor = UIColor.App.highlightPrimary
        
        self.settingsPickerContainerView.backgroundColor = UIColor.App.backgroundPrimary

        StyleHelper.styleButton(button: self.selectSystemBetTypeButton)
        StyleHelper.styleButton(button: self.placeBetButton)
        StyleHelper.styleButton(button: self.secondaryPlaceBetButton)
        StyleHelper.styleButton(button: self.settingsPickerButton)

        self.settingsButton.setTitleColor(UIColor.App.highlightPrimary, for: .normal)
        self.clearButton.setTitleColor(UIColor.App.highlightPrimary, for: .normal)

    }

    @objc func dismissKeyboard() {
        self.amountTextfield.resignFirstResponder()
        self.secondaryAmountTextfield.resignFirstResponder()
    }

    @IBAction private func didTapSettingsButton() {
        self.showingSettingsSelector = true
    }

    @IBAction private func didTapClearButton() {
        Env.betslipManager.clearAllBettingTickets()

        self.suggestedBetsListViewController?.refreshSuggestedBets()
//
//        self.gomaSuggestedBetsResponse = []
//
//        for cachedBetSuggestedViewModel in self.cachedSuggestedBetViewModels.values {
//            cachedBetSuggestedViewModel.unregisterSuggestedBets()
//        }
//
//        self.cachedSuggestedBetViewModels = [:]
//
//        self.betSuggestedCollectionView.reloadData()
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

    private func didChangeSelectedSegmentItem(toIndex index: Int) {

        switch index {
        case 0:
            self.listTypePublisher.value = .simple
            self.userSelectedSystemBet = false
        case 1:
            self.listTypePublisher.value = .multiple
            self.userSelectedSystemBet = false
        case 2:
            self.listTypePublisher.value = .system
            self.userSelectedSystemBet = true
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

    @IBAction private func didTapSettingsSelectButton() {
        self.showingSettingsSelector = false
    }

/*
    func requestSystemBetsTypes() {

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
                
                guard let weakSelf = self else { return }
                
                weakSelf.systemBetOptions = systemBetResponse.systemBets
                
                var containsOldSelection = false
                var componentsIndex = 0
                if let currentSelection = weakSelf.selectedSystemBetType {
                    for (index, item) in weakSelf.systemBetOptions.enumerated() {
                        if currentSelection.id == item.id {
                            containsOldSelection = true
                            componentsIndex = index
                            break
                        }
                    }
                }
                
                if weakSelf.selectedSystemBetType == nil || !containsOldSelection {
                    weakSelf.selectedSystemBetType = weakSelf.systemBetOptions.first
                }
                else {
                    
                }
                
                weakSelf.systemBetTypePickerView.reloadAllComponents()
                weakSelf.systemBetTypePickerView.selectRow(componentsIndex, inComponent: 0, animated: false)
                 
                weakSelf.requestSystemBetInfo()
            })
            .store(in: &cancellables)
    }
*/

    func requestSystemBetInfo() {

        guard
            let selectedSystemBetType = self.selectedSystemBetType
        else {
            return
        }
        
        self.systemOddsValueLabel.text = localized("no_value")
        self.systemWinningsValueLabel.text = localized("no_value")
        
        self.secondarySystemOddsValueLabel.text = localized("no_value")
        self.secondarySystemWinningsValueLabel.text = localized("no_value")

        let stake = self.realBetValue
        Env.betslipManager.requestSystemBetPotentialReturn(withSkateAmount: stake,
                                                           systemBetType: selectedSystemBetType)
        .receive(on: DispatchQueue.main)
        .sink { completion in

        } receiveValue: { [weak self] betPotencialReturn in
            self?.configureWithSystemBetPotencialReturn(betPotencialReturn)
        }
        .store(in: &cancellables)


        /*
        Env.betslipManager
            .requestSystemBetslipSelectionState(systemBetType: selectedSystemBetType)
            .receive(on: DispatchQueue.main)
            .sink { _ in

            } receiveValue: { [weak self] betDetails in
               
                self?.configureWithSystemBetInfo(systemBetInfo: betDetails)
            }
            .store(in: &cancellables)
*/
    }

    func configureWithSystemBetPotencialReturn(_ betPotencialReturn: BetPotencialReturn) {

        let possibleWinningsString = CurrencyFormater.defaultFormat.string(from: NSNumber(value: betPotencialReturn.potentialReturn)) ?? localized("no_value")
        self.systemWinningsValueLabel.text = possibleWinningsString
        self.secondarySystemWinningsValueLabel.text = possibleWinningsString

        let totalBetAmountString = CurrencyFormater.defaultFormat.string(from: NSNumber(value: betPotencialReturn.totalStake)) ?? localized("no_value")
        self.systemOddsValueLabel.text = totalBetAmountString
        self.secondarySystemOddsValueLabel.text = totalBetAmountString

    }

    func configureWithSystemBetInfo(systemBetInfo: BetslipSelectionState) {

        if let priceValueFactor = systemBetInfo.priceValueFactor, self.realBetValue != 0 {
            let possibleWinnings = priceValueFactor * self.realBetValue

            let possibleWinningsString = CurrencyFormater.defaultFormat.string(from: NSNumber(value: possibleWinnings)) ?? localized("no_value")

            self.systemWinningsValueLabel.text = possibleWinningsString
            self.secondarySystemWinningsValueLabel.text = possibleWinningsString
        }
        else {
            self.systemWinningsValueLabel.text = localized("no_value")
            self.secondarySystemWinningsValueLabel.text = localized("no_value")
        }

        if let numberOfBets = self.selectedSystemBetType?.numberOfBets, self.realBetValue != 0 {
            let totalBetAmount = Double(numberOfBets) * self.realBetValue

            let totalBetAmountString = CurrencyFormater.defaultFormat.string(from: NSNumber(value: totalBetAmount)) ?? localized("no_value")

            self.systemOddsValueLabel.text = totalBetAmountString
            self.secondarySystemOddsValueLabel.text = totalBetAmountString
        }
        else {
            self.systemOddsValueLabel.text = localized("no_value")
            self.secondarySystemOddsValueLabel.text = localized("no_value")
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
        if UserSessionStore.isUserLogged() {
            
            if self.listTypePublisher.value == .simple {
                let singleBetTicketStakes = self.simpleBetsBettingValues.value
                Env.betslipManager.placeSingleBets(amounts: singleBetTicketStakes)
                .receive(on: DispatchQueue.main)
                .sink { [weak self] completion in
                    switch completion {
                    case .failure(let error):
                        var message = ""
                        switch error {
                        case .betPlacementDetailedError(let detailedMessage):
                            message = detailedMessage
                        default:
                            message = """
                            Something went wrong with your bet request.
                            Make sure you have completed your profile and enought balance.
                            """
                        }
                        self?.showErrorView(errorMessage: message)
                    default: ()
                    }
                    self?.isLoading = false
                } receiveValue: { [weak self] betPlacedDetailsArray in
                    self?.betPlacedAction?(betPlacedDetailsArray)
                }
                .store(in: &cancellables)
            }
            else if self.listTypePublisher.value == .multiple {
                Env.betslipManager.placeMultipleBet(withStake: self.realBetValue)
                    .receive(on: DispatchQueue.main)
                    .sink { [weak self] completion in
                        switch completion {
                        case .failure(let error):
                            var message = ""
                            switch error {
                            case .betPlacementDetailedError(let detailedMessage):
                                message = detailedMessage
                            default:
                                message = """
                                Something went wrong with your bet request.
                                Make sure you have completed your profile and enought balance.
                                """
                            }
                            self?.showErrorView(errorMessage: message)
                        default: ()
                        }
                        self?.isLoading = false
                    } receiveValue: { [weak self] betPlacedDetails in
                        self?.betPlacedAction?(betPlacedDetails)
                    }
                    .store(in: &cancellables)
            }
            else if self.listTypePublisher.value == .system, let selectedSystemBetType = self.selectedSystemBetType {
                Env.betslipManager.placeSystemBet(withStake: self.realBetValue, systemBetType: selectedSystemBetType)
                    .receive(on: DispatchQueue.main)
                    .sink { [weak self] completion in
                        switch completion {
                        case .failure(let error):
                            var message = ""
                            switch error {
                            case .betPlacementDetailedError(let detailedMessage):
                                message = detailedMessage
                            default:
                                message = """
                                Something went wrong with your bet request.
                                Make sure you have completed your profile and enought balance.
                                """
                            }
                            self?.showErrorView(errorMessage: message)
                        default: ()
                        }
                        self?.isLoading = false
                    } receiveValue: { [weak self] betPlacedDetails in
                        self?.betPlacedAction?(betPlacedDetails)
                    }
                    .store(in: &cancellables)
            }
        }
        else {
            let loginViewController = Router.navigationController(with: LoginViewController())
            self.present(loginViewController, animated: true, completion: nil)
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
        if pickerView.tag == 1 {
            return self.systemBetOptions.count
        }
        else {
            return Env.userBetslipSettingsSelectorList.count
        }
    }

    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        if pickerView.tag == 1 {
            let name = "\(self.systemBetOptions[safe: row]?.name ?? "--") x\(self.systemBetOptions[safe: row]?.numberOfBets ?? 0)"
            return NSAttributedString(string: name,
                                      attributes: [NSAttributedString.Key.foregroundColor: UIColor.App.textPrimary])
        }
        else {
            return NSAttributedString(string: Env.userBetslipSettingsSelectorList[safe: row]?.description ?? "--",
                                      attributes: [NSAttributedString.Key.foregroundColor: UIColor.App.textPrimary])
        }
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView.tag == 1 {
            self.selectedSystemBetType = self.systemBetOptions[safe: row]
        }
        else {
            self.selectedBetslipSetting = Env.userBetslipSettingsSelectorList[safe: row]?.key
            self.setUserSettings()
        }
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

class SingleBettingTicketDataSource: NSObject, UITableViewDelegate, UITableViewDataSource {

    var bettingTickets: [BettingTicket] = []

    var didUpdateBettingValueAction: ((String, Double) -> Void)?
    var bettingValueForId: ((String) -> (Double?))?

    var isFreeBetSelected: Bool = false
    var currentTicketFreeBetSelected: SingleBetslipFreebet?
    var changedFreebetSelectionState: ((SingleBetslipFreebet?) -> Void)?

    var isOddsBoostSelected: Bool = false
    var currentTicketOddsBoostSelected: SingleBetslipOddsBoost?
    var changedOddsBoostSelectionState: ((SingleBetslipOddsBoost?) -> Void)?
    var tableNeedsDebouncedReload: (() -> Void)?

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

        let cellBetError = Env.betslipManager.getErrorsForSingleBetBettingTicket(bettingTicket: bettingTicket)

        switch cellBetError.errorType {
        case .betPlacementError:
            cell.configureWithBettingTicket(bettingTicket, previousBettingAmount: storedValue, errorBetting: cellBetError.errorMessage)
        default:
            cell.configureWithBettingTicket(bettingTicket, previousBettingAmount: storedValue)
        }

        cell.didUpdateBettingValueAction = self.didUpdateBettingValueAction

        if let betslipSelectionState =  Env.betslipManager.simpleBetslipSelectionStateList.value[bettingTicket.id] {

            for freeBet in betslipSelectionState.freeBets {
                if freeBet.validForSelectionOdds {

                    if isFreeBetSelected == false {
                        cell.setupFreeBetInfo(freeBet: freeBet)
                        cell.showBonusInfo = true
                        cell.showFreeBetInfo = true
                    }
                    else {
                        if let currentTicketFreeBetSelected = self.currentTicketFreeBetSelected,
                           currentTicketFreeBetSelected.bettingId == bettingTicket.bettingId {
                            cell.setupFreeBetInfo(freeBet: freeBet, isSwitchOn: true)
                            cell.showFreeBetInfo = true
                        }
                        else {
                            cell.setupFreeBetInfo(freeBet: freeBet)
                            cell.showFreeBetInfo = false
                        }
                    }

                    cell.isFreeBetSelected = { [weak self] selected in
                        if selected {
                            self?.isFreeBetSelected = true
                            let singleBetslipFreebet = SingleBetslipFreebet(bettingId: bettingTicket.bettingId, freeBet: freeBet)
                            self?.currentTicketFreeBetSelected = singleBetslipFreebet
                            self?.changedFreebetSelectionState?(singleBetslipFreebet)

                        }
                        else {
                            self?.isFreeBetSelected = false
                            self?.currentTicketFreeBetSelected = nil
                            self?.changedFreebetSelectionState?(nil)
                        }

                        self?.tableNeedsDebouncedReload?()
                    }
                    // Only one to use each time
                    break
                }
            }

            for oddsBoost in betslipSelectionState.oddsBoosts {
                if oddsBoost.validForSelectionOdds {
                    if isOddsBoostSelected == false {
                        cell.setupOddsBoostInfo(oddsBoost: oddsBoost)
                        cell.showBonusInfo = true
                        cell.showOddsBoostInfo = true
                    }
                    else {
                        if let currentTicketOddsBoostSelected = self.currentTicketOddsBoostSelected,
                           currentTicketOddsBoostSelected.bettingId == bettingTicket.bettingId {
                            cell.setupOddsBoostInfo(oddsBoost: oddsBoost, isSwitchOn: true)
                            cell.showOddsBoostInfo = true
                        }
                        else {
                            cell.setupOddsBoostInfo(oddsBoost: oddsBoost)
                            cell.showOddsBoostInfo = false
                        }
                    }

                    cell.isOddsBoostSelected = { [weak self] selected in
                        if selected {
                            self?.isOddsBoostSelected = true
                            let singleBetslipOddsBoost = SingleBetslipOddsBoost(bettingId: bettingTicket.bettingId, oddsBoost: oddsBoost)
                            self?.currentTicketOddsBoostSelected = singleBetslipOddsBoost
                            self?.changedOddsBoostSelectionState?(singleBetslipOddsBoost)

                            Env.betslipManager.requestSimpleBetslipSelectionState(oddsBoostPercentage: oddsBoost.oddsBoostPercent)

                        }
                        else {
                            self?.isOddsBoostSelected = false
                            self?.currentTicketOddsBoostSelected = nil
                            self?.changedOddsBoostSelectionState?(nil)
                            Env.betslipManager.requestSimpleBetslipSelectionState()

                        }

                        self?.tableNeedsDebouncedReload?()
                    }
                    // Only one to use each time
                    break
                }
            }
        }

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
    var bonusMultiple: [BonusMultipleBetslip] = []

    var freebetSelected: Bool = false
    var changedFreebetSelectionState: ((BetslipFreebet?) -> Void)?

    var oddsBoostSelected: Bool = false
    var changedOddsBoostSelectionState: ((BetslipOddsBoost?) -> Void)?
    var isBetBuilderActive: Bool = false

    init(bettingTickets: [BettingTicket]) {
        self.bettingTickets = bettingTickets
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (bettingTickets.count + bonusMultiple.count)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueCellType(MultipleBettingTicketTableViewCell.self),
           let bettingTicket = self.bettingTickets[safe: indexPath.row] {
            let cellBetError = Env.betslipManager.getErrorsForBettingTicket(bettingTicket: bettingTicket)

            switch cellBetError.errorType {
            case .betPlacementError:
                cell.configureWithBettingTicket(bettingTicket, errorBetting: cellBetError.errorMessage)
            case .forbiddenBetError:
                cell.configureWithBettingTicket(bettingTicket, errorBetting: cellBetError.errorMessage)
            case .betPlacementDetailedError(let message):
                cell.configureWithBettingTicket(bettingTicket, errorBetting: message)
            default:
                cell.configureWithBettingTicket(bettingTicket)
            }

            if self.isBetBuilderActive {
                cell.updateOddWithBetBuilder(isActive: true, bettingTicket: bettingTicket)
            }
            else {
                cell.updateOddWithBetBuilder(isActive: false, bettingTicket: bettingTicket)
            }

            return cell
        }
        else if let cell = tableView.dequeueCellType(BonusSwitchTableViewCell.self),
                    let bonusMultiple = self.bonusMultiple[safe: (indexPath.row - self.bettingTickets.count)] {

            if let freeBet = bonusMultiple.freeBet {
                cell.setupBonusInfo(freeBet: freeBet, oddsBoost: nil, bonusType: .freeBet)

                cell.didTappedSwitch = { [weak self] in
                    if cell.isSwitchOn {
                        self?.changedFreebetSelectionState?(freeBet)
                    }
                    else {
                        self?.changedFreebetSelectionState?(nil)
                    }
                }
            }
            else if let oddsBoost = bonusMultiple.oddsBoost {
                cell.setupBonusInfo(freeBet: nil, oddsBoost: oddsBoost, bonusType: .oddsBoost)

                cell.didTappedSwitch = { [weak self] in
                    if cell.isSwitchOn {
                        self?.changedOddsBoostSelectionState?(oddsBoost)
                    }
                    else {
                        self?.changedOddsBoostSelectionState?(nil)
                    }
                }
            }
            return cell
        }
        else {
            fatalError()
        }

    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row <= self.bettingTickets.count - 1 {
            return 99
        }
        return 50
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

        let cellBetError = Env.betslipManager.getErrorsForBettingTicket(bettingTicket: bettingTicket)

        switch cellBetError.errorType {
        case .betPlacementError:
            cell.configureWithBettingTicket(bettingTicket, errorBetting: cellBetError.errorMessage)
        case .forbiddenBetError:
            cell.configureWithBettingTicket(bettingTicket, errorBetting: cellBetError.errorMessage)
        default:
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

//
struct SingleBetslipFreebet {
    var bettingId: String
    var freeBet: BetslipFreebet
}

struct SingleBetslipOddsBoost {
    var bettingId: String
    var oddsBoost: BetslipOddsBoost
}

struct BonusMultipleBetslip {
    var freeBet: BetslipFreebet?
    var oddsBoost: BetslipOddsBoost?
}

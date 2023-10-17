//
//  PreSubmissionBetslipViewController.swift
//  Sportsbook
//
//  Created by Ruben Roques on 03/11/2021.
//

import UIKit
import Combine
import OrderedCollections
import ServicesProvider

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

    @IBOutlet private weak var winningsTypeBaseView: UIView!

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

    @IBOutlet private weak var freeBetBaseView: UIView!
    @IBOutlet private weak var freeBetInternalView: UIView!
    @IBOutlet private weak var freeBetImageView: UIImageView!
    @IBOutlet private weak var freeBetTitleLabel: UILabel!
    @IBOutlet private weak var freeBetBalanceLabel: UILabel!
    @IBOutlet private weak var freeBetSwitch: UISwitch!
    @IBOutlet private weak var freeBetCloseButton: UIButton!

    @IBOutlet private weak var cashbackBaseView: UIView!
    @IBOutlet private weak var cashbackInnerBaseView: UIView!
    @IBOutlet private weak var cashbackTitleLabel: UILabel!
    @IBOutlet private weak var cashbackValueLabel: UILabel!
    @IBOutlet private weak var cashbackSwitch: UISwitch!
    @IBOutlet private weak var cashbackSeparatorView: UIView!

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
    @IBOutlet private weak var emptyBetsImageView: UIImageView!
    @IBOutlet private weak var emptyBetslipLabel: UILabel!

    @IBOutlet private weak var cashbackInfoSingleBaseView: UIView!
    @IBOutlet private weak var cashbackInfoSingleView: CashbackInfoView!
    @IBOutlet private weak var cashbackInfoSingleValueLabel: UILabel!

    @IBOutlet private weak var cashbackInfoMultipleBaseView: UIView!
    @IBOutlet private weak var cashbackInfoMultipleView: CashbackInfoView!
    @IBOutlet private weak var cashbackInfoMultipleValueLabel: UILabel!

    @IBOutlet private weak var loadingBaseView: UIView!
    @IBOutlet private weak var loadingView: UIActivityIndicatorView!
    private let loadingSpinnerViewController = LoadingSpinnerViewController()

    // Custom views
    lazy var learnMoreBaseView: CashbackLearnMoreView = {
        let view = CashbackLearnMoreView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

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

    private var isFreebetEnabled: CurrentValueSubject<Bool, Never> = .init(false)

    private var isFreebetDismissed = false {
        didSet {
            if isFreebetDismissed {
                self.freeBetBaseView.isHidden = true
            }
        }
    }

    private var isCashbackEnabled: Bool = false {
        didSet {
            self.cashbackBaseView.isHidden = !isCashbackEnabled
        }
    }

    private var showCashbackValues: Bool = false {
        didSet {
            self.cashbackInfoMultipleBaseView.isHidden = !showCashbackValues
        }
    }

    private var isCashbackToggleOn: CurrentValueSubject<Bool, Never> = .init(false)

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
                let optionName = systemBetType.name ?? localized("system_bet")

                let normalizedOptionName = optionName.replacingOccurrences(of: "[^a-zA-Z0-9]", with: "_", options: .regularExpression).lowercased()

                let optionKeyName = "allowed_bet_types_\(normalizedOptionName)"

                let optionKey = localized(optionKeyName)

                let name = "\(optionKey) x\(systemBetType.numberOfBets ?? 0)"

                self.systemBetTypeLabel.text = name
                // self.systemBetTypeLabel.text = "\(systemBetType.name ?? localized("system_bet")) x\(systemBetType.numberOfBets ?? 0)"
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
                self.systemBetTypeSelectorBaseView.isHidden = false
                self.systemBetTypeSelectorBaseView.alpha = 1.0
            }
            else {
                self.systemBetTypeSelectorBaseView.isHidden = true
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

    private var maxBetValue: Double {
        if let userWallet = Env.userSessionStore.userWalletPublisher.value {
            return userWallet.total
        }
        else {
            return 0
        }
    }

    private var cashbackBalance: Double {
        if let cashbackBalance = Env.userSessionStore.userCashbackBalance.value {
            return cashbackBalance
        }
        else {
            return 0
        }
    }

    private var cashbackResultValuePublisher: CurrentValueSubject<Double?, Never> = .init(nil)

    private var realBetValuePublisher: CurrentValueSubject<Double, Never> = .init(0.0)

    private var isKeyboardShowingPublisher: CurrentValueSubject<Bool, Never> = .init(false)

    private var isLoading = false {
        didSet {
            if isLoading {
                self.loadingSpinnerViewController.startAnimating()
                self.loadingBaseView.isHidden = false
            }
            else {
                self.loadingBaseView.isHidden = true
                self.loadingSpinnerViewController.stopAnimating()
            }
        }
    }

    var betPlacedAction: (([BetPlacedDetails], Double?, Bool) -> Void) = { _, _, _  in }

    var acceptingAnyReofferOnBetPlace: Bool = false

    var betslipSettingsSelectorList = BetslipOddValidationType.allCases

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
        self.loadingBaseView.isHidden = true
        self.settingsPickerBaseView.alpha = 0.0

        self.freeBetBaseView.isHidden = true
        self.cashbackBaseView.isHidden = true
        self.cashbackInfoSingleBaseView.isHidden = true
        self.cashbackInfoMultipleBaseView.isHidden = true

        self.simpleWinningsBaseView.isHidden = false
        self.multipleWinningsBaseView.isHidden = true
        self.systemWinningsBaseView.isHidden = true

        self.loadingView.alpha = 0.0
        self.loadingView.stopAnimating()
        self.loadingBaseView.isHidden = true
        self.addChildViewController(self.loadingSpinnerViewController, toView: self.loadingBaseView)

        self.view.bringSubviewToFront(systemBetTypeSelectorBaseView)
        self.view.bringSubviewToFront(settingsPickerBaseView)
        self.view.bringSubviewToFront(emptyBetsBaseView)
        self.view.bringSubviewToFront(loadingBaseView)

        self.betTypeSegmentControlView = SegmentControlView(options: [localized("single"), localized("multiple"), localized("system")])
        self.betTypeSegmentControlView?.translatesAutoresizingMaskIntoConstraints = false
        self.betTypeSegmentControlView?.didSelectItemAtIndexAction = { [weak self] index in
            self?.didChangeSelectedSegmentItem(toIndex: index)
        }

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
        self.placeBetButtonsSeparatorView.alpha = 1.0
        
        self.secondaryPlaceBetButtonsSeparatorView.alpha = 1.0

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
        
        self.systemBetTypeTitleLabel.text = localized("system_options")
        
        self.selectSystemBetTypeButton.setTitle(localized("select"), for: .normal)
        self.settingsPickerButton.setTitle(localized("select"), for: .normal)
        
        self.secondarySystemWinningsValueLabel.text = localized("no_value")
        self.secondarySystemOddsTitleLabel.text = localized("total_bet_amount")
        self.secondarySystemOddsValueLabel.text = localized("no_value")

        self.emptyBetsImageView.image = UIImage(named: "avatar_empty")

        self.emptyBetslipLabel.text = localized("empty_betslip_info_title")
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
        // Quick add buttons
        self.plusOneButtonView.setTitle("+10", for: .normal)
        self.plusFiveButtonView.setTitle("+20", for: .normal)
        self.maxValueButtonView.setTitle("+50", for: .normal)

        // Quick add buttons
        self.secondaryPlusOneButtonView.setTitle("+10", for: .normal)
        self.secondaryPlusFiveButtonView.setTitle("+20", for: .normal)
        self.secondaryMaxButtonView.setTitle("+50", for: .normal)

        // Disable settings until loaded
        self.settingsButton.isEnabled = false
        self.settingsButton.isUserInteractionEnabled = false

        // Default disable all
        self.betTypeSegmentControlView?.setEnabledItem(atIndex: 0, isEnabled: false)
        self.betTypeSegmentControlView?.setEnabledItem(atIndex: 1, isEnabled: false)
        self.betTypeSegmentControlView?.setEnabledItem(atIndex: 2, isEnabled: false)

        //
        //  Single bet cell amount sync
        //
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

        singleBettingTicketDataSource.shouldHighlightTextfield = { [weak self] in

            var isFreeBet = false

            if let freeBetEnabled = self?.isFreebetEnabled.value,
               let cashbackSelected = self?.isCashbackToggleOn.value {

                if freeBetEnabled || cashbackSelected {
                    isFreeBet = true
                }
            }

            return isFreeBet

            // return self?.isFreebetEnabled.value ?? false
        }

        // Loading settings odd change on bet
        Env.servicesProvider
            .getBetslipSettings()
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] betslipSettings in
                if let betslipSettingsValue = betslipSettings {
                    self?.acceptingAnyReofferOnBetPlace = betslipSettingsValue.acceptingAnyReoffer
                    self?.settingsButton.isEnabled = true
                    self?.settingsButton.isUserInteractionEnabled = true
                }
                else {
                    self?.acceptingAnyReofferOnBetPlace = false
                    self?.settingsButton.isEnabled = false
                    self?.settingsButton.isUserInteractionEnabled = false
                }
                if self?.acceptingAnyReofferOnBetPlace ?? false {
                    self?.settingsPickerView.selectRow(0, inComponent: 0, animated: false)
                }
                else {
                    self?.settingsPickerView.selectRow(1, inComponent: 0, animated: false)
                }
            })
            .store(in: &self.cancellables)

        // Reload if the betting Tickets odds cahnged
        Env.betslipManager.bettingTicketsPublisher
            .removeDuplicates(by: { lhs, rhs in
                let counts = lhs.count == rhs.count
                let odds = lhs.map(\.decimalOdd) == rhs.map(\.decimalOdd)
                let ids = lhs.map(\.bettingId) == rhs.map(\.bettingId)
                return counts && odds && ids
            })
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.requestMultipleBetReturn()
                self?.requestSystemBetInfo()
                self?.requestCashbackResult()
            }
            .store(in: &cancellables)

        // Reload if the betting Tickets list changes
        Env.betslipManager.bettingTicketsPublisher
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] tickets in
                self?.singleBettingTicketDataSource.bettingTickets = tickets
                self?.multipleBettingTicketDataSource.bettingTickets = tickets
                self?.systemBettingTicketDataSource.bettingTickets = tickets

                self?.simpleOddsValueLabel.text = "\(tickets.count)"

                self?.tableView.reloadData()
            }
            .store(in: &cancellables)

        Env.betslipManager.allowedBetTypesPublisher
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] allowedBetTypesContent in
                switch allowedBetTypesContent {
                case .loading:
                    self?.systemBetTypeLoadingView.startAnimating()
                    self?.systemBetInteriorView.alpha = 0.7
                    self?.systemBetInteriorView.isUserInteractionEnabled = false
                case .idle, .failed, .loaded:
                    self?.systemBetTypeLoadingView.stopAnimating()
                    self?.systemBetInteriorView.alpha = 1.0
                    self?.systemBetInteriorView.isUserInteractionEnabled = true
                }
            }
            .store(in: &self.cancellables)

        Publishers.CombineLatest(Env.betslipManager.bettingTicketsPublisher, Env.betslipManager.allowedBetTypesPublisher)
            .removeDuplicates(by: { (leftValue: ([BettingTicket], LoadableContent<[BetType]>),
                                     rightValue: ([BettingTicket], LoadableContent<[BetType]> )) -> Bool in
                return leftValue.0 == rightValue.0 && leftValue.1 == rightValue.1
            })
            .compactMap({ (bettingTickets: [BettingTicket], allowedBetTypesContent: LoadableContent<[BetType]>) -> ([BettingTicket], [BetType])? in
                switch allowedBetTypesContent {
                case .idle, .failed, .loading:
                    return nil
                case .loaded(let loadedContent):
                    return (bettingTickets, loadedContent)
                }
            })
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (betTickets: [BettingTicket], betTypes: [BetType]) in
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
                    if case .system = betType {
                        return true
                    }
                    return false
                }) != nil

                if betTickets.count == 1, containsSingle {
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
            .removeDuplicates()
            .compactMap({ loadableContent in
                switch loadableContent {
                case .loaded(let value):
                    return value
                default:
                    return nil
                }
            })
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (betTypes: [BetType]) in
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
                    if case .system = betType {
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
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] systemTypesAvailableContent in
                switch systemTypesAvailableContent {
                case .loading, .idle, .failed:
                    self?.systemBetOptions = []
                case .loaded(let systemBetType):
                    self?.systemBetOptions = systemBetType
                }
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
                self?.configureWithMultipleTotalOdd(multiplier)
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
                case .idle, .failed, .loaded:
                    return true
                case .loading:
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
                // self?.suggestedBetsListViewController?.isEmptySharedBet = isUnavailable
                // self?.suggestedBetsListViewController?.reloadTableView()
                if isUnavailable {
                    self?.showErrorView(errorMessage: localized("shared_bet_unavailable"))
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

        Env.userSessionStore.userProfilePublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] userProfile in
                
                if userProfile != nil {
                    self?.placeBetBaseView.isHidden = false
                    self?.tableView.isHidden = false
                    self?.clearBaseView.isHidden = false
                    self?.betTypeSegmentControlBaseView.isHidden = false
                
                }
            }).store(in: &self.cancellables)

        self.listTypePublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] betType in

                switch betType {
                case .simple:
                    self?.simpleWinningsBaseView.isHidden = false
                    self?.multipleWinningsBaseView.isHidden = true
                    self?.systemWinningsBaseView.isHidden = true

                    if let cashbackEnabled = self?.isCashbackEnabled,
                       cashbackEnabled,
                       let cashbackValue = Env.userSessionStore.userCashbackBalance.value {

                        if cashbackValue > 0 {
                            self?.cashbackBaseView.isHidden = false
                        }
                        else {
                            self?.cashbackBaseView.isHidden = true
                        }
                    }
//                    if let cashbackEnabled = self?.isCashbackEnabled,
//                       cashbackEnabled {
//                        self?.cashbackBaseView.isHidden = true
//                    }
                case .multiple:
                    self?.simpleWinningsBaseView.isHidden = true
                    self?.multipleWinningsBaseView.isHidden = false
                    self?.systemWinningsBaseView.isHidden = true

                    if let cashbackEnabled = self?.isCashbackEnabled,
                       cashbackEnabled,
                       let cashbackValue = Env.userSessionStore.userCashbackBalance.value {

                        if cashbackValue > 0 {
                            self?.cashbackBaseView.isHidden = false
                        }
                        else {
                            self?.cashbackBaseView.isHidden = true
                        }
                    }
                case .system:
                    self?.simpleWinningsBaseView.isHidden = true
                    self?.multipleWinningsBaseView.isHidden = true
                    self?.systemWinningsBaseView.isHidden = false

                    if let cashbackEnabled = self?.isCashbackEnabled,
                       cashbackEnabled,
                       let cashbackValue = Env.userSessionStore.userCashbackBalance.value {

                        if cashbackValue > 0 {
                            self?.cashbackBaseView.isHidden = false
                        }
                        else {
                            self?.cashbackBaseView.isHidden = true
                        }
                    }
//                    if let cashbackEnabled = self?.isCashbackEnabled,
//                       cashbackEnabled {
//                        self?.cashbackBaseView.isHidden = true
//                    }
                }
            })
            .store(in: &self.cancellables)

        Publishers.CombineLatest(self.realBetValuePublisher, self.listTypePublisher)
            .filter({ _, listTypePublisher -> Bool in
                return (listTypePublisher == .multiple || listTypePublisher == .system)
            })
            .map({ bettingValue, _ -> Bool in
                return bettingValue > 0
            })
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] hasValidBettingValue in

                if hasValidBettingValue {
                    self?.requestSystemBetInfo()
                    self?.requestMultipleBetReturn()
                    self?.requestCashbackResult()
                }
                else {
                    self?.multipleWinningsValueLabel.text = localized("no_value")
                    self?.secondaryMultipleWinningsValueLabel.text = localized("no_value")
                }

                self?.placeBetButton.isEnabled = hasValidBettingValue
            })
            .store(in: &self.cancellables)

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
                    return CurrencyFormater.defaultFormat.string(from: NSNumber(value: expectedReturn)) ?? localized("no_value")
                }
            })
            .sink(receiveValue: { [weak self] possibleEarningsString in
                self?.simpleWinningsValueLabel.text = possibleEarningsString
            })
            .store(in: &self.cancellables)

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
            .store(in: &self.cancellables)
        
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
                default:
                    self?.secondaryPlaceBetBaseView.isHidden = true
                }
            })
            .store(in: &self.cancellables)

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
            }
            else {
                self.oddsBoostSelected = nil
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

        if TargetVariables.features.contains(.freebets) {
            Env.servicesProvider
                .getFreebet()
                .receive(on: DispatchQueue.main)
                .sink { [weak self] completion in
                    if case .failure = completion {
                        self?.freeBetBalanceLabel.text = ""
                        self?.freeBetBaseView.isHidden = true
                    }
                } receiveValue: { [weak self] freebetBalance in
                    if freebetBalance.balance > 0.0 {
                        // Show freebet view
                        print("Show freebet view")
                        let balance = CurrencyFormater.defaultFormat.string(from: NSNumber(value: freebetBalance.balance))
                        self?.freeBetBalanceLabel.text = balance
                        self?.freeBetBaseView.isHidden = false
                    }
                    else {
                        // Hide freebet view
                        print("Hide freebet view")
                        self?.freeBetBalanceLabel.text = ""
                        self?.freeBetBaseView.isHidden = true
                    }
                }
                .store(in: &self.cancellables)

        // Free bet
        self.freeBetSwitch.addTarget(self, action: #selector(onFreebetSwitchValueChanged(_:)), for: .valueChanged)

        self.freeBetCloseButton.addTarget(self, action: #selector(didTapCloseFreebetButton), for: .primaryActionTriggered)
        self.freeBetInternalView.layer.cornerRadius = 5
        self.freeBetInternalView.layer.borderWidth = 2
        self.freeBetInternalView.layer.borderColor = UIColor.clear.cgColor

        self.freeBetSwitch.setOn(false, animated: true)
        self.freeBetTitleLabel.font = AppFont.with(type: .semibold, size: 14)
        self.freeBetBalanceLabel.font = AppFont.with(type: .semibold, size: 14)

        self.isFreebetEnabled
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isFreebetEnabled in
                if isFreebetEnabled {
                    self?.freeBetInternalView.layer.borderColor = UIColor.App.highlightPrimary.cgColor
                    self?.amountBaseView.layer.borderColor = UIColor.App.highlightPrimary.cgColor
                    self?.secondaryAmountBaseView.layer.borderColor = UIColor.App.highlightPrimary.cgColor
                }
                else {
                    self?.freeBetInternalView.layer.borderColor = UIColor.clear.cgColor

                    if self?.isKeyboardShowingPublisher.value ?? false {
                        self?.amountBaseView.layer.borderColor = UIColor.App.inputBorderActive.cgColor
                        self?.secondaryAmountBaseView.layer.borderColor = UIColor.App.inputBorderActive.cgColor
                    }
                    else {
                        self?.amountBaseView.layer.borderColor = UIColor.App.backgroundBorder.cgColor
                        self?.secondaryAmountBaseView.layer.borderColor = UIColor.App.backgroundBorder.cgColor
                    }
                }

                self?.tableView.reloadData()
            }
            .store(in: &self.cancellables)
        }
        else {
            self.freeBetBaseView.isHidden = true
        }

        // Cashback
        if TargetVariables.features.contains(.cashback) {
            self.isCashbackEnabled = true
            self.setupCashback()
        }
        else {
            self.isCashbackEnabled = false
        }

        self.setupWithTheme()

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)

        self.placeBetButton.isEnabled = false

    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        Env.betslipManager.refreshAllowedBetTypes()
        
        self.isKeyboardShowingPublisher.send(false) 
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

        //
        // Amount textfields
        //
        self.amountTextfield.textAlignment = .left
        self.amountTextfield.font = AppFont.with(type: .semibold, size: 15)
        self.amountTextfield.textColor = UIColor.App.inputText
        self.amountTextfield.attributedPlaceholder = NSAttributedString(string: localized("amount"), attributes: [
            NSAttributedString.Key.font: AppFont.with(type: .semibold, size: 15),
            NSAttributedString.Key.foregroundColor: UIColor.App.textDisablePrimary
        ])

        self.secondaryAmountTextfield.font = AppFont.with(type: .semibold, size: 15)
        self.secondaryAmountTextfield.textColor = UIColor.App.inputText
        self.secondaryAmountTextfield.attributedPlaceholder = NSAttributedString(string: localized("amount"), attributes: [
            NSAttributedString.Key.font: AppFont.with(type: .semibold, size: 15),
            NSAttributedString.Key.foregroundColor: UIColor.App.textDisablePrimary
        ])

        self.amountBaseView.backgroundColor = UIColor.App.inputBackground
        self.amountBaseView.layer.cornerRadius = 10.0
        self.amountBaseView.layer.borderWidth = 2
        self.amountBaseView.layer.borderColor = UIColor.App.backgroundBorder.cgColor

        self.secondaryAmountBaseView.backgroundColor = UIColor.App.inputBackground
        self.secondaryAmountBaseView.layer.cornerRadius = 10.0
        self.secondaryAmountBaseView.layer.borderWidth = 2
        self.secondaryAmountBaseView.layer.borderColor = UIColor.App.backgroundBorder.cgColor
        //
        //

        self.clearButton.setTitleColor(UIColor.App.highlightPrimary, for: .normal)
        self.clearButton.setTitle(localized("clear_all"), for: .normal)

        self.settingsButton.setTitleColor(UIColor.App.highlightPrimary, for: .normal)
        self.settingsButton.setTitleColor(UIColor.App.highlightPrimary.withAlphaComponent(0.4), for: .disabled)
        self.settingsButton.setTitle(localized("settings"), for: .normal)

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
        self.placeBetSendButtonBaseView.backgroundColor = UIColor.App.backgroundPrimary

        self.placeBetButton.setBackgroundColor(UIColor.App.buttonDisablePrimary, for: .disabled)
        self.placeBetButton.setTitleColor(UIColor.App.buttonTextDisablePrimary, for: .disabled)

        self.placeBetButton.setTitle(localized("place_bet"), for: .normal)
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

        self.placeBetButtonsSeparatorView.backgroundColor = UIColor.App.separatorLineSecondary
        self.secondaryPlaceBetButtonsSeparatorView.backgroundColor = UIColor.App.separatorLineSecondary

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

        self.freeBetBaseView.backgroundColor = .clear
        self.freeBetInternalView.backgroundColor = UIColor.App.backgroundSecondary
        self.freeBetImageView.setImageColor(color: UIColor.App.textPrimary)
        self.freeBetTitleLabel.textColor = UIColor.App.textPrimary
        self.freeBetBalanceLabel.textColor = UIColor.App.textPrimary
        self.freeBetSwitch.onTintColor = UIColor.App.highlightPrimary
        self.freeBetCloseButton.imageView?.setTintColor(color: UIColor.App.textPrimary)

        self.cashbackBaseView.backgroundColor = .clear
        self.cashbackInnerBaseView.backgroundColor = UIColor.App.backgroundSecondary
        self.cashbackSeparatorView.backgroundColor = UIColor.App.separatorLine
        self.cashbackTitleLabel.textColor = UIColor.App.textPrimary
        self.cashbackValueLabel.textColor = UIColor.App.textPrimary
        self.cashbackSwitch.onTintColor = UIColor.App.highlightPrimary
        self.cashbackInfoSingleBaseView.backgroundColor = .clear
        self.cashbackInfoSingleValueLabel.textColor = UIColor.App.textPrimary
        self.cashbackInfoMultipleBaseView.backgroundColor = .clear
        self.cashbackInfoMultipleValueLabel.textColor = UIColor.App.textPrimary

    }

    private func setupCashback() {
        self.cashbackSwitch.addTarget(self, action: #selector(cashbackSwitchValueChanged(_:)), for: .valueChanged)

        self.cashbackTitleLabel.text = localized("replay_balance")
        self.cashbackSwitch.setOn(false, animated: false)
        self.isCashbackToggleOn.send(false)

        self.cashbackInfoMultipleBaseView.isHidden = true  // Singles don't have cashback
        self.cashbackInfoSingleBaseView.isHidden = true // Singles don't have cashback

        //
        Env.userSessionStore.userCashbackBalance
            .receive(on: DispatchQueue.main)
            .sink { completion in
                print("userSessionStore userCashbackBalance completion: \(completion)")
            } receiveValue: { value in
                if let cashbackValue = value,
                   let formattedCashbackString = CurrencyFormater.defaultFormat.string(from: NSNumber(value: cashbackValue)) {
                    self.cashbackValueLabel.text = formattedCashbackString

                    if cashbackValue <= 0 {
                        self.cashbackBaseView.isHidden = true
                    }
                    else {
                        self.cashbackBaseView.isHidden = false
                    }
                }
                else {
                    self.cashbackValueLabel.text = "-.--€"
                    self.cashbackBaseView.isHidden = true
                }
            }
            .store(in: &self.cancellables)

        self.cashbackInfoMultipleView.didTapInfoAction = { [weak self] in
            guard let self = self else { return }
            UIView.animate(withDuration: 0.5, animations: {
                self.learnMoreBaseView.alpha = 1
            }, completion: { _ in
                UIView.animate(withDuration: 0.5, delay: 5.0) {
                    self.learnMoreBaseView.alpha = 0
                }
            })
        }

        self.cashbackInfoSingleView.didTapInfoAction = { [weak self] in
            guard let self = self else { return }
            UIView.animate(withDuration: 0.5, animations: {
                self.learnMoreBaseView.alpha = 1
            }, completion: { _ in
                UIView.animate(withDuration: 0.5, delay: 5.0) {
                    self.learnMoreBaseView.alpha = 0
                }
            })
        }

        self.placeBetBaseView.addSubview(self.learnMoreBaseView)

        NSLayoutConstraint.activate([
            self.learnMoreBaseView.bottomAnchor.constraint(equalTo: self.winningsTypeBaseView.topAnchor, constant: -1),
            self.learnMoreBaseView.trailingAnchor.constraint(equalTo: self.cashbackInfoMultipleView.trailingAnchor, constant: 10)
        ])

        self.learnMoreBaseView.didTapLearnMoreAction = { [weak self] in
            let cashbackInfoViewController = CashbackInfoViewController()
            self?.navigationController?.pushViewController(cashbackInfoViewController, animated: true)
        }

        self.learnMoreBaseView.alpha = 0

        self.isCashbackToggleOn
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isCashbackToggleOn in

                if isCashbackToggleOn {
                    self?.cashbackValueLabel.textColor = UIColor.App.highlightPrimary
                    self?.amountBaseView.layer.borderColor = UIColor.App.highlightPrimary.cgColor
                    self?.secondaryAmountBaseView.layer.borderColor = UIColor.App.highlightPrimary.cgColor
                }
                else {
                    self?.cashbackValueLabel.textColor = UIColor.App.textPrimary
                    if self?.isKeyboardShowingPublisher.value ?? false {
                        self?.amountBaseView.layer.borderColor = UIColor.App.inputBorderActive.cgColor
                        self?.secondaryAmountBaseView.layer.borderColor = UIColor.App.inputBorderActive.cgColor
                    }
                    else {
                        self?.amountBaseView.layer.borderColor = UIColor.App.backgroundBorder.cgColor
                        self?.secondaryAmountBaseView.layer.borderColor = UIColor.App.backgroundBorder.cgColor
                    }
                }

                self?.tableView.reloadData()
            }
            .store(in: &self.cancellables)

        Publishers.CombineLatest(self.isCashbackToggleOn, Env.userSessionStore.userCashbackBalance)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isCashbackToggleOn, userCashbackBalance in
                guard let self = self else { return }

                if isCashbackToggleOn, let cashbackBalance = userCashbackBalance {
                    self.displayBetValue = Int(cashbackBalance * 100.0)
                    self.amountTextfield.text = CurrencyFormater.defaultFormat.string(from: NSNumber(value: cashbackBalance))
                    self.secondaryAmountTextfield.text = CurrencyFormater.defaultFormat.string(from: NSNumber(value: cashbackBalance))

                    if self.singleBettingTicketDataSource.bettingTickets.count == 1,
                       let firstBetTicket = self.singleBettingTicketDataSource.bettingTickets.first,
                       let cashbackBalance = userCashbackBalance {
                        self.simpleBetsBettingValues.send([firstBetTicket.id: cashbackBalance])
                    }
                }
                else {
                    self.displayBetValue = 0
                    self.amountTextfield.text = CurrencyFormater.defaultFormat.string(from: NSNumber(value: self.realBetValue))
                    self.secondaryAmountTextfield.text = CurrencyFormater.defaultFormat.string(from: NSNumber(value: self.realBetValue))

                    if self.singleBettingTicketDataSource.bettingTickets.count == 1 {
                        self.simpleBetsBettingValues.send([:])
                    }
                }
                self.tableView.reloadData()
            }
            .store(in: &self.cancellables)

        //
        // Format the label with the value
        self.cashbackResultValuePublisher
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] cashbackResultValue in
                if let cashbackResultValue = cashbackResultValue {
                    let cashbackString = CurrencyFormater.defaultFormat.string(from: NSNumber(value: cashbackResultValue)) ?? localized("no_value")
                    self?.cashbackInfoMultipleValueLabel.text = cashbackString
                }
                else {
                    self?.cashbackInfoMultipleValueLabel.text = localized("no_value")
                }
            }
            .store(in: &self.cancellables)

        //
        // Check all the conditions for the cashback value and tooltip visibility
        let cashbackPublishers = Publishers.CombineLatest(self.cashbackResultValuePublisher, self.isCashbackToggleOn)
        Publishers.CombineLatest4(cashbackPublishers,
                                  self.realBetValuePublisher,
                                  Env.betslipManager.bettingTicketsPublisher.removeDuplicates(),
                                 Env.betslipManager.hasLiveTicketsPublisher.removeDuplicates())
            .map { cashbackPublishers, bettingValue, bettingTickets, hasLiveTickets -> Bool in

                let (cashbackValue, isCashbackOn) = cashbackPublishers

                let bettingTicketsSports = bettingTickets.map(\.sport)
                let allSportsPresent = !bettingTicketsSports.contains(nil)
                let validMatchesList = bettingTicketsSports
                    .compactMap({ $0 })
                    .map(RePlayFeatureHelper.shouldShowRePlay(forSport:))
                    .allSatisfy { $0 }

                return (cashbackValue ?? 0.0) > 0.0 && !isCashbackOn && bettingValue > 0 && allSportsPresent && validMatchesList && !hasLiveTickets
            }
            .receive(on: DispatchQueue.main)
            .sink {  [weak self] validMatchesList in
                self?.showCashbackValues = validMatchesList
            }
            .store(in: &self.cancellables)

    }

    func saveUserSettings(acceptingAnyReofferOnBetPlace: Bool) {
        let betslipSettings = ServicesProvider.BetslipSettings.init(acceptingAnyReoffer: acceptingAnyReofferOnBetPlace)
        Env.servicesProvider
            .updateBetslipSettings(betslipSettings)
            .sink { completed in
                print("ServicesProvider updateBetslipSettings \(completed)")
            }
            .store(in: &self.cancellables)
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

    @objc func dismissKeyboard() {
        self.amountTextfield.resignFirstResponder()
        self.secondaryAmountTextfield.resignFirstResponder()
    }

    @IBAction private func didTapSettingsButton() {
        self.showingSettingsSelector = true
    }

    @IBAction private func didTapClearButton() {
        Env.betslipManager.clearAllBettingTickets()

        // self.suggestedBetsListViewController?.refreshSuggestedBets()
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

        self.saveUserSettings(acceptingAnyReofferOnBetPlace: self.acceptingAnyReofferOnBetPlace)
    }

    func requestMultipleBetReturn() {

        let stake = self.realBetValue
        Env.betslipManager.requestMultipleBetPotentialReturn(withSkateAmount: stake)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                switch completion {
                case .finished:
                    ()
                case .failure(let error): // Error, clear previous info
                    print("requestMultipleBetPotentialReturn \(error)")
                    self?.multipleWinningsValueLabel.text = localized("no_value")
                    self?.secondaryMultipleWinningsValueLabel.text = localized("no_value")
                }
            } receiveValue: { [weak self] betPotencialReturn in
                self?.configureWithMultiplePotencialReturn(betPotencialReturn)
            }
            .store(in: &cancellables)

    }

    func configureWithMultiplePotencialReturn(_ betPotencialReturn: BetPotencialReturn) {

        let multiTicketsOdd = Env.betslipManager.bettingTicketsPublisher.value.map(\.decimalOdd).reduce(1.0, *)
        self.configureWithMultipleTotalOdd(multiTicketsOdd)

        let possibleWinningsString = CurrencyFormater.defaultFormat.string(from: NSNumber(value: betPotencialReturn.potentialReturn)) ?? localized("no_value")
        self.multipleWinningsValueLabel.text = possibleWinningsString
        self.secondaryMultipleWinningsValueLabel.text = possibleWinningsString

    }

    func configureWithMultipleTotalOdd(_ totalOdd: Double) {
//        self.multipleOddsValueLabel.text = OddConverter.stringForValue(totalOdd, format: UserDefaults.standard.userOddsFormat)
//        self.secondaryMultipleOddsValueLabel.text = OddConverter.stringForValue(totalOdd, format: UserDefaults.standard.userOddsFormat)
        self.multipleOddsValueLabel.text = OddFormatter.formatOdd(withValue: totalOdd)
        self.secondaryMultipleOddsValueLabel.text = OddFormatter.formatOdd(withValue: totalOdd)
    }

    func requestSystemBetInfo() {

        guard
            let selectedSystemBetType = self.selectedSystemBetType
        else {
            return
        }

        let stake = self.realBetValue
        Env.betslipManager.requestSystemBetPotentialReturn(withSkateAmount: stake, systemBetType: selectedSystemBetType)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                switch completion {
                case .finished:
                    ()
                case .failure(let error): // Error, clear previous info
                    print("requestSystemBetPotentialReturn \(error)")
                    self?.systemOddsValueLabel.text = localized("no_value")
                    self?.systemWinningsValueLabel.text = localized("no_value")
                    self?.secondarySystemOddsValueLabel.text = localized("no_value")
                    self?.secondarySystemWinningsValueLabel.text = localized("no_value")
                }
            } receiveValue: { [weak self] betPotencialReturn in
                self?.configureWithSystemBetPotencialReturn(betPotencialReturn)
            }
            .store(in: &cancellables)

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

    }

    func requestCashbackResult() {

        let stake = self.realBetValue

        if self.isCashbackToggleOn.value || stake <= 0.0 {
            // We can ignore the request if the cashback wallet amount is being used
            self.cashbackResultValuePublisher.send(nil)
            return
        }

        Env.betslipManager.requestCalculateCashback(stakeValue: stake)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                switch completion {
                case .finished:
                    ()
                case .failure:
                    self?.cashbackResultValuePublisher.send(nil)
                }
            } receiveValue: { [weak self] cashbackResult in
                self?.cashbackResultValuePublisher.send(cashbackResult.amount)
            }
            .store(in: &cancellables)
    }

    @IBAction private func didTapDoneButton() {
        self.dismissKeyboard()
    }

    @IBAction private func didTapPlaceBetButton() {

        self.isLoading = true
        if Env.userSessionStore.isUserLogged() {

            if self.isCashbackToggleOn.value, let cashbackValue = Env.userSessionStore.userCashbackBalance.value {
                if self.realBetValue > cashbackValue {
                    let errorMessage = localized("betslip_replay_error")
                    self.showErrorView(errorMessage: errorMessage)
                    self.isLoading = false
                    return
                }
            }

            //
            if self.listTypePublisher.value == .simple {
                var isFreeBet = false

                if self.isFreebetEnabled.value == true || self.isCashbackToggleOn.value == true {
                    isFreeBet = true
                }

                let singleBetTicketStakes = self.simpleBetsBettingValues.value
                
                let totalValue = singleBetTicketStakes.values.reduce(0.0, +)
                
                if totalValue > self.maxBetValue {
                    self.showErrorView(errorMessage: localized("deposit_more_funds"))
                    self.isLoading = false
                    return
                }
                
                Env.betslipManager.placeSingleBets(amounts: singleBetTicketStakes, useFreebetBalance: isFreeBet)
                .receive(on: DispatchQueue.main)
                .sink { [weak self] completion in
                    switch completion {
                    case .failure(let error):
                        var message = ""
                        switch error {
                        case .betPlacementDetailedError(let detailedMessage):
                            message = detailedMessage
                        default:
                            message = localized("error_placing_bet")
                        }
                        self?.showErrorView(errorMessage: message)
                    default: ()
                    }
                    self?.isLoading = false
                } receiveValue: { [weak self] betPlacedDetailsArray in

                    if let cashbackSelected = self?.isCashbackToggleOn.value {

                        if !cashbackSelected {
                            self?.betPlacedAction(betPlacedDetailsArray, nil, false)
                        }
                        else {
                            self?.betPlacedAction(betPlacedDetailsArray, nil, true)
                        }
                    }
                    else {
                        self?.betPlacedAction(betPlacedDetailsArray, nil, false)
                    }
                }
                .store(in: &cancellables)
            }
            else if self.listTypePublisher.value == .multiple {

                if self.realBetValue > self.maxBetValue {
                    self.showErrorView(errorMessage: localized("deposit_more_funds"))
                    self.isLoading = false
                    return
                }
                
                var isFreeBet = false

                if self.isFreebetEnabled.value == true || self.isCashbackToggleOn.value == true {
                    isFreeBet = true
                }

                Env.betslipManager.placeMultipleBet(withStake: self.realBetValue, useFreebetBalance: isFreeBet)
                    .receive(on: DispatchQueue.main)
                    .sink { [weak self] completion in
                        switch completion {
                        case .failure(let error):
                            var message = ""
                            switch error {
                            case .betPlacementDetailedError(let detailedMessage):
                                message = detailedMessage
                            default:
                                message = localized("error_placing_bet")
                            }
                            self?.showErrorView(errorMessage: message)
                        default: ()
                        }
                        self?.isLoading = false
                    } receiveValue: { [weak self] betPlacedDetails in
                        if let cashbackSelected = self?.isCashbackToggleOn.value {

                            if !cashbackSelected {
                                self?.betPlacedAction(betPlacedDetails, self?.cashbackResultValuePublisher.value, false)
                            }
                            else {
                                self?.betPlacedAction(betPlacedDetails, nil, true)
                            }
                        }
                        else {
                            self?.betPlacedAction(betPlacedDetails, nil, false)
                        }
                    }
                    .store(in: &cancellables)
            }
            else if self.listTypePublisher.value == .system, let selectedSystemBetType = self.selectedSystemBetType {
               
                if self.realBetValue > self.maxBetValue {
                    self.showErrorView(errorMessage: localized("deposit_more_funds"))
                    self.isLoading = false
                    return
                }
                
                var isFreeBet = false

                if self.isFreebetEnabled.value == true || self.isCashbackToggleOn.value == true {
                    isFreeBet = true
                }

                Env.betslipManager.placeSystemBet(withStake: self.realBetValue,
                                                  systemBetType: selectedSystemBetType,
                                                  useFreebetBalance: isFreeBet)
                    .receive(on: DispatchQueue.main)
                    .sink { [weak self] completion in
                        switch completion {
                        case .failure(let error):
                            var message = ""
                            switch error {
                            case .betPlacementDetailedError(let detailedMessage):
                                message = detailedMessage
                            default:
                                message = localized("error_placing_bet")
                            }
                            self?.showErrorView(errorMessage: message)
                        default: ()
                        }
                        self?.isLoading = false
                    } receiveValue: { [weak self] betPlacedDetails in

                        if let cashbackSelected = self?.isCashbackToggleOn.value {

                            if !cashbackSelected {
                                self?.betPlacedAction(betPlacedDetails, nil, false)
                            }
                            else {
                                self?.betPlacedAction(betPlacedDetails, nil, true)
                            }
                        }
                        else {
                            self?.betPlacedAction(betPlacedDetails, nil, false)
                        }
                        // self?.betPlacedAction(betPlacedDetails, nil, false)
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

    @objc private func onFreebetSwitchValueChanged(_ freeBetSwitch: UISwitch) {
        self.isFreebetEnabled.send(freeBetSwitch.isOn)
    }

    @objc private func cashbackSwitchValueChanged(_ cashbackSwitch: UISwitch) {
        self.isCashbackToggleOn.send(cashbackSwitch.isOn)
    }

    @IBAction private func didTapCloseFreebetButton() {
        self.freeBetSwitch.isOn = false
        self.isFreebetEnabled.send(false)

        self.isFreebetDismissed = true
    }

    @IBAction private func didTapPlusOneButton() {
        self.addAmountValue(10.0)
    }

    @IBAction private func didTapPlusFiveButton() {
        self.addAmountValue(20.0)
    }

    @IBAction private func didTapPlusMaxButton() {
        self.addAmountValue(50.0)
    }

}

extension PreSubmissionBetslipViewController: UITextFieldDelegate {

    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if self.isFreebetEnabled.value || self.isCashbackToggleOn.value {
            self.amountBaseView.layer.borderColor = UIColor.App.highlightPrimary.cgColor
            self.secondaryAmountBaseView.layer.borderColor = UIColor.App.highlightPrimary.cgColor
            return true // If the isFreebetEnabled the border should stay orange
        }

        if textField == self.amountTextfield {
            self.amountBaseView.layer.borderColor = UIColor.App.inputBorderActive.cgColor
        }
        else if textField == self.secondaryAmountTextfield {
            self.secondaryAmountBaseView.layer.borderColor = UIColor.App.inputBorderActive.cgColor
        }
        return true
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        if self.isFreebetEnabled.value || self.isCashbackToggleOn.value {
            self.amountBaseView.layer.borderColor = UIColor.App.highlightPrimary.cgColor
            self.secondaryAmountBaseView.layer.borderColor = UIColor.App.highlightPrimary.cgColor
            return // If the isFreebetEnabled the border should stay orange
        }

        if textField == self.amountTextfield {
            self.amountBaseView.layer.borderColor = UIColor.App.inputBorderActive.cgColor
        }
        else if textField == self.secondaryAmountTextfield {
            self.secondaryAmountBaseView.layer.borderColor = UIColor.App.inputBorderActive.cgColor
        }
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        if self.isFreebetEnabled.value || self.isCashbackToggleOn.value {
            self.amountBaseView.layer.borderColor = UIColor.App.highlightPrimary.cgColor
            self.secondaryAmountBaseView.layer.borderColor = UIColor.App.highlightPrimary.cgColor
            return // If the isFreebetEnabled the border should stay orange
        }

//        if self.isCashbackToggleOn.value {
//            self.amountBaseView.layer.borderColor = UIColor.App.highlightPrimary.cgColor
//            self.secondaryAmountBaseView.layer.borderColor = UIColor.App.highlightPrimary.cgColor
//            return
//        }

        if textField == self.amountTextfield {
            self.amountBaseView.layer.borderColor = UIColor.App.backgroundBorder.cgColor
        }
        else if textField == self.secondaryAmountTextfield {
            self.secondaryAmountBaseView.layer.borderColor = UIColor.App.backgroundBorder.cgColor
        }
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        self.updateAmountDigit(string)
      
        return false
    }

    private  func addAmountValue(_ value: Double, isMax: Bool = false) {
        if !isMax {
            displayBetValue += Int(value * 100.0)
        }
        else {
            displayBetValue = Int(value * 100.0)
        }

        let calculatedAmount = Double(displayBetValue/100) + Double(displayBetValue%100)/100
        amountTextfield.text = CurrencyFormater.defaultFormat.string(from: NSNumber(value: calculatedAmount))
        secondaryAmountTextfield.text = CurrencyFormater.defaultFormat.string(from: NSNumber(value: calculatedAmount))
    }

    private func updateAmountDigit(_ newValue: String) {
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
            return self.betslipSettingsSelectorList.count
        }
    }

    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        if pickerView.tag == 1 {
            let optionName = self.systemBetOptions[safe: row]?.name ?? localized("system_bet")

            let normalizedOptionName = optionName.replacingOccurrences(of: "[^a-zA-Z0-9]", with: "_", options: .regularExpression).lowercased()

            let optionKeyName = "allowed_bet_types_\(normalizedOptionName)"

            let optionKey = localized(optionKeyName)

            let name = "\(optionKey) x\(self.systemBetOptions[safe: row]?.numberOfBets ?? 0)"
            // let name = "\(self.systemBetOptions[safe: row]?.name ?? "--") x\(self.systemBetOptions[safe: row]?.numberOfBets ?? 0)"
            return NSAttributedString(string: name,
                                      attributes: [NSAttributedString.Key.foregroundColor: UIColor.App.textPrimary])
        }
        else {
            return NSAttributedString(string: self.betslipSettingsSelectorList[safe: row]?.localizedDescription ?? "--",
                                      attributes: [NSAttributedString.Key.foregroundColor: UIColor.App.textPrimary])
        }
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView.tag == 1 {
            self.selectedSystemBetType = self.systemBetOptions[safe: row]
        }
        else {
            let value = self.betslipSettingsSelectorList[safe: row]?.key

            if value == "ACCEPT_HIGHER" {
                self.acceptingAnyReofferOnBetPlace = false
            }
            else if value == "ACCEPT_ANY" {
                self.acceptingAnyReofferOnBetPlace = true
            }
            else {
                self.acceptingAnyReofferOnBetPlace = false
            }
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

    var shouldHighlightTextfield: () -> Bool = { return false }

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
        let bettingAmount = self.bettingValueForId?(bettingTicket.id)

        let shouldHighlightTextfield = self.shouldHighlightTextfield()
        cell.configureWithBettingTicket(bettingTicket,
                                        previousBettingAmount: bettingAmount,
                                        shouldHighlightTextfield: shouldHighlightTextfield)

        cell.didUpdateBettingValueAction = self.didUpdateBettingValueAction
        cell.shouldHighlightTextfield = { [weak self] in
            return self?.shouldHighlightTextfield() ?? false
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
            cell.configureWithBettingTicket(bettingTicket)
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

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
import Lottie
import Extensions

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

    @IBOutlet private weak var mixMatchWinningsBaseView: UIView!
    @IBOutlet private weak var mixMatchWinningsSeparatorView: UIView!
    @IBOutlet private weak var mixMatchWinningsTitleLabel: UILabel!
    @IBOutlet private weak var mixMatchWinningsValueLabel: UILabel!
    @IBOutlet private weak var mixMatchOddsTitleLabel: UILabel!
    @IBOutlet private weak var mixMatchOddsValueLabel: UILabel!

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
    @IBOutlet private weak var cashbackInfoTriggerView: UIImageView!
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

    @IBOutlet private weak var spinWheelButton: UIButton!
    
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

    @IBOutlet private weak var secondaryMixMatchWinningsBaseView: UIView!
    @IBOutlet private weak var secondaryMixMatchWinningsValueLabel: UILabel!
    @IBOutlet private weak var secondaryMixMatchOddsTitleLabel: UILabel!
    @IBOutlet private weak var secondaryMixMatchWinningsTitleLabel: UILabel!
    @IBOutlet private weak var secondaryMixMatchOddsValueLabel: UILabel!
    @IBOutlet private weak var secondaryMixMatchWinningsSeparatorView: UIView!

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

    private var betBuilderWarningView: BetslipErrorView = BetslipErrorView()

    // Custom views
    lazy var learnMoreBaseView: CashbackLearnMoreView = {
        let view = CashbackLearnMoreView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    lazy var cashbackCoinAnimationView: LottieAnimationView = {
        let animationView = LottieAnimationView()
        animationView.translatesAutoresizingMaskIntoConstraints = false
        animationView.contentMode = .scaleAspectFit

        let startAnimation = LottieAnimation.named("replay_coin")

        animationView.animation = startAnimation
        animationView.loopMode = .playOnce

        animationView.alpha = 0
        return animationView
    }()

    lazy var flipNumberView: FlipNumberView = {
        let view = FlipNumberView(hasCommaSeparator: true, hasMultipleThemes: true)
        view.setNumber(0.01, animated: false)
        view.setNumber(0.00, animated: false)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    lazy var currencyTypeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = Env.userSessionStore.userProfilePublisher.value?.currency
        label.font = AppFont.with(type: .bold, size: 14)
        return label
    }()
    
    lazy var cashbackInfoDialogView: InfoDialogView = {
        let view = InfoDialogView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.configure(title: localized("betsson_credits_dialog_info"))
        return view
    }()

    @IBOutlet private weak var secondPlaceBetBaseViewConstraint: NSLayoutConstraint!

    //
    //
    private var suggestedBetsListViewController: SuggestedBetsListViewController?

    private var singleBettingTicketDataSource = SingleBettingTicketDataSource.init(bettingTickets: [])
    private var multipleBettingTicketDataSource = MultipleBettingTicketDataSource.init(bettingTickets: [])
    private var systemBettingTicketDataSource = SystemBettingTicketDataSource(bettingTickets: [])
    private var betBuilderBettingTicketDataSource = BetBuilderBettingTicketDataSource(bettingTickets: [])

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

    enum BetslipType: CaseIterable {
        case simple
        case multiple
        case system
        case betBuilder

        var title: String {
            switch self {
            case .simple:
                return localized("single")
            case .multiple:
                return localized("multiple")
            case .system:
                return localized("system")
            case .betBuilder:
                return localized("mix_match_mix_string") + localized("mix_match_match_string")
            }
        }
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
    private var betValueSubject: CurrentValueSubject<Double, Never> = .init(0.0)

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

    var betslipOddChangeSettingMode: BetslipOddChangeSettingMode = .bothGameStatus
    var betslipOddChangeSetting: BetslipOddChangeSetting = .none

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

        self.cashbackInfoSingleBaseView.isHidden = true // Singles don't have cashback anymore
        self.cashbackInfoMultipleBaseView.isHidden = true

        self.showCashbackValues = false

        self.simpleWinningsBaseView.isHidden = false
        self.multipleWinningsBaseView.isHidden = true
        self.systemWinningsBaseView.isHidden = true
        self.mixMatchWinningsBaseView.isHidden = true

        self.loadingView.alpha = 0.0
        self.loadingView.stopAnimating()
        self.loadingBaseView.isHidden = true
        self.addChildViewController(self.loadingSpinnerViewController, toView: self.loadingBaseView)

        self.view.bringSubviewToFront(systemBetTypeSelectorBaseView)
        self.view.bringSubviewToFront(settingsPickerBaseView)
        self.view.bringSubviewToFront(emptyBetsBaseView)
        self.view.bringSubviewToFront(loadingBaseView)

        self.betTypeSegmentControlView = SegmentControlView(
            options: BetslipType.allCases.map(\.title),
            customItemAttributedString: { index in
                if index == 3 {
                    let mixString = localized("mix_match_mix_string") // Mix
                    let matchString = localized("mix_match_match_string") // Match
                    let fullString = mixString + matchString

                    // Create an NSMutableAttributedString from the full string
                    let attributedString = NSMutableAttributedString(string: fullString)
                    let mixAttributes: [NSAttributedString.Key: Any] = [
                        .foregroundColor: UIColor.App.highlightPrimary
                    ]
                    let matchAttributes: [NSAttributedString.Key: Any] = [
                        .foregroundColor: UIColor.App.textPrimary
                    ]
                    attributedString.addAttributes(mixAttributes, range: NSRange(location: 0, length: mixString.count))
                    attributedString.addAttributes(matchAttributes, range: NSRange(location: mixString.count, length: matchString.count))
                    return attributedString
                }
                return nil
            },
            customItemLeftAccessoryImage: { index in
                if index == 3 {
                    return UIImage(named: "mix_match_icon")
                }
                return nil
            }
        )

        self.betTypeSegmentControlView?.translatesAutoresizingMaskIntoConstraints = false
        self.betTypeSegmentControlView?.didSelectItemAtIndexAction = { [weak self] index in
            self?.didChangeSelectedSegmentItem(toIndex: index)
        }

        self.betTypeSegmentControlBaseView.addSubview(self.betTypeSegmentControlView!)
        NSLayoutConstraint.activate([
            self.betTypeSegmentControlView!.centerXAnchor.constraint(equalTo: self.betTypeSegmentControlBaseView.centerXAnchor),
            self.betTypeSegmentControlView!.centerYAnchor.constraint(equalTo: self.betTypeSegmentControlBaseView.centerYAnchor),
        ])

        //
        self.betBuilderWarningView = BetslipErrorView()
        self.betBuilderWarningView.isHidden = true
        self.betBuilderWarningView.alpha = 0.0
        self.betBuilderWarningView.setDescription(localized("error"))

        self.betBuilderWarningView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(self.betBuilderWarningView)

        NSLayoutConstraint.activate([
            self.betBuilderWarningView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
            self.betBuilderWarningView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor),
            self.betBuilderWarningView.bottomAnchor.constraint(equalTo: self.placeBetBaseView.safeAreaLayoutGuide.topAnchor, constant: -10)
        ])
        
        self.cashbackInfoTriggerView.image = UIImage(named: "info_small_icon")?.withRenderingMode(.alwaysTemplate)
        self.cashbackInfoTriggerView.setTintColor(color: UIColor.App.iconPrimary)
        self.cashbackInfoTriggerView.isUserInteractionEnabled = true
        
        let cashbackInfoTriggerTap = UITapGestureRecognizer(target: self, action: #selector(didTapCashbackInfoTriggerView))

        self.cashbackInfoTriggerView.addGestureRecognizer(cashbackInfoTriggerTap)
        
        self.view.addSubview(self.cashbackInfoDialogView)

        NSLayoutConstraint.activate([

            self.cashbackInfoDialogView.bottomAnchor.constraint(equalTo: self.cashbackBaseView.topAnchor, constant: -10),
            self.cashbackInfoDialogView.trailingAnchor.constraint(equalTo: self.cashbackInfoTriggerView.trailingAnchor, constant: 10),
            self.cashbackInfoDialogView.widthAnchor.constraint(lessThanOrEqualToConstant: 186)
        ])

        self.cashbackInfoDialogView.alpha = 0
        //
        self.setupFonts()

        //
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
        self.simpleOddsTitleLabel.text = localized("total_bets")
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
        self.systemOddsTitleLabel.text = localized("total_amount")
        self.systemOddsValueLabel.text = localized("no_value")

        self.systemBetTypeTitleLabel.text = localized("system_options")

        //
        self.mixMatchWinningsValueLabel.text = localized("no_value")
        self.mixMatchOddsTitleLabel.text = localized("total_odd")
        self.mixMatchOddsValueLabel.text = localized("no_value")

        self.secondaryMixMatchWinningsValueLabel.text = localized("no_value")
        self.secondaryMixMatchOddsTitleLabel.text = localized("total_bet_amount")
        self.secondaryMixMatchOddsValueLabel.text = localized("no_value")
        //

        self.selectSystemBetTypeButton.setTitle(localized("select"), for: .normal)
        self.settingsPickerButton.setTitle(localized("select"), for: .normal)

        self.secondarySystemWinningsValueLabel.text = localized("no_value")
        self.secondarySystemOddsTitleLabel.text = localized("total_bet_amount")
        self.secondarySystemOddsValueLabel.text = localized("no_value")

        // Possible winnings title
        self.simpleWinningsTitleLabel.text = localized("possible_winnings")
        self.systemWinningsTitleLabel.text = localized("possible_winnings")
        self.multipleWinningsTitleLabel.text = localized("possible_winnings")
        self.mixMatchWinningsTitleLabel.text = localized("possible_winnings")

        self.secondaryMultipleWinningsTitleLabel.text = localized("possible_winnings")
        self.secondarySystemWinningsTitleLabel.text = localized("possible_winnings")
        self.secondaryMixMatchWinningsTitleLabel.text = localized("possible_winnings")
        //

        self.emptyBetsImageView.image = UIImage(named: "empty_betslip_icon")

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

        self.amountTextfield.text = ""
        self.secondaryAmountTextfield.text = ""

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

        let buttonFont = AppFont.with(type: .bold, size: 16)
        self.plusOneButtonView.titleLabel?.font = buttonFont
        self.plusFiveButtonView.titleLabel?.font = buttonFont
        self.maxValueButtonView.titleLabel?.font = buttonFont
        self.secondaryPlusOneButtonView.titleLabel?.font = buttonFont
        self.secondaryPlusFiveButtonView.titleLabel?.font = buttonFont
        self.secondaryMaxButtonView.titleLabel?.font = buttonFont

        // Disable settings until loaded
        self.settingsButton.isEnabled = false
        self.settingsButton.isUserInteractionEnabled = false

        // Default disable all
        self.betTypeSegmentControlView?.disableAll()

        //
        // Default cashback/replay bar base view
        self.cashbackBaseView.isHidden = true

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

                    var changeSetting: ServicesProvider.BetslipOddChangeSetting = .none

                    if let oddChangeRunningOrPreMatch = betslipSettingsValue.oddChangeRunningOrPreMatch {
                        changeSetting  = oddChangeRunningOrPreMatch
                        self?.betslipOddChangeSettingMode = .bothGameStatus
                    }
                    else if let oddChangeLegacy = betslipSettingsValue.oddChangeLegacy {
                        changeSetting  = oddChangeLegacy
                        self?.betslipOddChangeSettingMode = .legacy
                    }

                    switch changeSetting {
                    case .none:
                        self?.betslipOddChangeSetting = .none
                        self?.settingsPickerView.selectRow(0, inComponent: 0, animated: false)
                    case .higher:
                        self?.betslipOddChangeSetting = .higher
                        self?.settingsPickerView.selectRow(1, inComponent: 0, animated: false)
                    }

                    self?.settingsButton.isEnabled = true
                    self?.settingsButton.isUserInteractionEnabled = true
                }
                else {
                    self?.betslipOddChangeSetting = .none
                    self?.settingsPickerView.selectRow(0, inComponent: 0, animated: false)

                    self?.settingsButton.isEnabled = false
                    self?.settingsButton.isUserInteractionEnabled = false
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
                self?.refreshBetBuilderExpectedReturn()
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
                self?.betBuilderBettingTicketDataSource.bettingTickets = tickets

                self?.simpleOddsValueLabel.text = "\(tickets.count)"

                if tickets.isEmpty {
                    self?.betBuilderWarningView.setDescription("")
                    self?.betBuilderWarningView.alpha = 0.0
                }

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
                let ticketsMatches = betTickets.map(\.matchId)
                let sameMatchBets = ticketsMatches.count != Set(ticketsMatches).count

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
                else if betTickets.count > 1, sameMatchBets {
                    self?.betTypeSegmentControlView?.setSelectedItem(atIndex: 3, animated: true)
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

                self?.betTypeSegmentControlView?.setEnabledItem(atIndex: 3, isEnabled: true)
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

        //        Env.betslipManager.bettingTicketsPublisher
        //            .receive(on: DispatchQueue.main)
        //            .map({ orderedSet -> Double in
        //                let newArray = orderedSet.map { $0.decimalOdd }
        //                let multiple: Double = newArray.reduce(1.0, *)
        //                return multiple
        //            })
        //            .sink(receiveValue: { [weak self] multiplier in
        //                self?.configureWithMultipleTotalOdd(multiplier)
        //            })
        //            .store(in: &cancellables)

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
                    self?.mixMatchWinningsBaseView.isHidden = true

                    self?.betBuilderWarningView.isHidden = true

//                    if let cashbackEnabled = self?.isCashbackEnabled,
//                       cashbackEnabled,
//                       let cashbackValue = Env.userSessionStore.userCashbackBalance.value {
//
//                        if cashbackValue > 0 {
//                            self?.cashbackBaseView.isHidden = false
//                        }
//                        else {
//                            self?.cashbackBaseView.isHidden = true
//                        }
//                    }
                    if let cashbackEnabled = self?.isCashbackEnabled,
                       cashbackEnabled {
                        
                        let cashbackValue = Env.userSessionStore.userCashbackBalance.value ?? 0.0
                        let freeBetValue = Env.userSessionStore.userFreeBetBalance.value ?? 0.0
                        
                        if cashbackValue > 0 || freeBetValue > 0 {
                            self?.cashbackBaseView.isHidden = false
                        } else {
                            self?.cashbackBaseView.isHidden = true
                        }
                    }

                case .multiple:
                    self?.simpleWinningsBaseView.isHidden = true
                    self?.multipleWinningsBaseView.isHidden = false
                    self?.systemWinningsBaseView.isHidden = true
                    self?.mixMatchWinningsBaseView.isHidden = true

                    self?.betBuilderWarningView.isHidden = true

                    if let cashbackEnabled = self?.isCashbackEnabled,
                       cashbackEnabled {
                        
                        let cashbackValue = Env.userSessionStore.userCashbackBalance.value ?? 0.0
                        let freeBetValue = Env.userSessionStore.userFreeBetBalance.value ?? 0.0
                        
                        if cashbackValue > 0 || freeBetValue > 0 {
                            self?.cashbackBaseView.isHidden = false
                        } else {
                            self?.cashbackBaseView.isHidden = true
                        }
                    }
                    
                case .system:
                    self?.simpleWinningsBaseView.isHidden = true
                    self?.multipleWinningsBaseView.isHidden = true
                    self?.systemWinningsBaseView.isHidden = false
                    self?.mixMatchWinningsBaseView.isHidden = true

                    self?.betBuilderWarningView.isHidden = true

                    if let cashbackEnabled = self?.isCashbackEnabled,
                       cashbackEnabled {
                        
                        let cashbackValue = Env.userSessionStore.userCashbackBalance.value ?? 0.0
                        let freeBetValue = Env.userSessionStore.userFreeBetBalance.value ?? 0.0
                        
                        if cashbackValue > 0 || freeBetValue > 0 {
                            self?.cashbackBaseView.isHidden = false
                        } else {
                            self?.cashbackBaseView.isHidden = true
                        }
                    }

                case .betBuilder:
                    self?.simpleWinningsBaseView.isHidden = true
                    self?.multipleWinningsBaseView.isHidden = true
                    self?.systemWinningsBaseView.isHidden = true

                    self?.mixMatchWinningsBaseView.isHidden = false

                    self?.betBuilderWarningView.isHidden = false
                    
                    if let cashbackEnabled = self?.isCashbackEnabled,
                       cashbackEnabled {
                        
                        let cashbackValue = Env.userSessionStore.userCashbackBalance.value ?? 0.0
                        let freeBetValue = Env.userSessionStore.userFreeBetBalance.value ?? 0.0
                        
                        if cashbackValue > 0 || freeBetValue > 0 {
                            self?.cashbackBaseView.isHidden = false
                        } else {
                            self?.cashbackBaseView.isHidden = true
                        }
                    }
                }
            })
            .store(in: &self.cancellables)

        let debounceRealValuePublisher = self.betValueSubject.debounce(for: .milliseconds(400), scheduler: DispatchQueue.main)

        Publishers.CombineLatest(debounceRealValuePublisher, self.listTypePublisher)
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
                    
                    self?.systemWinningsValueLabel.text = localized("no_value")
                    self?.secondarySystemWinningsValueLabel.text = localized("no_value")
                }

                self?.placeBetButton.isEnabled = hasValidBettingValue
            })
            .store(in: &self.cancellables)

        //
        // BetBuilder logic
        Publishers.CombineLatest3(debounceRealValuePublisher, self.listTypePublisher, Env.betslipManager.bettingTicketsPublisher)
            .filter({ _, listTypePublisher, _ -> Bool in
                return listTypePublisher == .betBuilder
            })
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] bettingValue, listTypePublisher, bettingTickets in
                
                let ticketsMatches = bettingTickets.map(\.matchId)
//                let allBetsSameMatch = Set(ticketsMatches).count == 1

                let hasValidBettingValue = bettingValue > 0.0 /*&& allBetsSameMatch*/
                if hasValidBettingValue {
                    self?.refreshBetBuilderExpectedReturn()
                    self?.requestCashbackResult()
                }
                else {

                    self?.mixMatchWinningsValueLabel.text = localized("no_value")
                    self?.secondaryMixMatchWinningsValueLabel.text = localized("no_value")
                }

            })
            .store(in: &self.cancellables)

        // PlaceBetButton for betBuilder
        Publishers.CombineLatest3(debounceRealValuePublisher, self.listTypePublisher, Env.betslipManager.bettingTicketsPublisher)
            .filter({ _, listTypePublisher, _ -> Bool in
                return listTypePublisher == .betBuilder
            })
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] bettingValue, listTypePublisher, bettingTickets in
                let ticketsMatches = bettingTickets.map(\.matchId)
                
                let hasValidBettingValue = bettingValue > 0.0
                
                self?.placeBetButton.isEnabled = hasValidBettingValue
            })
            .store(in: &self.cancellables)
        
        //
        //
        Publishers.CombineLatest4(self.listTypePublisher,
                                  self.simpleBetsBettingValues,
                                  Env.betslipManager.bettingTicketsPublisher,
                                  self.isCashbackToggleOn)
            .receive(on: DispatchQueue.main)
            .filter { betslipType, _, _, _ in
                betslipType == .simple
            }
            .map({ [weak self] _, simpleBetsBettingValues, tickets, isCashbackToggleOn -> String in
                
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
                            var expectedTicketReturn = ticket.decimalOdd * betValue
                            if isCashbackToggleOn {
                                expectedTicketReturn -= betValue
                            }
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
                    self?.secondaryMixMatchWinningsBaseView.isHidden = true
                case (.system, true):
                    self?.secondaryPlaceBetBaseView.isHidden = false
                    self?.secondaryMultipleWinningsBaseView.isHidden = true
                    self?.secondarySystemWinningsBaseView.isHidden = false
                    self?.secondaryMixMatchWinningsBaseView.isHidden = true
                case (.betBuilder, true):
                    self?.secondaryPlaceBetBaseView.isHidden = false
                    self?.secondaryMultipleWinningsBaseView.isHidden = true
                    self?.secondarySystemWinningsBaseView.isHidden = true
                    self?.secondaryMixMatchWinningsBaseView.isHidden = false
                default:
                    self?.secondaryPlaceBetBaseView.isHidden = true
                }
            })
            .store(in: &self.cancellables)

        self.multipleBettingTicketDataSource.changedFreebetSelectionState = { [weak self] freeBetMultiple in

            guard let self = self else { return }

            if let freeBet = freeBetMultiple {
                self.freeBetSelected = freeBet
                self.betValueSubject.send(freeBet.freeBetAmount)
                self.amountTextfield.text = String(format: "%.2f", freeBet.freeBetAmount) // CurrencyFormater.defaultFormat.string(from: NSNumber(value: freeBet.freeBetAmount))
                self.secondaryAmountTextfield.text = String(format: "%.2f", freeBet.freeBetAmount) // CurrencyFormater.defaultFormat.string(from: NSNumber(value: freeBet.freeBetAmount))
                self.placeBetButtonsBaseView.isUserInteractionEnabled = false
            }
            else {
                self.freeBetSelected = nil
                self.betValueSubject.send(0)
                self.amountTextfield.text = "" // CurrencyFormater.defaultFormat.string(from: NSNumber(value: self.betValueSubject.value))
                self.secondaryAmountTextfield.text = "" // CurrencyFormater.defaultFormat.string(from: NSNumber(value: self.betValueSubject.value))
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

        //
        // BetBuilder
        //
        Env.betslipManager.betBuilderProcessor.invalidTicketsPublisher
            .map({ tickets in
                return tickets.map(\.id)
            })
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] invalidTicketIds in
                self?.betBuilderBettingTicketDataSource.invalidBettingTicketIds = invalidTicketIds
                self?.tableView.reloadData()
            }
            .store(in: &self.cancellables)

        //
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

        self.amountTextfield.tag = 12 // for debug only
        self.secondaryAmountTextfield.tag = 22 // for debug only

        self.amountTextfield.keyboardType = .decimalPad
        self.secondaryAmountTextfield.keyboardType = .decimalPad

        self.secondaryAmountTextfield.textPublisher
            .receive(on: DispatchQueue.main)
            .removeDuplicates()
            .sink { [weak self] amountValue in
                self?.amountTextfield.text = amountValue

                if let doubleValue = Double(amountValue.replacingOccurrences(of: ",", with: ".")) {
                    self?.betValueSubject.send(doubleValue)
                }
                else {
                    self?.betValueSubject.send(0)
                }
            }
            .store(in: &self.cancellables)

        self.setupWithTheme()

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)

        self.placeBetButton.isEnabled = false
        
        self.spinWheelButton.setTitle("Turnoyer!", for: .normal)
        self.spinWheelButton.titleLabel?.font = AppFont.with(type: .bold, size: 18)

        self.spinWheelButton.isHidden = true
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

        self.secondaryMultipleWinningsSeparatorView.backgroundColor = UIColor.App.separatorLine
        self.secondarySystemWinningsSeparatorView.backgroundColor = UIColor.App.separatorLine
        self.secondaryMixMatchWinningsSeparatorView.backgroundColor = UIColor.App.separatorLine

        self.simpleWinningsBaseView.backgroundColor = UIColor.App.backgroundPrimary
        self.simpleWinningsTitleLabel.textColor = UIColor.App.textSecondary

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

        self.mixMatchWinningsBaseView.backgroundColor = UIColor.App.backgroundPrimary
        self.mixMatchWinningsTitleLabel.textColor = UIColor.App.textSecondary
        self.mixMatchWinningsValueLabel.textColor = UIColor.App.textPrimary
        self.mixMatchOddsTitleLabel.textColor = UIColor.App.textSecondary
        self.mixMatchOddsValueLabel.textColor = UIColor.App.textPrimary

        self.secondaryMixMatchWinningsBaseView.backgroundColor = UIColor.App.backgroundPrimary
        self.secondaryMixMatchWinningsTitleLabel.textColor = UIColor.App.textDisablePrimary
        self.secondaryMixMatchWinningsValueLabel.textColor = UIColor.App.textPrimary
        self.secondaryMixMatchOddsTitleLabel.textColor = UIColor.App.textDisablePrimary
        self.secondaryMixMatchOddsValueLabel.textColor = UIColor.App.textPrimary

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

        self.cashbackCoinAnimationView.backgroundColor = .clear
        
        // Spin Wheel
        StyleHelper.styleButton(button: self.spinWheelButton)
        self.spinWheelButton.setBackgroundColor(UIColor.App.buttonBackgroundSecondary, for: .normal)

    }

    private func setupFonts() {
        // Font size 17
        self.cashbackValueLabel.font = AppFont.with(type: .bold, size: 17)
        
        // Font size 16
        let size16Labels: [UILabel] = [
            self.systemBetTypeTitleLabel,
            self.systemBetTypeLabel,
            self.systemWinningsTitleLabel,
            self.systemWinningsValueLabel,
            self.mixMatchWinningsTitleLabel,
            self.mixMatchWinningsValueLabel,
            self.multipleWinningsTitleLabel,
            self.multipleWinningsValueLabel,
            self.simpleWinningsTitleLabel,
            self.simpleWinningsValueLabel,
            self.secondarySystemWinningsTitleLabel,
            self.secondarySystemWinningsValueLabel,
            self.secondaryMultipleWinningsTitleLabel,
            self.secondaryMultipleWinningsValueLabel,
            self.secondaryMixMatchWinningsTitleLabel,
            self.secondaryMixMatchWinningsValueLabel
        ]
        size16Labels.forEach { $0.font = AppFont.with(type: .bold, size: 16) }
        
        // Font size 14
        let size14Labels: [UILabel] = [
            self.cashbackTitleLabel,
            self.cashbackInfoMultipleValueLabel,
            self.cashbackInfoSingleValueLabel
        ]
        size14Labels.forEach { $0.font = AppFont.with(type: .bold, size: 14) }
        
        // Font size 11
        let size11Labels: [UILabel] = [
            self.systemOddsTitleLabel,
            self.systemOddsValueLabel,
            self.mixMatchOddsTitleLabel,
            self.mixMatchOddsValueLabel,
            self.multipleOddsTitleLabel,
            self.multipleOddsValueLabel,
            self.simpleOddsTitleLabel,
            self.simpleOddsValueLabel,
            self.secondarySystemOddsTitleLabel,
            self.secondarySystemOddsValueLabel,
            self.secondaryMultipleOddsTitleLabel,
            self.secondaryMultipleOddsValueLabel,
            self.secondaryMixMatchOddsTitleLabel,
            self.secondaryMixMatchOddsValueLabel
        ]
        size11Labels.forEach { $0.font = AppFont.with(type: .bold, size: 11) }
    }
    private func setupCashback() {
        self.cashbackSwitch.addTarget(self, action: #selector(cashbackSwitchValueChanged(_:)), for: .valueChanged)

        self.cashbackTitleLabel.text = localized("betsson_credits_mise_max")
        self.cashbackSwitch.setOn(false, animated: false)
        self.isCashbackToggleOn.send(false)

        self.showCashbackValues = false

        //

        Publishers.CombineLatest3(Env.userSessionStore.userCashbackBalance, Env.userSessionStore.userFreeBetBalance, self.listTypePublisher)
            .filter({ _, _, listTypePublisher -> Bool in
                switch listTypePublisher {
                case .simple, .multiple, .system:
                    return true
                case .betBuilder:
                    return false
                }
            })
            .map({ userCashbackBalance, freeBetBalance, _ in
                return (userCashbackBalance, freeBetBalance)
            })
            .receive(on: DispatchQueue.main)
            .sink { completion in
                print("userSessionStore userCashbackBalance completion: \(completion)")
            } receiveValue: { [weak self] cashbackValue, freeBetValue in
                
                var displayValue: Double?
                
                if let cashbackValue = cashbackValue,
                   let freeBetValue = freeBetValue {
                    // Both values exist - use the higher one
                    displayValue = max(cashbackValue, freeBetValue)
                } else if let cashbackValue = cashbackValue {
                    // Only cashback value exists
                    displayValue = cashbackValue
                } else if let freeBetValue = freeBetValue {
                    // Only free bet balance exists
                    displayValue = freeBetValue
                }

                if let displayValue = displayValue,
                   let formattedString = CurrencyFormater.defaultFormat.string(from: NSNumber(value: displayValue)) {
                    
                    self?.cashbackValueLabel.text = formattedString
                                        
                    self?.cashbackInfoDialogView.configure(title: localized("betsson_credits_dialog_info").replacingFirstOccurrence(of: "{amount}", with: formattedString),
                                                           highlightText: formattedString)
                    
                    if displayValue <= 0 {
                        self?.cashbackBaseView.isHidden = true
                    } else {
                        self?.cashbackBaseView.isHidden = false
                    }
                } else {
                    self?.cashbackValueLabel.text = "-.--€"
                    self?.cashbackBaseView.isHidden = true
                }
            }
            .store(in: &self.cancellables)

        self.cashbackInfoMultipleView.didTapInfoAction = { [weak self] in

            UIView.animate(withDuration: 0.5, delay: 0, options: [.allowUserInteraction], animations: {
                self?.learnMoreBaseView.alpha = 1
            })

            DispatchQueue.main.asyncAfter(deadline: .now() + 5.5) {
                UIView.animate(withDuration: 0.5, delay: 0, options: [.allowUserInteraction], animations: {
                    self?.learnMoreBaseView.alpha = 0
                })
            }

        }

        self.cashbackInfoSingleView.didTapInfoAction = { [weak self] in

            UIView.animate(withDuration: 0.5, delay: 0, options: [.allowUserInteraction], animations: {
                self?.learnMoreBaseView.alpha = 1
            })

            DispatchQueue.main.asyncAfter(deadline: .now() + 5.5) {
                UIView.animate(withDuration: 0.5, delay: 0, options: [.allowUserInteraction], animations: {
                    self?.learnMoreBaseView.alpha = 0
                })
            }
        }

        self.view.addSubview(self.learnMoreBaseView)
        self.view.bringSubviewToFront(self.learnMoreBaseView)

        NSLayoutConstraint.activate([
            self.learnMoreBaseView.bottomAnchor.constraint(equalTo: self.winningsTypeBaseView.topAnchor, constant: -1),
            self.learnMoreBaseView.trailingAnchor.constraint(equalTo: self.cashbackInfoMultipleBaseView.trailingAnchor, constant: -60),
            self.learnMoreBaseView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 10)
        ])

        self.learnMoreBaseView.didTapLearnMoreAction = { [weak self] in
            let cashbackInfoViewController = CashbackInfoViewController()
            self?.navigationController?.pushViewController(cashbackInfoViewController, animated: true)
        }

        self.learnMoreBaseView.alpha = 0

        self.cashbackInfoMultipleBaseView.addSubview(self.currencyTypeLabel)
        self.cashbackInfoMultipleBaseView.addSubview(self.flipNumberView)

        self.cashbackInfoMultipleBaseView.addSubview(self.cashbackCoinAnimationView)
        self.cashbackInfoMultipleBaseView.bringSubviewToFront(self.cashbackCoinAnimationView)

        NSLayoutConstraint.activate([
            self.cashbackCoinAnimationView.widthAnchor.constraint(equalToConstant: 100),
            self.cashbackCoinAnimationView.heightAnchor.constraint(equalToConstant: 50),
            self.cashbackCoinAnimationView.bottomAnchor.constraint(equalTo: self.cashbackInfoMultipleBaseView.bottomAnchor),
            self.cashbackCoinAnimationView.centerXAnchor.constraint(equalTo: self.cashbackInfoMultipleValueLabel.centerXAnchor)

        ])

        NSLayoutConstraint.activate([
            self.currencyTypeLabel.leadingAnchor.constraint(equalTo: self.flipNumberView.trailingAnchor),
            self.currencyTypeLabel.trailingAnchor.constraint(equalTo: self.cashbackInfoMultipleBaseView.trailingAnchor, constant: -2),
            self.currencyTypeLabel.topAnchor.constraint(equalTo: self.cashbackInfoMultipleBaseView.topAnchor, constant: 5),
            self.currencyTypeLabel.bottomAnchor.constraint(equalTo: self.cashbackInfoMultipleBaseView.bottomAnchor, constant: -3)

        ])

        NSLayoutConstraint.activate([
            self.flipNumberView.leadingAnchor.constraint(equalTo: self.cashbackInfoMultipleView.trailingAnchor, constant: 5),
            //            self.flipNumberView.trailingAnchor.constraint(equalTo: self.cashbackInfoMultipleBaseView.trailingAnchor, constant: -2),
            self.flipNumberView.topAnchor.constraint(equalTo: self.cashbackInfoMultipleBaseView.topAnchor, constant: 5),
            self.flipNumberView.bottomAnchor.constraint(equalTo: self.cashbackInfoMultipleBaseView.bottomAnchor, constant: -3)

        ])

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

        Publishers.CombineLatest3(self.isCashbackToggleOn, Env.userSessionStore.userCashbackBalance, Env.userSessionStore.userFreeBetBalance)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isCashbackToggleOn, userCashbackBalance, userFreeBetBalance in
                guard let self = self else { return }

                if isCashbackToggleOn {
                    let cashbackBalance = userCashbackBalance ?? 0
                    let freeBetBalance = userFreeBetBalance ?? 0
                    let higherBalance = max(cashbackBalance, freeBetBalance)
                    
                    if self.listTypePublisher.value != .system {
                        self.betValueSubject.send(higherBalance)
                        self.amountTextfield.text = String(format: "%.2f", higherBalance) // CurrencyFormater.defaultFormat.string(from: NSNumber(value: higherBalance))
                        self.secondaryAmountTextfield.text = String(format: "%.2f", higherBalance)
                    }
                    // For system bets, send the same bet amount and re-check potential winnings
                    else {
                        let currentStake = self.betValueSubject.value
                        self.betValueSubject.send(currentStake)
                        self.amountTextfield.text = String(format: "%.2f", currentStake)
                        self.secondaryAmountTextfield.text = String(format: "%.2f", currentStake)
                    }

                    if self.singleBettingTicketDataSource.bettingTickets.count == 1,
                       let firstBetTicket = self.singleBettingTicketDataSource.bettingTickets.first {
                        self.simpleBetsBettingValues.send([firstBetTicket.id: higherBalance])
                    }
                }
                else {
                    self.betValueSubject.send(0)
                    self.amountTextfield.text = ""
                    self.secondaryAmountTextfield.text = ""

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
        let cashbackLogicPublishers = Publishers.CombineLatest4(self.cashbackResultValuePublisher,
                                                                self.isCashbackToggleOn,
                                                                self.betValueSubject,
                                                                Env.betslipManager.bettingTicketsPublisher.removeDuplicates())
            .map { cashbackValue, isCashbackOn, bettingValue, bettingTickets -> Bool in

                let bettingTicketsSports = bettingTickets.map(\.sport)
                let allSportsPresent = !bettingTicketsSports.contains(nil)
                let validMatchesList = bettingTicketsSports
                    .compactMap({ $0 })
                    .map(RePlayFeatureHelper.shouldShowRePlay(forSport:))
                    .allSatisfy { $0 }

                let validCashbackValueValid = (cashbackValue ?? 0.0) > 0.0
                let isCashbackTurnOff = !isCashbackOn
                let validBettingValue = bettingValue > 0

                let valuesJoined = validCashbackValueValid && isCashbackTurnOff && validBettingValue && allSportsPresent && validMatchesList

                return valuesJoined
            }

        // Check bettint type mode
        Publishers.CombineLatest(cashbackLogicPublishers, self.listTypePublisher)
            .receive(on: DispatchQueue.main)
            .sink {  [weak self] cashbackLogic, listType in
                switch listType {
                case .betBuilder:
                    self?.showCashbackValues = false
                case .simple, .multiple, .system:
                    self?.showCashbackValues = cashbackLogic
                }
            }
            .store(in: &self.cancellables)

        Publishers.CombineLatest(self.cashbackResultValuePublisher, self.isKeyboardShowingPublisher)
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] cashbackValue, isKeyboardShowing in

                if !isKeyboardShowing {
                    if let cashbackValue {
                        self?.cashbackCoinAnimationView.alpha = 1

                        self?.cashbackCoinAnimationView.play(completion: { _ in
                            self?.cashbackCoinAnimationView.alpha = 0
                            self?.cashbackCoinAnimationView.stop()

                        })

                        self?.flipNumberView.setNumber(cashbackValue, animated: true)
                    }
                    else {
                        self?.flipNumberView.setNumber(0.00, animated: true)
                    }
                }
            })
            .store(in: &cancellables)

    }

    func saveOddChangeUserSettings() {

        var externalSetting: ServicesProvider.BetslipOddChangeSetting = .none
        switch self.betslipOddChangeSetting {
        case .none:
            externalSetting = .none
        case .higher:
            externalSetting = .higher
        }

        var betslipSettings: ServicesProvider.BetslipSettings
        switch self.betslipOddChangeSettingMode {
        case .bothGameStatus:
            betslipSettings = ServicesProvider.BetslipSettings(oddChangeLegacy: nil,
                                                               oddChangeRunningOrPreMatch: externalSetting)
        case .legacy:
            betslipSettings = ServicesProvider.BetslipSettings(oddChangeLegacy: externalSetting,
                                                               oddChangeRunningOrPreMatch: nil)
        }

        Env.servicesProvider
            .updateBetslipSettings(betslipSettings)
            .sink { completed in
                print("ServicesProvider updateBetslipSettings \(completed)")
            }
            .store(in: &self.cancellables)
    }

    func showErrorView(errorMessage: String?, isAlertLayout: Bool = false, isFixed: Bool = false) {

        let errorView = BetslipErrorView()
        errorView.alpha = 0
        errorView.setDescription(errorMessage ?? localized("error"))

        if isAlertLayout {
            errorView.setAlertMode()
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
        case 3:
            self.listTypePublisher.value = .betBuilder
            self.userSelectedSystemBet = false
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

        self.saveOddChangeUserSettings()
    }

    func requestMultipleBetReturn() {

        let stake = self.betValueSubject.value
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
        self.multipleOddsValueLabel.text = OddFormatter.formatOdd(withValue: multiTicketsOdd)
        self.secondaryMultipleOddsValueLabel.text = OddFormatter.formatOdd(withValue: multiTicketsOdd)

        if self.isCashbackToggleOn.value {
            let freeBetPotentialReturn = betPotencialReturn.potentialReturn - betPotencialReturn.totalStake
            let possibleWinningsString = CurrencyFormater.defaultFormat.string(from: NSNumber(value: freeBetPotentialReturn)) ?? localized("no_value")
            self.multipleWinningsValueLabel.text = possibleWinningsString
            self.secondaryMultipleWinningsValueLabel.text = possibleWinningsString
        }
        else {
            let possibleWinningsString = CurrencyFormater.defaultFormat.string(from: NSNumber(value: betPotencialReturn.potentialReturn)) ?? localized("no_value")
            self.multipleWinningsValueLabel.text = possibleWinningsString
            self.secondaryMultipleWinningsValueLabel.text = possibleWinningsString
        }
    }

    func requestSystemBetInfo() {

        guard
            let selectedSystemBetType = self.selectedSystemBetType
        else {
            return
        }

        let stake = self.betValueSubject.value
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

        if self.isCashbackToggleOn.value {
            let freeBetPotentialReturn = betPotencialReturn.potentialReturn - betPotencialReturn.totalStake
            let possibleWinningsString = CurrencyFormater.defaultFormat.string(from: NSNumber(value: freeBetPotentialReturn)) ?? localized("no_value")
            self.systemWinningsValueLabel.text = possibleWinningsString
            self.secondarySystemWinningsValueLabel.text = possibleWinningsString
        }
        else {
            let possibleWinningsString = CurrencyFormater.defaultFormat.string(from: NSNumber(value: betPotencialReturn.potentialReturn)) ?? localized("no_value")
            self.systemWinningsValueLabel.text = possibleWinningsString
            self.secondarySystemWinningsValueLabel.text = possibleWinningsString
        }
        
        let totalBetAmountString = CurrencyFormater.defaultFormat.string(from: NSNumber(value: betPotencialReturn.totalStake)) ?? localized("no_value")
        self.systemOddsValueLabel.text = totalBetAmountString
        self.secondarySystemOddsValueLabel.text = totalBetAmountString

    }

    func configureWithSystemBetInfo(systemBetInfo: BetslipSelectionState) {

        if let priceValueFactor = systemBetInfo.priceValueFactor, self.betValueSubject.value != 0 {
            let possibleWinnings = priceValueFactor * self.betValueSubject.value

            let possibleWinningsString = CurrencyFormater.defaultFormat.string(from: NSNumber(value: possibleWinnings)) ?? localized("no_value")

            self.systemWinningsValueLabel.text = possibleWinningsString
            self.secondarySystemWinningsValueLabel.text = possibleWinningsString
        }
        else {
            self.systemWinningsValueLabel.text = localized("no_value")
            self.secondarySystemWinningsValueLabel.text = localized("no_value")
        }

        if let numberOfBets = self.selectedSystemBetType?.numberOfBets, self.betValueSubject.value != 0 {
            let totalBetAmount = Double(numberOfBets) * self.betValueSubject.value

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

        if !Env.userSessionStore.isUserLogged() {
            return
        }

        let stake = self.betValueSubject.value

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
                if let cashbackAmountResult = cashbackResult.amount {
                    if let cashbackFreeResult = cashbackResult.amountFree,
                       cashbackFreeResult > 0 && cashbackAmountResult == 0 {
                        self?.cashbackResultValuePublisher.send(cashbackFreeResult)
                    }
                    else {
                        self?.cashbackResultValuePublisher.send(cashbackAmountResult)

                    }
                }
                else if let cashbackAmountFreeResult = cashbackResult.amountFree {
                    if let cashbackAmountResult = cashbackResult.amount,
                       cashbackAmountResult > 0 && cashbackAmountFreeResult == 0 {

                        self?.cashbackResultValuePublisher.send(cashbackAmountResult)
                    }
                    else {
                        self?.cashbackResultValuePublisher.send(cashbackAmountFreeResult)

                    }
                }
            }
            .store(in: &cancellables)
    }

    @IBAction private func didTapDoneButton() {
        self.dismissKeyboard()
    }

    @IBAction private func didTapPlaceBetButton() {

        self.isLoading = true
        if Env.userSessionStore.isUserLogged() {

            //
            if self.listTypePublisher.value == .simple {
                var isFreeBet = false

                if self.isFreebetEnabled.value == true || self.isCashbackToggleOn.value == true {
                    isFreeBet = true
                }

                let singleBetTicketStakes = self.simpleBetsBettingValues.value

                let totalValue = singleBetTicketStakes.values.reduce(0.0, +)

//                if self.isCashbackToggleOn.value, let cashbackValue = Env.userSessionStore.userCashbackBalance.value {
//                    if totalValue > cashbackValue {
//                        let errorMessage = localized("betslip_cashback_error")
//                        self.showErrorView(errorMessage: errorMessage)
//                        self.isLoading = false
//                        return
//                    }
//                }
                
                if self.isCashbackToggleOn.value {
                    let cashbackValue = Env.userSessionStore.userCashbackBalance.value ?? 0.0
                    let freeBetValue = Env.userSessionStore.userFreeBetBalance.value ?? 0.0
                    let maxAvailableBalance = max(cashbackValue, freeBetValue)
                    
                    if totalValue > maxAvailableBalance {
                        let amount = CurrencyFormater.defaultFormat.string(from: NSNumber(value: maxAvailableBalance))
                        
                        let errorMessage = localized("betslip_credits_error").replacingFirstOccurrence(of: "{amount}", with: amount ?? "")
                        
                        self.showErrorView(errorMessage: errorMessage, isAlertLayout: true)
                        self.isLoading = false
                        return
                    }
                }

                if !self.isCashbackToggleOn.value, totalValue > self.maxBetValue {
                    self.showErrorView(errorMessage: localized("deposit_more_funds"))
                    self.isLoading = false
                    return
                }

                // ============================
                // PLACE SINGLE
                Env.betslipManager.placeSingleBets(amounts: singleBetTicketStakes, useFreebetBalance: isFreeBet)
                    .receive(on: DispatchQueue.main)
                    .sink { [weak self] completion in
                        switch completion {
                        case .failure(let error):
                            switch error {
                            case .betPlacementDetailedError(let detailedMessage):
                                self?.showErrorView(errorMessage: detailedMessage)
                            case .betNeedsUserConfirmation(let betDetails):
                                self?.requestUserConfirmationForBoostedBet(betDetails: betDetails)
                            default:
                                self?.showErrorView(errorMessage: localized("error_placing_bet"))
                            }
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

//                if self.isCashbackToggleOn.value, let cashbackValue = Env.userSessionStore.userCashbackBalance.value {
//                    if self.betValueSubject.value > cashbackValue {
//                        let errorMessage = localized("betslip_cashback_error")
//                        self.showErrorView(errorMessage: errorMessage)
//                        self.isLoading = false
//                        return
//                    }
//                }
                
                if self.isCashbackToggleOn.value {
                    let cashbackValue = Env.userSessionStore.userCashbackBalance.value ?? 0.0
                    let freeBetValue = Env.userSessionStore.userFreeBetBalance.value ?? 0.0
                    let maxAvailableBalance = max(cashbackValue, freeBetValue)
                    
                    if self.betValueSubject.value > maxAvailableBalance {
                        let amount = CurrencyFormater.defaultFormat.string(from: NSNumber(value: maxAvailableBalance))
                        
                        let errorMessage = localized("betslip_credits_error").replacingFirstOccurrence(of: "{amount}", with: amount ?? "")
                        
                        self.showErrorView(errorMessage: errorMessage, isAlertLayout: true)
                        self.isLoading = false
                        return
                    }
                }

                if !self.isCashbackToggleOn.value, self.betValueSubject.value > self.maxBetValue {
                    self.showErrorView(errorMessage: localized("deposit_more_funds"))
                    self.isLoading = false
                    return
                }

                var isFreeBet = false

                if self.isFreebetEnabled.value == true || self.isCashbackToggleOn.value == true {
                    isFreeBet = true
                }

                // ============================
                // PLACE MULTIPLE
                Env.betslipManager.placeMultipleBet(withStake: self.betValueSubject.value, useFreebetBalance: isFreeBet)
                    .receive(on: DispatchQueue.main)
                    .sink { [weak self] completion in
                        switch completion {
                        case .failure(let error):
                            switch error {
                            case .betPlacementDetailedError(let detailedMessage):
                                self?.showErrorView(errorMessage: detailedMessage)
                            case .betNeedsUserConfirmation(let betDetails):
                                self?.requestUserConfirmationForBoostedBet(betDetails: betDetails)
                            default:
                                self?.showErrorView(errorMessage: localized("error_placing_bet"))
                            }
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

                if self.isCashbackToggleOn.value {
                    let cashbackValue = Env.userSessionStore.userCashbackBalance.value ?? 0.0
                    let freeBetValue = Env.userSessionStore.userFreeBetBalance.value ?? 0.0
                    let maxAvailableBalance = max(cashbackValue, freeBetValue)
                    
                    if self.betValueSubject.value > maxAvailableBalance {
                        let amount = CurrencyFormater.defaultFormat.string(from: NSNumber(value: maxAvailableBalance))
                        
                        let errorMessage = localized("betslip_credits_error").replacingFirstOccurrence(of: "{amount}", with: amount ?? "")
                        
                        self.showErrorView(errorMessage: errorMessage, isAlertLayout: true)
                        self.isLoading = false
                        return
                    }
                }

                if !self.isCashbackToggleOn.value, self.betValueSubject.value > self.maxBetValue {
                    self.showErrorView(errorMessage: localized("deposit_more_funds"))
                    self.isLoading = false
                    return
                }

                var isFreeBet = false

                if self.isFreebetEnabled.value == true || self.isCashbackToggleOn.value == true {
                    isFreeBet = true
                }

                // ============================
                // PLACE SYSTEM
                Env.betslipManager.placeSystemBet(withStake: self.betValueSubject.value,
                                                  systemBetType: selectedSystemBetType,
                                                  useFreebetBalance: isFreeBet)
                .receive(on: DispatchQueue.main)
                .sink { [weak self] completion in
                    switch completion {
                    case .failure(let error):
                        switch error {
                        case .betPlacementDetailedError(let detailedMessage):
                            self?.showErrorView(errorMessage: detailedMessage)
                        case .betNeedsUserConfirmation(let betDetails):
                            self?.requestUserConfirmationForBoostedBet(betDetails: betDetails)
                        default:
                            self?.showErrorView(errorMessage: localized("error_placing_bet"))
                        }
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
                }
                .store(in: &cancellables)
            }
            else if self.listTypePublisher.value == .betBuilder {
                self.placeBetBuilderBet()
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
        case .betBuilder:
            return self.betBuilderBettingTicketDataSource
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
    
    @objc private func didTapCashbackInfoTriggerView() {
        
        UIView.animate(withDuration: 0.5, animations: {
            self.cashbackInfoDialogView.alpha = 1
        }) { (completed) in
            if completed {
                DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                    UIView.animate(withDuration: 0.5) {
                        self.cashbackInfoDialogView.alpha = 0
                    }
                }
            }
        }
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

    @IBAction private func didTapSpinWheelButton() {
        // Only proceed if the feature is enabled
        guard TargetVariables.hasFeatureEnabled(feature: .spinWheel) else {
            Logger.log("SpinWheel feature is disabled, button tap ignored.")
            return
        }

        
        let urlString = TargetVariables.clientBaseUrl + "/odds-boost-spinner/index.html"
        if let url = URL(string: urlString) {
            let spinWheelWebViewModel = SpinWheelViewModel(url: url, prize: "20%")
            let spinWheelWebViewController = SpinWheelViewController(viewModel: spinWheelWebViewModel)
            spinWheelWebViewController.modalPresentationStyle = .fullScreen
            self.present(spinWheelWebViewController, animated: true)
        }
    }
    
}

extension PreSubmissionBetslipViewController {

    private func refreshBetBuilderExpectedReturn() {

        let stake = self.betValueSubject.value

        Env.betslipManager.requestBetBuilderPotentialReturn(withSkateAmount: stake)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in

                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    switch error {
                    case .insufficientSelections:
                        self?.betBuilderWarningView.setDescription(localized("mix_match_min_compatible_selections"))
                        self?.betBuilderWarningView.alpha = 1.0
                    case .emptyBetslip:
                        self?.betBuilderWarningView.setDescription("")
                        self?.betBuilderWarningView.alpha = 0.0
                    default:
                        ()
                    }
                }

            }, receiveValue: { [weak self] betBuilderCalculateResponse in
                self?.configureWithBetBuilderExpectedReturn(betBuilderCalculateResponse)
            })
            .store(in: &self.cancellables)

    }

    private func configureWithBetBuilderExpectedReturn(_ betBuilderCalculateResponse: BetBuilderCalculateResponse) {

        switch betBuilderCalculateResponse {
        case .valid(let potentialReturn, _):
            print("DebugMixMatch: response valid \(dump(potentialReturn))")

            // Hide error view
            self.betBuilderWarningView.alpha = 0.0
            
            if self.isCashbackToggleOn.value {
                let freeBetPotentialReturn = potentialReturn.potentialReturn - potentialReturn.totalStake
                
                let possibleWinningsString = CurrencyFormater.defaultFormat.string(from: NSNumber(value: freeBetPotentialReturn)) ?? localized("no_value")

                self.mixMatchWinningsValueLabel.text = possibleWinningsString
                self.secondaryMixMatchWinningsValueLabel.text = possibleWinningsString

                self.mixMatchOddsValueLabel.text = OddFormatter.formatOdd(withValue: potentialReturn.totalOdd)
                self.secondaryMixMatchOddsValueLabel.text = OddFormatter.formatOdd(withValue: potentialReturn.totalOdd)
            }
            else {
                let possibleWinningsString = CurrencyFormater.defaultFormat.string(from: NSNumber(value: potentialReturn.potentialReturn)) ?? localized("no_value")

                self.mixMatchWinningsValueLabel.text = possibleWinningsString
                self.secondaryMixMatchWinningsValueLabel.text = possibleWinningsString

                self.mixMatchOddsValueLabel.text = OddFormatter.formatOdd(withValue: potentialReturn.totalOdd)
                self.secondaryMixMatchOddsValueLabel.text = OddFormatter.formatOdd(withValue: potentialReturn.totalOdd)
            }

        case .invalid:
            print("DebugMixMatch: response invalid")

            // Show error view
            self.betBuilderWarningView.setDescription(localized("mix_match_compatible_selections_warning"))
            self.betBuilderWarningView.alpha = 1.0
        }

    }

    private func placeBetBuilderBet() {
        if self.isCashbackToggleOn.value {
            let cashbackValue = Env.userSessionStore.userCashbackBalance.value ?? 0.0
            let freeBetValue = Env.userSessionStore.userFreeBetBalance.value ?? 0.0
            let maxAvailableBalance = max(cashbackValue, freeBetValue)
            
            if self.betValueSubject.value > maxAvailableBalance {
                let amount = CurrencyFormater.defaultFormat.string(from: NSNumber(value: maxAvailableBalance))
                
                let errorMessage = localized("betslip_credits_error").replacingFirstOccurrence(of: "{amount}", with: amount ?? "")
                
                self.showErrorView(errorMessage: errorMessage, isAlertLayout: true)
                self.isLoading = false
                return
            }
        }

        if !self.isCashbackToggleOn.value, self.betValueSubject.value > self.maxBetValue {
            self.showErrorView(errorMessage: localized("deposit_more_funds"))
            self.isLoading = false
            return
        }

        var isFreeBet = false

        if self.isFreebetEnabled.value == true || self.isCashbackToggleOn.value == true {
            isFreeBet = true
        }

        let stake = self.betValueSubject.value

        Env.betslipManager.placeBetBuilderBetValidTickets(stake: stake, useFreebetBalance: isFreeBet)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                switch completion {
                case .failure(let error):
                    switch error {
                    case .betPlacementDetailedError(let detailedMessage):
                        self?.showErrorView(errorMessage: detailedMessage)
                    case .betNeedsUserConfirmation(let betDetails):
                        self?.requestUserConfirmationForBoostedBet(betDetails: betDetails)
                    case .betPlacementError:
                        self?.showErrorView(errorMessage: localized("betting_fail_to_place_bets"))
                    default:
                        self?.showErrorView(errorMessage: localized("error_placing_bet"))
                    }
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

}

extension PreSubmissionBetslipViewController {

    func requestUserConfirmationForBoostedBet(betDetails: PlacedBetsResponse) {
        guard let window = UIApplication.shared.windows.filter({$0.isKeyWindow}).first else { return }
        //
        // Create and configure the background view
        let backgroundView = UIView(frame: UIScreen.main.bounds)
        backgroundView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        //
        //
        let boostedBetConfirmationView = BoostedBetConfirmationView(betDetails: betDetails)
        boostedBetConfirmationView.translatesAutoresizingMaskIntoConstraints = false

        boostedBetConfirmationView.didTapAcceptBetAction = { [weak self] betDetails in
            self?.confirmBoostedBet(betDetails: betDetails)
            backgroundView.removeFromSuperview()
        }
        boostedBetConfirmationView.didTapRejectBetAction = { [weak self] betDetails in
            self?.rejectBet(betDetails: betDetails)
            backgroundView.removeFromSuperview()
        }
        boostedBetConfirmationView.didDisappearAction = { [weak self] betDetails in
            backgroundView.removeFromSuperview()
        }
        //
        // Add
        backgroundView.addSubview(boostedBetConfirmationView)
        window.addSubview(backgroundView)
        //
        // Constraints for the background view
        NSLayoutConstraint.activate([
            boostedBetConfirmationView.centerXAnchor.constraint(equalTo: backgroundView.centerXAnchor),
            boostedBetConfirmationView.centerYAnchor.constraint(equalTo: backgroundView.centerYAnchor),
            boostedBetConfirmationView.leadingAnchor.constraint(equalTo: backgroundView.leadingAnchor, constant: 24),
        ])
        boostedBetConfirmationView.startCountdown()
    }

    func confirmBoostedBet(betDetails: PlacedBetsResponse) {
        
        Env.servicesProvider.confirmBoostedBet(identifier: betDetails.identifier, detailedCode: betDetails.detailedCode)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                switch completion {
                case .failure(let error):
                    self?.showErrorView(errorMessage: localized("error_placing_bet"))
                default: ()
                }
            } receiveValue: { [weak self] requestSuccessful in
                if requestSuccessful {
                    let betPlacedDetailsArray = ServiceProviderModelMapper.betPlacedDetailsArray(fromPlacedBetsResponse: betDetails)
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
                else {
                    self?.showErrorView(errorMessage: localized("error_placing_bet"))
                }
            }
            .store(in: &self.cancellables)
    }

    func rejectBet(betDetails: PlacedBetsResponse) {

        Env.servicesProvider.rejectBoostedBet(identifier: betDetails.identifier)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                switch completion {
                case .failure(let error):
//                    self?.showErrorView(errorMessage: localized("error_placing_bet"))
                    ()
                default: ()
                }
            } receiveValue: { [weak self] rejectedBetSucceeded in
                print("rejectedBetSucceeded: ", rejectedBetSucceeded)
            }
            .store(in: &self.cancellables)

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
        // Define the valid character set (numbers and both decimal separators)
        let allowedCharacters = CharacterSet(charactersIn: "0123456789.,")

        // Ensure the replacement string contains only allowed characters
        if string.rangeOfCharacter(from: allowedCharacters.inverted) != nil {
            return false
        }

        // Get the current text in the text field
        let currentText = textField.text ?? ""
        let newText = (currentText as NSString).replacingCharacters(in: range, with: string)

        // Check for multiple decimal separators (both . and ,)
        let dotCount = newText.components(separatedBy: ".").count - 1
        let commaCount = newText.components(separatedBy: ",").count - 1

        // Don't allow mixing of different decimal separators
        if dotCount > 0 && commaCount > 0 {
            return false
        }

        // Don't allow more than one of either separator
        if dotCount > 1 || commaCount > 1 {
            return false
        }

        // Check decimal places limit for dot
        if let dotIndex = newText.firstIndex(of: ".") {
            let decimalPart = newText[dotIndex...].dropFirst()
            if decimalPart.count > 2 {
                return false
            }
        }

        // Check decimal places limit for comma
        if let commaIndex = newText.firstIndex(of: ",") {
            let decimalPart = newText[commaIndex...].dropFirst()
            if decimalPart.count > 2 {
                return false
            }
        }

        return true
    }

    private  func addAmountValue(_ value: Double, isMax: Bool = false) {
        var internalValue = self.betValueSubject.value

        if !isMax {
            internalValue = internalValue + value // swiftlint:disable:this shorthand_operator
        }
        else {
            internalValue = value
        }

        // let calculatedAmount = Double(internalValue/100) + Double(internalValue%100)/100
        let valueString = String(format: "%.2f", internalValue)
        self.amountTextfield.text = valueString // CurrencyFormater.defaultFormat.string(from: NSNumber(value: internalValue))
        self.secondaryAmountTextfield.text = valueString // CurrencyFormater.defaultFormat.string(from: NSNumber(value: internalValue))

        self.betValueSubject.send(internalValue)
    }

    // This func append a new digit to the end of an existing one, end converts to double
    // current value is 1
    // user inserts 0 -> betValueSubject become 10
    // user inserts .
    private func updateAmountDigit(_ newValue: String) {
        var internalValue = self.betValueSubject.value // get the current value from the controller
        var internalValueString = String(internalValue)

        var processedNewValue = newValue
        processedNewValue = processedNewValue.replacingOccurrences(of: ",", with: ".")

        if internalValueString.contains(".") {
            // The string already contains a .
            return
        }

        // Append the new digit to the end of the string
        internalValueString = internalValueString + newValue // swiftlint:disable:this shorthand_operator
        
        //
        // internalValue = (internalValue * 10) + newValue

        if newValue == "" {
            internalValue = 0
        }

        guard let doubleValue = Double(internalValueString) else { return }


        // let calculatedAmount = Double(internalValue/100) + Double(internalValue%100)/100
        self.amountTextfield.text = CurrencyFormater.defaultFormat.string(from: NSNumber(value: doubleValue))
        self.secondaryAmountTextfield.text = CurrencyFormater.defaultFormat.string(from: NSNumber(value: doubleValue))

        // Send to new double value to the controller
        self.betValueSubject.send(doubleValue)
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
            return BetslipOddChangeSetting.allCases.count
        }
    }

    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let label: UILabel

        if let labelView = view as? UILabel {
            label = labelView
        }
        else {
            label = UILabel(frame: CGRect(x: 0, y: 0, width: pickerView.frame.width - 32, height: 400))
        }
        label.font = AppFont.with(type: .medium, size: 18)
        label.lineBreakMode = .byWordWrapping
        label.textAlignment = .center
        label.numberOfLines = 0

        if pickerView.tag == 1 {
            let optionName = self.systemBetOptions[safe: row]?.name ?? localized("system_bet")
            let normalizedOptionName = optionName.replacingOccurrences(of: "[^a-zA-Z0-9]", with: "_", options: .regularExpression).lowercased()
            let optionKeyName = "allowed_bet_types_\(normalizedOptionName)"
            let optionKey = localized(optionKeyName)

            let name = "\(optionKey) x\(self.systemBetOptions[safe: row]?.numberOfBets ?? 0)"
            label.attributedText = NSAttributedString(string: name,
                                                      attributes: [NSAttributedString.Key.foregroundColor: UIColor.App.textPrimary])
        }
        else {
            let title = BetslipOddChangeSetting.allCases[safe: row]?.localizedString ?? "--"
            label.attributedText = NSAttributedString(string: title,
                                                      attributes: [NSAttributedString.Key.foregroundColor: UIColor.App.textPrimary])
        }

        label.sizeToFit()

        return label
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView.tag == 1 {
            self.selectedSystemBetType = self.systemBetOptions[safe: row]
        }
        else {
            if let newValue = BetslipOddChangeSetting.allCases[safe: row] {
                self.betslipOddChangeSetting = newValue
            }
        }
    }

    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        if pickerView.tag == 1 {
            return 30.0
        }
        else {
            return 40.0
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


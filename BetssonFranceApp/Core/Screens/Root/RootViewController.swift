//
//  RootViewController.swift
//  Sportsbook
//
//  Created by Ruben Roques on 24/09/2021.
//

import UIKit
import Combine
import WebKit
import LocalAuthentication
import RegisterFlow
import Adyen
import AdyenDropIn
import AdyenComponents
import OptimoveSDK
import ServicesProvider

class RootViewController: UIViewController, RootActionable {
    // MARK: - Private Properties
    private lazy var topSafeAreaView: UIView = Self.createTopSafeAreaView()
    private lazy var topBarContainerBaseView: UIView = Self.createTopBarContainerBaseView()
    private lazy var topBarView: UIView = Self.createTopBarView()

    private lazy var profileStackView: UIStackView = Self.createProfileStackView()

    private lazy var profileBaseView: UIView = Self.createProfileBaseView()
    private lazy var profilePictureBaseView: UIView = Self.createProfilePictureBaseView()
    private lazy var profilePictureBaseInnerView: UIView = Self.createProfilePictureBaseInnerView()
    private lazy var profilePictureImageView: UIImageView = Self.createProfilePictureImageView()

    private lazy var anonymousUserMenuBaseView: UIView = Self.createAnonymousUserMenuBaseView()
    private lazy var anonymousUserMenuImageView: UIImageView = Self.createAnonymousUserMenuImageView()

    private lazy var accountStackView: UIStackView = Self.createAccountStackView()

    private lazy var logoImageBaseView: UIView = Self.createLogoImageBaseView()
    private lazy var logoImageView: UIImageView = Self.createLogoImageView()

    private let topBackgroundGradientLayer = CAGradientLayer()
    private lazy var topGradientBackgroundView: UIView = Self.createTopGradientBackgroundView()

    private lazy var containerView: UIView = Self.createContainerView()
    private lazy var mainContainerView: UIView = Self.createMainContainerView()

    private let mainContainerGradientLayer = CAGradientLayer()
    private lazy var mainContainerGradientView: UIView = Self.createMainContainerGradientView()

    private lazy var bottomBackgroundView: UIView = Self.createBottomBackgroundView()

    private lazy var sportsBookContentView: UIView = Self.createSportsBookContentView()
    private lazy var casinoContentView: UIView = Self.createCasinoContentView()

    private lazy var homeBaseView: UIView = Self.createHomeBaseView()
    private lazy var preLiveBaseView: UIView = Self.createPreLiveBaseView()
    private lazy var liveBaseView: UIView = Self.createLiveBaseView()
    private lazy var tipsBaseView: UIView = Self.createTipsBaseView()
    private lazy var cashbackBaseView: UIView = Self.createCashbackBaseView()
    private lazy var ticketsBaseView: UIView = Self.createTicketsBaseView()
    private lazy var featuredCompetitionBaseView: UIView = Self.createFeaturedCompetitionBaseView()

    private lazy var casinoBaseView: UIView = Self.createCasinoBaseView()

    private lazy var tabBarView: UIView = Self.createTabBarView()
    private lazy var tabBarStackView: UIStackView = Self.createTabBarStackView()
    private lazy var bottomSafeAreaView: UIView = Self.createBottomSafeAreaView()
    private lazy var casinoBottomView: UIView = Self.createCasinoBottomView()

    // Navigation Items
    private lazy var sportsButtonBaseView: UIView = Self.createSportsButtonBaseView()
    private lazy var sportsIconImageView: UIImageView = Self.createSportsIconImageView()
    private lazy var sportsTitleLabel: UILabel = Self.createSportsTitleLabel()

    private lazy var homeButtonBaseView: UIView = Self.createHomeButtonBaseView()
    private lazy var homeIconImageView: UIImageView = Self.createHomeIconImageView()
    private lazy var homeTitleLabel: UILabel = Self.createHomeTitleLabel()

    private lazy var liveButtonBaseView: UIView = Self.createLiveButtonBaseView()
    private lazy var liveIconImageView: UIImageView = Self.createLiveIconImageView()
    private lazy var liveTitleLabel: UILabel = Self.createLiveTitleLabel()

    private lazy var tipsButtonBaseView: UIView = Self.createTipsButtonBaseView()
    private lazy var tipsIconImageView: UIImageView = Self.createTipsIconImageView()
    private lazy var tipsTitleLabel: UILabel = Self.createTipsTitleLabel()

    private lazy var cashbackButtonBaseView: UIView = Self.createCashbackButtonBaseView()
    private lazy var cashbackIconImageView: UIImageView = Self.createCashbackIconImageView()
    private lazy var cashbackTitleLabel: UILabel = Self.createCashbackTitleLabel()

    private lazy var myTicketsButtonBaseView: UIView = Self.createMyTicketsButtonBaseView()
    private lazy var myTicketsIconImageView: UIImageView = Self.createMyTicketsIconImageView()
    private lazy var myTicketsTitleLabel: UILabel = Self.createMyTicketsTitleLabel()

    private lazy var featuredCompetitionButtonBaseView: UIView = Self.createFeaturedCompetitionButtonBaseView()
    private lazy var featuredCompetitionIconImageView: UIImageView = Self.createFeaturedCompetitionIconImageView()
    private lazy var featuredCompetitionTitleLabel: UILabel = Self.createFeaturedCompetitionTitleLabel()

    private lazy var casinoButtonBaseView: UIView = Self.createCasinoButtonBaseView()
    private lazy var casinoIconImageView: UIImageView = Self.createCasinoIconImageView()
    private lazy var casinoTitleLabel: UILabel = Self.createCasinoTitleLabel()

    private lazy var sportsbookButtonBaseView: UIView = Self.createSportsbookButtonBaseView()
    private lazy var sportsbookIconImageView: UIImageView = Self.createSportsbookIconImageView()
    private lazy var sportsbookTitleLabel: UILabel = Self.createSportsbookTitleLabel()

    private lazy var searchButton: UIButton = Self.createSearchButton()

    private lazy var loginBaseView: UIView = Self.createLoginBaseView()
    private lazy var loginButton: UIButton = Self.createLoginButton()

    // Account Value Views
    private lazy var accountValueBaseView: UIView = Self.createAccountValueBaseView()
    private lazy var accountValueView: UIView = Self.createAccountValueView()
    private lazy var accountPlusView: UIView = Self.createAccountPlusView()
    private lazy var accountValueLabel: UILabel = Self.createAccountValueLabel()
    private lazy var accountPlusImageView: UIImageView = Self.createAccountPlusImageView()

    // Notification Views
    private lazy var notificationCounterView: UIView = Self.createNotificationCounterView()
    private lazy var notificationCounterLabel: UILabel = Self.createNotificationCounterLabel()

    // Authentication Views
    private lazy var localAuthenticationBaseView: UIView = Self.createLocalAuthenticationBaseView()
    private lazy var unlockAppButton: UIButton = Self.createUnlockAppButton()
    private lazy var cancelUnlockAppButton: UIButton = Self.createCancelUnlockAppButton()
    private lazy var isLoadingUserSessionView: UIActivityIndicatorView = Self.createLoadingUserSessionView()

    private var pictureInPictureView: PictureInPictureView?

    private lazy var overlayWindow: PassthroughWindow = Self.createOverlayWindow()

    private lazy var blockingWindow: BlockingWindow = Self.createBlockingWindow()

    private lazy var topBarAlternateView: TopBarView = Self.createTopBarAlternateView()

    // Constraints
    private lazy var leadingSportsBookContentConstriant: NSLayoutConstraint = Self.createLeadingSportsBookContentConstriant()
    private lazy var logoImageWidthConstraint: NSLayoutConstraint = Self.createLogoImageWidthConstraint()
    private lazy var logoImageHeightConstraint: NSLayoutConstraint = Self.createLogoImageHeightConstraint()

    private var viewModel: RootViewModel

    // Add tabBarStackViewTrailingConstraint property
    private var tabBarStackViewTrailingConstraint: NSLayoutConstraint!

    // MARK: Public properties
    // Child view controllers
    lazy var homeViewController = HomeViewController()
    
    lazy var preLiveViewController: PreLiveEventsViewController = {
        let defaultSport = Env.sportsStore.defaultSport
        let viewModel = PreLiveEventsViewModel(selectedSport: defaultSport)
        let preLiveEventsViewController = PreLiveEventsViewController(viewModel: viewModel)
        return preLiveEventsViewController
    }()
    
    lazy var liveEventsViewController: LiveEventsViewController = {
        let defaultLiveSport = Env.sportsStore.defaultLiveSport
        let liveEventsViewModel = LiveEventsViewModel(selectedSport: defaultLiveSport)
        let liveEventsViewController = LiveEventsViewController(viewModel: liveEventsViewModel)
        return liveEventsViewController
    }()
    
    lazy var tipsRootViewController = TipsRootViewController()
    lazy var cashbackViewController = CashbackRootViewController()
    lazy var myTicketsRootViewController = MyTicketsRootViewController(viewModel: MyTicketsRootViewModel(startTabIndex: 0))
    lazy var featuredCompetitionViewController: FeaturedCompetitionDetailRootViewController? = {
        let sport = Sport(id: "", name: "", alphaId: "", numericId: "", showEventCategory: false, liveEventsCount: 0)

        if let competitionId = Env.businessSettingsSocket.clientSettings.featuredCompetition?.id {

            let topCompetitionDetailsViewModel = TopCompetitionDetailsViewModel(competitionsIds: [competitionId], sport: sport)
            
            let featuredCompetitionDetailRootViewController = FeaturedCompetitionDetailRootViewController(viewModel: topCompetitionDetailsViewModel)

            return featuredCompetitionDetailRootViewController
        }

        return nil
    }()
    lazy var casinoViewController = CasinoDemoImageWebViewController()

    // Loaded view controllers
    var homeViewControllerLoaded = false
    var preLiveViewControllerLoaded = false
    var liveEventsViewControllerLoaded = false
    var tipsRootViewControllerLoaded = false
    var ticketsRootViewControllerLoaded = false
    var featuredCompetitionViewControllerLoaded = false
    var casinoViewControllerLoaded = false
    var cashbackViewControllerLoaded = false

    // General properties
    var isLocalAuthenticationCoveringView: Bool = true {
        didSet {
            if isLocalAuthenticationCoveringView {
                self.localAuthenticationBaseView.isHidden = false
                self.blockingWindow.isHidden = false
            }
            else {
                self.localAuthenticationBaseView.isHidden = true
                self.blockingWindow.isHidden = true

            }
        }
    }

    var selectedTabItem: RootViewModel.TabItem {
        willSet {
            if self.selectedTabItem == .cashback && newValue != .cashback {
                self.cashbackViewController.didBecomeInactive()
            }
        }
        didSet {
            switch selectedTabItem {
            case .home:
                self.selectHomeTabBarItem()
            case .preLive:
                self.selectSportsTabBarItem()
            case .live:
                self.selectLiveTabBarItem()
            case .tips:
                self.selectTipsTabBarItem()
            case .cashback:
                self.selectCashbackTabBarItem()
            case .tickets:
                self.selectTicketsTabBarItem()
            case .featuredCompetition:
                self.selectFeaturedCompetitionTabBarItem()
            case .casino:
                self.selectCasinoTabBarItem()
            }

        }
    }

    enum AppMode {
        case sportsbook
        case casino
    }

    var appMode: AppMode = .sportsbook

    var screenState: ScreenState = .anonymous {
        didSet {
            self.setupWithState(self.screenState)
        }
    }

    static let casinoButtonWidth: CGFloat = 66

    let activeButtonAlpha = 1.0
    let idleButtonAlpha = 0.52

    var currentSport: Sport
    var canShowPopUp: Bool = true
    var popUpPromotionView: PopUpPromotionView?
    var popUpBackgroundView: UIView?
    var cancellables = Set<AnyCancellable>()

    // MARK: Lifetime and cycle
    init(initialScreen: RootViewModel.TabItem = .home, defaultSport: Sport) {
        self.selectedTabItem = initialScreen
        self.currentSport = defaultSport
        self.viewModel = RootViewModel()
        super.init(nibName: nil, bundle: nil)
    }

    @available(iOS, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupSubviews()
        self.commonInit()

        let initialTab = self.selectedTabItem
        self.selectedTabItem = initialTab

        //
         self.pictureInPictureView = PictureInPictureView()
         self.overlayWindow.addSubview(self.pictureInPictureView!, anchors: [.leading(0), .trailing(0), .top(0), .bottom(0)] )
         self.overlayWindow.isHidden = false // .makeKeyAndVisible()

        self.blockingWindow.addSubview(self.localAuthenticationBaseView, anchors: [.leading(0), .trailing(0), .top(0), .bottom(0)])
        self.blockingWindow.isHidden = false

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.windowDidResignKeyNotification(_:)),
                                               name: UIWindow.didResignKeyNotification,
                                               object: nil)

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.windowDidBecomeKeyNotification(_:)),
                                               name: UIWindow.didBecomeKeyNotification,
                                               object: nil)

        //
        // UIApplication States
        //
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.appWillEnterForeground),
                                               name: UIApplication.willEnterForegroundNotification,
                                               object: nil)

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.appDidEnterBackground),
                                               name: UIApplication.didEnterBackgroundNotification,
                                               object: nil)

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.appWillResignActive),
                                               name: UIApplication.willResignActiveNotification,
                                               object: nil)

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.appDidBecomeActive),
                                               name: UIApplication.didBecomeActiveNotification,
                                               object: nil)

        //
        self.setupWithTheme()

        // Detects a new login
        Env.userSessionStore.userProfilePublisher
            .receive(on: DispatchQueue.main)
            .sink { userProfile in
                if let userProfile = userProfile {
                    self.screenState = .logged(user: userProfile)

                    if let avatarName = userProfile.avatarName {
                        if let avatarImage = UIImage(named: avatarName) {
                            self.profilePictureImageView.image = avatarImage
                        }
                        else {
                            self.profilePictureImageView.image = UIImage(named: "empty_user_image")
                        }
                    }
                    else {
                        self.profilePictureImageView.image = UIImage(named: "empty_user_image")
                    }

                    self.checkUserLimitsSet()
                }
                else {
                    self.screenState = .anonymous

                    if self.preLiveViewControllerLoaded {
                        self.preLiveViewController.reloadData()
                    }
                }
            }
            .store(in: &cancellables)

        Env.businessSettingsSocket.clientSettingsPublisher
            .delay(for: .seconds(1), scheduler: DispatchQueue.main)
            .receive(on: DispatchQueue.main)
            .filter { [weak self] _ in
                return self?.canShowPopUp ?? false
            }
            .compactMap({ $0 })
            .map(\.showInformationPopUp)
            .sink { [weak self] showInformationPopUp in
                if showInformationPopUp {
                    self?.canShowPopUp = false
                    self?.requestPopUpContent()
                }
            }
            .store(in: &cancellables)

        Env.userSessionStore
            .isLoadingUserSessionPublisher
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoadingUserSession in

                if !isLoadingUserSession {
                    self?.isLocalAuthenticationCoveringView = false
                }

                self?.isLoadingUserSessionView.isHidden = !isLoadingUserSession
                self?.unlockAppButton.isHidden = isLoadingUserSession
                self?.cancelUnlockAppButton.isHidden = isLoadingUserSession
            }
            .store(in: &self.cancellables)

        //
        let debugTapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapLogoImageView))
        self.logoImageView.addGestureRecognizer(debugTapGesture)
        self.logoImageView.isUserInteractionEnabled = true

        //
        Env.gomaSocialClient.inAppMessagesCounter
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] notificationCounter in
                if notificationCounter > 0 {
                    self?.notificationCounterView.isHidden = false
                    self?.notificationCounterLabel.text = "\(notificationCounter)"
                }
                else {
                    self?.notificationCounterView.isHidden = true
                }
            })
            .store(in: &cancellables)

        self.isLoadingUserSessionView.isHidden = true

        // Add blur effect
        self.localAuthenticationBaseView.backgroundColor = .clear

        let blurEffect = UIBlurEffect(style: .regular)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.translatesAutoresizingMaskIntoConstraints = false

        self.localAuthenticationBaseView.insertSubview(blurEffectView, at: 0)

        NSLayoutConstraint.activate([
            blurEffectView.leadingAnchor.constraint(equalTo: self.localAuthenticationBaseView.leadingAnchor),
            blurEffectView.trailingAnchor.constraint(equalTo: self.localAuthenticationBaseView.trailingAnchor),
            blurEffectView.topAnchor.constraint(equalTo: self.localAuthenticationBaseView.topAnchor),
            blurEffectView.bottomAnchor.constraint(equalTo: self.localAuthenticationBaseView.bottomAnchor),
        ])

        self.localAuthenticationBaseView.alpha = 1.0
        self.showLocalAuthenticationCoveringViewIfNeeded()

        self.authenticateUser()

        becomeFirstResponder() // Enable shake detection
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.setNeedsStatusBarAppearanceUpdate()

        Env.userSessionStore.userWalletPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] userWallet in
                if let userWallet = userWallet,
                   let formattedTotalString = CurrencyFormater.defaultFormat.string(from: NSNumber(value: userWallet.total)) {
                    self?.accountValueLabel.text = formattedTotalString
                }
                else {
                    self?.accountValueLabel.text = "-.--€"
                }
            }
            .store(in: &cancellables)

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

    }

    func commonInit() {

        // Top Bar
        if TargetVariables.shouldUseAlternateTopBar {
            self.topBarView.isHidden = true
            self.topBarAlternateView.isHidden = false
        }
        else {
            self.topBarView.isHidden = false
            self.topBarAlternateView.isHidden = true
        }

        self.redrawButtonButtons()
        if let image = self.logoImageView.image {

            let maxAllowedWidth = CGFloat(150)
            let defaultHeight = self.logoImageHeightConstraint.constant
            let ratio = image.size.height / image.size.width
            let newWidth = defaultHeight / ratio

            if newWidth > maxAllowedWidth {
                 let limitedHeight = maxAllowedWidth * ratio
                 self.logoImageWidthConstraint.constant = maxAllowedWidth
                 self.logoImageHeightConstraint.constant = limitedHeight
            }
            else {
                 self.logoImageWidthConstraint.constant = newWidth
                 self.logoImageHeightConstraint.constant = defaultHeight
            }
            self.profileStackView.setNeedsLayout()
            self.profileStackView.layoutIfNeeded()

            self.view.layoutIfNeeded()
        }

        self.casinoButtonBaseView.layer.maskedCorners = [ .layerMinXMaxYCorner, .layerMinXMinYCorner]

        self.sportsbookButtonBaseView.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMaxXMinYCorner]

        let homeTapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapHomeTabItem))
        self.homeButtonBaseView.addGestureRecognizer(homeTapGesture)

        let sportsTapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapSportsTabItem))
        self.sportsButtonBaseView.addGestureRecognizer(sportsTapGesture)

        let liveTapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapLiveTabItem))
        self.liveButtonBaseView.addGestureRecognizer(liveTapGesture)

        let tipsTapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapTipsTabItem))
        self.tipsButtonBaseView.addGestureRecognizer(tipsTapGesture)

        let ticketsTapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapTicketsTabItem))
        self.myTicketsButtonBaseView.addGestureRecognizer(ticketsTapGesture)

        let featuredCompetitionTapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapFeaturedCompetitionTabItem))
        self.featuredCompetitionButtonBaseView.addGestureRecognizer(featuredCompetitionTapGesture)
        
        let cashbackTapgesture = UITapGestureRecognizer(target: self, action: #selector(didTapCashbackTabItem))
        self.cashbackButtonBaseView.addGestureRecognizer(cashbackTapgesture)

        let sportsbookTapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapSportsbookIcon))
        self.sportsbookButtonBaseView.addGestureRecognizer(sportsbookTapGesture)

        let profileTapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapProfileButton))
        self.profilePictureBaseView.addGestureRecognizer(profileTapGesture)

        let anonymousTapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapAnonymousButton))
        self.anonymousUserMenuBaseView.addGestureRecognizer(anonymousTapGesture)

        let accountValueTapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapAccountValue))
        self.accountValueView.addGestureRecognizer(accountValueTapGesture)

        let casinoTapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapCasinoTabItem))
        self.casinoButtonBaseView.addGestureRecognizer(casinoTapGesture)

        self.loginButton.addTarget(self, action: #selector(didTapLoginButton), for: .primaryActionTriggered)
        //
        if TargetVariables.hasFeatureEnabled(feature: .casino) {
            self.casinoButtonBaseView.isHidden = false
            self.updateTabBarForCasino(isVisible: true)
        }
        else {
            self.casinoButtonBaseView.isHidden = true
            self.updateTabBarForCasino(isVisible: false)
        }

        //
        if TargetVariables.hasFeatureEnabled(feature: .tips) {
            self.tipsButtonBaseView.isHidden = false
        }
        else {
            self.tipsButtonBaseView.isHidden = true
        }

        if TargetVariables.hasFeatureEnabled(feature: .cashback) {
            self.cashbackButtonBaseView.isHidden = false
        }
        else {
            self.cashbackButtonBaseView.isHidden = true

        }

        if TargetVariables.hasFeatureEnabled(feature: .homeTickets) {
            self.myTicketsButtonBaseView.isHidden = false
        }
        else {
            self.myTicketsButtonBaseView.isHidden = true
        }
        
        if TargetVariables.hasFeatureEnabled(feature: .userWalletBalance) {
            self.accountValueBaseView.isHidden = false
            Env.userSessionStore.refreshUserWallet()
        }
        else {
            self.accountValueBaseView.isHidden = true
        }

        if
            TargetVariables.hasFeatureEnabled(feature: .featuredCompetitionInTabBar),
            let featuredCompetition = Env.businessSettingsSocket.clientSettings.featuredCompetition,
            featuredCompetition.id != nil
        {
            self.featuredCompetitionButtonBaseView.isHidden = false
            
            // Set bottom banner icon
            if let bottomBarIcon = featuredCompetition.bottomBarIcon,
               let url = URL(string: "\(bottomBarIcon)") {
                
                self.featuredCompetitionIconImageView.kf.setImage(with: url)
                
            }
            
            // Set bottom banner name
            if let bottomBarName = featuredCompetition.bottomBarName {
                self.featuredCompetitionTitleLabel.text = bottomBarName
            }
        }
        else {
            self.featuredCompetitionButtonBaseView.isHidden = true
        }

        Env.businessSettingsSocket.clientSettingsPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] clientSettings in
                if let featuredCompetition = clientSettings?.featuredCompetition,
                   let featuredCompetitionId = featuredCompetition.id {
                    self?.featuredCompetitionButtonBaseView.isHidden = false

                    // Set bottom banner icon
                    if let bottomBarIcon = featuredCompetition.bottomBarIcon,
                       let url = URL(string: "\(bottomBarIcon)") {

                        self?.featuredCompetitionIconImageView.kf.setImage(with: url)

                    }

                    // Set bottom banner name
                    if let bottomBarName = featuredCompetition.bottomBarName {
                        self?.featuredCompetitionTitleLabel.text = bottomBarName
                    }
                }
                else {
                    self?.featuredCompetitionButtonBaseView.isHidden = true
                }
            })
            .store(in: &cancellables)

        self.mainContainerGradientLayer.locations = [0.0, 1.0]
        self.mainContainerGradientView.backgroundColor = .white
        self.mainContainerGradientView.layer.insertSublayer(self.mainContainerGradientLayer, at: 0)

        self.topBackgroundGradientLayer.locations = [0.0, 0.41, 1.0]
        self.topBackgroundGradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
        self.topBackgroundGradientLayer.endPoint = CGPoint(x: 1.0, y: 0.4)

        if TargetVariables.shouldUseGradientBackgrounds {
            self.topGradientBackgroundView.backgroundColor = .white
            self.topGradientBackgroundView.layer.insertSublayer(self.topBackgroundGradientLayer, at: 0)
        }
        else {
            self.topGradientBackgroundView.backgroundColor = .clear
        }

        //
        if TargetVariables.shouldUseBlurEffectTabBar {
            
            self.bottomBackgroundView.backgroundColor = .clear

            let blurEffect = UIBlurEffect(style: .regular)
            let blurEffectView = UIVisualEffectView(effect: blurEffect)
            blurEffectView.translatesAutoresizingMaskIntoConstraints = false

            self.bottomBackgroundView.insertSubview(blurEffectView, at: 0)

            NSLayoutConstraint.activate([
                blurEffectView.leadingAnchor.constraint(equalTo: self.bottomBackgroundView.leadingAnchor),
                blurEffectView.trailingAnchor.constraint(equalTo: self.bottomBackgroundView.trailingAnchor),
                blurEffectView.topAnchor.constraint(equalTo: self.bottomBackgroundView.topAnchor),
                blurEffectView.bottomAnchor.constraint(equalTo: self.bottomBackgroundView.bottomAnchor),
            ])
        }

        // Top bar callbacks
        self.topBarAlternateView.shouldShowLogin = { [weak self] in
            self?.presentLoginScreen()
        }

        self.topBarAlternateView.shouldShowProfile = { [weak self] in
            self?.presentProfileViewController()
        }

        self.topBarAlternateView.shouldShowDeposit = { [weak self] in
            let depositViewController = DepositViewController()
            let navigationViewController = Router.navigationController(with: depositViewController)
            depositViewController.shouldRefreshUserWallet = {
                Env.userSessionStore.refreshUserWallet()
            }
            self?.present(navigationViewController, animated: true, completion: nil)
        }

        self.topBarAlternateView.shouldShowAnonymousMenu = { [weak self] in
            self?.presentAnonymousSideMenuViewController()
        }

        self.topBarAlternateView.shouldShowReplay = {  [weak self] in
            self?.didTapCashbackTabItem()
        }
    }

    // MARK: Layout and theme
    override var preferredStatusBarStyle: UIStatusBarStyle {
        let barStyle: UIStatusBarStyle = traitCollection.userInterfaceStyle == .dark ? .lightContent : .darkContent
        return barStyle
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        self.setNeedsStatusBarAppearanceUpdate()
        self.setupWithTheme()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        self.topBackgroundGradientLayer.frame = self.topGradientBackgroundView.bounds

        self.mainContainerGradientLayer.frame = self.mainContainerGradientView.bounds

        self.profilePictureBaseView.layer.cornerRadius = profilePictureBaseView.frame.size.width/2

        self.profilePictureImageView.layer.cornerRadius = profilePictureImageView.frame.size.width/2
        self.profilePictureImageView.layer.masksToBounds = true
        self.profilePictureImageView.clipsToBounds = true

        self.profilePictureBaseInnerView.layer.cornerRadius = self.profilePictureBaseInnerView.frame.size.width/2

        self.accountValueView.layer.cornerRadius = CornerRadius.view
        self.accountValueView.layer.masksToBounds = true
        self.accountValueView.isUserInteractionEnabled = true

        self.accountPlusView.layer.cornerRadius = CornerRadius.squareView
        self.accountPlusView.layer.masksToBounds = true

        self.accountPlusImageView.setImageColor(color: UIColor.App.buttonTextPrimary)

        self.casinoButtonBaseView.layer.cornerRadius = self.casinoButtonBaseView.frame.height / 2
        self.sportsbookButtonBaseView.layer.cornerRadius = self.sportsbookButtonBaseView .frame.height / 2

        self.notificationCounterView.layer.cornerRadius = self.notificationCounterView.frame.height/2
    }

    func setupWithTheme() {

        self.view.backgroundColor = UIColor.App.backgroundPrimary

        if TargetVariables.shouldUseGradientBackgrounds {
            self.topSafeAreaView.backgroundColor = .clear
            self.topBarView.backgroundColor = .clear

            self.topGradientBackgroundView.backgroundColor = .clear
            self.topBackgroundGradientLayer.colors = [UIColor.App.topBarGradient1.cgColor,
                                                      UIColor.App.topBarGradient2.cgColor,
                                                      UIColor.App.topBarGradient3.cgColor]

            self.containerView.backgroundColor = .clear
            self.mainContainerView.backgroundColor = .clear
            self.mainContainerGradientView.backgroundColor = .clear

            self.mainContainerGradientLayer.colors = [UIColor.App.backgroundPrimary.cgColor,
                                                      UIColor.App.backgroundPrimary.cgColor]

            self.searchButton.imageView?.setImageColor(color: UIColor.white)
            self.anonymousUserMenuImageView.setImageColor(color: UIColor.white)
        }
        else {
            self.topSafeAreaView.backgroundColor = UIColor.App.backgroundPrimary
            self.topBarView.backgroundColor = UIColor.App.backgroundPrimary

            self.topGradientBackgroundView.backgroundColor = .clear
            self.topBackgroundGradientLayer.colors = []

            self.containerView.backgroundColor = .clear
            self.mainContainerView.backgroundColor = UIColor.App.backgroundPrimary
            self.mainContainerGradientView.backgroundColor = .clear
            self.mainContainerGradientLayer.colors = []

            self.searchButton.imageView?.setImageColor(color: UIColor.App.textPrimary)
            self.anonymousUserMenuImageView.setImageColor(color: UIColor.App.textPrimary)
        }

        self.homeBaseView.backgroundColor = .clear
        self.preLiveBaseView.backgroundColor = .clear
        self.liveBaseView.backgroundColor = .clear
        self.tipsBaseView.backgroundColor = .clear
        self.casinoBaseView.backgroundColor = .clear
        self.ticketsBaseView.backgroundColor = .clear
        self.featuredCompetitionBaseView.backgroundColor = .clear

        self.homeTitleLabel.textColor = UIColor.App.highlightPrimary
        self.liveTitleLabel.textColor = UIColor.App.highlightPrimary
        self.sportsTitleLabel.textColor = UIColor.App.highlightPrimary
        self.tipsTitleLabel.textColor = UIColor.App.highlightPrimary
        self.casinoTitleLabel.textColor = UIColor.App.textSecondary
        self.sportsbookTitleLabel.textColor = UIColor.App.textSecondary

        if TargetVariables.shouldUseBlurEffectTabBar {
            self.tabBarView.backgroundColor = .clear
            self.bottomSafeAreaView.backgroundColor = .clear
        }
        else {
            self.tabBarView.backgroundColor = UIColor.App.backgroundSecondary
            self.bottomSafeAreaView.backgroundColor = UIColor.App.backgroundSecondary
        }

        self.homeButtonBaseView.backgroundColor = .clear // UIColor.App.backgroundPrimary
        self.sportsButtonBaseView.backgroundColor = .clear // UIColor.App.backgroundPrimary
        self.liveButtonBaseView.backgroundColor = .clear // UIColor.App.backgroundPrimary
        self.tipsButtonBaseView.backgroundColor = .clear // UIColor.App.backgroundPrimary
        self.cashbackButtonBaseView.backgroundColor = .clear
        self.myTicketsButtonBaseView.backgroundColor = .clear
        self.featuredCompetitionButtonBaseView.backgroundColor = .clear

        self.profilePictureBaseView.backgroundColor = UIColor.App.highlightPrimary

        self.profilePictureBaseInnerView.backgroundColor = UIColor.App.backgroundPrimary

        self.loginButton.setTitleColor(UIColor.App.buttonTextPrimary, for: .normal)
        self.loginButton.setTitleColor(UIColor.App.buttonTextPrimary.withAlphaComponent(0.7), for: .highlighted)
        self.loginButton.setTitleColor(UIColor.App.buttonTextPrimary.withAlphaComponent(0.4), for: .disabled)
        self.loginButton.setBackgroundColor(UIColor.App.buttonBackgroundPrimary, for: .normal)
        self.loginButton.setBackgroundColor(UIColor.App.buttonBackgroundPrimary, for: .highlighted)

        self.loginButton.layer.cornerRadius = CornerRadius.view
        self.loginButton.layer.masksToBounds = true

        self.accountValueView.backgroundColor = UIColor.App.backgroundSecondary
        self.accountValueLabel.textColor = UIColor.App.textPrimary
        self.accountPlusView.backgroundColor = UIColor.App.highlightSecondary

        self.accountPlusImageView.tintColor = UIColor.App.buttonTextPrimary

        self.casinoBottomView.backgroundColor = UIColor.App.backgroundPrimary

        self.casinoButtonBaseView.backgroundColor = UIColor.App.backgroundCards

        self.casinoButtonBaseView.alpha = self.activeButtonAlpha
        self.casinoIconImageView.setImageColor(color: UIColor.App.iconSecondary)

        self.sportsbookButtonBaseView.backgroundColor = UIColor.App.backgroundCards
        self.sportsbookButtonBaseView.alpha = self.activeButtonAlpha

        self.sportsbookIconImageView.setImageColor(color: UIColor.App.iconSecondary)

        self.redrawButtonButtons()

        self.notificationCounterView.backgroundColor = UIColor.App.alertError

        self.notificationCounterLabel.textColor = UIColor.App.buttonTextPrimary

        self.searchButton.tintColor = UIColor.App.iconSecondary

        self.isLoadingUserSessionView.tintColor = UIColor.App.textSecondary
        self.isLoadingUserSessionView.color = UIColor.App.textSecondary

        self.unlockAppButton.backgroundColor = UIColor.App.highlightPrimary
        self.unlockAppButton.setTitleColor(UIColor.App.buttonTextPrimary, for: .normal)

        self.cancelUnlockAppButton.backgroundColor = .systemGray
        self.cancelUnlockAppButton.setTitleColor(UIColor.App.highlightPrimary, for: .normal)
    }

    // MARK: Functions
    func setupWithState(_ screenState: ScreenState) {
        switch screenState {
        case .logged:
            self.loginBaseView.isHidden = true

            self.profilePictureBaseView.isHidden = false
            self.accountValueBaseView.isHidden = false

            self.anonymousUserMenuBaseView.isHidden = true
            Env.userSessionStore.refreshUserWallet()

        case .anonymous:
            self.loginBaseView.isHidden = false

            self.profilePictureBaseView.isHidden = true
            self.accountValueBaseView.isHidden = true

            self.anonymousUserMenuBaseView.isHidden = false
        }
    }

    func selectSport(_ sport: Sport) {
        self.currentSport = sport

        if self.preLiveViewControllerLoaded {
            self.preLiveViewController.selectSport(sport)
        }

        if self.liveEventsViewControllerLoaded {
            self.liveEventsViewController.selectSport(sport)
        }
    }

    func didChangedPreLiveSport(_ sport: Sport) {
//        self.currentSport = sport
//        if self.liveEventsViewControllerLoaded {
//            self.liveEventsViewController.selectedSport = sport
//        }
    }

    func didChangedLiveSport(_ sport: Sport) {
//        self.currentSport = sport
//        if self.preLiveViewControllerLoaded {
//            self.preLiveViewController.selectSport(sport)
//        }
    }

    // Open screens functions
    func openBetslipModal() {
        let betslipViewModel = BetslipViewModel()
        let betslipViewController = BetslipViewController(viewModel: betslipViewModel)

        betslipViewController.willDismissAction = { [weak self] in
            self?.reloadChildViewControllersData()
        }
        self.present(Router.navigationController(with: betslipViewController), animated: true, completion: nil)
    }

    func openBetslipModalWithShareData(ticketToken: String) {
        
        let betslipViewModel = BetslipViewModel(startScreen: .sharedBet(ticketToken))
        let betslipViewController = BetslipViewController(viewModel: betslipViewModel)

        betslipViewController.willDismissAction = { [weak self] in
            self?.reloadChildViewControllersData()
        }

        self.present(Router.navigationController(with: betslipViewController), animated: true, completion: nil)
    }

    func openChatModal() {
        if Env.userSessionStore.isUserLogged() {
            let socialViewController = SocialViewController()
//            let socialViewController = ChatListViewController()
            self.present(Router.navigationController(with: socialViewController), animated: true, completion: nil)
        }
        else {
            let loginViewController = Router.navigationController(with: LoginViewController())
            self.present(loginViewController, animated: true, completion: nil)
        }
    }

    func openInternalWebview(onURL url: URL) {
        let internalBrowserViewController = InternalBrowserViewController(url: url, fullscreen: true)
        let navigationViewController = Router.navigationController(with: internalBrowserViewController)
        navigationViewController.modalPresentationStyle = .fullScreen
        self.present(navigationViewController, animated: true, completion: nil)
    }

    func openExternalBrowser(onURL url: URL) {
        UIApplication.shared.open(url)
    }

    func openUserProfile(userBasicInfo: UserBasicInfo) {
        let userProfileViewModel = UserProfileViewModel(userBasicInfo: userBasicInfo)

        let userProfileViewController = UserProfileViewController(viewModel: userProfileViewModel)

//        userProfileViewController.shouldShowLogin = { [weak self] in
//            self?.presentLoginScreen()
//        }

        self.navigationController?.pushViewController(userProfileViewController, animated: true)
    }

    func openMatchDetail(matchId: String) {

        let matchDetailsViewController = MatchDetailsViewController(viewModel: MatchDetailsViewModel(matchId: matchId))

        self.present(Router.navigationController(with: matchDetailsViewController), animated: true, completion: nil)
    }
    
    func openCompetitionDetail(competitionId: String) {
        
        let sport = Sport(id: "", name: "Sport", alphaId: "", numericId: "", showEventCategory: false, liveEventsCount: 0)
        
        let topCompetitionDetailsViewModel = TopCompetitionDetailsViewModel(competitionsIds: [competitionId], sport: sport)
        let topCompetitionDetailsViewController = TopCompetitionDetailsViewController(viewModel: topCompetitionDetailsViewModel)
        
        let navigationController = Router.navigationController(with: topCompetitionDetailsViewController)
        
        self.present(navigationController, animated: true, completion: nil)
    }
    
    func openContactSettings() {
        Env.userSessionStore.isLoadingUserSessionPublisher
            .filter({ $0 == false })
            .receive(on: DispatchQueue.main)
            .first()
            .sink(receiveValue: { [weak self] _ in
                if Env.userSessionStore.isUserLogged() {
                    let contactSettingsViewModel = ContactSettingsViewModel()
                    
                    let contactSettingsViewController = ContactSettingsViewController(viewModel: contactSettingsViewModel)
                    
                    let navigationController = Router.navigationController(with: contactSettingsViewController)
                    
                    self?.present(navigationController, animated: true, completion: nil)
                }
                else {
                    
                    let loginViewController = LoginViewController()
                    
                    let navigationViewController = Router.navigationController(with: loginViewController)
                    
                    loginViewController.hasPendingRedirect = true
                    
                    loginViewController.needsRedirect = { [weak self] in
                        self?.openContactSettings()
                    }
                    
                    self?.present(navigationViewController, animated: true, completion: nil)
                }
            })
            .store(in: &cancellables)
    }
    
    func openBetswipe() {
        
        self.homeViewController.openBetSwipe()
    }
    
    func openDeposit() {
        Env.userSessionStore.isLoadingUserSessionPublisher
            .filter({ $0 == false })
            .receive(on: DispatchQueue.main)
            .first()
            .sink(receiveValue: { [weak self] _ in
                
                if Env.userSessionStore.isUserLogged() {
                    let depositViewController = DepositViewController()
                    
                    depositViewController.shouldRefreshUserWallet = {
                        Env.userSessionStore.refreshUserWallet()
                    }
                    
                    let navigationController = Router.navigationController(with: depositViewController)
                    
                    self?.present(navigationController, animated: true, completion: nil)
                }
                else {
                    
                    let loginViewController = LoginViewController()
                    
                    let navigationViewController = Router.navigationController(with: loginViewController)
                    
                    loginViewController.hasPendingRedirect = true
                    
                    loginViewController.needsRedirect = { [weak self] in
                        self?.openDeposit()
                    }
                    
                    self?.present(navigationViewController, animated: true, completion: nil)
                }
                
            })
            .store(in: &cancellables)
    }
    
    func openBonus() {
        Env.userSessionStore.isLoadingUserSessionPublisher
            .filter({ $0 == false })
            .receive(on: DispatchQueue.main)
            .first()
            .sink(receiveValue: { [weak self] _ in
                
                if Env.userSessionStore.isUserLogged() {
                    let bonusRootViewController = BonusRootViewController(viewModel: BonusRootViewModel(startTabIndex: 0))
                    
                    let navigationController = Router.navigationController(with: bonusRootViewController)
                    
                    self?.present(navigationController, animated: true, completion: nil)
                }
                else {
                    
                    let loginViewController = LoginViewController()
                    
                    let navigationViewController = Router.navigationController(with: loginViewController)
                    
                    loginViewController.hasPendingRedirect = true
                    
                    loginViewController.needsRedirect = { [weak self] in
                        self?.openBonus()
                    }
                    
                    self?.present(navigationViewController, animated: true, completion: nil)
                }
                
            })
            .store(in: &cancellables)
    }
    
    func openDocuments() {
        
        Env.userSessionStore.isLoadingUserSessionPublisher
            .filter({ $0 == false })
            .receive(on: DispatchQueue.main)
            .first()
            .sink(receiveValue: { [weak self] _ in
                
                if Env.userSessionStore.isUserLogged() {
                    let documentsRootViewModel = DocumentsRootViewModel()
                    
                    let documentsRootViewController = DocumentsRootViewController(viewModel: documentsRootViewModel)
                    
                    let navigationController = Router.navigationController(with: documentsRootViewController)
                    
                    self?.present(navigationController, animated: true, completion: nil)
                }
                else {
                    
                    let loginViewController = LoginViewController()
                    
                    let navigationViewController = Router.navigationController(with: loginViewController)
                    
                    loginViewController.hasPendingRedirect = true
                    
                    loginViewController.needsRedirect = { [weak self] in
                        self?.openDocuments()
                    }
                    
                    self?.present(navigationViewController, animated: true, completion: nil)
                }
                
            })
            .store(in: &cancellables)
        
    }
    
    func openCustomerSupport() {
        
        //        let supportViewController = SupportPageViewController(viewModel: SupportPageViewModel())
        //
        //        let navigationController = Router.navigationController(with: supportViewController)
        //
        //        self.present(navigationController, animated: true, completion: nil)
        
        if let url = URL(string: TargetVariables.links.support.helpCenter) {
            UIApplication.shared.open(url)
        }
        
    }
    
    func openFavorites() {
        
        Env.userSessionStore.isLoadingUserSessionPublisher
            .filter({ $0 == false })
            .receive(on: DispatchQueue.main)
            .first()
            .sink(receiveValue: { [weak self] _ in
                
                if Env.userSessionStore.isUserLogged() {
                    let myFavoritesViewController = MyFavoritesRootViewController()
                    
                    let navigationController = Router.navigationController(with: myFavoritesViewController)
                    
                    self?.present(navigationController, animated: true, completion: nil)
                }
                else {
                    
                    let loginViewController = LoginViewController()
                    
                    let navigationViewController = Router.navigationController(with: loginViewController)
                    
                    loginViewController.hasPendingRedirect = true
                    
                    loginViewController.needsRedirect = { [weak self] in
                        self?.openFavorites()
                    }
                    
                    self?.present(navigationViewController, animated: true, completion: nil)
                }
                
            })
            .store(in: &cancellables)
        
    }
    
    func openPromotions() {
        
        let promotionsWebViewModel = PromotionsWebViewModel()
        let appLanguage = "fr"
        let isDarkTheme = self.traitCollection.userInterfaceStyle == .dark ? true : false
        let urlString = TargetVariables.generatePromotionsPageUrlString(forAppLanguage: appLanguage, isDarkTheme: isDarkTheme)
        
        if let url = URL(string: urlString) {
            
            let promotionsWebViewController = PromotionsWebViewController(url: url, viewModel: promotionsWebViewModel)
            
            let navigationController = Router.navigationController(with: promotionsWebViewController)
            
            promotionsWebViewController.openHomeAction = { [weak self] in
                self?.dismiss(animated: true)
            }
            
            promotionsWebViewController.openLiveAction = { [weak self] in
                self?.dismiss(animated: true)
                self?.selectLiveTabBarItem()
            }
            
            promotionsWebViewController.openBetSwipeAction = { [weak self] in
                self?.dismiss(animated: true, completion: {
                    self?.openBetswipe()
                })
            }
            promotionsWebViewController.openRegisterAction = { [weak self] in
                self?.dismiss(animated: true, completion: {
                    self?.presentRegisterScreen()
                })
            }
            
            promotionsWebViewController.openContactSettingsAction = { [weak self] in
                self?.dismiss(animated: true, completion: {
                    self?.openContactSettings()
                })
            }
            
            self.present(navigationController, animated: true, completion: nil)
        }
    }
    
    func openRegisterWithCode(code: String) {
        
        self.presentRegisterScreen(withReferralCode: code)
    }
    
    func openResponsibleForm() {
        
        Env.userSessionStore.isLoadingUserSessionPublisher
            .filter({ $0 == false })
            .receive(on: DispatchQueue.main)
            .first()
            .sink(receiveValue: { [weak self] _ in
                
                if Env.userSessionStore.isUserLogged() {
                    let bettingPracticesViewController = BettingPracticesViewController()
                    
                    let navigationController = Router.navigationController(with: bettingPracticesViewController)
                    
                    self?.present(navigationController, animated: true, completion: nil)
                }
                else {
                    
                    let loginViewController = LoginViewController()
                    
                    let navigationViewController = Router.navigationController(with: loginViewController)
                    
                    loginViewController.hasPendingRedirect = true
                    
                    loginViewController.needsRedirect = { [weak self] in
                        self?.openResponsibleForm()
                    }
                    
                    self?.present(navigationViewController, animated: true, completion: nil)
                }
                
            })
            .store(in: &cancellables)
        
    }

    private func openExternalVideo(fromURL url: URL) {
        self.pictureInPictureView?.playVideo(fromURL: url)
    }

    private func presentProfileViewController() {

        // TODO: Enables when marged
//        if let loggedUser = Env.userSessionStore.loggedUserProfile {
//            let profileAlternateViewController = ProfileAlternateViewController()
//
//            let navigationViewController = Router.navigationController(with: profileAlternateViewController)
//
//            self.present(navigationViewController, animated: true)
//        }

    }

    private func presentAnonymousSideMenuViewController() {
        let anonymousSideMenuViewController = AnonymousSideMenuViewController(viewModel: AnonymousSideMenuViewModel())

        let anonymousNavigationViewController = Router.navigationController(with: anonymousSideMenuViewController)

        anonymousSideMenuViewController.requestLoginAction = { [weak self] in
            anonymousNavigationViewController.dismiss(animated: true, completion: {
                self?.presentLoginScreen()
            })
        }

        anonymousSideMenuViewController.requestRegisterAction = { [weak self] in
            anonymousNavigationViewController.dismiss(animated: true, completion: {
                self?.presentRegisterScreen()
            })
        }

        anonymousSideMenuViewController.requestHomeAction = { [weak self] in
            anonymousNavigationViewController.dismiss(animated: true, completion: {
                self?.didTapHomeTabItem()
            })
        }

        anonymousSideMenuViewController.requestBetSwipeAction = { [weak self] in
            anonymousNavigationViewController.dismiss(animated: true, completion: {
                self?.didTapHomeTabItem()
                self?.homeViewController.openBetSwipe()
            })
        }

        self.present(anonymousNavigationViewController, animated: true, completion: nil)
    }

    func hideAnonymousSideMenuViewController() {
        if let presentedViewController = self.presentedViewController {
            if presentedViewController is AnonymousSideMenuViewController {
                presentedViewController.dismiss(animated: true, completion: nil)
            }
            else if let navigationController = presentedViewController as? UINavigationController,
                    navigationController.rootViewController is AnonymousSideMenuViewController {
                navigationController.dismiss(animated: true, completion: nil)
            }
        }
    }

    // Login and register
    private func presentLoginScreen() {
        let loginViewController = Router.navigationController(with: LoginViewController())
        self.present(loginViewController, animated: true, completion: nil)
    }
    
    private func presentRegisterScreen(withReferralCode: String? = nil) {
        let loginViewController = Router.navigationController(with: LoginViewController(shouldPresentRegisterFlow: true, referralCode: withReferralCode))
        self.present(loginViewController, animated: true, completion: nil)
    }

    // Limits
    func checkUserLimitsSet() {

        Publishers.CombineLatest(Env.userSessionStore.shouldRequestLimits(), Env.userSessionStore.loginFlowSuccess)
            .filter({ [weak self] _, loginFlowSuccess in
                loginFlowSuccess == true
            })
            .first()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] limitsValidation, loginFlowSuccess in
                if !limitsValidation.valid && loginFlowSuccess {
                    
                    self?.showLimitsScreenOnRegister(limits: limitsValidation.limits)
                }
            }
            .store(in: &self.cancellables)

    }

    func showLimitsScreenOnRegister(limits: [ResponsibleGamingLimit] = []) {
        if self.presentedViewController?.isModal == true {
            self.presentedViewController?.dismiss(animated: true, completion: nil)
        }

        let limitsOnRegisterViewModel = LimitsOnRegisterViewModel(servicesProvider: Env.servicesProvider, limits: limits)
        
        limitsOnRegisterViewModel.hasRollingWeeklyLimits = Env.businessSettingsSocket.clientSettings.hasRollingWeeklyLimits
        
        let limitsOnRegisterViewController = LimitsOnRegisterViewController.init(viewModel: limitsOnRegisterViewModel)

        limitsOnRegisterViewController.triggeredContinueAction = { [weak self] in
            self?.hideLimitsScreenOnRegister()
        }

        let navigationViewController = Router.navigationController(with: limitsOnRegisterViewController)
        navigationViewController.isModalInPresentation = true
        navigationViewController.modalPresentationStyle = .fullScreen
        self.present(navigationViewController, animated: false, completion: nil)
    }

    func hideLimitsScreenOnRegister() {
        if let presentedViewController = self.presentedViewController {
            if presentedViewController is LimitsOnRegisterViewController {
                presentedViewController.dismiss(animated: true, completion: nil)
            }
            else if let navigationController = presentedViewController as? UINavigationController,
                    navigationController.rootViewController is LimitsOnRegisterViewController {
                navigationController.dismiss(animated: true, completion: nil)
            }
        }
    }

    // Reload data
    func reloadChildViewControllersData() {
        if preLiveViewControllerLoaded {
            self.preLiveViewController.reloadData()
        }
        if liveEventsViewControllerLoaded {
            self.liveEventsViewController.reloadData()
        }
        if homeViewControllerLoaded {
            self.homeViewController.reloadData()
        }
    }

    func reloadViewControllersFromSharedData() {
        if preLiveViewControllerLoaded {
            self.preLiveViewController.reloadData()
        }
        if liveEventsViewControllerLoaded {
            self.liveEventsViewController.reloadData()
        }
        self.homeViewController.reloadData()
    }

    // Load data
    func loadChildViewControllerIfNeeded(tab: RootViewModel.TabItem) {
        if case .home = tab, !homeViewControllerLoaded {
            self.addChildViewController(self.homeViewController, toView: self.homeBaseView)
            self.homeViewController.didTapBetslipButtonAction = { [weak self] in
                self?.openBetslipModal()
            }
            self.homeViewController.didTapChatButtonAction = { [weak self] in
                self?.openChatModal()
            }
            self.homeViewController.didTapExternalVideoAction = { [weak self] url in
                self?.openExternalVideo(fromURL: url)
            }
            self.homeViewController.didTapExternalLinkAction = { [weak self] url in
                self?.openExternalBrowser(onURL: url)
            }
            self.homeViewController.didTapUserProfileAction = { [weak self] userBasicInfo in
                self?.openUserProfile(userBasicInfo: userBasicInfo)
            }
//            self.homeViewController.shouldShowLogin = { [weak self] in
//                self?.presentLoginScreen()
//            }
//            self.homeViewController.requestTipsAction = { [weak self] in
//                self?.didTapTipsTabItem()
//            }
//            self.homeViewController.requestPopularAction = { [weak self] in
//                self?.didTapSportsTabItem()
//            }
            homeViewControllerLoaded = true

        }

        if case .preLive = tab, !preLiveViewControllerLoaded {
            // Iniciar prelive vc
            self.addChildViewController(self.preLiveViewController, toView: self.preLiveBaseView)

            self.preLiveViewController.didChangeSport = { [weak self] newSport in
                self?.didChangedPreLiveSport(newSport)
            }
            self.preLiveViewController.didTapChatButtonAction = { [weak self] in
                self?.openChatModal()
            }
            self.preLiveViewController.didTapBetslipButtonAction = { [weak self] in
                self?.openBetslipModal()
            }
            preLiveViewControllerLoaded = true
        }

        if case .live = tab, !liveEventsViewControllerLoaded {
            self.addChildViewController(self.liveEventsViewController, toView: self.liveBaseView)

            self.liveEventsViewController.didChangeSport = { [weak self] newSport in
                self?.didChangedLiveSport(newSport)
            }
            self.liveEventsViewController.didTapChatButtonAction = { [weak self] in
                self?.openChatModal()
            }
            self.liveEventsViewController.didTapBetslipButtonAction = { [weak self] in
                self?.openBetslipModal()
            }
            liveEventsViewControllerLoaded = true
        }

        if case .tips = tab, !tipsRootViewControllerLoaded {
            self.addChildViewController(self.tipsRootViewController, toView: self.tipsBaseView)

            self.tipsRootViewController.didTapBetslipButtonAction = { [weak self] in
                self?.openBetslipModal()
            }
            self.tipsRootViewController.didTapChatButtonAction = { [weak self] in
                self?.openChatModal()
            }
            self.tipsRootViewController.shouldShowUserProfile = { [weak self] userBasicInfo in
                self?.openUserProfile(userBasicInfo: userBasicInfo)
            }
//            self.tipsRootViewController.shouldShowLogin = { [weak self] in
//                self?.presentLoginScreen()
//            }

            tipsRootViewControllerLoaded = true
        }

        if case .tickets = tab, !ticketsRootViewControllerLoaded {

//            self.myTicketsRootViewController.showFloatingShortcuts = true

            self.addChildViewController(self.myTicketsRootViewController, toView: self.ticketsBaseView)

//            self.myTicketsRootViewController.didTapBetslipButtonAction = { [weak self] in
//                self?.openBetslipModal()
//            }
//            self.myTicketsRootViewController.didTapChatButtonAction = { [weak self] in
//                self?.openChatModal()
//            }

            ticketsRootViewControllerLoaded = true
        }

        if case .featuredCompetition = tab, !featuredCompetitionViewControllerLoaded {

            if let featuredCompetitionViewController = self.featuredCompetitionViewController {
                self.addChildViewController(featuredCompetitionViewController, toView: self.featuredCompetitionBaseView)

                // Cashback Callbacks if needed

                featuredCompetitionViewControllerLoaded = true
            }

        }
        if case .casino = tab, !casinoViewControllerLoaded {
            self.searchButton.isHidden = true

//            self.casinoViewController.modalPresentationStyle = .fullScreen
            self.casinoViewController.navigationItem.hidesBackButton = true
            self.addChildViewController(self.casinoViewController, toView: self.casinoBaseView)
        }
        
        if case .cashback = tab, !cashbackViewControllerLoaded {
            self.addChildViewController(self.cashbackViewController, toView: self.cashbackBaseView)

            // Cashback Callbacks if needed

            cashbackViewControllerLoaded = true
        }

    }

    // User functions
    func authenticateUser() {

        if Env.userSessionStore.shouldAuthenticateUser {
            print("LocalAuth shouldAuthenticateUser yes")
        }
        else {
            print("LocalAuth shouldAuthenticateUser no")
            self.unlockAppWithUser()
            return
        }

        if !Env.userSessionStore.shouldRequestBiometrics() {
            self.unlockAppAnonymous()
            return
        }

        let context = LAContext()

        var error: NSError?
        if context.canEvaluatePolicy(LAPolicy.deviceOwnerAuthentication, error: &error) {

            // Device can use biometric authentication
            context.evaluatePolicy(
                LAPolicy.deviceOwnerAuthentication,
                localizedReason: localized("access_requires_authentication"),
                reply: { success, error in
                    DispatchQueue.main.async {
                        if let err = error {
                            switch err._code {
                            case LAError.Code.systemCancel.rawValue:
                                self.notifyUser(localized("session_cancelled"), errorMessage: err.localizedDescription)
                            case LAError.Code.userCancel.rawValue:
                                self.notifyUser(localized("please_try_again"), errorMessage: err.localizedDescription)
                            case LAError.Code.userFallback.rawValue:
                                self.notifyUser(localized("authentication"), errorMessage: localized("password_option_selected"))
                            default:
                                self.notifyUser(localized("authentication_failed"), errorMessage: err.localizedDescription)
                            }
                        }
                        else {
                            self.unlockAppWithUser()
                        }
                    }
            })
        }
        else {
            // Device cannot use biometric authentication
            if let err = error {
                switch err.code {
                case LAError.Code.biometryNotEnrolled.rawValue:
                    notifyUser(localized("user_not_enrolled"), errorMessage: err.localizedDescription)
                case LAError.Code.passcodeNotSet.rawValue:
                    notifyUser(localized("passcode_not_set"), errorMessage: err.localizedDescription)
                case LAError.Code.biometryNotAvailable.rawValue:
                    notifyUser(localized("biometric_auth_not_available"), errorMessage: err.localizedDescription)
                default:
                    notifyUser(localized("unknown_error"), errorMessage: err.localizedDescription)
                }
            }

        }

    }

    func notifyUser(_ title: String, errorMessage: String?) {
        let alert = UIAlertController(title: title,
                                      message: errorMessage,
                                      preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: localized("ok"),
                                         style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
    }

    // MARK: Actions
    @objc private func windowDidResignKeyNotification(_ notification: NSNotification) {
        if let actorWindow = notification.object as? UIWindow {
            if actorWindow == self.view.window {
                print("WindowNotification main window resigning")
            }
            else if actorWindow == self.overlayWindow {
                print("WindowNotification overlayWindow window resigning")
            }
            else {
                print("WindowNotification other window resigning")
            }
        }
    }

    @objc private func windowDidBecomeKeyNotification(_ notification: NSNotification) {
        if let actorWindow = notification.object as? UIWindow {
            if actorWindow == self.view.window {
                print("WindowNotification main window active")
            }
            else if actorWindow == self.overlayWindow {
                print("WindowNotification overlayWindow window active")
                self.pictureInPictureView?.isHidden = false
            }
            else {
                print("WindowNotification other window active")
                self.pictureInPictureView?.isHidden = true
            }
        }
    }

    @objc private func didTapSearchButton() {
        let searchViewModel = SearchViewModel()

        let searchViewController = SearchViewController(viewModel: searchViewModel)

        let navigationViewController = Router.navigationController(with: searchViewController)
        self.present(navigationViewController, animated: true, completion: nil)
    }

    @objc func didTapLogoImageView() {

    }

    @objc private func didTapLoginButton() {
        self.presentLoginScreen()
    }

    @objc private func didTapLoginAlternateButton() {
        self.presentLoginScreen()
    }

    @objc private func didTapProfileButton() {
        self.presentProfileViewController()
    }

    @objc private func didTapAccountValue() {
        let depositViewController = DepositViewController()
        let navigationViewController = Router.navigationController(with: depositViewController)
        depositViewController.shouldRefreshUserWallet = { [weak self] in
            Env.userSessionStore.refreshUserWallet()
        }
        self.present(navigationViewController, animated: true, completion: nil)
    }

    @objc private func didTapAnonymousButton() {
        self.presentAnonymousSideMenuViewController()
    }

    @objc private func didTapCasinoTabItem() {
        self.flipToCasinoIfNeeded()

        self.selectedTabItem = .casino
    }
}

// MARK: Bottom bar items
extension RootViewController {

    // Tab functions
    func selectHomeTabBarItem() {

        self.loadChildViewControllerIfNeeded(tab: .home)

        self.homeBaseView.isHidden = false
        self.preLiveBaseView.isHidden = true
        self.liveBaseView.isHidden = true
        self.tipsBaseView.isHidden = true
        self.cashbackBaseView.isHidden = true
        self.ticketsBaseView.isHidden = true
        self.featuredCompetitionBaseView.isHidden = true

        self.redrawButtonButtons()
    }

    func selectSportsTabBarItem() {
        self.loadChildViewControllerIfNeeded(tab: .preLive)

        self.homeBaseView.isHidden = true
        self.preLiveBaseView.isHidden = false
        self.liveBaseView.isHidden = true
        self.tipsBaseView.isHidden = true
        self.cashbackBaseView.isHidden = true
        self.ticketsBaseView.isHidden = true
        self.featuredCompetitionBaseView.isHidden = true

        self.redrawButtonButtons()
    }

    func selectLiveTabBarItem() {
        self.loadChildViewControllerIfNeeded(tab: .live)

        self.homeBaseView.isHidden = true
        self.preLiveBaseView.isHidden = true
        self.liveBaseView.isHidden = false
        self.tipsBaseView.isHidden = true
        self.cashbackBaseView.isHidden = true
        self.ticketsBaseView.isHidden = true
        self.featuredCompetitionBaseView.isHidden = true

        self.redrawButtonButtons()
    }

    func selectTipsTabBarItem() {
        self.loadChildViewControllerIfNeeded(tab: .tips)

        self.homeBaseView.isHidden = true
        self.preLiveBaseView.isHidden = true
        self.liveBaseView.isHidden = true
        self.tipsBaseView.isHidden = false
        self.cashbackBaseView.isHidden = true
        self.ticketsBaseView.isHidden = true
        self.featuredCompetitionBaseView.isHidden = true

        self.redrawButtonButtons()
    }

    func selectTicketsTabBarItem() {
        self.loadChildViewControllerIfNeeded(tab: .tickets)

        self.homeBaseView.isHidden = true
        self.preLiveBaseView.isHidden = true
        self.liveBaseView.isHidden = true
        self.tipsBaseView.isHidden = true
        self.cashbackBaseView.isHidden = true
        self.ticketsBaseView.isHidden = false
        self.featuredCompetitionBaseView.isHidden = true

        self.redrawButtonButtons()
    }
    
    func selectCashbackTabBarItem() {
        self.loadChildViewControllerIfNeeded(tab: .cashback)

        self.homeBaseView.isHidden = true
        self.preLiveBaseView.isHidden = true
        self.liveBaseView.isHidden = true
        self.tipsBaseView.isHidden = true
        self.cashbackBaseView.isHidden = false
        self.ticketsBaseView.isHidden = true
        self.featuredCompetitionBaseView.isHidden = true
        self.redrawButtonButtons()
    }

    func selectFeaturedCompetitionTabBarItem() {
        self.loadChildViewControllerIfNeeded(tab: .featuredCompetition)

        self.homeBaseView.isHidden = true
        self.preLiveBaseView.isHidden = true
        self.liveBaseView.isHidden = true
        self.tipsBaseView.isHidden = true
        self.cashbackBaseView.isHidden = true
        self.ticketsBaseView.isHidden = true
        self.featuredCompetitionBaseView.isHidden = false

        self.redrawButtonButtons()
    }

    func selectCasinoTabBarItem() {
        self.loadChildViewControllerIfNeeded(tab: .casino)

        self.redrawButtonButtons()
    }

    func redrawButtonButtons() {

        switch self.selectedTabItem {
        case .home:
            homeButtonBaseView.alpha = self.activeButtonAlpha
            homeTitleLabel.textColor = UIColor.App.highlightPrimary
            homeIconImageView.setImageColor(color: UIColor.App.highlightPrimary)
            sportsTitleLabel.textColor = UIColor.App.iconSecondary
            sportsIconImageView.setImageColor(color: UIColor.App.iconSecondary)
            liveTitleLabel.textColor = UIColor.App.iconSecondary
            liveIconImageView.setImageColor(color: UIColor.App.iconSecondary)
            tipsTitleLabel.textColor = UIColor.App.iconSecondary
            tipsIconImageView.setImageColor(color: UIColor.App.iconSecondary)
            cashbackTitleLabel.textColor = UIColor.App.iconSecondary
            cashbackIconImageView.setImageColor(color: UIColor.App.iconSecondary)
            myTicketsTitleLabel.textColor = UIColor.App.iconSecondary
            myTicketsIconImageView.setImageColor(color: UIColor.App.iconSecondary)
            featuredCompetitionTitleLabel.textColor = UIColor.App.iconSecondary
        case .preLive:
            sportsButtonBaseView.alpha = self.activeButtonAlpha
            homeTitleLabel.textColor = UIColor.App.iconSecondary
            homeIconImageView.setImageColor(color: UIColor.App.iconSecondary)
            sportsTitleLabel.textColor = UIColor.App.highlightPrimary
            sportsIconImageView.setImageColor(color: UIColor.App.highlightPrimary)
            liveTitleLabel.textColor = UIColor.App.iconSecondary
            liveIconImageView.setImageColor(color: UIColor.App.iconSecondary)
            tipsTitleLabel.textColor = UIColor.App.iconSecondary
            tipsIconImageView.setImageColor(color: UIColor.App.iconSecondary)
            cashbackTitleLabel.textColor = UIColor.App.iconSecondary
            cashbackIconImageView.setImageColor(color: UIColor.App.iconSecondary)
            myTicketsTitleLabel.textColor = UIColor.App.iconSecondary
            myTicketsIconImageView.setImageColor(color: UIColor.App.iconSecondary)
            featuredCompetitionTitleLabel.textColor = UIColor.App.iconSecondary
        case .live:
            liveButtonBaseView.alpha = self.activeButtonAlpha
            homeTitleLabel.textColor = UIColor.App.iconSecondary
            homeIconImageView.setImageColor(color: UIColor.App.iconSecondary)
            sportsTitleLabel.textColor = UIColor.App.iconSecondary
            sportsIconImageView.setImageColor(color: UIColor.App.iconSecondary)
            liveTitleLabel.textColor = UIColor.App.highlightPrimary
            liveIconImageView.setImageColor(color: UIColor.App.highlightPrimary)
            tipsTitleLabel.textColor = UIColor.App.iconSecondary
            tipsIconImageView.setImageColor(color: UIColor.App.iconSecondary)
            cashbackTitleLabel.textColor = UIColor.App.iconSecondary
            cashbackIconImageView.setImageColor(color: UIColor.App.iconSecondary)
            myTicketsTitleLabel.textColor = UIColor.App.iconSecondary
            myTicketsIconImageView.setImageColor(color: UIColor.App.iconSecondary)
            featuredCompetitionTitleLabel.textColor = UIColor.App.iconSecondary
        case .tips:
            tipsButtonBaseView.alpha = self.activeButtonAlpha
            homeTitleLabel.textColor = UIColor.App.iconSecondary
            homeIconImageView.setImageColor(color: UIColor.App.iconSecondary)
            sportsTitleLabel.textColor = UIColor.App.iconSecondary
            sportsIconImageView.setImageColor(color: UIColor.App.iconSecondary)
            liveTitleLabel.textColor = UIColor.App.iconSecondary
            liveIconImageView.setImageColor(color: UIColor.App.iconSecondary)
            tipsTitleLabel.textColor = UIColor.App.highlightPrimary
            tipsIconImageView.setImageColor(color: UIColor.App.highlightPrimary)
            cashbackTitleLabel.textColor = UIColor.App.iconSecondary
            cashbackIconImageView.setImageColor(color: UIColor.App.iconSecondary)
            myTicketsTitleLabel.textColor = UIColor.App.iconSecondary
            myTicketsIconImageView.setImageColor(color: UIColor.App.iconSecondary)
            featuredCompetitionTitleLabel.textColor = UIColor.App.iconSecondary
        case .tickets:
            tipsButtonBaseView.alpha = self.activeButtonAlpha
            homeTitleLabel.textColor = UIColor.App.iconSecondary
            homeIconImageView.setImageColor(color: UIColor.App.iconSecondary)
            sportsTitleLabel.textColor = UIColor.App.iconSecondary
            sportsIconImageView.setImageColor(color: UIColor.App.iconSecondary)
            liveTitleLabel.textColor = UIColor.App.iconSecondary
            liveIconImageView.setImageColor(color: UIColor.App.iconSecondary)
            tipsTitleLabel.textColor = UIColor.App.iconSecondary
            tipsIconImageView.setImageColor(color: UIColor.App.iconSecondary)
            cashbackTitleLabel.textColor = UIColor.App.iconSecondary
            cashbackIconImageView.setImageColor(color: UIColor.App.iconSecondary)
            myTicketsTitleLabel.textColor = UIColor.App.highlightPrimary
            myTicketsIconImageView.setImageColor(color: UIColor.App.highlightPrimary)
            featuredCompetitionTitleLabel.textColor = UIColor.App.iconSecondary

        case .featuredCompetition:
            featuredCompetitionButtonBaseView.alpha = self.activeButtonAlpha

            homeTitleLabel.textColor = UIColor.App.iconSecondary
            homeIconImageView.setImageColor(color: UIColor.App.iconSecondary)
            sportsTitleLabel.textColor = UIColor.App.iconSecondary
            sportsIconImageView.setImageColor(color: UIColor.App.iconSecondary)
            liveTitleLabel.textColor = UIColor.App.iconSecondary
            liveIconImageView.setImageColor(color: UIColor.App.iconSecondary)
            tipsTitleLabel.textColor = UIColor.App.iconSecondary
            tipsIconImageView.setImageColor(color: UIColor.App.iconSecondary)
            cashbackTitleLabel.textColor = UIColor.App.iconSecondary
            cashbackIconImageView.setImageColor(color: UIColor.App.iconSecondary)
            myTicketsTitleLabel.textColor = UIColor.App.iconSecondary
            myTicketsIconImageView.setImageColor(color: UIColor.App.iconSecondary)
            featuredCompetitionTitleLabel.textColor = UIColor.App.highlightPrimary

        case .casino:
            homeTitleLabel.textColor = UIColor.App.iconSecondary
            homeIconImageView.setImageColor(color: UIColor.App.iconSecondary)
            sportsTitleLabel.textColor = UIColor.App.iconSecondary
            sportsIconImageView.setImageColor(color: UIColor.App.iconSecondary)
            liveTitleLabel.textColor = UIColor.App.iconSecondary
            liveIconImageView.setImageColor(color: UIColor.App.iconSecondary)
        case .cashback:
            cashbackButtonBaseView.alpha = self.activeButtonAlpha
            homeTitleLabel.textColor = UIColor.App.iconSecondary
            homeIconImageView.setImageColor(color: UIColor.App.iconSecondary)
            sportsTitleLabel.textColor = UIColor.App.iconSecondary
            sportsIconImageView.setImageColor(color: UIColor.App.iconSecondary)
            liveTitleLabel.textColor = UIColor.App.iconSecondary
            liveIconImageView.setImageColor(color: UIColor.App.iconSecondary)
            tipsTitleLabel.textColor = UIColor.App.iconSecondary
            tipsIconImageView.setImageColor(color: UIColor.App.iconSecondary)
            cashbackTitleLabel.textColor = UIColor.App.highlightPrimary
            cashbackIconImageView.setImageColor(color: UIColor.App.highlightPrimary)
            myTicketsTitleLabel.textColor = UIColor.App.iconSecondary
            myTicketsIconImageView.setImageColor(color: UIColor.App.iconSecondary)
            featuredCompetitionTitleLabel.textColor = UIColor.App.iconSecondary
        }

    }

    func flipToCasinoIfNeeded() {
        if self.appMode == .casino {
            return
        }

        self.appMode = .casino
        self.searchButton.isHidden = true

        UIView.animate(withDuration: 0.35,
                       delay: 0.0,
                       options: .curveEaseInOut,
                       animations: {

            self.sportsBookContentView.alpha = 0.45
            self.casinoContentView.alpha = 1.0

            self.leadingSportsBookContentConstriant.constant = -self.containerView.frame.size.width

            self.view.setNeedsLayout()
            self.view.layoutIfNeeded()

        }, completion: nil)

    }

    func flipToSportsbookIfNeeded() {
        if self.appMode == .sportsbook {
            return
        }

        self.appMode = .sportsbook
        self.searchButton.isHidden = false

        UIView.animate(withDuration: 0.35,
                       delay: 0.0,
                       options: .curveEaseInOut,
                       animations: {

            self.sportsBookContentView.alpha = 1.0
            self.casinoContentView.alpha = 0.45

            self.leadingSportsBookContentConstriant.constant = 0

            self.view.setNeedsLayout()
            self.view.layoutIfNeeded()

        }, completion: nil)

    }

    // Tab items actions
    @objc private func didTapHomeTabItem() {

        if self.selectedTabItem == .home {
            self.homeViewController.scrollToTop()
        }

        self.selectedTabItem = .home

    }

    @objc private func didTapSportsTabItem() {
        if self.selectedTabItem == .preLive {
            self.preLiveViewController.scrollToTop()
        }

        self.selectedTabItem = .preLive
    }

    @objc private func didTapLiveTabItem() {
        if self.selectedTabItem == .live {
            self.liveEventsViewController.scrollToTop()
        }

        self.selectedTabItem = .live
    }

    @objc private func didTapTipsTabItem() {

        self.selectedTabItem = .tips
    }

    @objc private func didTapCashbackTabItem() {
        self.selectedTabItem = .cashback
    }

    @objc private func didTapTicketsTabItem() {

        self.selectedTabItem = .tickets
    }

    @objc private func didTapFeaturedCompetitionTabItem() {

        if self.selectedTabItem == .featuredCompetition {
            self.featuredCompetitionViewController?.scrollToTop()
        }

        self.selectedTabItem = .featuredCompetition
    }

    @objc private func didTapSportsbookIcon() {

        self.flipToSportsbookIfNeeded()

        self.selectedTabItem = .home
    }
}

// MARK: App States
extension RootViewController {

    // App States
    func unlockAppWithUser() {
        // Unlock the app

        Env.userSessionStore.startUserSession()
    }

    func unlockAppAnonymous() {
        Env.userSessionStore.logout()
        self.isLocalAuthenticationCoveringView = false
    }

    func showLocalAuthenticationCoveringViewIfNeeded() {
        if Env.userSessionStore.shouldRequestBiometrics() {
            self.isLocalAuthenticationCoveringView = true
        }
    }

    // App states actions
    @objc private func didTapUnlockButton() {
        self.authenticateUser()
    }

    @objc private func didTapCancelUnlockButton() {
        self.unlockAppAnonymous()
    }

    @objc func appWillEnterForeground() {
        if Env.userSessionStore.shouldRequestBiometrics() {
            self.authenticateUser()
        }
        else if Env.userSessionStore.isUserLogged() {

        }
        print("LocalAuth Foreground")
    }

    @objc func appDidEnterBackground() {
//        Env.userSessionStore.shouldAuthenticateUser = true
//
//        self.showLocalAuthenticationCoveringViewIfNeeded()
//        print("LocalAuth Background")
    }

    @objc func appDidBecomeActive() {
        // self.authenticateUser()
        print("LocalAuth Active")

        self.reloadChildViewControllersData()
    }

    @objc func appWillResignActive() {
        // self.showLocalAuthenticationCoveringViewIfNeeded()
        print("LocalAuth Inactive")
    }
}

// MARK: Popups
extension RootViewController {

    func requestPopUpContent() {
        if TargetVariables.hasFeatureEnabled(feature: .homePopUps) {
            Env.gomaNetworkClient.requestPopUpInfo(deviceId: Env.deviceId)
                .compactMap({$0})
                .receive(on: DispatchQueue.main)
                .sink(receiveValue: { popUpDetails in
                    print("popUpDetails \(popUpDetails)")
                })
                .store(in: &cancellables)
        }
    }

    func showPopUp(_ details: PopUpDetails) {

        if !PopUpStore.shouldShowPopUp(withId: details.id) {
            return
        }

        self.popUpPromotionView = PopUpPromotionView(details)
        self.popUpBackgroundView = UIView()

        guard
            let popUpBackgroundView = self.popUpBackgroundView,
            let popUpPromotionView = self.popUpPromotionView
        else {
            return
        }

        popUpPromotionView.translatesAutoresizingMaskIntoConstraints = false
        popUpPromotionView.alpha = 0
        popUpPromotionView.didTapCloseButton = { [weak self] in
            PopUpStore.didHidePopUp(withId: details.id, withTimeout: details.intervalMinutes ?? 0)
            self?.closePopUp()
        }
        popUpPromotionView.didTapPromotionButton = { [weak self] link in
            if let link = link, let url = URL(string: link) {
                UIApplication.shared.open(url)
            }
            PopUpStore.didHidePopUp(withId: details.id, withTimeout: details.intervalMinutes ?? 0)
            AnalyticsClient.sendEvent(event: .infoDialogButtonClicked)
            self?.closePopUp()
        }

        popUpBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        popUpBackgroundView.backgroundColor = .black
        popUpBackgroundView.alpha = 0.0

        self.view.addSubview(popUpBackgroundView)
        self.view.addSubview(popUpPromotionView)

        self.view.addSubview(popUpBackgroundView, anchors: [.top(0), .bottom(0), .leading(0), .trailing(0)])
        self.view.addSubview(popUpPromotionView, anchors: [.centerX(0), .centerY(0), .width(338)])

        popUpPromotionView.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)

        UIView.animate(withDuration: 0.5) {
            popUpBackgroundView.alpha = 0.58
        }
        UIView.animate(
            withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.55, initialSpringVelocity: 3,
            options: .curveEaseOut, animations: {
                popUpPromotionView.transform = .identity
                popUpPromotionView.alpha = 1
        }, completion: nil)

    }

    func closePopUp() {

        guard
            let popUpBackgroundView = self.popUpBackgroundView,
            let popUpPromotionView = self.popUpPromotionView
        else {
            return
        }

        UIView.animate(withDuration: 0.5) {
            popUpBackgroundView.alpha = 0.0
        }

        UIView.animate(
            withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.55, initialSpringVelocity: 3,
            options: .curveEaseOut, animations: {
            popUpPromotionView.alpha = 0
            popUpPromotionView.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        }, completion: { _ in
            popUpBackgroundView.removeFromSuperview()
            popUpPromotionView.removeFromSuperview()
        })

    }
}

// MARK: - Shake Gesture Handling
extension RootViewController {

    override var canBecomeFirstResponder: Bool {
        return true
    }

    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            self.presentColorDebugPanel()
        }
    }

    private func presentColorDebugPanel() {
//        let colorDebugVC = ColorDebugViewController()
//        let navController = UINavigationController(rootViewController: colorDebugVC)
//        navController.modalPresentationStyle = .formSheet
//        present(navController, animated: true)
    }
}

extension RootViewController {
    private static func createTopSafeAreaView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createTopBarContainerBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createTopBarView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createProfileStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.distribution = .equalSpacing
        stackView.spacing = 4
        return stackView
    }

    private static func createAccountStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.distribution = .equalSpacing
        stackView.spacing = 4
        return stackView
    }

    private static func createTopGradientBackgroundView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createContainerView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createMainContainerView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createMainContainerGradientView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createBottomBackgroundView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createSportsBookContentView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createCasinoContentView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createHomeBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createPreLiveBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createLiveBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createTipsBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createCashbackBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createCasinoBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createTicketsBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createFeaturedCompetitionBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createTabBarView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createTabBarStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 16
        return stackView
    }

    private static func createBottomSafeAreaView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createCasinoBottomView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createSportsButtonBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createSportsIconImageView() -> UIImageView {
        let imageView = UIImageView(image: UIImage(named: "tabbar_sports_icon"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }

    private static func createSportsTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.text = localized("sports")
        label.font = AppFont.with(type: .bold, size: 10)
        return label
    }

    private static func createHomeButtonBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createHomeIconImageView() -> UIImageView {
        let imageView = UIImageView(image: UIImage(named: "tabbar_home_icon"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }

    private static func createHomeTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.text = localized("home")
        label.font = AppFont.with(type: .bold, size: 10)
        return label
    }

    private static func createLiveButtonBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createLiveIconImageView() -> UIImageView {
        let imageView = UIImageView(image: UIImage(named: "tabbar_live_icon"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }

    private static func createLiveTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.text = localized("live")
        label.font = AppFont.with(type: .bold, size: 10)
        return label
    }

    private static func createTipsButtonBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createTipsIconImageView() -> UIImageView {
        let imageView = UIImageView(image: UIImage(named: "tabbar_tips_icon"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }

    private static func createTipsTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.text = localized("tips")
        label.font = AppFont.with(type: .bold, size: 10)
        return label
    }

    private static func createCashbackButtonBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createCashbackIconImageView() -> UIImageView {
        let imageView = UIImageView(image: UIImage(named: "cashback_bar_icon"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }

    private static func createCashbackTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.text = localized("cashback")
        label.font = AppFont.with(type: .bold, size: 10)
        return label
    }

    private static func createMyTicketsButtonBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createMyTicketsIconImageView() -> UIImageView {
        let imageView = UIImageView(image: UIImage(named: "tabbar_my_tickets"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }

    private static func createMyTicketsTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.text = localized("my_tickets")
        label.font = AppFont.with(type: .bold, size: 10)
        return label
    }

    private static func createFeaturedCompetitionButtonBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createFeaturedCompetitionIconImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }

    private static func createFeaturedCompetitionTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.text = localized("featured_competition")
        label.font = AppFont.with(type: .bold, size: 10)
        return label
    }

    private static func createCasinoButtonBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createCasinoIconImageView() -> UIImageView {
        let imageView = UIImageView(image: UIImage(named: "casino_icon"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }

    private static func createCasinoTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.text = localized("casino")
        label.font = AppFont.with(type: .bold, size: 10)
        return label
    }

    private static func createSportsbookButtonBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createSportsbookIconImageView() -> UIImageView {
        let imageView = UIImageView(image: UIImage(named: "sportsbook_icon"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }

    private static func createSportsbookTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.text = localized("sportsbook")
        label.font = AppFont.with(type: .bold, size: 10)
        return label
    }

    private static func createProfileBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createProfilePictureBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        view.layer.cornerRadius = 15
        view.clipsToBounds = true
        return view
    }

    private static func createProfilePictureBaseInnerView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createProfilePictureImageView() -> UIImageView {
        let imageView = UIImageView(image: UIImage(named: "empty_user_image"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }

    private static func createAnonymousUserMenuBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createAnonymousUserMenuImageView() -> UIImageView {
        let imageView = UIImageView(image: UIImage(named: "side_menu_icon"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }

    private static func createSearchButton() -> UIButton {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(named: "search_bar_icon"), for: .normal)
        return button
    }

    private static func createLogoImageBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createLogoImageView() -> UIImageView {
        let imageView = UIImageView(image: UIImage(named: "logo_horizontal_left"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }

    private static func createLoginBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createLoginButton() -> UIButton {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(localized("login"), for: .normal)
        button.titleLabel?.font = AppFont.with(type: AppFont.AppFontType.bold, size: 13)
        button.setTitleColor(UIColor.App.bubblesPrimary, for: .normal)
        return button
    }

    private static func createAccountValueBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        view.isUserInteractionEnabled = true
        return view
    }

    private static func createAccountValueView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.App.backgroundSecondary
        view.layer.cornerRadius = 13.5
        view.clipsToBounds = true
        return view
    }

    private static func createAccountPlusView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.App.highlightSecondary
        view.layer.cornerRadius = 9.5
        view.clipsToBounds = true
        return view
    }

    private static func createAccountValueLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = localized("loading")
        label.font = AppFont.with(type: .bold, size: 12)
        label.textAlignment = .center
        return label
    }

    private static func createAccountPlusImageView() -> UIImageView {
        let imageView = UIImageView(image: UIImage(named: "plus_small_icon"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }

    private static func createNotificationCounterView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createNotificationCounterLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFont.with(type: .semibold, size: 12)
        label.textAlignment = .center
        return label
    }

    private static func createLocalAuthenticationBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createUnlockAppButton() -> UIButton {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(localized("unlock_app"), for: .normal)
        button.layer.cornerRadius = CornerRadius.button
        return button
    }

    private static func createCancelUnlockAppButton() -> UIButton {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(localized("cancel_unlock_app"), for: .normal)
        button.layer.cornerRadius = CornerRadius.button
        return button
    }

    private static func createLoadingUserSessionView() -> UIActivityIndicatorView {
        let view = UIActivityIndicatorView(style: .large)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.hidesWhenStopped = true
        return view
    }

    //
    private static func createOverlayWindow() -> PassthroughWindow {
        var overlayWindow: PassthroughWindow = PassthroughWindow(frame: UIScreen.main.bounds)
        overlayWindow.windowLevel = .alert
        return overlayWindow
    }

    private static func createBlockingWindow() -> BlockingWindow {
        var blockingWindow: BlockingWindow = BlockingWindow(frame: UIScreen.main.bounds)
        blockingWindow.windowLevel = .statusBar
        return blockingWindow
    }

    private static func createTopBarAlternateView() -> TopBarView {
        let topBar = TopBarView()
        topBar.translatesAutoresizingMaskIntoConstraints = false
        return topBar
    }

    // Constraints
    private static func createLeadingSportsBookContentConstriant() -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint()
        return constraint
    }

    private static func createLogoImageWidthConstraint() -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint()
        return constraint
    }

    private static func createLogoImageHeightConstraint() -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint()
        return constraint
    }

    private func setupSubviews() {

        // Add main container views
        self.view.addSubview(self.topSafeAreaView)
        self.view.addSubview(self.topBarContainerBaseView)
        self.view.addSubview(self.containerView)
        self.view.addSubview(self.bottomSafeAreaView)
        self.view.addSubview(self.localAuthenticationBaseView)

        // Add top bar elements
        self.topBarContainerBaseView.addSubview(self.topBarView)

        self.topBarView.addSubview(self.profileStackView)

        self.profileStackView.addArrangedSubview(self.profileBaseView)

        self.profileBaseView.addSubview(self.anonymousUserMenuBaseView)

        self.anonymousUserMenuBaseView.addSubview(anonymousUserMenuImageView)

        self.profileBaseView.addSubview(profilePictureBaseView)

        self.profilePictureBaseView.addSubview(profilePictureBaseInnerView)

        self.profilePictureBaseInnerView.addSubview(profilePictureImageView)

        self.profilePictureBaseView.addSubview(self.notificationCounterView)

        self.notificationCounterView.addSubview(self.notificationCounterLabel)

        self.profileStackView.addArrangedSubview(self.logoImageBaseView)

        self.logoImageBaseView.addSubview(self.logoImageView)

        self.topBarView.addSubview(self.accountStackView)

        self.accountStackView.addArrangedSubview(self.accountValueBaseView)

        self.accountValueBaseView.addSubview(accountValueView)

        self.accountValueView.addSubview(accountPlusView)
        self.accountPlusView.addSubview(accountPlusImageView)

        self.accountValueView.addSubview(accountValueLabel)

        self.accountStackView.addArrangedSubview(self.loginBaseView)

        self.loginBaseView.addSubview(self.loginButton)

        self.accountStackView.addArrangedSubview(self.searchButton)

        // Setup container views
        self.containerView.addSubview(self.mainContainerView)

        self.mainContainerView.addSubview(self.sportsBookContentView)

        // Setup content views
        self.sportsBookContentView.addSubview(self.homeBaseView)
        self.sportsBookContentView.addSubview(self.preLiveBaseView)
        self.sportsBookContentView.addSubview(self.liveBaseView)
        self.sportsBookContentView.addSubview(self.tipsBaseView)
        self.sportsBookContentView.addSubview(self.cashbackBaseView)
        self.sportsBookContentView.addSubview(self.ticketsBaseView)
        self.sportsBookContentView.addSubview(self.featuredCompetitionBaseView)

        // Setup tab bar
        self.mainContainerView.addSubview(self.tabBarView)

        self.tabBarView.addSubview(self.tabBarStackView)

        self.tabBarStackView.addArrangedSubview(self.homeButtonBaseView)

        self.homeButtonBaseView.addSubview(self.homeIconImageView)
        self.homeButtonBaseView.addSubview(self.homeTitleLabel)

        self.tabBarStackView.addArrangedSubview(self.sportsButtonBaseView)

        self.sportsButtonBaseView.addSubview(self.sportsIconImageView)
        self.sportsButtonBaseView.addSubview(self.sportsTitleLabel)

        self.tabBarStackView.addArrangedSubview(self.featuredCompetitionButtonBaseView)

        self.featuredCompetitionButtonBaseView.addSubview(self.featuredCompetitionIconImageView)
        self.featuredCompetitionButtonBaseView.addSubview(self.featuredCompetitionTitleLabel)

        self.tabBarStackView.addArrangedSubview(self.liveButtonBaseView)

        self.liveButtonBaseView.addSubview(self.liveIconImageView)
        self.liveButtonBaseView.addSubview(self.liveTitleLabel)

        self.tabBarStackView.addArrangedSubview(self.tipsButtonBaseView)

        self.tipsButtonBaseView.addSubview(self.tipsIconImageView)
        self.tipsButtonBaseView.addSubview(self.tipsTitleLabel)

        self.tabBarStackView.addArrangedSubview(self.cashbackButtonBaseView)

        self.cashbackButtonBaseView.addSubview(self.cashbackIconImageView)
        self.cashbackButtonBaseView.addSubview(self.cashbackTitleLabel)

        self.tabBarStackView.addArrangedSubview(self.myTicketsButtonBaseView)

        self.myTicketsButtonBaseView.addSubview(self.myTicketsIconImageView)
        self.myTicketsButtonBaseView.addSubview(self.myTicketsTitleLabel)

        self.tabBarView.addSubview(casinoButtonBaseView)

        self.casinoButtonBaseView.addSubview(self.casinoIconImageView)
        self.casinoButtonBaseView.addSubview(self.casinoTitleLabel)

        self.containerView.addSubview(self.casinoContentView)

        self.casinoContentView.addSubview(self.casinoBaseView)
        self.casinoContentView.addSubview(self.casinoBottomView)

        self.casinoBottomView.addSubview(self.sportsbookButtonBaseView)

        self.sportsbookButtonBaseView.addSubview(self.sportsbookIconImageView)
        self.sportsbookButtonBaseView.addSubview(self.sportsbookTitleLabel)

        self.localAuthenticationBaseView.addSubview(unlockAppButton)
        self.localAuthenticationBaseView.addSubview(cancelUnlockAppButton)
        self.localAuthenticationBaseView.addSubview(isLoadingUserSessionView)

        self.topBarContainerBaseView.addSubview(self.topBarAlternateView)

        self.view.addSubview(self.topGradientBackgroundView)

        self.mainContainerView.insertSubview(self.mainContainerGradientView, at: 0)
        self.mainContainerView.insertSubview(self.bottomBackgroundView, belowSubview: self.tabBarView)

        self.view.bringSubviewToFront(self.topGradientBackgroundView)
        self.view.bringSubviewToFront(self.topBarContainerBaseView)

       // Initialize the tabBarStackViewTrailingConstraint
        self.tabBarStackViewTrailingConstraint = self.tabBarStackView.trailingAnchor.constraint(equalTo: self.tabBarView.trailingAnchor)

        self.initConstraints()
    }

    private func initConstraints() {

        NSLayoutConstraint.activate([
            // Top Safe Area
            self.topSafeAreaView.topAnchor.constraint(equalTo: self.view.topAnchor),
            self.topSafeAreaView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.topSafeAreaView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.topSafeAreaView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),

            // Top Bar Container
            self.topBarContainerBaseView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.topBarContainerBaseView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.topBarContainerBaseView.topAnchor.constraint(equalTo: self.topSafeAreaView.bottomAnchor),

            self.topBarView.leadingAnchor.constraint(equalTo: self.topBarContainerBaseView.leadingAnchor),
            self.topBarView.trailingAnchor.constraint(equalTo: self.topBarContainerBaseView.trailingAnchor),
            self.topBarView.topAnchor.constraint(equalTo: self.topBarContainerBaseView.topAnchor),
            self.topBarView.bottomAnchor.constraint(equalTo: self.topBarContainerBaseView.bottomAnchor),
            self.topBarView.heightAnchor.constraint(equalToConstant: 64),

            self.profileStackView.leadingAnchor.constraint(equalTo: self.topBarView.leadingAnchor, constant: 16),
            self.profileStackView.topAnchor.constraint(equalTo: self.topBarView.topAnchor),
            self.profileStackView.bottomAnchor.constraint(equalTo: self.topBarView.bottomAnchor),

            self.profileBaseView.widthAnchor.constraint(equalToConstant: 42),

            // Anonymous User Menu Base View
            self.anonymousUserMenuBaseView.leadingAnchor.constraint(equalTo: self.profileBaseView.leadingAnchor),
            self.anonymousUserMenuBaseView.trailingAnchor.constraint(equalTo: self.profileBaseView.trailingAnchor),
            self.anonymousUserMenuBaseView.topAnchor.constraint(equalTo: self.profileBaseView.topAnchor),
            self.anonymousUserMenuBaseView.bottomAnchor.constraint(equalTo: self.profileBaseView.bottomAnchor),

            // Anonymous User Menu Image View
            self.anonymousUserMenuImageView.leadingAnchor.constraint(equalTo: self.anonymousUserMenuBaseView.leadingAnchor, constant: 3),
            self.anonymousUserMenuImageView.trailingAnchor.constraint(equalTo: self.anonymousUserMenuBaseView.trailingAnchor, constant: -3),
            self.anonymousUserMenuImageView.topAnchor.constraint(equalTo: self.anonymousUserMenuBaseView.topAnchor, constant: 3),
            self.anonymousUserMenuImageView.bottomAnchor.constraint(equalTo: self.anonymousUserMenuBaseView.bottomAnchor, constant: -3),

            // Profile Picture Base View
            self.profilePictureBaseView.leadingAnchor.constraint(equalTo: self.profileBaseView.leadingAnchor),
            self.profilePictureBaseView.widthAnchor.constraint(equalToConstant: 35),
            self.profilePictureBaseView.heightAnchor.constraint(equalTo: self.profilePictureBaseView.widthAnchor),
            self.profilePictureBaseView.centerYAnchor.constraint(equalTo: self.profileBaseView.centerYAnchor),

            // Profile Picture Base Inner View
            self.profilePictureBaseInnerView.topAnchor.constraint(equalTo: self.profilePictureBaseView.topAnchor, constant: 1),
            self.profilePictureBaseInnerView.leadingAnchor.constraint(equalTo: self.profilePictureBaseView.leadingAnchor, constant: -1),
            self.profilePictureBaseInnerView.trailingAnchor.constraint(equalTo: self.profilePictureBaseView.trailingAnchor, constant: 1),
            self.profilePictureBaseInnerView.bottomAnchor.constraint(equalTo: self.profilePictureBaseView.bottomAnchor, constant: -1),

            // Profile Picture Image View
            self.profilePictureImageView.centerXAnchor.constraint(equalTo: self.profilePictureBaseView.centerXAnchor),
            self.profilePictureImageView.centerYAnchor.constraint(equalTo: self.profilePictureBaseView.centerYAnchor),
            self.profilePictureImageView.widthAnchor.constraint(equalToConstant: 40),
            self.profilePictureImageView.heightAnchor.constraint(equalTo: self.profilePictureImageView.widthAnchor),

            // Notification Counter View
            self.notificationCounterView.topAnchor.constraint(equalTo: self.profilePictureBaseView.topAnchor, constant: -6),
            self.notificationCounterView.trailingAnchor.constraint(equalTo: self.profilePictureBaseView.trailingAnchor, constant: 6),
            self.notificationCounterView.widthAnchor.constraint(equalToConstant: 18),
            self.notificationCounterView.heightAnchor.constraint(equalToConstant: 18),

            // Notification Counter Label
            self.notificationCounterLabel.centerXAnchor.constraint(equalTo: self.notificationCounterView.centerXAnchor),
            self.notificationCounterLabel.centerYAnchor.constraint(equalTo: self.notificationCounterView.centerYAnchor),


            // Logo Image View
            self.logoImageBaseView.heightAnchor.constraint(equalTo: self.profileStackView.heightAnchor),

            self.logoImageView.centerYAnchor.constraint(equalTo: topBarContainerBaseView.centerYAnchor),
            self.logoImageView.leadingAnchor.constraint(equalTo: self.logoImageBaseView.leadingAnchor),
            self.logoImageView.trailingAnchor.constraint(equalTo: self.logoImageBaseView.trailingAnchor),

            self.accountStackView.trailingAnchor.constraint(equalTo: self.topBarView.trailingAnchor, constant: -12),
            self.accountStackView.topAnchor.constraint(equalTo: self.topBarView.topAnchor),
            self.accountStackView.bottomAnchor.constraint(equalTo: self.topBarView.bottomAnchor),

            self.accountValueView.heightAnchor.constraint(equalToConstant: 40),

            // Account Value View
            self.accountValueView.leadingAnchor.constraint(equalTo: accountValueBaseView.leadingAnchor),
            self.accountValueView.trailingAnchor.constraint(equalTo: accountValueBaseView.trailingAnchor),
            self.accountValueView.centerYAnchor.constraint(equalTo: self.accountValueBaseView.centerYAnchor),
            self.accountValueView.heightAnchor.constraint(equalToConstant: 24),

            self.accountPlusView.leadingAnchor.constraint(equalTo: self.accountValueView.leadingAnchor, constant: 4),
            self.accountPlusView.topAnchor.constraint(equalTo: self.accountValueView.topAnchor, constant: 4),
            self.accountPlusView.bottomAnchor.constraint(equalTo: self.accountValueView.bottomAnchor, constant: -4),
            self.accountPlusView.widthAnchor.constraint(equalToConstant: 14),
            self.accountPlusView.heightAnchor.constraint(equalTo: self.accountPlusView.widthAnchor),

            // Account Plus Image View
            self.accountPlusImageView.leadingAnchor.constraint(equalTo: self.accountPlusView.leadingAnchor, constant: 2),
            self.accountPlusImageView.trailingAnchor.constraint(equalTo: self.accountPlusView.trailingAnchor, constant: -2),
            self.accountPlusImageView.topAnchor.constraint(equalTo: self.accountPlusView.topAnchor, constant: 2),
            self.accountPlusImageView.bottomAnchor.constraint(equalTo: self.accountPlusView.bottomAnchor, constant: -2),
//            self.accountPlusImageView.centerXAnchor.constraint(equalTo: accountPlusView.centerXAnchor),
//            self.accountPlusImageView.centerYAnchor.constraint(equalTo: accountPlusView.centerYAnchor),
            self.accountPlusImageView.widthAnchor.constraint(equalToConstant: 12),
            self.accountPlusImageView.heightAnchor.constraint(equalTo: self.accountPlusImageView.widthAnchor),

            // Account Value Label
            self.accountValueLabel.leadingAnchor.constraint(equalTo: self.accountPlusView.trailingAnchor, constant: 4),
            self.accountValueLabel.trailingAnchor.constraint(equalTo: self.accountValueView.trailingAnchor, constant: -4),
            self.accountValueLabel.centerYAnchor.constraint(equalTo: self.accountValueView.centerYAnchor),

            self.loginBaseView.widthAnchor.constraint(equalToConstant: 96),
            self.loginBaseView.heightAnchor.constraint(equalToConstant: 64),

            self.loginButton.trailingAnchor.constraint(equalTo: self.loginBaseView.trailingAnchor),
            self.loginButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 84),
            self.loginButton.heightAnchor.constraint(equalToConstant: 30),
            self.loginButton.centerYAnchor.constraint(equalTo: self.loginBaseView.centerYAnchor),

            self.searchButton.widthAnchor.constraint(equalToConstant: 38),

            // Container View
            self.containerView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.containerView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.containerView.topAnchor.constraint(equalTo: self.topBarContainerBaseView.bottomAnchor),
            self.containerView.bottomAnchor.constraint(equalTo: self.bottomSafeAreaView.topAnchor),

            // Main Container View
            self.mainContainerView.topAnchor.constraint(equalTo: self.containerView.topAnchor),
//            self.mainContainerView.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor),
//            self.mainContainerView.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor),
            self.mainContainerView.bottomAnchor.constraint(equalTo: self.containerView.bottomAnchor),
            self.mainContainerView.widthAnchor.constraint(equalTo: self.containerView.widthAnchor),

            // Sports Book Content View
            self.sportsBookContentView.topAnchor.constraint(equalTo: self.mainContainerView.topAnchor),
            self.sportsBookContentView.leadingAnchor.constraint(equalTo: self.mainContainerView.leadingAnchor),
            self.sportsBookContentView.widthAnchor.constraint(equalTo: self.mainContainerView.widthAnchor),

            // Tab Bar
            self.tabBarView.leadingAnchor.constraint(equalTo: self.mainContainerView.leadingAnchor),
            self.tabBarView.trailingAnchor.constraint(equalTo: self.mainContainerView.trailingAnchor),
            self.tabBarView.topAnchor.constraint(equalTo: self.sportsBookContentView.bottomAnchor),
            self.tabBarView.bottomAnchor.constraint(equalTo: self.mainContainerView.bottomAnchor),
            self.tabBarView.heightAnchor.constraint(equalToConstant: 52),

            // Tab Bar Stack View - using stored constraint for trailing
            self.tabBarStackView.leadingAnchor.constraint(equalTo: self.tabBarView.leadingAnchor),
            self.tabBarStackView.topAnchor.constraint(equalTo: self.tabBarView.topAnchor),
            self.tabBarStackView.centerYAnchor.constraint(equalTo: self.tabBarView.centerYAnchor),
            // self.tabBarStackView.trailingAnchor.constraint(equalTo: self.tabBarView.trailingAnchor),

            // Bottom Safe Area
            self.bottomSafeAreaView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.bottomSafeAreaView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.bottomSafeAreaView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor),
            self.bottomSafeAreaView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),


            // Local Authentication Base View
            self.localAuthenticationBaseView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.localAuthenticationBaseView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.localAuthenticationBaseView.topAnchor.constraint(equalTo: self.view.topAnchor),
            self.localAuthenticationBaseView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),

            // Unlock App Button
            self.unlockAppButton.centerXAnchor.constraint(equalTo: self.localAuthenticationBaseView.centerXAnchor),
            self.unlockAppButton.centerYAnchor.constraint(equalTo: localAuthenticationBaseView.centerYAnchor, constant: -20),
            self.unlockAppButton.heightAnchor.constraint(equalToConstant: 35),

            // Cancel Unlock App Button
            self.cancelUnlockAppButton.centerXAnchor.constraint(equalTo: self.localAuthenticationBaseView.centerXAnchor),
            self.cancelUnlockAppButton.topAnchor.constraint(equalTo: self.unlockAppButton.bottomAnchor, constant: 30),
            self.cancelUnlockAppButton.heightAnchor.constraint(equalToConstant: 35),

            // Loading User Session View
            self.isLoadingUserSessionView.centerXAnchor.constraint(equalTo: self.localAuthenticationBaseView.centerXAnchor),
            self.isLoadingUserSessionView.centerYAnchor.constraint(equalTo: self.localAuthenticationBaseView.centerYAnchor)
        ])

        // Activate the tabBarStackViewTrailingConstraint
        self.tabBarStackViewTrailingConstraint.isActive = true

        // Sportsbook content items
        NSLayoutConstraint.activate([

            self.homeBaseView.leadingAnchor.constraint(equalTo: self.sportsBookContentView.leadingAnchor),
            self.homeBaseView.trailingAnchor.constraint(equalTo: self.sportsBookContentView.trailingAnchor),
            self.homeBaseView.topAnchor.constraint(equalTo: self.sportsBookContentView.topAnchor),
            self.homeBaseView.bottomAnchor.constraint(equalTo: self.sportsBookContentView.bottomAnchor),

            self.preLiveBaseView.leadingAnchor.constraint(equalTo: self.sportsBookContentView.leadingAnchor),
            self.preLiveBaseView.trailingAnchor.constraint(equalTo: self.sportsBookContentView.trailingAnchor),
            self.preLiveBaseView.topAnchor.constraint(equalTo: self.sportsBookContentView.topAnchor),
            self.preLiveBaseView.bottomAnchor.constraint(equalTo: self.sportsBookContentView.bottomAnchor),

            self.liveBaseView.leadingAnchor.constraint(equalTo: self.sportsBookContentView.leadingAnchor),
            self.liveBaseView.trailingAnchor.constraint(equalTo: self.sportsBookContentView.trailingAnchor),
            self.liveBaseView.topAnchor.constraint(equalTo: self.sportsBookContentView.topAnchor),
            self.liveBaseView.bottomAnchor.constraint(equalTo: self.sportsBookContentView.bottomAnchor),

            self.tipsBaseView.leadingAnchor.constraint(equalTo: self.sportsBookContentView.leadingAnchor),
            self.tipsBaseView.trailingAnchor.constraint(equalTo: self.sportsBookContentView.trailingAnchor),
            self.tipsBaseView.topAnchor.constraint(equalTo: self.sportsBookContentView.topAnchor),
            self.tipsBaseView.bottomAnchor.constraint(equalTo: self.sportsBookContentView.bottomAnchor),

            self.cashbackBaseView.leadingAnchor.constraint(equalTo: self.sportsBookContentView.leadingAnchor),
            self.cashbackBaseView.trailingAnchor.constraint(equalTo: self.sportsBookContentView.trailingAnchor),
            self.cashbackBaseView.topAnchor.constraint(equalTo: self.sportsBookContentView.topAnchor),
            self.cashbackBaseView.bottomAnchor.constraint(equalTo: self.sportsBookContentView.bottomAnchor),

            self.ticketsBaseView.leadingAnchor.constraint(equalTo: self.sportsBookContentView.leadingAnchor),
            self.ticketsBaseView.trailingAnchor.constraint(equalTo: self.sportsBookContentView.trailingAnchor),
            self.ticketsBaseView.topAnchor.constraint(equalTo: self.sportsBookContentView.topAnchor),
            self.ticketsBaseView.bottomAnchor.constraint(equalTo: self.sportsBookContentView.bottomAnchor),

            self.featuredCompetitionBaseView.leadingAnchor.constraint(equalTo: self.sportsBookContentView.leadingAnchor),
            self.featuredCompetitionBaseView.trailingAnchor.constraint(equalTo: self.sportsBookContentView.trailingAnchor),
            self.featuredCompetitionBaseView.topAnchor.constraint(equalTo: self.sportsBookContentView.topAnchor),
            self.featuredCompetitionBaseView.bottomAnchor.constraint(equalTo: self.sportsBookContentView.bottomAnchor)
        ])

        // Tab bar items
        NSLayoutConstraint.activate([
            // Home Button
            self.homeIconImageView.centerXAnchor.constraint(equalTo: homeButtonBaseView.centerXAnchor),
            self.homeIconImageView.bottomAnchor.constraint(equalTo: self.homeButtonBaseView.centerYAnchor, constant: 2),
            self.homeIconImageView.widthAnchor.constraint(equalToConstant: 20),

            self.homeTitleLabel.leadingAnchor.constraint(equalTo: self.homeButtonBaseView.leadingAnchor, constant: 4),
            self.homeTitleLabel.centerXAnchor.constraint(equalTo: homeButtonBaseView.centerXAnchor),
            self.homeTitleLabel.topAnchor.constraint(equalTo: homeIconImageView.bottomAnchor, constant: 2),
            self.homeTitleLabel.bottomAnchor.constraint(equalTo: self.homeButtonBaseView.bottomAnchor, constant: -3),
            self.homeTitleLabel.heightAnchor.constraint(equalToConstant: 19),

            self.sportsIconImageView.centerXAnchor.constraint(equalTo: self.sportsButtonBaseView.centerXAnchor),
            self.sportsIconImageView.bottomAnchor.constraint(equalTo: self.homeIconImageView.bottomAnchor),
            self.sportsIconImageView.widthAnchor.constraint(equalToConstant: 20),

            self.sportsTitleLabel.leadingAnchor.constraint(equalTo: self.sportsButtonBaseView.leadingAnchor, constant: 4),
            self.sportsTitleLabel.topAnchor.constraint(equalTo: self.homeTitleLabel.topAnchor),
            self.sportsTitleLabel.centerXAnchor.constraint(equalTo: self.sportsButtonBaseView.centerXAnchor),
            self.sportsTitleLabel.bottomAnchor.constraint(equalTo: self.sportsButtonBaseView.bottomAnchor, constant: -2),

            self.liveIconImageView.centerXAnchor.constraint(equalTo: self.liveButtonBaseView.centerXAnchor),
            self.liveIconImageView.bottomAnchor.constraint(equalTo: self.homeIconImageView.bottomAnchor),
            self.liveIconImageView.widthAnchor.constraint(equalToConstant: 20),

            self.liveTitleLabel.leadingAnchor.constraint(equalTo: self.liveButtonBaseView.leadingAnchor, constant: 4),
            self.liveTitleLabel.topAnchor.constraint(equalTo: self.homeTitleLabel.topAnchor),
            self.liveTitleLabel.centerXAnchor.constraint(equalTo: self.liveButtonBaseView.centerXAnchor),
            self.liveTitleLabel.bottomAnchor.constraint(equalTo: self.liveButtonBaseView.bottomAnchor, constant: -2),

            self.tipsIconImageView.centerXAnchor.constraint(equalTo: self.tipsButtonBaseView.centerXAnchor),
            self.tipsIconImageView.bottomAnchor.constraint(equalTo: self.homeIconImageView.bottomAnchor),
            self.tipsIconImageView.widthAnchor.constraint(equalToConstant: 20),

            self.tipsTitleLabel.leadingAnchor.constraint(equalTo: self.tipsButtonBaseView.leadingAnchor, constant: 4),
            self.tipsTitleLabel.topAnchor.constraint(equalTo: self.homeTitleLabel.topAnchor),
            self.tipsTitleLabel.centerXAnchor.constraint(equalTo: self.tipsButtonBaseView.centerXAnchor),
            self.tipsTitleLabel.bottomAnchor.constraint(equalTo: self.tipsButtonBaseView.bottomAnchor, constant: -2),

            self.cashbackIconImageView.centerXAnchor.constraint(equalTo: self.cashbackButtonBaseView.centerXAnchor),
            self.cashbackIconImageView.bottomAnchor.constraint(equalTo: self.homeIconImageView.bottomAnchor),
            self.cashbackIconImageView.widthAnchor.constraint(equalToConstant: 20),

            self.cashbackTitleLabel.leadingAnchor.constraint(equalTo: self.cashbackButtonBaseView.leadingAnchor, constant: 4),
            self.cashbackTitleLabel.topAnchor.constraint(equalTo: self.homeTitleLabel.topAnchor),
            self.cashbackTitleLabel.centerXAnchor.constraint(equalTo: self.cashbackButtonBaseView.centerXAnchor),
            self.cashbackTitleLabel.bottomAnchor.constraint(equalTo: self.cashbackButtonBaseView.bottomAnchor, constant: -2),

            // My Tickets Button
            self.myTicketsIconImageView.centerXAnchor.constraint(equalTo: self.myTicketsButtonBaseView.centerXAnchor),
            self.myTicketsIconImageView.bottomAnchor.constraint(equalTo: self.homeIconImageView.bottomAnchor),
            self.myTicketsIconImageView.widthAnchor.constraint(equalToConstant: 20),

            self.myTicketsTitleLabel.leadingAnchor.constraint(equalTo: self.myTicketsButtonBaseView.leadingAnchor, constant: 4),
            self.myTicketsTitleLabel.topAnchor.constraint(equalTo: self.homeTitleLabel.topAnchor),
            self.myTicketsTitleLabel.centerXAnchor.constraint(equalTo: self.myTicketsButtonBaseView.centerXAnchor),
            self.myTicketsTitleLabel.bottomAnchor.constraint(equalTo: self.myTicketsButtonBaseView.bottomAnchor, constant: -2),

            // Featured Competition Button
            self.featuredCompetitionIconImageView.centerXAnchor.constraint(equalTo: self.featuredCompetitionButtonBaseView.centerXAnchor),
            self.featuredCompetitionIconImageView.bottomAnchor.constraint(equalTo: self.homeIconImageView.bottomAnchor),
            self.featuredCompetitionIconImageView.widthAnchor.constraint(equalToConstant: 20),

            self.featuredCompetitionTitleLabel.leadingAnchor.constraint(equalTo: self.featuredCompetitionButtonBaseView.leadingAnchor, constant: 4),
            self.featuredCompetitionTitleLabel.topAnchor.constraint(equalTo: self.homeTitleLabel.topAnchor),
            self.featuredCompetitionTitleLabel.centerXAnchor.constraint(equalTo: self.featuredCompetitionButtonBaseView.centerXAnchor),
            self.featuredCompetitionTitleLabel.bottomAnchor.constraint(equalTo: self.featuredCompetitionButtonBaseView.bottomAnchor, constant: -2),

            // Casino Button
            self.casinoButtonBaseView.trailingAnchor.constraint(equalTo: self.tabBarView.trailingAnchor),
            self.casinoButtonBaseView.widthAnchor.constraint(equalToConstant: RootViewController.casinoButtonWidth),
            self.casinoButtonBaseView.centerYAnchor.constraint(equalTo: self.tabBarView.centerYAnchor),
            self.casinoButtonBaseView.heightAnchor.constraint(equalTo: self.tabBarView.heightAnchor),

            self.casinoIconImageView.centerXAnchor.constraint(equalTo: self.casinoButtonBaseView.centerXAnchor),
            self.casinoIconImageView.centerYAnchor.constraint(equalTo: self.homeIconImageView.centerYAnchor),
            self.casinoIconImageView.widthAnchor.constraint(equalToConstant: 20),

            self.casinoTitleLabel.centerXAnchor.constraint(equalTo: self.casinoButtonBaseView.centerXAnchor),
            self.casinoTitleLabel.leadingAnchor.constraint(equalTo: self.casinoButtonBaseView.leadingAnchor),
            self.casinoTitleLabel.trailingAnchor.constraint(equalTo: self.casinoButtonBaseView.trailingAnchor),
            self.casinoTitleLabel.centerYAnchor.constraint(equalTo: self.homeTitleLabel.centerYAnchor),
            self.casinoTitleLabel.bottomAnchor.constraint(equalTo: self.casinoButtonBaseView.bottomAnchor, constant: -2)
        ])

        // Casino items
        NSLayoutConstraint.activate([
            self.casinoContentView.topAnchor.constraint(equalTo: self.containerView.topAnchor),
            self.casinoContentView.leadingAnchor.constraint(equalTo: self.sportsBookContentView.trailingAnchor),
            self.casinoContentView.bottomAnchor.constraint(equalTo: self.containerView.bottomAnchor),
            self.casinoContentView.widthAnchor.constraint(equalTo: self.sportsBookContentView.widthAnchor),

            self.casinoBaseView.leadingAnchor.constraint(equalTo: self.casinoContentView.leadingAnchor),
            self.casinoBaseView.trailingAnchor.constraint(equalTo: self.casinoContentView.trailingAnchor),
            self.casinoBaseView.topAnchor.constraint(equalTo: self.casinoContentView.topAnchor),

            self.casinoBottomView.leadingAnchor.constraint(equalTo: self.casinoContentView.leadingAnchor),
            self.casinoBottomView.trailingAnchor.constraint(equalTo: self.casinoContentView.trailingAnchor),
            self.casinoBottomView.topAnchor.constraint(equalTo: self.casinoBaseView.bottomAnchor),
            self.casinoBottomView.bottomAnchor.constraint(equalTo: self.casinoContentView.bottomAnchor),
            self.casinoBottomView.heightAnchor.constraint(equalToConstant: 52),

            // Sportsbook Button
            self.sportsbookButtonBaseView.leadingAnchor.constraint(equalTo: self.casinoBottomView.leadingAnchor),
            self.sportsbookButtonBaseView.topAnchor.constraint(equalTo: self.casinoBottomView.topAnchor),
            self.sportsbookButtonBaseView.bottomAnchor.constraint(equalTo: self.casinoBottomView.bottomAnchor),
            self.sportsbookButtonBaseView.widthAnchor.constraint(equalToConstant: 78),

            self.sportsbookIconImageView.centerXAnchor.constraint(equalTo: sportsbookButtonBaseView.centerXAnchor),
            self.sportsbookIconImageView.topAnchor.constraint(equalTo: self.homeIconImageView.topAnchor),
            self.sportsbookIconImageView.widthAnchor.constraint(equalToConstant: 20),

            self.sportsbookTitleLabel.leadingAnchor.constraint(equalTo: self.sportsbookButtonBaseView.leadingAnchor),
            self.sportsbookTitleLabel.trailingAnchor.constraint(equalTo: self.sportsbookButtonBaseView.trailingAnchor),
            self.sportsbookTitleLabel.topAnchor.constraint(equalTo: self.homeTitleLabel.topAnchor),
            self.sportsbookTitleLabel.bottomAnchor.constraint(equalTo: self.homeTitleLabel.bottomAnchor)

        ])

        NSLayoutConstraint.activate([
            self.topBarAlternateView.leadingAnchor.constraint(equalTo: self.topBarContainerBaseView.leadingAnchor),
            self.topBarAlternateView.trailingAnchor.constraint(equalTo: self.topBarContainerBaseView.trailingAnchor),
            self.topBarAlternateView.topAnchor.constraint(equalTo: self.topBarContainerBaseView.topAnchor),
            self.topBarAlternateView.bottomAnchor.constraint(equalTo: self.topBarContainerBaseView.bottomAnchor)
        ])

        // Gradient containers
        NSLayoutConstraint.activate([
            self.topGradientBackgroundView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.topGradientBackgroundView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.topGradientBackgroundView.topAnchor.constraint(equalTo: self.topSafeAreaView.topAnchor),
            self.topGradientBackgroundView.bottomAnchor.constraint(equalTo: self.topBarView.bottomAnchor),

            self.mainContainerGradientView.leadingAnchor.constraint(equalTo: self.mainContainerView.leadingAnchor),
            self.mainContainerGradientView.trailingAnchor.constraint(equalTo: self.mainContainerView.trailingAnchor),
            self.mainContainerGradientView.topAnchor.constraint(equalTo: self.mainContainerView.topAnchor),
            self.mainContainerGradientView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),

            self.bottomBackgroundView.leadingAnchor.constraint(equalTo: self.bottomSafeAreaView.leadingAnchor),
            self.bottomBackgroundView.trailingAnchor.constraint(equalTo: self.bottomSafeAreaView.trailingAnchor),
            self.bottomBackgroundView.topAnchor.constraint(equalTo: self.tabBarView.topAnchor),
            self.bottomBackgroundView.bottomAnchor.constraint(equalTo: self.bottomSafeAreaView.bottomAnchor),
        ])

        // Constraints
        self.logoImageWidthConstraint = self.logoImageView.widthAnchor.constraint(equalToConstant: 0)
        self.logoImageWidthConstraint.isActive = true

        self.logoImageHeightConstraint = self.logoImageView.heightAnchor.constraint(equalToConstant: 30)
        self.logoImageHeightConstraint.isActive = true

        self.leadingSportsBookContentConstriant = self.mainContainerView.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor)
        self.leadingSportsBookContentConstriant.isActive = true
    }

    // Add a method to update the tab bar layout based on casino visibility
    func updateTabBarForCasino(isVisible: Bool) {
        // Deactivate the current constraint
        self.tabBarStackViewTrailingConstraint.isActive = false

        if isVisible {
            // Calculate the width needed for the casino button
            let casinoButtonWidth = self.casinoBottomView.frame.width

            // Create a new trailing constraint with inset for the casino button
            self.tabBarStackViewTrailingConstraint = self.tabBarStackView.trailingAnchor.constraint(
                equalTo: self.tabBarView.trailingAnchor,
                constant: -RootViewController.casinoButtonWidth - 8 // Add some padding
            )
        } else {
            // Restore the original trailing constraint
            self.tabBarStackViewTrailingConstraint = self.tabBarStackView.trailingAnchor.constraint(
                equalTo: self.tabBarView.trailingAnchor
            )
        }

        // Activate the new constraint
        self.tabBarStackViewTrailingConstraint.isActive = true

        // Update layout
        self.view.layoutIfNeeded()
    }
}

class RootViewModel: NSObject {
    
    // Mark: Public properties
    enum TabItem {
        case home
        case preLive
        case live
        case tips
        case cashback
        case tickets
        case featuredCompetition
        case casino
    }
    
    // MARK: Lifetime and Cycle
    override init() {
  
        super.init()
        
        AnalyticsClient.sendEvent(event: .appStart)

    }
}

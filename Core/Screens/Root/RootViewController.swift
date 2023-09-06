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

class RootViewController: UIViewController {

    @IBOutlet private var topSafeAreaView: UIView!

    @IBOutlet private var topBarContainerBaseView: UIView!

    @IBOutlet private var topBarView: UIView!

    private let topBackgroundGradientLayer = CAGradientLayer()
    private lazy var topGradientBackgroundView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    @IBOutlet private var containerView: UIView!
    @IBOutlet private var mainContainerView: UIView!

    private let mainContainerGradientLayer = CAGradientLayer()
    private lazy var mainContainerGradientView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var bottomBackgroundView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    @IBOutlet private var leadingSportsBookContentConstriant: NSLayoutConstraint!

    @IBOutlet private var sportsBookContentView: UIView!
    @IBOutlet private var casinoContentView: UIView!

    @IBOutlet private var homeBaseView: UIView!
    @IBOutlet private var preLiveBaseView: UIView!
    @IBOutlet private var liveBaseView: UIView!
    @IBOutlet private var tipsBaseView: UIView!
    @IBOutlet private var cashbackBaseView: UIView!
    @IBOutlet private var casinoBaseView: UIView!

    @IBOutlet private var tabBarView: UIView!
    @IBOutlet private var bottomSafeAreaView: UIView!
    @IBOutlet private var casinoBottomView: UIView!

    @IBOutlet private var sportsButtonBaseView: UIView!
    @IBOutlet private var sportsIconImageView: UIImageView!
    @IBOutlet private var sportsTitleLabel: UILabel!

    @IBOutlet private var homeButtonBaseView: UIView!
    @IBOutlet private var homeIconImageView: UIImageView!
    @IBOutlet private var homeTitleLabel: UILabel!

    @IBOutlet private var liveButtonBaseView: UIView!
    @IBOutlet private var liveIconImageView: UIImageView!
    @IBOutlet private var liveTitleLabel: UILabel!

    @IBOutlet private var tipsButtonBaseView: UIView!
    @IBOutlet private var tipsIconImageView: UIImageView!
    @IBOutlet private var tipsTitleLabel: UILabel!

    @IBOutlet private var cashbackButtonBaseView: UIView!
    @IBOutlet private var cashbackIconImageView: UIImageView!
    @IBOutlet private var cashbackTitleLabel: UILabel!

    @IBOutlet private var casinoButtonBaseView: UIView!
    @IBOutlet private var casinoIconImageView: UIImageView!
    @IBOutlet private var casinoTitleLabel: UILabel!

    @IBOutlet private var sportsbookButtonBaseView: UIView!
    @IBOutlet private var sportsbookIconImageView: UIImageView!
    @IBOutlet private var sportsbookTitleLabel: UILabel!

    @IBOutlet private var profileBaseView: UIView!
    @IBOutlet private var profilePictureBaseView: UIView!
    @IBOutlet private var profilePictureBaseInnerView: UIView!
    @IBOutlet private var profilePictureImageView: UIImageView!

    @IBOutlet private var anonymousUserMenuBaseView: UIView!
    @IBOutlet private var anonymousUserMenuImageView: UIImageView!

    @IBOutlet private var searchButton: UIButton!
    @IBOutlet private var logoImageView: UIImageView!
    @IBOutlet private var logoImageWidthConstraint: NSLayoutConstraint!
    @IBOutlet private var logoImageHeightConstraint: NSLayoutConstraint!

    @IBOutlet private var loginBaseView: UIView!
    @IBOutlet private var loginButton: UIButton!

    @IBOutlet private var accountValueBaseView: UIView!
    @IBOutlet private var accountValueView: UIView!
    @IBOutlet private var accountPlusView: UIView!
    @IBOutlet private var accountValueLabel: UILabel!
    @IBOutlet private var accountPlusImageView: UIImageView!

    @IBOutlet private var notificationCounterView: UIView!
    @IBOutlet private var notificationCounterLabel: UILabel!

    @IBOutlet private var localAuthenticationBaseView: UIView!
    @IBOutlet private var unlockAppButton: UIButton!
    @IBOutlet private var cancelUnlockAppButton: UIButton!
    @IBOutlet private var isLoadingUserSessionView: UIActivityIndicatorView!

    //
    //
    private var pictureInPictureView: PictureInPictureView?
    
    private lazy var overlayWindow: PassthroughWindow = {
        var overlayWindow: PassthroughWindow = PassthroughWindow(frame: UIScreen.main.bounds)
        overlayWindow.windowLevel = .alert
        return overlayWindow
    }()

    //
    //
    private lazy var blockingWindow: BlockingWindow = {
        var blockingWindow: BlockingWindow = BlockingWindow(frame: UIScreen.main.bounds)
        blockingWindow.windowLevel = .statusBar
        return blockingWindow
    }()

    private lazy var topBarAlternateView: TopBarView = {
        let topBar = TopBarView()

        topBar.translatesAutoresizingMaskIntoConstraints = false

        topBar.shouldShowLogin = { [weak self] in
            self?.presentLoginScreen()
        }

        topBar.shouldShowProfile = { [weak self] in
            self?.presentProfileViewController()
        }

        topBar.shouldShowDeposit = { [weak self] in
            let depositViewController = DepositViewController()

            let navigationViewController = Router.navigationController(with: depositViewController)

            depositViewController.shouldRefreshUserWallet = {
                Env.userSessionStore.refreshUserWallet()
            }

            self?.present(navigationViewController, animated: true, completion: nil)
        }

        topBar.shouldShowAnonymousMenu = { [weak self] in
            self?.presentAnonymousSideMenuViewController()
        }

        topBar.shouldShowReplay = {  [weak self] in
            self?.didTapCashbackTabItem()
        }

        self.topBarContainerBaseView.addSubview(topBar)

        NSLayoutConstraint.activate([
            topBar.leadingAnchor.constraint(equalTo: self.topBarContainerBaseView.leadingAnchor),
            topBar.trailingAnchor.constraint(equalTo: self.topBarContainerBaseView.trailingAnchor),
            topBar.topAnchor.constraint(equalTo: self.topBarContainerBaseView.topAnchor),
            topBar.bottomAnchor.constraint(equalTo: self.topBarContainerBaseView.bottomAnchor)
        ])

        return topBar
    }()

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

    //
    let activeButtonAlpha = 1.0
    let idleButtonAlpha = 0.52

    //
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
    lazy var casinoViewController = CasinoWebViewController()

    // Loaded view controllers
    var homeViewControllerLoaded = false
    var preLiveViewControllerLoaded = false
    var liveEventsViewControllerLoaded = false
    var tipsRootViewControllerLoaded = false
    var cashbackViewControllerLoaded = false
    var casinoViewControllerLoaded = false

    var currentSport: Sport

    // Combine
    var cancellables = Set<AnyCancellable>()

    //
    var canShowPopUp: Bool = true
    var popUpPromotionView: PopUpPromotionView?
    var popUpBackgroundView: UIView?

    enum TabItem {
        case home
        case preLive
        case live
        case tips
        case cashback
        case casino
    }
    var selectedTabItem: TabItem {
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

    //
    //
    init(initialScreen: TabItem = .home, defaultSport: Sport) {
        self.selectedTabItem = initialScreen
        self.currentSport = defaultSport
        super.init(nibName: "RootViewController", bundle: nil)
    }

    @available(iOS, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

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

    override func viewDidLoad() {
        super.viewDidLoad()

        AnalyticsClient.sendEvent(event: .appStart)

        self.commonInit()
        // self.loadChildViewControllerIfNeeded(tab: )

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

//        NotificationCenter.default.addObserver(
//            forName: UIWindow.didResignKeyNotification,
//            object: self.overlayWindow,
//            queue: nil
//        ) { notification in
//            print("Video is now fullscreen")
//
//            self.pictureInPictureView?.isHidden = true
//        }
//
//        NotificationCenter.default.addObserver(
//            forName: UIWindow.didBecomeKeyNotification,
//            object: self.overlayWindow,
//            queue: nil
//        ) { notification in
//            print("Video stopped")
//
//            self.pictureInPictureView?.isHidden = false
//        }

        //
        self.setupWithTheme()

        // Detects a new login

        Env.userSessionStore.userProfilePublisher
            .receive(on: DispatchQueue.main)
            .sink { userProfile in
                if let userProfile = userProfile {
                    self.screenState = .logged(user: userProfile)

                    if let avatarName = userProfile.avatarName {
                        self.profilePictureImageView.image = UIImage(named: avatarName)
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

        let debugTapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapLogoImageView))
        logoImageView.addGestureRecognizer(debugTapGesture)
        logoImageView.isUserInteractionEnabled = true

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

        Env.userSessionStore.refreshUserWallet()

    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

    }

    func checkUserLimitsSet() {

        Env.userSessionStore
            .shouldRequestLimits()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] shouldRequestLimits in
                if shouldRequestLimits {
                    self?.showLimitsScreenOnRegister()
                }
            }
            .store(in: &self.cancellables)

    }

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
        profilePictureImageView.layer.masksToBounds = false
        profilePictureImageView.clipsToBounds = true

        self.profilePictureBaseInnerView.layer.cornerRadius = self.profilePictureBaseInnerView.frame.size.width/2

        self.profilePictureImageView.layer.masksToBounds = true

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
            self.view.layoutIfNeeded()
        }

        //
        self.homeTitleLabel.text = localized("home")
        self.sportsTitleLabel.text = localized("sports")
        self.liveTitleLabel.text = localized("live")
        self.casinoTitleLabel.text = localized("casino")
        self.sportsbookTitleLabel.text = localized("sportsbook")
        self.tipsTitleLabel.text = localized("tips")
        self.cashbackTitleLabel.text = localized("cashback")

        self.casinoBottomView.backgroundColor = UIColor.App.backgroundPrimary

        self.casinoButtonBaseView.backgroundColor = UIColor.App.backgroundCards
        self.casinoButtonBaseView.layer.maskedCorners = [ .layerMinXMaxYCorner, .layerMinXMinYCorner]

        self.sportsbookButtonBaseView.backgroundColor = UIColor.App.backgroundCards
        self.sportsbookButtonBaseView.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMaxXMinYCorner]

        let homeTapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapHomeTabItem))
        self.homeButtonBaseView.addGestureRecognizer(homeTapGesture)

        let sportsTapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapSportsTabItem))
        self.sportsButtonBaseView.addGestureRecognizer(sportsTapGesture)

        let liveTapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapLiveTabItem))
        self.liveButtonBaseView.addGestureRecognizer(liveTapGesture)

        let tipsTapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapTipsTabItem))
        self.tipsButtonBaseView.addGestureRecognizer(tipsTapGesture)

        let cashbackTapgesture = UITapGestureRecognizer(target: self, action: #selector(didTapCashbackTabItem))
        self.cashbackButtonBaseView.addGestureRecognizer(cashbackTapgesture)

        let casinoTapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapCasinoTabItem))
        self.casinoButtonBaseView.addGestureRecognizer(casinoTapGesture)

        let sportsbookTapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapSportsbookIcon))
        self.sportsbookButtonBaseView.addGestureRecognizer(sportsbookTapGesture)

        let profileTapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapProfileButton))
        self.profilePictureBaseView.addGestureRecognizer(profileTapGesture)

        let anonymousTapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapAnonymousButton))
        self.anonymousUserMenuBaseView.addGestureRecognizer(anonymousTapGesture)

        //
        self.accountValueLabel.text = localized("loading")
        self.accountValueLabel.font = AppFont.with(type: .bold, size: 12)

        let accountValueTapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapAccountValue))
        self.accountValueView.addGestureRecognizer(accountValueTapGesture)

        //
        self.loginButton.setTitle(localized("login"), for: .normal)
        self.loginButton.titleLabel?.font = AppFont.with(type: AppFont.AppFontType.bold, size: 13)

        self.notificationCounterLabel.font = AppFont.with(type: .semibold, size: 12)

        //
        if TargetVariables.hasFeatureEnabled(feature: .casino) {
            self.casinoButtonBaseView.isHidden = false
        }
        else {
            self.casinoButtonBaseView.isHidden = true
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

        //
        self.view.insertSubview(self.topGradientBackgroundView, belowSubview: self.topSafeAreaView)

        self.mainContainerView.insertSubview(self.mainContainerGradientView, at: 0)
        self.mainContainerView.insertSubview(self.bottomBackgroundView, belowSubview: self.tabBarView)

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
        if TargetVariables.shouldUserBlurEffectTabBar {

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

    }

    func setupWithTheme() {

        self.view.backgroundColor = .black

        if TargetVariables.shouldUseGradientBackgrounds {
            self.topSafeAreaView.backgroundColor = .clear
            self.topBarView.backgroundColor = .clear

            self.topGradientBackgroundView.backgroundColor = .clear
            self.topBackgroundGradientLayer.colors = [UIColor.App.headerGradient1.cgColor,
                                                      UIColor.App.headerGradient2.cgColor,
                                                      UIColor.App.headerGradient3.cgColor]

            self.containerView.backgroundColor = .clear
            self.mainContainerView.backgroundColor = .clear
            self.mainContainerGradientView.backgroundColor = .clear
            self.mainContainerGradientLayer.colors = [UIColor.App.backgroundGradient1.cgColor,
                                                      UIColor.App.backgroundGradient2.cgColor]

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

        self.homeTitleLabel.textColor = UIColor.App.highlightPrimary
        self.liveTitleLabel.textColor = UIColor.App.highlightPrimary
        self.sportsTitleLabel.textColor = UIColor.App.highlightPrimary
        self.tipsTitleLabel.textColor = UIColor.App.highlightPrimary
        self.casinoTitleLabel.textColor = UIColor.App.textSecondary
        self.sportsbookTitleLabel.textColor = UIColor.App.textSecondary

        if TargetVariables.shouldUserBlurEffectTabBar {
            self.tabBarView.backgroundColor = .clear
            self.bottomSafeAreaView.backgroundColor = .clear
        }
        else {
            self.tabBarView.backgroundColor = UIColor.App.backgroundPrimary
            self.bottomSafeAreaView.backgroundColor = UIColor.App.backgroundPrimary
        }

        self.homeButtonBaseView.backgroundColor = .clear // UIColor.App.backgroundPrimary
        self.sportsButtonBaseView.backgroundColor = .clear // UIColor.App.backgroundPrimary
        self.liveButtonBaseView.backgroundColor = .clear // UIColor.App.backgroundPrimary
        self.tipsButtonBaseView.backgroundColor = .clear // UIColor.App.backgroundPrimary
        self.cashbackButtonBaseView.backgroundColor = .clear

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

        self.casinoButtonBaseView.alpha = self.activeButtonAlpha
        self.casinoIconImageView.setImageColor(color: UIColor.App.iconPrimary)

        self.sportsbookButtonBaseView.alpha = self.activeButtonAlpha
        self.sportsbookIconImageView.setImageColor(color: UIColor.App.iconPrimary)

        self.redrawButtonButtons()

        self.notificationCounterLabel.textColor = UIColor.App.buttonTextPrimary

        self.isLoadingUserSessionView.tintColor = UIColor.App.textSecondary
        self.isLoadingUserSessionView.color = UIColor.App.textSecondary

    }

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

    func openBetslipModal() {
        let betslipViewController = BetslipViewController()
        betslipViewController.willDismissAction = { [weak self] in
            self?.reloadChildViewControllersData()
        }
        self.present(Router.navigationController(with: betslipViewController), animated: true, completion: nil)
    }

    func openChatModal() {
        if Env.userSessionStore.isUserLogged() {
            let socialViewController = SocialViewController()
            self.present(Router.navigationController(with: socialViewController), animated: true, completion: nil)
        }
        else {
            let loginViewController = Router.navigationController(with: LoginViewController())
            self.present(loginViewController, animated: true, completion: nil)
        }
    }

    func openInternalWebview(onURL url: URL) {
        let internalBrowserViewController = InternalBrowserViewController(url: url, fullscreen: false)
        let navigationViewController = Router.navigationController(with: internalBrowserViewController)
        navigationViewController.modalPresentationStyle = .fullScreen
        self.present(navigationViewController, animated: true, completion: nil)
    }

    func openUserProfile(userBasicInfo: UserBasicInfo) {
        let userProfileViewModel = UserProfileViewModel(userBasicInfo: userBasicInfo)

        let userProfileViewController = UserProfileViewController(viewModel: userProfileViewModel)

        self.navigationController?.pushViewController(userProfileViewController, animated: true)
    }

    //
    // Obrigatory Limits
    //
    func showLimitsScreenOnRegister() {
        if self.presentedViewController?.isModal == true {
            self.presentedViewController?.dismiss(animated: true, completion: nil)
        }

        let limitsOnRegisterViewModel = LimitsOnRegisterViewModel(servicesProvider: Env.servicesProvider)
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

    @IBAction private func didTapSearchButton() {
        let searchViewModel = SearchViewModel()

        let searchViewController = SearchViewController(viewModel: searchViewModel)

        let navigationViewController = Router.navigationController(with: searchViewController)
        self.present(navigationViewController, animated: true, completion: nil)
    }

    @objc func didTapLogoImageView() {

    }

}

extension RootViewController {

    private func openExternalVideo(fromURL url: URL) {
        self.pictureInPictureView?.playVideo(fromURL: url)
    }

}

extension RootViewController {
    func loadChildViewControllerIfNeeded(tab: TabItem) {
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
                self?.openInternalWebview(onURL: url)
            }
            self.homeViewController.didTapUserProfileAction = { [weak self] userBasicInfo in
                self?.openUserProfile(userBasicInfo: userBasicInfo)
            }
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

            tipsRootViewControllerLoaded = true
        }

        if case .cashback = tab, !cashbackViewControllerLoaded {
            self.addChildViewController(self.cashbackViewController, toView: self.cashbackBaseView)

            // Cashback Callbacks if needed

            cashbackViewControllerLoaded = true
        }

        if case .casino = tab, !casinoViewControllerLoaded {
            self.searchButton.isHidden = true

            self.casinoViewController.modalPresentationStyle = .fullScreen
            self.casinoViewController.navigationItem.hidesBackButton = true
            self.addChildViewController(self.casinoViewController, toView: self.casinoBaseView)
        }

    }
}

extension RootViewController {

    @IBAction private func didTapLoginButton() {
        self.presentLoginScreen()
    }

    @objc private func didTapLoginAlternateButton() {
        self.presentLoginScreen()
    }

    private func presentLoginScreen() {
        let loginViewController = Router.navigationController(with: LoginViewController())
        self.present(loginViewController, animated: true, completion: nil)
    }

    private func presentRegisterScreen() {
        let loginViewController = Router.navigationController(with: LoginViewController(shouldPresentRegisterFlow: true))
        self.present(loginViewController, animated: true, completion: nil)
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

    private func presentProfileViewController() {
        if let loggedUser = Env.userSessionStore.loggedUserProfile {
            let profileViewController = ProfileViewController(userProfile: loggedUser)
            let navigationViewController = Router.navigationController(with: profileViewController)
            self.present(navigationViewController, animated: true, completion: nil)
        }
    }

    @objc private func didTapAnonymousButton() {
        self.presentAnonymousSideMenuViewController()
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
}

extension RootViewController {

    func requestPopUpContent() {
        if TargetVariables.hasFeatureEnabled(feature: .homePopUps) {
            Env.gomaNetworkClient.requestPopUpInfo(deviceId: Env.deviceId)
                .compactMap({$0})
                .receive(on: DispatchQueue.main)
                .sink(receiveValue: showPopUp(_:))
                .store(in: &cancellables)
        }
    }

    func showPopUp(_ details: PopUpDetails) {

        #if DEBUG
        return
        #endif

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

extension RootViewController {

    @objc private func didTapHomeTabItem() {

        self.flipToSportsbookIfNeeded()

        self.selectedTabItem = .home
    }

    @objc private func didTapSportsTabItem() {
        self.flipToSportsbookIfNeeded()

        self.selectedTabItem = .preLive
    }

    @objc private func didTapLiveTabItem() {
        self.flipToSportsbookIfNeeded()

        self.selectedTabItem = .live
    }

    @objc private func didTapTipsTabItem() {

        self.flipToSportsbookIfNeeded()

        self.selectedTabItem = .tips
    }

    @objc private func didTapCashbackTabItem() {
        self.flipToSportsbookIfNeeded()

        self.selectedTabItem = .cashback
    }

    @objc private func didTapCasinoTabItem() {
        self.flipToCasinoIfNeeded()

        self.selectedTabItem = .casino
    }

    @objc private func didTapSportsbookIcon() {
        self.flipToSportsbookIfNeeded()

        self.selectedTabItem = .home
    }

    //
    //
    func selectHomeTabBarItem() {
        self.loadChildViewControllerIfNeeded(tab: .home)

        self.homeBaseView.isHidden = false
        self.preLiveBaseView.isHidden = true
        self.liveBaseView.isHidden = true
        self.tipsBaseView.isHidden = true
        self.cashbackBaseView.isHidden = true

        self.redrawButtonButtons()
    }

    func selectSportsTabBarItem() {
        self.loadChildViewControllerIfNeeded(tab: .preLive)

        self.homeBaseView.isHidden = true
        self.preLiveBaseView.isHidden = false
        self.liveBaseView.isHidden = true
        self.tipsBaseView.isHidden = true
        self.cashbackBaseView.isHidden = true

        self.redrawButtonButtons()
    }

    func selectLiveTabBarItem() {
        self.loadChildViewControllerIfNeeded(tab: .live)

        self.homeBaseView.isHidden = true
        self.preLiveBaseView.isHidden = true
        self.liveBaseView.isHidden = false
        self.tipsBaseView.isHidden = true
        self.cashbackBaseView.isHidden = true

        self.redrawButtonButtons()
    }

    func selectTipsTabBarItem() {
        self.loadChildViewControllerIfNeeded(tab: .tips)

        self.homeBaseView.isHidden = true
        self.preLiveBaseView.isHidden = true
        self.liveBaseView.isHidden = true
        self.tipsBaseView.isHidden = false
        self.cashbackBaseView.isHidden = true

        self.redrawButtonButtons()
    }

    func selectCashbackTabBarItem() {
        self.loadChildViewControllerIfNeeded(tab: .cashback)

        self.homeBaseView.isHidden = true
        self.preLiveBaseView.isHidden = true
        self.liveBaseView.isHidden = true
        self.tipsBaseView.isHidden = true
        self.cashbackBaseView.isHidden = false
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
            sportsTitleLabel.textColor = UIColor.App.iconPrimary
            sportsIconImageView.setImageColor(color: UIColor.App.iconPrimary)
            liveTitleLabel.textColor = UIColor.App.iconPrimary
            liveIconImageView.setImageColor(color: UIColor.App.iconPrimary)
            tipsTitleLabel.textColor = UIColor.App.iconPrimary
            tipsIconImageView.setImageColor(color: UIColor.App.iconPrimary)
            cashbackTitleLabel.textColor = UIColor.App.iconPrimary
            cashbackIconImageView.setImageColor(color: UIColor.App.iconPrimary)
        case .preLive:
            sportsButtonBaseView.alpha = self.activeButtonAlpha
            homeTitleLabel.textColor = UIColor.App.iconPrimary
            homeIconImageView.setImageColor(color: UIColor.App.iconPrimary)
            sportsTitleLabel.textColor = UIColor.App.highlightPrimary
            sportsIconImageView.setImageColor(color: UIColor.App.highlightPrimary)
            liveTitleLabel.textColor = UIColor.App.iconPrimary
            liveIconImageView.setImageColor(color: UIColor.App.iconPrimary)
            tipsTitleLabel.textColor = UIColor.App.iconPrimary
            tipsIconImageView.setImageColor(color: UIColor.App.iconPrimary)
            cashbackTitleLabel.textColor = UIColor.App.iconPrimary
            cashbackIconImageView.setImageColor(color: UIColor.App.iconPrimary)
        case .live:
            liveButtonBaseView.alpha = self.activeButtonAlpha
            homeTitleLabel.textColor = UIColor.App.iconPrimary
            homeIconImageView.setImageColor(color: UIColor.App.iconPrimary)
            sportsTitleLabel.textColor = UIColor.App.iconPrimary
            sportsIconImageView.setImageColor(color: UIColor.App.iconPrimary)
            liveTitleLabel.textColor = UIColor.App.highlightPrimary
            liveIconImageView.setImageColor(color: UIColor.App.highlightPrimary)
            tipsTitleLabel.textColor = UIColor.App.iconPrimary
            tipsIconImageView.setImageColor(color: UIColor.App.iconPrimary)
            cashbackTitleLabel.textColor = UIColor.App.iconPrimary
            cashbackIconImageView.setImageColor(color: UIColor.App.iconPrimary)
        case .tips:
            tipsButtonBaseView.alpha = self.activeButtonAlpha
            homeTitleLabel.textColor = UIColor.App.iconPrimary
            homeIconImageView.setImageColor(color: UIColor.App.iconPrimary)
            sportsTitleLabel.textColor = UIColor.App.iconPrimary
            sportsIconImageView.setImageColor(color: UIColor.App.iconPrimary)
            liveTitleLabel.textColor = UIColor.App.iconPrimary
            liveIconImageView.setImageColor(color: UIColor.App.iconPrimary)
            tipsTitleLabel.textColor = UIColor.App.highlightPrimary
            tipsIconImageView.setImageColor(color: UIColor.App.highlightPrimary)
            cashbackTitleLabel.textColor = UIColor.App.iconPrimary
            cashbackIconImageView.setImageColor(color: UIColor.App.iconPrimary)
        case .cashback:
            cashbackButtonBaseView.alpha = self.activeButtonAlpha
            homeTitleLabel.textColor = UIColor.App.iconPrimary
            homeIconImageView.setImageColor(color: UIColor.App.iconPrimary)
            sportsTitleLabel.textColor = UIColor.App.iconPrimary
            sportsIconImageView.setImageColor(color: UIColor.App.iconPrimary)
            liveTitleLabel.textColor = UIColor.App.iconPrimary
            liveIconImageView.setImageColor(color: UIColor.App.iconPrimary)
            tipsTitleLabel.textColor = UIColor.App.iconPrimary
            tipsIconImageView.setImageColor(color: UIColor.App.iconPrimary)
            cashbackTitleLabel.textColor = UIColor.App.highlightPrimary
            cashbackIconImageView.setImageColor(color: UIColor.App.highlightPrimary)
        case .casino:
            homeTitleLabel.textColor = UIColor.App.iconPrimary
            homeIconImageView.setImageColor(color: UIColor.App.iconPrimary)
            sportsTitleLabel.textColor = UIColor.App.iconPrimary
            sportsIconImageView.setImageColor(color: UIColor.App.iconPrimary)
            liveTitleLabel.textColor = UIColor.App.iconPrimary
            liveIconImageView.setImageColor(color: UIColor.App.iconPrimary)
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

}

extension RootViewController {

    func unlockAppWithUser() {
        // Unlock the app

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

    @IBAction private func didTapUnlockButton() {
        self.authenticateUser()
    }

    @IBAction private func didTapCancelUnlockButton() {
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
        self.showLocalAuthenticationCoveringViewIfNeeded()
        print("LocalAuth Background")
    }

    @objc func appDidBecomeActive() {
        // self.authenticateUser()
        print("LocalAuth Active")

        self.reloadChildViewControllersData()
    }

    @objc func appWillResignActive() {
        //  self.isLocalAuthenticationCoveringView = true
        print("LocalAuth Inactive")
    }

    func authenticateUser() {
        
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
                localizedReason: "Access requires authentication",
                reply: { success, error in

                    DispatchQueue.main.async {
                        if let err = error {
                            switch err._code {
                            case LAError.Code.systemCancel.rawValue:
                                self.notifyUser("Session cancelled", errorMessage: err.localizedDescription)
                            case LAError.Code.userCancel.rawValue:
                                self.notifyUser("Please try again", errorMessage: err.localizedDescription)
                            case LAError.Code.userFallback.rawValue:
                                self.notifyUser("Authentication", errorMessage: "Password option selected")
                            default:
                                self.notifyUser("Authentication failed", errorMessage: err.localizedDescription)
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
                    notifyUser("User is not enrolled", errorMessage: err.localizedDescription)
                case LAError.Code.passcodeNotSet.rawValue:
                    notifyUser("A passcode has not been set", errorMessage: err.localizedDescription)
                case LAError.Code.biometryNotAvailable.rawValue:
                    notifyUser("Biometric authentication not available", errorMessage: err.localizedDescription)
                default:
                    notifyUser("Unknown error", errorMessage: err.localizedDescription)
                }
            }
        }

    }

    func notifyUser(_ title: String, errorMessage: String?) {
        let alert = UIAlertController(title: title,
                                      message: errorMessage,
                                      preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "OK",
                                         style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
    }

}

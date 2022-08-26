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

class RootViewController: UIViewController {

    @IBOutlet private var topSafeAreaView: UIView!
    @IBOutlet private var topBarView: UIView!
    
    @IBOutlet private var containerView: UIView!
    
    @IBOutlet private var leadingSportsBookContentConstriant: NSLayoutConstraint!
    
    @IBOutlet private var sportsBookContentView: UIView!
    @IBOutlet private var casinoContentView: UIView!

    @IBOutlet private var homeBaseView: UIView!
    @IBOutlet private var preLiveBaseView: UIView!
    @IBOutlet private var liveBaseView: UIView!
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
    
    @IBOutlet private var casinoButtonBaseView: UIView!
    @IBOutlet private var casinoIconImageView: UIImageView!
    @IBOutlet private var casinoTitleLabel: UILabel!
    
    @IBOutlet private var sportsbookButtonBaseView: UIView!
    @IBOutlet private var sportsbookIconImageView: UIImageView!
    @IBOutlet private var sportsbookTitleLabel: UILabel!
    
    @IBOutlet private var profileBaseView: UIView!
    @IBOutlet private var profilePictureBaseView: UIView!
    @IBOutlet private var profilePictureImageView: UIImageView!

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
    var isLocalAuthenticationCoveringView: Bool = true {
        didSet {
            if isLocalAuthenticationCoveringView {
                self.localAuthenticationBaseView.alpha = 1.0
//                UIView.animate(withDuration: 0.2,
//                               delay: 0.0,
//                               options: .curveEaseIn,
//                               animations: {
//                    self.localAuthenticationBaseView.alpha = 1.0
//                }, completion: { _ in
//
//                })
            }
            else {
                self.localAuthenticationBaseView.alpha = 0.0
//                UIView.animate(withDuration: 0.2,
//                               delay: 0.0,
//                               options: .curveEaseOut,
//                               animations: {
//                    self.localAuthenticationBaseView.alpha = 0.0
//                }, completion: { _ in
//
//                })
            }
        }
    }
    
    //
    let activeButtonAlpha = 1.0
    let idleButtonAlpha = 0.52
    
    var userId: String {
    
        let status = Env.everyMatrixClient.userSessionStatusPublisher.value
        if status == .logged {
            if let session = UserSessionStore.loggedUserSession() {
                return session.userId
            }
            else {
                return ""
            }
        }
        else {
                return ""
        }
    }
    
    //
    // Child view controllers
    lazy var homeViewController = HomeViewController()
    lazy var preLiveViewController = PreLiveEventsViewController(selectedSportType: Sport.football)
    lazy var liveEventsViewController = LiveEventsViewController()
    
    lazy var casinoViewController = CasinoWebViewController(userId: self.userId)

    // Loaded view controllers
    var homeViewControllerLoaded = false
    var preLiveViewControllerLoaded = false
    var liveEventsViewControllerLoaded = false
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
    
    enum ScreenState {
        case logged(user: UserSession)
        case anonymous
    }
    var screenState: ScreenState = .anonymous {
        didSet {
            self.setupWithState(self.screenState)
        }
    }

    //
    //
    init(initialScreen: TabItem = .home, defaultSport: Sport = .football) {
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

        self.view.sendSubviewToBack(topBarView)
        self.view.sendSubviewToBack(tabBarView)

        self.commonInit()
        self.loadChildViewControllerIfNeeded(tab: self.selectedTabItem)

        //
         self.pictureInPictureView = PictureInPictureView()
         self.overlayWindow.addSubview(self.pictureInPictureView!, anchors: [.leading(0), .trailing(0), .top(0), .bottom(0)] )
         self.overlayWindow.isHidden = false // .makeKeyAndVisible()

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

        Env.userSessionStore.userSessionPublisher
            .receive(on: DispatchQueue.main) 
            .sink { userSession in
                if let userSession = userSession {
                    self.screenState = .logged(user: userSession)

                    Env.everyMatrixClient.getUserMetadata()
                        .receive(on: DispatchQueue.main)
                        .eraseToAnyPublisher()
                        .sink { _ in
                        } receiveValue: { [weak self] userMetadata in
                            if let userMetadataFavorites = userMetadata.records[0].value {
                                Env.favoritesManager.favoriteEventsIdPublisher.send(userMetadataFavorites)
                            }

                            if self?.preLiveViewControllerLoaded ?? false {
                                self?.preLiveViewController.reloadData()
                            }                        }
                        .store(in: &self.cancellables)
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
        
        //Add blur effect
        self.localAuthenticationBaseView.backgroundColor = .clear
        
        let blurEffect = UIBlurEffect(style: .regular)
        
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.translatesAutoresizingMaskIntoConstraints = false
        
        //if you have more UIViews, use an insertSubview API to place it where needed
        self.localAuthenticationBaseView.insertSubview(blurEffectView, at: 0)

        NSLayoutConstraint.activate([
            blurEffectView.leadingAnchor.constraint(equalTo: self.localAuthenticationBaseView.leadingAnchor),
            blurEffectView.trailingAnchor.constraint(equalTo: self.localAuthenticationBaseView.trailingAnchor),
            blurEffectView.topAnchor.constraint(equalTo: self.localAuthenticationBaseView.topAnchor),
            blurEffectView.bottomAnchor.constraint(equalTo: self.localAuthenticationBaseView.bottomAnchor),
        ])
        
        self.localAuthenticationBaseView.alpha = 0.0
        self.showLocalAuthenticationCoveringViewIfNeeded()
        
        self.authenticateUser()

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        Env.userSessionStore.userBalanceWallet
            .compactMap({$0})
            .map(\.amount)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] value in
                if let bonusWallet = Env.userSessionStore.userBonusBalanceWallet.value {
                    let accountValue = bonusWallet.amount + value
                    self?.accountValueLabel.text = CurrencyFormater.defaultFormat.string(from: NSNumber(value: accountValue)) ?? "-.--€"

                }
                else {
                    self?.accountValueLabel.text = CurrencyFormater.defaultFormat.string(from: NSNumber(value: value)) ?? "-.--€"
                }
            }
            .store(in: &cancellables)

        Env.userSessionStore.userBonusBalanceWallet
            .compactMap({$0})
            .map(\.amount)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] value in
                if let currentWallet = Env.userSessionStore.userBalanceWallet.value {
                    let accountValue = currentWallet.amount + value
                    self?.accountValueLabel.text = CurrencyFormater.defaultFormat.string(from: NSNumber(value: accountValue)) ?? "-.--€"
                }
            }
            .store(in: &cancellables)

        Env.userSessionStore.forceWalletUpdate()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    
        executeDelayed(0.1) {
            self.loadChildViewControllerIfNeeded(tab: .preLive)
        }
        
        executeDelayed(0.2) {
            self.loadChildViewControllerIfNeeded(tab: .live)
        }
        
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        self.setupWithTheme()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        self.profilePictureBaseView.layer.cornerRadius = profilePictureBaseView.frame.size.width/2
        self.profilePictureImageView.layer.cornerRadius = profilePictureImageView.frame.size.width/2
        self.profilePictureImageView.layer.borderWidth = 1
        self.profilePictureImageView.layer.borderColor = UIColor.App.highlightPrimary.cgColor
        
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
        
        self.casinoBottomView.backgroundColor = UIColor.App.backgroundPrimary
        
        self.casinoButtonBaseView.backgroundColor = UIColor.App.backgroundCards
        self.casinoButtonBaseView.layer.maskedCorners = [ .layerMinXMaxYCorner, .layerMinXMinYCorner]
        
        self.sportsbookButtonBaseView.backgroundColor = UIColor.App.backgroundCards
        self.sportsbookButtonBaseView.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMaxXMinYCorner]
        
        let homeTapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapHomeTabItem))
        homeButtonBaseView.addGestureRecognizer(homeTapGesture)

        let sportsTapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapSportsTabItem))
        sportsButtonBaseView.addGestureRecognizer(sportsTapGesture)

        let liveTapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapLiveTabItem))
        liveButtonBaseView.addGestureRecognizer(liveTapGesture)
        
        let casinoTapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapCasinoTabItem))
        casinoButtonBaseView.addGestureRecognizer(casinoTapGesture)
        
        let sportsbookTapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapSportsbookIcon))
        sportsbookButtonBaseView.addGestureRecognizer(sportsbookTapGesture)

        let profileTapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapProfileButton))
        profilePictureBaseView.addGestureRecognizer(profileTapGesture)

        //
        accountValueLabel.text = localized("loading")
        accountValueLabel.font = AppFont.with(type: .bold, size: 12)

        let accountValueTapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapAccountValue))
        accountValueView.addGestureRecognizer(accountValueTapGesture)

        //
        loginButton.setTitle(localized("login"), for: .normal)
        loginButton.titleLabel?.font = AppFont.with(type: AppFont.AppFontType.bold, size: 13)

        self.notificationCounterLabel.font = AppFont.with(type: .semibold, size: 12)

    }

    func setupWithTheme() {

        self.homeBaseView.backgroundColor = UIColor.App.backgroundPrimary
        self.preLiveBaseView.backgroundColor = UIColor.App.backgroundPrimary
        self.liveBaseView.backgroundColor = UIColor.App.backgroundPrimary
        self.casinoBaseView.backgroundColor = UIColor.App.backgroundPrimary
        
        self.homeTitleLabel.textColor = UIColor.App.highlightPrimary
        self.liveTitleLabel.textColor = UIColor.App.highlightPrimary
        self.sportsTitleLabel.textColor = UIColor.App.highlightPrimary
        
        self.casinoTitleLabel.textColor = UIColor.App.textSecondary
        self.sportsbookTitleLabel.textColor = UIColor.App.textSecondary
        
        self.topSafeAreaView.backgroundColor = UIColor.App.backgroundPrimary
        self.topBarView.backgroundColor = UIColor.App.backgroundPrimary
        self.sportsBookContentView.backgroundColor = UIColor.App.backgroundPrimary
        self.tabBarView.backgroundColor = UIColor.App.backgroundPrimary
        self.bottomSafeAreaView.backgroundColor = UIColor.App.backgroundPrimary

        self.tabBarView.layer.shadowRadius = 20
        self.tabBarView.layer.shadowOffset = .zero
        self.tabBarView.layer.shadowColor = UIColor.black.cgColor
        self.tabBarView.layer.shadowOpacity = 0.25

        self.topBarView.layer.shadowRadius = 20
        self.topBarView.layer.shadowOffset = .zero
        self.topBarView.layer.shadowColor = UIColor.black.cgColor
        self.topBarView.layer.shadowOpacity = 0.25

        self.homeButtonBaseView.backgroundColor = UIColor.App.backgroundPrimary
        self.sportsButtonBaseView.backgroundColor = UIColor.App.backgroundPrimary
        self.liveButtonBaseView.backgroundColor = UIColor.App.backgroundPrimary
        self.profilePictureBaseView.backgroundColor = UIColor.App.highlightPrimary

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
        self.casinoIconImageView.setImageColor(color: UIColor.App.iconSecondary)
        
        self.sportsbookButtonBaseView.alpha = self.activeButtonAlpha
        self.sportsbookIconImageView.setImageColor(color: UIColor.App.iconSecondary)
        
        self.redrawButtonButtons()

        self.notificationCounterLabel.textColor = UIColor.App.buttonTextPrimary
    }

    func setupWithState(_ state: ScreenState) {
        switch state {
        case .logged:
            self.loginBaseView.isHidden = true
            self.profileBaseView.isHidden = false
            self.accountValueBaseView.isHidden = false
            
            Env.userSessionStore.forceWalletUpdate()
        case .anonymous:
            self.loginBaseView.isHidden = false
            self.profileBaseView.isHidden = true
            self.accountValueBaseView.isHidden = true
            
        }
    }

    func selectSport(_ sport: Sport) {
        self.currentSport = sport
        if preLiveViewControllerLoaded {
            self.preLiveViewController.selectedSport = sport
        }
        if liveEventsViewControllerLoaded {
            self.liveEventsViewController.selectedSport = sport
        }
    }

    func didChangedPreLiveSport(_ sport: Sport) {
        self.currentSport = sport
        if liveEventsViewControllerLoaded {
            self.liveEventsViewController.selectedSport = sport
        }
    }

    func didChangedLiveSport(_ sport: Sport) {
        self.currentSport = sport
        if preLiveViewControllerLoaded {
            self.preLiveViewController.selectedSport = sport
        }
    }

    func openBetslipModal() {
        let betslipViewController = BetslipViewController()
        betslipViewController.willDismissAction = { [weak self] in
            self?.reloadChildViewControllersData()
        }
        self.present(Router.navigationController(with: betslipViewController), animated: true, completion: nil)
    }

    func openChatModal() {
        if UserSessionStore.isUserLogged() {
            let socialViewController = SocialViewController()
            self.present(Router.navigationController(with: socialViewController), animated: true, completion: nil)
        }
        else {
            let loginViewController = Router.navigationController(with: LoginViewController())
            self.present(loginViewController, animated: true, completion: nil)
        }
    }

    func openInternalWebview(onURL url: URL) {
        let internalBrowserViewController = InternalBrowserViewController(url: url)
        let navigationViewController = Router.navigationController(with: internalBrowserViewController)
        navigationViewController.modalPresentationStyle = .fullScreen
        self.present(navigationViewController, animated: true, completion: nil)
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

    //
    @IBAction private func didTapLogin() {
        let loginViewController = Router.navigationController(with: LoginViewController())
        self.present(loginViewController, animated: true, completion: nil)
    }

    @IBAction private func didTapSearchButton() {
        let searchViewController = SearchViewController()
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

// Navigations between tabs
extension RootViewController {

    func didSelectSeeAllPopular(sport: Sport) {
        self.loadChildViewControllerIfNeeded(tab: .preLive)
        if preLiveViewControllerLoaded {
            self.selectSport(sport)
            self.preLiveViewController.openPopularTab()
            self.didTapSportsTabItem()
        }
    }

    func didSelectSeeAllLive(sport: Sport) {
        self.loadChildViewControllerIfNeeded(tab: .live)
        if liveEventsViewControllerLoaded {
            self.selectSport(sport)
            self.didTapLiveTabItem()
        }
    }

    func didSelectSeeAllCompetition(sport: Sport, competitionId: String) {
        self.loadChildViewControllerIfNeeded(tab: .preLive)
        if preLiveViewControllerLoaded {
            self.selectSport(sport)
            self.preLiveViewController.openCompetitionTab(withId: competitionId)
            self.didTapSportsTabItem()
        }
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
            homeViewControllerLoaded = true
            
        }

        if case .preLive = tab, !preLiveViewControllerLoaded {
            self.addChildViewController(self.preLiveViewController, toView: self.preLiveBaseView)
            self.preLiveViewController.selectedSport = self.currentSport
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
            self.liveEventsViewController.selectedSport = self.currentSport
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
        let loginViewController = Router.navigationController(with: LoginViewController())
        self.present(loginViewController, animated: true, completion: nil)
    }

    @objc private func didTapProfileButton() {
        self.presentProfileViewController()
    }

    @objc private func didTapAccountValue() {
        let depositViewController = DepositViewController()
        let navigationViewController = Router.navigationController(with: depositViewController)
        self.present(navigationViewController, animated: true, completion: nil)
    }

    private func presentProfileViewController() {
        if let loggedUser = UserSessionStore.loggedUserSession() {
            let profileViewController = ProfileViewController(userSession: loggedUser)
            let navigationViewController = Router.navigationController(with: profileViewController)
            self.present(navigationViewController, animated: true, completion: nil)
        }
    }
}

extension RootViewController {

    func requestPopUpContent() {
        Env.gomaNetworkClient.requestPopUpInfo(deviceId: Env.deviceId)
            .compactMap({$0})
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: showPopUp(_:))
            .store(in: &cancellables)
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

        self.redrawButtonButtons()
    }

    func selectSportsTabBarItem() {
        self.loadChildViewControllerIfNeeded(tab: .preLive)

        self.homeBaseView.isHidden = true
        self.preLiveBaseView.isHidden = false
        self.liveBaseView.isHidden = true

        self.redrawButtonButtons()
    }

    func selectLiveTabBarItem() {
        self.loadChildViewControllerIfNeeded(tab: .live)

        self.homeBaseView.isHidden = true
        self.preLiveBaseView.isHidden = true
        self.liveBaseView.isHidden = false

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
           
        case .preLive:
            sportsButtonBaseView.alpha = self.activeButtonAlpha
            homeTitleLabel.textColor = UIColor.App.iconSecondary
            homeIconImageView.setImageColor(color: UIColor.App.iconSecondary)
            sportsTitleLabel.textColor = UIColor.App.highlightPrimary
            sportsIconImageView.setImageColor(color: UIColor.App.highlightPrimary)
            liveTitleLabel.textColor = UIColor.App.iconSecondary
            liveIconImageView.setImageColor(color: UIColor.App.iconSecondary)

        case .live:
            liveButtonBaseView.alpha = self.activeButtonAlpha
            homeTitleLabel.textColor = UIColor.App.iconSecondary
            homeIconImageView.setImageColor(color: UIColor.App.iconSecondary)
            sportsTitleLabel.textColor = UIColor.App.iconSecondary
            sportsIconImageView.setImageColor(color: UIColor.App.iconSecondary)
            liveTitleLabel.textColor = UIColor.App.highlightPrimary
            liveIconImageView.setImageColor(color: UIColor.App.highlightPrimary)
            
        case .casino:
            homeTitleLabel.textColor = UIColor.App.iconSecondary
            homeIconImageView.setImageColor(color: UIColor.App.iconSecondary)
            sportsTitleLabel.textColor = UIColor.App.iconSecondary
            sportsIconImageView.setImageColor(color: UIColor.App.iconSecondary)
            liveTitleLabel.textColor = UIColor.App.iconSecondary
            liveIconImageView.setImageColor(color: UIColor.App.iconSecondary)
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
    
    func showLocalAuthenticationCoveringViewIfNeeded() {
        if Env.userSessionStore.shouldRequestFaceId() {
            self.isLocalAuthenticationCoveringView = true
        }
    }
    
    @IBAction private func didTapUnlockButton() {
        self.authenticateUser()
    }
    
    @objc func appWillEnterForeground() {
        self.authenticateUser()
        print("LocalAuth Foreground")
    }
    
    @objc func appDidEnterBackground() {
        self.showLocalAuthenticationCoveringViewIfNeeded()
        print("LocalAuth Background")
    }

    @objc func appDidBecomeActive() {
        // self.authenticateUser()
        print("LocalAuth Active")
    }
    
    @objc func appWillResignActive() {
        //  self.isLocalAuthenticationCoveringView = true
        print("LocalAuth Inactive")
    }
    
    func authenticateUser() {
    
        if !Env.userSessionStore.shouldRequestFaceId() {
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
                                self.notifyUser("Session cancelled", err: err.localizedDescription)
                            case LAError.Code.userCancel.rawValue:
                                self.notifyUser("Please try again", err: err.localizedDescription)
                            case LAError.Code.userFallback.rawValue:
                                self.notifyUser("Authentication", err: "Password option selected")
                            default:
                                self.notifyUser("Authentication failed", err: err.localizedDescription)
                            }
                        }
                        else {
                            // Unlock the app
                            self.isLocalAuthenticationCoveringView = false
                        }
                    }
            })
            
        }
        else {
            // Device cannot use biometric authentication
            if let err = error {
                switch err.code {
                case LAError.Code.biometryNotEnrolled.rawValue:
                    notifyUser("User is not enrolled", err: err.localizedDescription)
                case LAError.Code.passcodeNotSet.rawValue:
                    notifyUser("A passcode has not been set", err: err.localizedDescription)
                case LAError.Code.biometryNotAvailable.rawValue:
                    notifyUser("Biometric authentication not available", err: err.localizedDescription)
                default:
                    notifyUser("Unknown error", err: err.localizedDescription)
                }
            }
        }
        
    }
    
    func notifyUser(_ msg: String, err: String?) {
        let alert = UIAlertController(title: msg,
                                      message: err,
                                      preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "OK",
                                         style: .cancel, handler: nil)
        
        alert.addAction(cancelAction)
        self.present(alert, animated: true,
                     completion: nil)
    }
    
}

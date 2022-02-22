//
//  RootViewController.swift
//  Sportsbook
//
//  Created by Ruben Roques on 24/09/2021.
//

import UIKit
import Combine

class RootViewController: UIViewController {

    @IBOutlet private weak var topSafeAreaView: UIView!
    @IBOutlet private weak var topBarView: UIView!
    @IBOutlet private weak var contentView: UIView!

    @IBOutlet private weak var homeBaseView: UIView!
    @IBOutlet private weak var preLiveBaseView: UIView!
    @IBOutlet private weak var liveBaseView: UIView!

    @IBOutlet private weak var tabBarView: UIView!
    @IBOutlet private weak var bottomSafeAreaView: UIView!

    @IBOutlet private weak var sportsButtonBaseView: UIView!
    @IBOutlet private weak var sportsIconImageView: UIImageView!
    @IBOutlet private weak var sportsTitleLabel: UILabel!

    @IBOutlet private weak var homeButtonBaseView: UIView!
    @IBOutlet private weak var homeIconImageView: UIImageView!
    @IBOutlet private weak var homeTitleLabel: UILabel!

    @IBOutlet private weak var liveButtonBaseView: UIView!
    @IBOutlet private weak var liveIconImageView: UIImageView!
    @IBOutlet private weak var liveTitleLabel: UILabel!

    @IBOutlet private weak var profileBaseView: UIView!
    @IBOutlet private weak var profilePictureBaseView: UIView!
    @IBOutlet private weak var profilePictureImageView: UIImageView!

    @IBOutlet private weak var searchButton: UIButton!
    @IBOutlet private weak var logoImageView: UIImageView!

    @IBOutlet private var loginBaseView: UIView!
    @IBOutlet private var loginButton: UIButton!

    @IBOutlet private var accountValueBaseView: UIView!
    @IBOutlet private var accountValueView: UIView!
    @IBOutlet private var accountPlusView: UIView!
    @IBOutlet private var accountValueLabel: UILabel!

    // Child view controllers
    lazy var homeViewController = HomeViewController()
    lazy var preLiveViewController = PreLiveEventsViewController(selectedSportType: Sport.football)
    lazy var liveEventsViewController = LiveEventsViewController()

    // Loaded view controllers
    var homeViewControllerLoaded = false
    var preLiveViewControllerLoaded = false
    var liveEventsViewControllerLoaded = false

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
            }
        }
    }

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

    override func viewDidLoad() {
        super.viewDidLoad()
        
        AnalyticsClient.sendEvent(event: .appStart)

        self.view.sendSubviewToBack(topBarView)
        self.view.sendSubviewToBack(tabBarView)
        self.view.sendSubviewToBack(contentView)

        self.commonInit()
        self.loadChildViewControllerIfNeeded(tab: self.selectedTabItem)
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
                                self?.preLiveViewController.reloadTableViewData()
                            }                        }
                        .store(in: &self.cancellables)
                }
                else {
                    self.screenState = .anonymous

                    if self.preLiveViewControllerLoaded {
                        self.preLiveViewController.reloadTableViewData()
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

        // TODO: Code Review 14/02 - Remove this after the option is added to the correct place
        self.testNewFavorites()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        Env.userSessionStore.userBalanceWallet
            .compactMap({$0})
            .map(\.amount)
            .map({ CurrencyFormater.defaultFormat.string(from: NSNumber(value: $0)) ?? "-.--€"})
            .receive(on: DispatchQueue.main)
            .sink { [weak self] value in
                self?.accountValueLabel.text = value
            }
            .store(in: &cancellables)

        Env.userSessionStore.forceWalletUpdate()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        self.setupWithTheme()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        profilePictureBaseView.layer.cornerRadius = profilePictureBaseView.frame.size.width/2
        profilePictureImageView.layer.cornerRadius = profilePictureImageView.frame.size.width/2
        profilePictureImageView.layer.borderWidth = 1
        profilePictureImageView.layer.borderColor = UIColor.App.highlightSecondary.cgColor
        
        profilePictureImageView.layer.masksToBounds = true

        accountValueView.layer.cornerRadius = CornerRadius.view
        accountValueView.layer.masksToBounds = true
        accountValueView.isUserInteractionEnabled = true

        accountPlusView.layer.cornerRadius = CornerRadius.squareView
        accountPlusView.layer.masksToBounds = true
    }

    func commonInit() {

        switch self.selectedTabItem {
        case .home:
            homeButtonBaseView.alpha = 1.0
            sportsButtonBaseView.alpha = 0.2
            liveButtonBaseView.alpha = 0.2
        case .preLive:
            homeButtonBaseView.alpha = 0.2
            sportsButtonBaseView.alpha = 1.0
            liveButtonBaseView.alpha = 0.2
        case .live:
            homeButtonBaseView.alpha = 0.2
            sportsButtonBaseView.alpha = 0.2
            liveButtonBaseView.alpha = 1.0
        }

        //
        self.homeTitleLabel.text = localized("home")
        self.sportsTitleLabel.text = localized("sports")
        self.liveTitleLabel.text = localized("live")

        //
        let homeTapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapHomeTabItem))
        homeButtonBaseView.addGestureRecognizer(homeTapGesture)

        let sportsTapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapSportsTabItem))
        sportsButtonBaseView.addGestureRecognizer(sportsTapGesture)

        let liveTapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapLiveTabItem))
        liveButtonBaseView.addGestureRecognizer(liveTapGesture)

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

    }

    func setupWithTheme() {

        homeBaseView.backgroundColor = UIColor.App.backgroundPrimary
        preLiveBaseView.backgroundColor = UIColor.App.backgroundPrimary
        liveBaseView.backgroundColor = UIColor.App.backgroundPrimary

        homeTitleLabel.textColor = UIColor.App.textPrimary
        liveTitleLabel.textColor = UIColor.App.textPrimary
        sportsTitleLabel.textColor = UIColor.App.textPrimary

        topSafeAreaView.backgroundColor = UIColor.App.backgroundPrimary
        topBarView.backgroundColor = UIColor.App.backgroundPrimary
        contentView.backgroundColor = UIColor.App.backgroundPrimary
        tabBarView.backgroundColor = UIColor.App.backgroundPrimary
        bottomSafeAreaView.backgroundColor = UIColor.App.backgroundPrimary

        tabBarView.layer.shadowRadius = 20
        tabBarView.layer.shadowOffset = .zero
        tabBarView.layer.shadowColor = UIColor.black.cgColor
        tabBarView.layer.shadowOpacity = 0.25

        topBarView.layer.shadowRadius = 20
        topBarView.layer.shadowOffset = .zero
        topBarView.layer.shadowColor = UIColor.black.cgColor
        topBarView.layer.shadowOpacity = 0.25

        homeButtonBaseView.backgroundColor = .clear
        sportsButtonBaseView.backgroundColor = .clear
        liveButtonBaseView.backgroundColor = .clear

        profilePictureBaseView.backgroundColor = UIColor.App.highlightSecondary

        loginButton.setTitleColor(UIColor.App.buttonTextPrimary, for: .normal)
        loginButton.setTitleColor(UIColor.App.buttonTextPrimary.withAlphaComponent(0.7), for: .highlighted)
        loginButton.setTitleColor(UIColor.App.buttonTextPrimary.withAlphaComponent(0.4), for: .disabled)
        loginButton.setBackgroundColor(UIColor.App.buttonBackgroundPrimary, for: .normal)
        loginButton.setBackgroundColor(UIColor.App.buttonBackgroundPrimary, for: .highlighted)
        loginButton.layer.cornerRadius = CornerRadius.view
        loginButton.layer.masksToBounds = true

        accountValueView.backgroundColor = UIColor.App.backgroundSecondary
        accountValueLabel.textColor = UIColor.App.textPrimary
        accountPlusView.backgroundColor = UIColor.App.separatorLineHighlightSecondary
    }

    func setupWithState(_ state: ScreenState) {
        switch state {
        case let .logged:
            self.loginBaseView.isHidden = true
            self.profileBaseView.isHidden = false
            self.accountValueBaseView.isHidden = false
            self.searchButton.isHidden = false
            Env.userSessionStore.forceWalletUpdate()
        case .anonymous:
            self.loginBaseView.isHidden = false
            self.profileBaseView.isHidden = true
            self.accountValueBaseView.isHidden = true
            self.searchButton.isHidden = false
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

    func reloadChildViewControllersData() {
        if preLiveViewControllerLoaded {
            self.preLiveViewController.reloadData()
        }
        if liveEventsViewControllerLoaded {
            self.liveEventsViewController.reloadData()
        }
    }

    //
    func testNewFavorites() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        self.topBarView.addGestureRecognizer(tap)
    }

    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
        print("TAP")
        let favoritesVC = MyFavoritesViewController()
        self.present(favoritesVC, animated: true, completion: nil)
    }

    //
    @IBAction private func didTapLogin() {
        let loginViewController = Router.navigationController(with: LoginViewController())
        self.present(loginViewController, animated: true, completion: nil)
    }

    @IBAction private func didTapSearchButton() {
        let searchViewController = SearchViewController()

        searchViewController.didSelectCompetitionAction = { [weak self] value in
            searchViewController.dismiss(animated: true, completion: nil)
            self?.preLiveViewController.selectedShortcutItem = 2
            self?.preLiveViewController.applyCompetitionsFiltersWithIds([value])
        }

        self.present(searchViewController, animated: true, completion: nil)
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

            self.homeViewController.didSelectSeeAllPopular = { [weak self] sport in
                self?.didSelectSeeAllPopular(sport: sport)
            }
            self.homeViewController.didSelectSeeAllLive = { [weak self] sport in
                self?.didSelectSeeAllLive(sport: sport)
            }
            self.homeViewController.didSelectSeeAllCompetition = { [weak self] sport, competitionId in
                self?.didSelectSeeAllCompetition(sport: sport, competitionId: competitionId)
            }

            homeViewControllerLoaded = true
        }

        if case .preLive = tab, !preLiveViewControllerLoaded {
            self.addChildViewController(self.preLiveViewController, toView: self.preLiveBaseView)
            self.preLiveViewController.selectedSport = self.currentSport
            self.preLiveViewController.didChangeSport = { [weak self] newSport in
                self?.didChangedPreLiveSport(newSport)
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
            self.liveEventsViewController.didTapBetslipButtonAction = { [weak self] in
                self?.openBetslipModal()
            }
            liveEventsViewControllerLoaded = true
        }

    }
}

extension RootViewController {

    // TODO: Not implemented on the flow
    @IBAction private func didTapLoginButton() {
        let loginViewController = Router.navigationController(with: LoginViewController())
        self.present(loginViewController, animated: true, completion: nil)
    }

    @objc private func didTapProfileButton() {
        self.pushProfileViewController()
    }

    @objc private func didTapAccountValue() {
        let depositViewController = DepositViewController()
        self.navigationController?.pushViewController(depositViewController, animated: true)
    }

    private func pushProfileViewController() {
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
        self.selectedTabItem = .home
    }

    @objc private func didTapSportsTabItem() {
        self.selectedTabItem = .preLive
    }

    @objc private func didTapLiveTabItem() {
        self.selectedTabItem = .live
    }

    func selectHomeTabBarItem() {
        self.loadChildViewControllerIfNeeded(tab: .home)

        self.homeBaseView.isHidden = false
        self.preLiveBaseView.isHidden = true
        self.liveBaseView.isHidden = true

        homeButtonBaseView.alpha = 1.0
        sportsButtonBaseView.alpha = 0.2
        liveButtonBaseView.alpha = 0.2
    }

    func selectSportsTabBarItem() {
        self.loadChildViewControllerIfNeeded(tab: .preLive)

        self.homeBaseView.isHidden = true
        self.preLiveBaseView.isHidden = false
        self.liveBaseView.isHidden = true

        homeButtonBaseView.alpha = 0.2
        sportsButtonBaseView.alpha = 1.0
        liveButtonBaseView.alpha = 0.2
    }

    func selectLiveTabBarItem() {
        self.loadChildViewControllerIfNeeded(tab: .live)

        self.homeBaseView.isHidden = true
        self.preLiveBaseView.isHidden = true
        self.liveBaseView.isHidden = false

        homeButtonBaseView.alpha = 0.2
        sportsButtonBaseView.alpha = 0.2
        liveButtonBaseView.alpha = 1.0
    }

}

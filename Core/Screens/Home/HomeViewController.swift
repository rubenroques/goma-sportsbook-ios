//
//  HomeViewController.swift
//  Sportsbook
//
//  Created by Ruben Roques on 24/09/2021.
//

import UIKit
import Combine

class HomeViewController: UIViewController {

    @IBOutlet private weak var topSafeAreaView: UIView!
    @IBOutlet private weak var topBarView: UIView!
    @IBOutlet private weak var contentView: UIView!

    @IBOutlet private weak var preLiveBaseView: UIView!
    @IBOutlet private weak var liveBaseView: UIView!

    @IBOutlet private weak var tabBarView: UIView!
    @IBOutlet private weak var bottomSafeAreaView: UIView!

    @IBOutlet private weak var sportsButtonBaseView: UIView!
    @IBOutlet private weak var sportsIconImageView: UIImageView!
    @IBOutlet private weak var sportsTitleLabel: UILabel!

    @IBOutlet private weak var liveButtonBaseView: UIView!
    @IBOutlet private weak var liveIconImageView: UIImageView!
    @IBOutlet private weak var liveTitleLabel: UILabel!

    @IBOutlet private weak var profilePictureBaseView: UIView!
    @IBOutlet private weak var profilePictureImageView: UIImageView!

    @IBOutlet private weak var searchButton: UIButton!
    @IBOutlet private weak var logoImageView: UIImageView!

    @IBOutlet private weak var loginButton: UIButton!

    // Child view controllers
    lazy var preLiveViewController = PreLiveEventsViewController()
    lazy var liveEventsViewController = LiveEventsViewController()

    // Loaded view controllers
    var preLiveViewControllerLoaded = false
    var liveEventsViewControllerLoaded = false

    var currentSportType: SportType

    // Combine
    var cancellables = Set<AnyCancellable>()

    //
    var canShowPopUp: Bool = true
    var popUpPromotionView: PopUpPromotionView?
    var popUpBackgroundView: UIView?

    enum TabItem {
        case sports
        case live
    }
    var selectedTabItem: TabItem {
        didSet {
            switch selectedTabItem {
            case .sports:
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
    init(initialScreen: TabItem = .sports) {
        self.selectedTabItem = initialScreen
        self.currentSportType = .football
        super.init(nibName: "HomeViewController", bundle: nil)
    }

    @available(iOS, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

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

                    Env.everyMatrixAPIClient.getUserMetadata()
                        .receive(on: DispatchQueue.main)
                        .eraseToAnyPublisher()
                        .sink { _ in
                        } receiveValue: { [weak self] userMetadata in
                            if userMetadata.records[0].value != nil {
                                Env.favoritesManager.favoriteEventsId = userMetadata.records[0].value!
                            }

                            self?.preLiveViewController.reloadTableViewData()

                        }
                        .store(in: &self.cancellables)
                }
                else {
                    self.screenState = .anonymous
                    self.preLiveViewController.reloadTableViewData()
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

        Env.everyMatrixAPIClient.getOperatorInfo()
            .receive(on: DispatchQueue.main)
            .sink { completed in
                print(completed)
            } receiveValue: { operatorInfo in
                print(operatorInfo)
            }
            .store(in: &cancellables)

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
//
//                EveryMatrixAPIClient.operatorInfo().sink(receiveCompletion: { completion in
//                    Logger.log("completion \(completion)")
//                }, receiveValue: { operatorInfo in
//                    Logger.log("Socket connected: \(TSManager.shared.isConnected)")
//                })
//                .store(in: &cancellables)
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        self.setupWithTheme()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        profilePictureBaseView.layer.cornerRadius = profilePictureBaseView.frame.size.width/2
        profilePictureImageView.layer.cornerRadius = profilePictureImageView.frame.size.width/2
    }

    func commonInit() {

        liveButtonBaseView.alpha = 0.2

        loginButton.setTitle(localized("string_login"), for: .normal)
        loginButton.titleLabel?.font = AppFont.with(type: AppFont.AppFontType.bold, size: 13)

        let sportsTapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapSportsTabItem))
        sportsButtonBaseView.addGestureRecognizer(sportsTapGesture)

        let liveTapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapLiveTabItem))
        liveButtonBaseView.addGestureRecognizer(liveTapGesture)

        let profileTapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapProfileButton))
        profilePictureBaseView.addGestureRecognizer(profileTapGesture)
    }

    func setupWithTheme() {

        preLiveBaseView.backgroundColor = UIColor.App.mainBackground
        liveBaseView.backgroundColor = UIColor.App.mainBackground

        topSafeAreaView.backgroundColor = UIColor.App.mainBackground
        topBarView.backgroundColor = UIColor.App.mainBackground
        contentView.backgroundColor = UIColor.App.contentBackground
        tabBarView.backgroundColor = UIColor.App.mainBackground
        bottomSafeAreaView.backgroundColor = UIColor.App.mainBackground

        tabBarView.layer.shadowRadius = 20
        tabBarView.layer.shadowOffset = .zero
        tabBarView.layer.shadowColor = UIColor.black.cgColor
        tabBarView.layer.shadowOpacity = 0.25

        topBarView.layer.shadowRadius = 20
        topBarView.layer.shadowOffset = .zero
        topBarView.layer.shadowColor = UIColor.black.cgColor
        topBarView.layer.shadowOpacity = 0.25

        sportsButtonBaseView.backgroundColor = .clear
        liveButtonBaseView.backgroundColor = .clear

        profilePictureBaseView.backgroundColor = UIColor.App.mainTint

        loginButton.setTitleColor(UIColor.App.headingMain, for: .normal)
        loginButton.setTitleColor(UIColor.white.withAlphaComponent(0.7), for: .highlighted)
        loginButton.setTitleColor(UIColor.white.withAlphaComponent(0.4), for: .disabled)
        loginButton.setBackgroundColor(UIColor.App.primaryButtonNormal, for: .normal)
        loginButton.setBackgroundColor(UIColor.App.primaryButtonPressed, for: .highlighted)
        loginButton.layer.cornerRadius = CornerRadius.view
        loginButton.layer.masksToBounds = true
    }

    func setupWithState(_ state: ScreenState) {
        switch state {
        case let .logged(user):
            self.loginButton.isHidden = true
            Logger.log("User session updated, user: \(user)")
        case .anonymous:
            self.loginButton.isHidden = false
        }
    }

    func didChangedPreLiveSportType(sportType: SportType) {
        self.currentSportType = sportType
        if liveEventsViewControllerLoaded {
            self.liveEventsViewController.selectedSportType = sportType
        }
    }

    func didChangedLiveSportType(sportType: SportType) {
        self.currentSportType = sportType
        if preLiveViewControllerLoaded {
            self.preLiveViewController.selectedSportType = sportType
        }
    }

    func openBetslipModel() {

        let betslipViewController = BetslipViewController()
        betslipViewController.willDismissAction = { [weak self] in
            self?.reloadChildViewControllersData()
        }

        self.present(Router.navigationController(with: betslipViewController), animated: true, completion: {

        })
    }

    func reloadChildViewControllersData() {
        if preLiveViewControllerLoaded {
            self.preLiveViewController.reloadData()
        }
        if liveEventsViewControllerLoaded {
            self.liveEventsViewController.reloadData()
        }
    }
}

extension HomeViewController {
    func loadChildViewControllerIfNeeded(tab: TabItem) {
        if case .sports = tab, !preLiveViewControllerLoaded {
            self.addChildViewController(self.preLiveViewController, toView: self.preLiveBaseView)
            self.preLiveViewController.selectedSportType = self.currentSportType
            self.preLiveViewController.didChangeSportType = { [weak self] newSportType in
                self?.didChangedPreLiveSportType(sportType: newSportType)
            }
            self.preLiveViewController.didTapBetslipButtonAction = { [weak self] in
                self?.openBetslipModel()
            }
            preLiveViewControllerLoaded = true
        }
        if case .live = tab, !liveEventsViewControllerLoaded {
            self.addChildViewController(self.liveEventsViewController, toView: self.liveBaseView)
            self.liveEventsViewController.selectedSportType = self.currentSportType
            self.liveEventsViewController.didChangeSportType = { [weak self] newSportType in
                self?.didChangedLiveSportType(sportType: newSportType)
            }
            self.liveEventsViewController.didTapBetslipButtonAction = { [weak self] in
                self?.openBetslipModel()
            }
            liveEventsViewControllerLoaded = true
        }
    }
}

extension HomeViewController {

    // ToDo: Not implemented on the flow
    @IBAction private func didTapLoginButton() {
        let loginViewController = Router.navigationController(with: LoginViewController())
        self.present(loginViewController, animated: true, completion: nil)
    }

    @objc private func didTapProfileButton() {
        self.pushProfileViewController()
    }

    private func pushProfileViewController() {
        if UserSessionStore.isUserLogged(), let loggedUser = UserSessionStore.loggedUserSession() {
            let profileViewController = ProfileViewController(userSession: loggedUser)
            let navigationViewController = Router.navigationController(with: profileViewController)
            self.present(navigationViewController, animated: true, completion: nil)
        }
    }
}

extension HomeViewController {

    func requestPopUpContent() {
        Env.gomaNetworkClient.requestPopUpInfo(deviceId: Env.deviceId)
            .compactMap({$0})
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: showPopUp(_:))
            .store(in: &cancellables)
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

        // Finally the animation!
        UIView.animate(withDuration: 0.5) {
            popUpBackgroundView.alpha = 0.4
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

        // Finally the animation!
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

extension HomeViewController {
    
    @objc private func didTapSportsTabItem() {
        self.selectedTabItem = .sports
    }

    @objc private func didTapLiveTabItem() {
        self.selectedTabItem = .live
    }

    func selectSportsTabBarItem() {
        self.loadChildViewControllerIfNeeded(tab: .sports)

        self.preLiveBaseView.isHidden = false
        self.liveBaseView.isHidden = true

        sportsButtonBaseView.alpha = 1.0
        liveButtonBaseView.alpha = 0.2
    }

    func selectLiveTabBarItem() {
        self.loadChildViewControllerIfNeeded(tab: .live)

        self.preLiveBaseView.isHidden = true
        self.liveBaseView.isHidden = false

        sportsButtonBaseView.alpha = 0.2
        liveButtonBaseView.alpha = 1.0
    }

}


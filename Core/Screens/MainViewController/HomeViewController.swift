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
    @IBOutlet private weak var tabBarView: UIView!
    @IBOutlet private weak var bottomSafeAreaView: UIView!

    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var dummyStackBiew: UIStackView!

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
    
    var cancellables = Set<AnyCancellable>()

    enum TabItem {
        case sports
        case live
    }

    var selectedTabItem: TabItem = .sports {
        didSet {
            switch selectedTabItem {
            case .sports:
                self.selectSportsTabBarItem()
            case .live:
                self.selectLiveTabBarItem()
            }
        }
    }

    init() {
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
        self.setupWithTheme()

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if UserSessionStore.isUserLogged() {
            self.loginButton.isHidden = true
        }
        else {
            self.loginButton.isHidden = false
        }
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

        topSafeAreaView.backgroundColor = UIColor.App.mainBackgroundColor
        topBarView.backgroundColor = UIColor.App.mainBackgroundColor
        contentView.backgroundColor = UIColor.App.contentBackgroundColor
        tabBarView.backgroundColor = UIColor.App.mainBackgroundColor
        bottomSafeAreaView.backgroundColor = UIColor.App.mainBackgroundColor

        tabBarView.layer.shadowRadius = 20
        tabBarView.layer.shadowOffset = .zero
        tabBarView.layer.shadowColor = UIColor.black.cgColor
        tabBarView.layer.shadowOpacity = 0.25

        topBarView.layer.shadowRadius = 20
        topBarView.layer.shadowOffset = .zero
        topBarView.layer.shadowColor = UIColor.black.cgColor
        topBarView.layer.shadowOpacity = 0.25

        scrollView.backgroundColor = .clear
        dummyStackBiew.backgroundColor = .clear
        dummyStackBiew.arrangedSubviews.forEach { view in
            view.backgroundColor = UIColor.App.secundaryBackgroundColor
            view.layer.cornerRadius = BorderRadius.view
        }

        sportsButtonBaseView.backgroundColor = .clear
        liveButtonBaseView.backgroundColor = .clear

        profilePictureBaseView.backgroundColor = UIColor.App.mainTintColor

        loginButton.setTitleColor(UIColor.App.headingMain, for: .normal)
        loginButton.setTitleColor(UIColor.white.withAlphaComponent(0.7), for: .highlighted)
        loginButton.setTitleColor(UIColor.white.withAlphaComponent(0.4), for: .disabled)
        loginButton.setBackgroundColor(UIColor.App.primaryButtonNormalColor, for: .normal)
        loginButton.setBackgroundColor(UIColor.App.primaryButtonPressedColor, for: .highlighted)
        loginButton.layer.cornerRadius = BorderRadius.view
        loginButton.layer.masksToBounds = true
    }

}

extension HomeViewController {

    // ToDo: Not implemented on the flow
    @IBAction private func didTapLoginButton() {
        let loginViewController = LoginViewController()
        self.navigationController?.pushViewController(loginViewController, animated: true)
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
    
    @objc private func didTapSportsTabItem() {
        self.selectedTabItem = .sports
    }

    @objc private func didTapLiveTabItem() {
        self.selectedTabItem = .live
    }

    func selectSportsTabBarItem() {
        sportsButtonBaseView.alpha = 1.0
        liveButtonBaseView.alpha = 0.2
    }

    func selectLiveTabBarItem() {
        sportsButtonBaseView.alpha = 0.2
        liveButtonBaseView.alpha = 1.0
    }

}



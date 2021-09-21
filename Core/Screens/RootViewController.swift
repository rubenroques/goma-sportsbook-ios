//
//  RootViewController.swift
//  Sportsbook
//
//  Created by Ruben Roques on 20/07/2021.
//

import UIKit
import Combine
import SwiftUI

class RootViewController: UIViewController {

    @IBOutlet private weak var openProfileButton: UIButton!

    var showingDebug: Bool = false
    var gomaGamingAPIClient: GomaGamingServiceClient
    var everyMatrixAPIClient: EveryMatrixAPIClient

    var cancellables = Set<AnyCancellable>()

    init() {
        gomaGamingAPIClient = Env.gomaNetworkClient
        everyMatrixAPIClient = Env.everyMatrixAPIClient

        super.init(nibName: "RootViewController", bundle: nil)
    }

    @available(iOS, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupWithTheme()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.openProfileButton.setTitle("Profile", for: .normal)
        self.openProfileButton.setTitle("Profile-disabled", for: .disabled)

        if !UserSessionStore.isUserLogged() {
            self.openProfileButton.isEnabled = false
        }
        else {
            self.openProfileButton.isEnabled = true
        }
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        self.setupWithTheme()
    }

    func setupWithTheme() {
        self.view.backgroundColor = UIColor.App.mainTintColor
    }

    @IBAction private func didTapAPITest() {

        gomaGamingAPIClient.requestTest(deviceId: Env.deviceId)
            .sink(receiveCompletion: {
                print("Received completion: \($0).")
            },
            receiveValue: { user in
                print("Received Content - user: \(String(describing: user)).")
            })
            .store(in: &cancellables)
    }

    @IBAction private func didTapUserSettings() {

        gomaGamingAPIClient.requestSettings(deviceId: Env.deviceId)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure:
                    print("Error retrieving user settings!")

                case .finished:
                    print("User settings retrieved!")
                }

                print("Received completion: \(completion).")

            },
            receiveValue: { data in
                print("Received Content - data: \(data!).")
                var settingsArray = [GomaClientSettings]()
                for value in data! {
                    let setting = GomaClientSettings(id: value.id, category: value.category, name: value.name, type: value.type)
                    settingsArray.append(setting)
                }
                let settingsData = try? JSONEncoder().encode(settingsArray)

                UserDefaults.standard.set(settingsData, forKey: "user_settings")

                let settingsStored = Env.getUserSettings()
                print("User settings: \(String(describing: settingsStored))")

            })
            .store(in: &cancellables)
    }

    @IBAction private func testEveryMatrixAPI() {
        // let payload = ["lang":"en", "maxResults":"10"]
        // let payloadToday = ["lang":"en", "userTimezoneOffsetInMinutes":"0", "maxResults":"10"]
        // let payloadNext = ["lang":"en", "hoursTillLive":"2", "maxResults":"10", "disciplineId":"1"]
        let payloadOdd: [String: Any] = ["lang": "en",
                          "matchId": "148056830725115904",
                          "tournamentId": "",
                          "bettingOfferId": "",
                          "bettingOfferIds": [],
                          "eventIds": []] // as [String : Any?]

        everyMatrixAPIClient.getOdds(payload: payloadOdd)
    }

    @IBAction private func testSubscription() {
        // everyMatrixAPIClient.subscribeOdd(payload: nil)

//        everyMatrixAPIClient.login(username: "test 11", password: "12345678")
//            .map({ loggedUser in
//                return everyMatrixAPIClient.getSessionInfo().map({ sessionInfo in
//
//                })
//            })

//            .sink(receiveCompletion: { completion in
//                switch completion {
//                case .failure:
//                    print("Error retrieving data!")
//
//                case .finished:
//                    print("Data retrieved!")
//                }
//                debugPrint("TSRequestCompleted")
//            }, receiveValue: { value in
//                debugPrint("TSRequest: \(String(describing: value.records))")
//            })
//            .store(in: &cancellables)
    }

    @IBAction private func didTapOpenProfileButton() {

    }

    @IBAction private func didTapLoginProfileButton() {

    }

    @IBAction private func didTapPopupButton() {
        let fadeView = UIView()
        fadeView.translatesAutoresizingMaskIntoConstraints = false
        fadeView.alpha = 0
        fadeView.backgroundColor = UIColor.App.backgroundDarkModal.withAlphaComponent(0.9)
        self.view.addSubview(fadeView)
        NSLayoutConstraint.activate([

            fadeView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            fadeView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            fadeView.topAnchor.constraint(equalTo: self.view.topAnchor),
            fadeView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
        ])
        let popup = PopupView()
        popup.backgroundView = fadeView
        popup.translatesAutoresizingMaskIntoConstraints = false
        popup.alpha = 0
        popup.setPromoItems(image: UIImage(named: "promo_image")!, imageTitle: "SERIE A IS COMING", imageSubtitle: "DEPOSIT 20€ AND GET 10€ FREE", title: "SERIE A is Coming", text: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore.")
        self.view.addSubview(popup)
        NSLayoutConstraint.activate([

            popup.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 30),
            popup.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: -30),
            popup.centerXAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.centerXAnchor),
            popup.centerYAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.centerYAnchor)
        ])

        PopupView.animate(
            withDuration: 0.2,
            delay: 0.0,
            options: .curveEaseIn,
            animations: {
                fadeView.alpha = 1
                popup.alpha = 1
            }, completion: {_ in
            })
    }

    func showForbiddenAccess() {
        let forbiddenAccessViewController = ForbiddenLocationViewController()
        let navigationController = UINavigationController(rootViewController: forbiddenAccessViewController)
        navigationController.modalPresentationStyle = .fullScreen

        self.present(navigationController, animated: true, completion: nil)
    }

}

extension RootViewController {

    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        super.motionEnded(motion, with: event)

        // Do any additional setup after loading the view.
        AnalyticsClient.logEvent(event: .login)

        let limit = TargetVariables.featureFlags.limitCheckoutItems
        // print("Target config flags \(limit)")

        Logger.log("Target config flags \(limit)")

        if showingDebug {
            return
        }

        Logger.log("Debug screen called")

        showingDebug = true

        if TargetVariables.environmentType == .dev {
            if motion == .motionShake {

                let debugViewController = DebugViewController()
                debugViewController.isBeingDismissedAction = { [weak self] _ in
                    self?.showingDebug = false
                }
                let navigationController = UINavigationController(rootViewController: debugViewController)
                navigationController.modalPresentationStyle = .fullScreen

                self.present(navigationController, animated: true, completion: nil)
            }
        }

    }
}

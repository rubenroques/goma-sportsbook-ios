//
//  SplashViewController.swift
//  Sportsbook
//
//  Created by Ruben Roques on 28/09/2021.
//

import UIKit
import Combine
import FirebaseMessaging

class SplashViewController: UIViewController {

    var cancellables = Set<AnyCancellable>()

    typealias Loaded = () -> Void
    var loadingCompleted: Loaded

    init(loadingCompleted: @escaping Loaded) {
        self.loadingCompleted = loadingCompleted
        
        super.init(nibName: "SplashViewController", bundle: nil)
    }

    @available(iOS, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        Logger.log("Starting connections")

        NotificationCenter.default.publisher(for: .wampSocketConnected)
            .setFailureType(to: EveryMatrix.APIError.self)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                Logger.log("completion \(completion)")
                Logger.log("Services Bootstrap")
            }, receiveValue: { [weak self] operatorInfo in
                Logger.log("Socket connected: \(TSManager.shared.isConnected)")
                self?.startUserSessionIfNeeded()
            })
            .store(in: &cancellables)
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    func saveOperatorInfo(operatorInfo: EveryMatrix.OperatorInfo) {
        if let operatorId = operatorInfo.ucsOperatorId {
            Env.appSession.operatorId = String(operatorId)
        }
    }

    func startUserSessionIfNeeded() {

        guard
            let user = UserSessionStore.loggedUserSession(),
            let userPassword = UserSessionStore.storedUserPassword()
        else {
            self.splashLoadingCompleted()
            return
        }
        Env.userSessionStore.loadLoggedUser()

        //Get and store FCM token
        Messaging.messaging().token { token, error in
          if let error = error {
            print("Error fetching FCM registration token: \(error)")
          } else if let token = token {
            print("FCM registration token: \(token)")
            Env.deviceFCMToken = token
          }
        }

        TSManager.shared
            .getModel(router: .login(username: user.username, password: userPassword), decodingType: LoginAccount.self)
            .receive(on: RunLoop.main)
            .sink { completion in
                switch completion {
                case .finished:
                    Env.favoritesManager.getUserMetadata()
                    self.loginGomaAPI(username: user.username, password: user.userId)
                case .failure(let error):
                    print("error \(error)")
                }
            } receiveValue: { account in
                print(account)
                Env.userSessionStore.isUserProfileIncomplete = account.isProfileIncomplete
            }
            .store(in: &cancellables)
    }

    func splashLoadingCompleted() {
        self.loadingCompleted()
    }

    func loginGomaAPI(username: String, password: String) {
        let userLoginForm = UserLoginForm(username: username, password: password, deviceToken: Env.deviceFCMToken)

        Env.gomaNetworkClient.requestLogin(deviceId: Env.deviceId, loginForm: userLoginForm)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let error):
                    print("GOMA Login Error: \(error)")
                case .finished:
                    print("GOMA Login Finished")
                }
                self.splashLoadingCompleted()
            }, receiveValue: { value in
                Env.gomaNetworkClient.networkClient.refreshAuthToken(token: value)
            })
            .store(in: &cancellables)

    }

}

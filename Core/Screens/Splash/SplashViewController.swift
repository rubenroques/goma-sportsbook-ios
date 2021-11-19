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
                    //self.checkGomaLogin(username: user.username, password: user.userId)
                    self.splashLoadingCompleted()
                case .failure(let error):
                    print("error \(error)")
                }
            } receiveValue: { account in
                print(account)
            }
            .store(in: &cancellables)
    }

    func splashLoadingCompleted() {
        self.loadingCompleted()
    }

    func loginGomaAPI(username: String, password: String) {
        let userLoginForm = UserLoginForm(username: username, password: password, deviceToken: Env.deviceFCMToken)

        Env.gomaNetworkClient.requestLogin(deviceId: Env.deviceId, loginForm: userLoginForm)
            .replaceError(with: MessageNetworkResponse.failed)
            .sink { login in
                print("GOMA LOGIN: \(login)")
            } receiveValue: { value in
                print("GOMA LOGIN VALUE: \(value)")
            }
            .store(in: &cancellables)

    }

//    func checkFCMAuth() {
//        let authEndpointURL = URL(string: TargetVariables.gomaGamingAuthEndpoint)!
//        var request = URLRequest(url: authEndpointURL)
//        request.httpMethod = "POST"
//        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
//        let bodyJSON = [
//            "device_uuid": Env.deviceId,
//            "device_type": "ios",
//            "type": "anonymous",
//            "device_token": Env.deviceFCMToken
//        ]
//
//
//        let jsonData = try! JSONEncoder().encode(bodyJSON) // swiftlint:disable:this force_try
//        request.httpBody = jsonData
//        let session = URLSession.shared
//
//        session.dataTask(with: request) { (data, response, error) in
//                if let response = response {
//                    print("RESPONSE: \(response)")
//                }
//                if let data = data {
//                    do {
//                        let json = try JSONSerialization.jsonObject(with: data, options: [])
//                        print("JSON TOKEN: \(json)")
//                    } catch {
//                        print("ERROR: \(error)")
//                    }
//                }
//            }.resume()
//    }

    func checkGomaLogin(username: String, password: String) {
        print("USER: \(username)")
        let endpointUrl = URL(string: "https://sportsbook-api.gomagaming.com/api/auth/v1/login")!
        var request = URLRequest(url: endpointUrl)
        request.httpMethod = "POST"
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        let bodyJSON = [
            "username": username,
            "password": password,
            "device_token": Env.deviceFCMToken
        ]

        let jsonData = try! JSONEncoder().encode(bodyJSON) // swiftlint:disable:this force_try
        request.httpBody = jsonData
        let session = URLSession.shared

        session.dataTask(with: request) { (data, response, error) in
            if let response = response {
                print("RESPONSE: \(response)")
            }
            if let data = data {
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                    print("JSON: \(json)")
                } catch {
                    print("ERROR: \(error)")
                }
            }
            if let error = error {
                print("LOGIN ERROR: \(error)")
            }
        }.resume()
    }

}

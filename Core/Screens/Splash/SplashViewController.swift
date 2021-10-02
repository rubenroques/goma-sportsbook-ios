//
//  SplashViewController.swift
//  Sportsbook
//
//  Created by Ruben Roques on 28/09/2021.
//

import UIKit
import Combine

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
        _ = TSManager.shared.isConnected

        NotificationCenter.default.publisher(for: .wampSocketConnected)
            .receive(on: DispatchQueue.main)
            .sink { _ in
                Logger.log("Socket connected: \(TSManager.shared.isConnected)")
                self.startUserSessionIfNeeded()
            }
            .store(in: &cancellables)
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }


    func startUserSessionIfNeeded() {

        guard
            let user = UserSessionStore.loggedUserSession()
        else {
            self.splashLoadingCompleted()
            return
        }

        let username = user.username
        let password = "12345678-GOMA-sportsbook"

        TSManager.shared
            .getModel(router: .login(username: username, password: password), decodingType: LoginAccount.self)
            .receive(on: RunLoop.main)
            .sink { completion in
                print(completion)

                switch completion {
                case .finished:
                    self.splashLoadingCompleted()
                case .failure(let everyMatrixSocketAPIError):
                    print("error \(everyMatrixSocketAPIError)")
                }

            } receiveValue: { account in
                print(account)
            }
            .store(in: &cancellables)
    }

    func splashLoadingCompleted() {
        self.loadingCompleted()
    }

}

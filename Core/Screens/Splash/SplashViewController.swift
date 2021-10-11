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
            .setFailureType(to: EveryMatrix.APIError.self)
//            .flatMap({ _ -> AnyPublisher<EveryMatrix.OperatorInfo, EveryMatrix.APIError> in
//                return EveryMatrixAPIClient.operatorInfo()
//            })
//            .eraseToAnyPublisher()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                Logger.log("completion \(completion)")
                Logger.log("Services Bootstrap")
            }, receiveValue: { operatorInfo in
                Logger.log("Socket connected: \(TSManager.shared.isConnected)")
                self.startUserSessionIfNeeded()
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
//
//        EveryMatrixAPIClient.operatorInfo().sink(receiveCompletion: { completion in
//            Logger.log("completion \(completion)")
//
//        }, receiveValue: { operatorInfo in
//            Logger.log("Socket connected: \(TSManager.shared.isConnected)")
//            self.startUserSessionIfNeeded()
//        })
//        .store(in: &cancellables)

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

}

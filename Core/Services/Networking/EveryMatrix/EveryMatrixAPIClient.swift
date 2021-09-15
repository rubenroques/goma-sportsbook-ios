//
//  EveryMatrixAPIClient.swift
//  Sportsbook
//
//  Created by André Lascas on 01/09/2021.
//

import Foundation
import Combine

class EveryMatrixAPIClient: ObservableObject {

    private var cancellable = Set<AnyCancellable>()
    var manager: TSManager!

    init() {
        //The singleton init below is used to start up TS connection
        manager = TSManager.shared

        NotificationCenter.default.publisher(for: .wampSocketConnected)
            .sink { _ in
                print("Socket connected: \(TSManager.shared.isConnected)")
            }
            .store(in: &cancellable)

        NotificationCenter.default.publisher(for: .wampSocketDisconnected)
            .sink { _ in
                self.reconnectTS()
            }
            .store(in: &cancellable)
    }

    private func reconnectTS() {
        debugPrint("***ShouldReconnectTS")
        TSManager.shared.destroySwampSession()
        TSManager.reconnect()
        manager = TSManager.shared
    }

    func login(username: String, password: String) -> AnyPublisher<LoginAccount, EveryMatrixSocketAPIError> {
        return TSManager.shared
            .getModel(router: .login(username: username, password: password), decodingType: LoginAccount.self)
            .receive(on: RunLoop.main)
            .eraseToAnyPublisher()
    }

    func getSessionInfo() -> AnyPublisher<SessionInfo, EveryMatrixSocketAPIError> {
        return TSManager.shared
            .getModel(router: .getSessionInfo, decodingType: SessionInfo.self)
            .receive(on: RunLoop.main)
            .eraseToAnyPublisher()
    }

    func getDisciplines(payload: [String: Any]?) {
        TSManager.shared.getModel(router: .disciplines(payload: payload), decodingType: EveryMatrixSocketResponse<Discipline>.self)
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure:
                    print("Error retrieving data!")

                case .finished:
                    print("Data retrieved!")
                }
                debugPrint("TSRequestCompleted")
            }, receiveValue: { value in
                debugPrint("TSRequest: \(String(describing: value.records))")
            })
            .store(in: &cancellable)
    }

    func getLocations(payload: [String: Any]?) {
        TSManager.shared.getModel(router: .locations(payload: payload), decodingType: EveryMatrixSocketResponse<Location>.self)
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure:
                    print("Error retrieving data!")

                case .finished:
                    print("Data retrieved!")
                }
                debugPrint("TSRequestCompleted")
            }, receiveValue: { value in
                debugPrint("TSRequest: \(String(describing: value.records))")
            })
            .store(in: &cancellable)
    }

    func getTournaments(payload: [String: Any]?) {
        TSManager.shared.getModel(router: .tournaments(payload: payload), decodingType: EveryMatrixSocketResponse<Tournament>.self)
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure:
                    print("Error retrieving data!")

                case .finished:
                    print("Data retrieved!")
                }
                debugPrint("TSRequestCompleted")
            }, receiveValue: { value in
                debugPrint("TSRequest: \(String(describing: value.records))")
            })
            .store(in: &cancellable)
    }

    func getPopularTournaments(payload: [String: Any]?) {
        TSManager.shared.getModel(router: .popularTournaments(payload: payload), decodingType: EveryMatrixSocketResponse<Tournament>.self)
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure:
                    print("Error retrieving data!")

                case .finished:
                    print("Data retrieved!")
                }
                debugPrint("TSRequestCompleted")
            }, receiveValue: { value in
                debugPrint("TSRequest: \(String(describing: value.records))")
            })
            .store(in: &cancellable)
    }

    func getMatches(payload: [String: Any]?) {
        TSManager.shared.getModel(router: .matches(payload: payload), decodingType: EveryMatrixSocketResponse<Match>.self)
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure:
                    print("Error retrieving data!")

                case .finished:
                    print("Data retrieved!")
                }
                debugPrint("TSRequestCompleted")
            }, receiveValue: { value in
                debugPrint("TSRequest: \(String(describing: value.records))")
            })
            .store(in: &cancellable)
    }

    func getPopularMatches(payload: [String: Any]?) {
        TSManager.shared.getModel(router: .popularMatches(payload: payload), decodingType: EveryMatrixSocketResponse<Match>.self)
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure:
                    print("Error retrieving data!")

                case .finished:
                    print("Data retrieved!")
                }
                debugPrint("TSRequestCompleted")
            }, receiveValue: { value in
                debugPrint("TSRequest: \(String(describing: value.records))")
            })
            .store(in: &cancellable)
    }

    func getTodayMatches(payload: [String: Any]?) {
        TSManager.shared.getModel(router: .todayMatches(payload: payload), decodingType: EveryMatrixSocketResponse<Match>.self)
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure:
                    print("Error retrieving data!")

                case .finished:
                    print("Data retrieved!")
                }
                debugPrint("TSRequestCompleted")
            }, receiveValue: { value in
                debugPrint("TSRequest: \(String(describing: value.records))")
            })
            .store(in: &cancellable)
    }

    func getNextMatches(payload: [String: Any]?) {
        TSManager.shared.getModel(router: .nextMatches(payload: payload), decodingType: EveryMatrixSocketResponse<Match>.self)
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure:
                    print("Error retrieving data!")

                case .finished:
                    print("Data retrieved!")
                }
                debugPrint("TSRequestCompleted")
            }, receiveValue: { value in
                debugPrint("TSRequest: \(String(describing: value.records))")
            })
            .store(in: &cancellable)
    }

    func getEvents(payload: [String: Any]?) {
        TSManager.shared.getModel(router: .events(payload: payload), decodingType: EveryMatrixSocketResponse<Event>.self)
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure:
                    print("Error retrieving data!")

                case .finished:
                    print("Data retrieved!")
                }
                debugPrint("TSRequestCompleted")
            }, receiveValue: { value in
                debugPrint("TSRequest: \(String(describing: value.records))")
            })
            .store(in: &cancellable)
    }

    func getOdds(payload: [String: Any]?) {
        TSManager.shared.getModel(router: .odds(payload: payload), decodingType: EveryMatrixSocketResponse<Odd>.self)
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure:
                    print("Error retrieving data!")

                case .finished:
                    print("Data retrieved!")
                }
                debugPrint("TSRequestCompleted")
            }, receiveValue: { value in
                debugPrint("TSRequest: \(String(describing: value.records))")
            })
            .store(in: &cancellable)
    }

    func subscribeOdd(payload: [String: Any]?) {
        TSManager.shared.subscribeProcedure(procedure: .oddsMatch(language: "en", matchId: "148002218755281152"))
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure:
                    print("Error retrieving data!")

                case .finished:
                    print("Data retrieved!")
                }
                debugPrint("Subscription Request Complete!")
            }, receiveValue: { value in
                debugPrint("Subscription: \(String(describing: value))")
                
            })
            .store(in: &cancellable)
    }

}

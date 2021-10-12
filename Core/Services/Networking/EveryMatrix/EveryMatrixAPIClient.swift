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
                Logger.log("Socket connected: \(TSManager.shared.isConnected)")
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

    static func operatorInfo() -> AnyPublisher<EveryMatrix.OperatorInfo, EveryMatrix.APIError> {
        return TSManager.shared.getModel(router: .getOperatorInfo, decodingType: EveryMatrix.OperatorInfo.self)
            .handleEvents(receiveOutput: { (operatorInfo: EveryMatrix.OperatorInfo) in
                print("OperatorInfo \(operatorInfo)")
            })
            .eraseToAnyPublisher()
    }

    func login(username: String, password: String) -> AnyPublisher<LoginAccount, EveryMatrix.APIError> {
        return TSManager.shared
            .getModel(router: .login(username: username, password: password), decodingType: LoginAccount.self)
            .receive(on: RunLoop.main)
            .eraseToAnyPublisher()
    }


    func loginComplete(username: String, password: String) -> AnyPublisher<SessionInfo, EveryMatrix.APIError> {
        return self.login(username: username, password: password).flatMap { _ in
            return self.getSessionInfo()
        }
        .eraseToAnyPublisher()
    }


    func logout() -> AnyPublisher<Bool, EveryMatrix.APIError> {
        return TSManager.shared
            .getModel(router: .logout, decodingType: Bool.self)
            .receive(on: RunLoop.main)
            .eraseToAnyPublisher()
    }

    func getSessionInfo() -> AnyPublisher<SessionInfo, EveryMatrix.APIError> {
        return TSManager.shared
            .getModel(router: .getSessionInfo, decodingType: SessionInfo.self)
            .eraseToAnyPublisher()
    }

    func validateEmail(_ email: String) -> AnyPublisher<EveryMatrix.EmailAvailability, EveryMatrix.APIError> {
        return TSManager.shared.getModel(router: .validateEmail(email: email), decodingType: EveryMatrix.EmailAvailability.self)
            .eraseToAnyPublisher()
    }

    func validateUsername(_ username: String) -> AnyPublisher<EveryMatrix.UsernameAvailability, EveryMatrix.APIError> {
        return TSManager.shared.getModel(router: .validateUsername(username: username), decodingType: EveryMatrix.UsernameAvailability.self)
            .eraseToAnyPublisher()
    }

    func simpleRegister(form: EveryMatrix.SimpleRegisterForm) -> AnyPublisher<EveryMatrix.RegistrationResponse, EveryMatrix.APIError> {
        return TSManager.shared.getModel(router: .simpleRegister(form: form), decodingType: EveryMatrix.RegistrationResponse.self)
            .breakpointOnError()
            .eraseToAnyPublisher()
    }

    func getCountries() -> AnyPublisher<EveryMatrix.CountryListing, EveryMatrix.APIError> {
        return TSManager.shared.getModel(router: .getCountries, decodingType: EveryMatrix.CountryListing.self)
            .eraseToAnyPublisher()
    }

    func getDisciplinesData(payload: [String: Any]?) -> AnyPublisher<EveryMatrixSocketResponse<Discipline>, EveryMatrix.APIError> {
        return TSManager.shared.getModel(router: .disciplines(payload: payload), decodingType: EveryMatrixSocketResponse<Discipline>.self)
            .eraseToAnyPublisher()
    }

    func getDisciplines(payload: [String: Any]?) {
        TSManager.shared.getModel(router: .disciplines(payload: payload), decodingType: EveryMatrixSocketResponse<EveryMatrix.Discipline>.self)
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
        TSManager.shared.getModel(router: .locations(payload: payload), decodingType: EveryMatrixSocketResponse<EveryMatrix.Location>.self)
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
        TSManager.shared.getModel(router: .tournaments(payload: payload), decodingType: EveryMatrixSocketResponse<EveryMatrix.Tournament>.self)
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
        TSManager.shared.getModel(router: .popularTournaments(payload: payload), decodingType: EveryMatrixSocketResponse<EveryMatrix.Tournament>.self)
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

    func getMatches(payload: [String: Any]?) -> AnyPublisher<EveryMatrixSocketResponse<EveryMatrix.Match>, EveryMatrix.APIError>  {
        return TSManager.shared.getModel(router: .matches(payload: payload), decodingType: EveryMatrixSocketResponse<EveryMatrix.Match>.self)
    }

    func getMatchDetails(language: String, matchId: String) -> AnyPublisher<EveryMatrixSocketResponse<EveryMatrix.Match>, EveryMatrix.APIError>  {
        return TSManager.shared.getModel(router: .matchDetails(language: language, matchId: matchId) , decodingType: EveryMatrixSocketResponse<EveryMatrix.Match>.self)
    }

    func getPopularMatches(payload: [String: Any]?) {
        TSManager.shared.getModel(router: .popularMatches(payload: payload), decodingType: EveryMatrixSocketResponse<EveryMatrix.Match>.self)
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
        TSManager.shared.getModel(router: .todayMatches(payload: payload), decodingType: EveryMatrixSocketResponse<EveryMatrix.Match>.self)
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
        TSManager.shared.getModel(router: .nextMatches(payload: payload), decodingType: EveryMatrixSocketResponse<EveryMatrix.Match>.self)
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

    func getEvents(payload: [String: Any]?) -> AnyPublisher<EveryMatrixSocketResponse<Event>, EveryMatrix.APIError> {
        return TSManager.shared.getModel(router: .events(payload: payload), decodingType: EveryMatrixSocketResponse<Event>.self)
    }

    func getOdds(payload: [String: Any]?) -> AnyPublisher<EveryMatrixSocketResponse<Odd>, EveryMatrix.APIError> {
        return TSManager.shared.getModel(router: .odds(payload: payload), decodingType: EveryMatrixSocketResponse<Odd>.self)
    }

    func subscribeOdds(language: String, matchId: String) -> AnyPublisher<EveryMatrixSocketResponse<Odd>, EveryMatrix.APIError> {
        do {

            let operatorId = Env.appSession.operatorId
            let publisher = try TSManager.shared.subscribeEndpoint(.oddsMatch(operatorId: operatorId,
                                                                              language: language,
                                                                              matchId: matchId),
                                                                   decodingType: EveryMatrixSocketResponse<Odd>.self)

                .map { (subscriptionContent: TSSubscriptionContent<EveryMatrixSocketResponse<Odd>>) -> EveryMatrixSocketResponse<Odd>? in
                    print("subscriptionContent \(subscriptionContent)")
                    switch subscriptionContent {
                    case let .updatedContent(oddsData):
                        return oddsData
                    default:
                        return nil
                    }
                }
                .compactMap({ $0 })

            return publisher.eraseToAnyPublisher()
        }
        catch {
            return Fail.init(outputType: EveryMatrixSocketResponse<Odd>.self, failure: EveryMatrix.APIError.notConnected).eraseToAnyPublisher()
        }
    }

    func subscribeSportsStatus(language: String, sportType: SportType) -> AnyPublisher<EveryMatrixSocketResponse<EveryMatrix.Discipline>, EveryMatrix.APIError> {
        do {
            let sportId = sportType.rawValue
            let operatorId = Env.appSession.operatorId
            let publisher = try TSManager.shared.subscribeEndpoint( .sportsStatus(operatorId: operatorId,
                                                                                  language: language,
                                                                                  sportId: sportId),
                                                                    decodingType: EveryMatrixSocketResponse<EveryMatrix.Discipline>.self)

                .map { (subscriptionContent: TSSubscriptionContent<EveryMatrixSocketResponse<EveryMatrix.Discipline>>) -> EveryMatrixSocketResponse<EveryMatrix.Discipline>? in
                    print("subscriptionContent \(subscriptionContent)")
                    switch subscriptionContent {
                    case let .updatedContent(oddsData):
                        return oddsData
                    default:
                        return nil
                    }
                }
                .compactMap({ $0 })

            return publisher.eraseToAnyPublisher()
        }
        catch {
            return Fail.init(outputType: EveryMatrixSocketResponse<EveryMatrix.Discipline>.self, failure: EveryMatrix.APIError.notConnected).eraseToAnyPublisher()
        }
    }

    func registerOnSportsStatus(language: String, sportType: SportType) -> AnyPublisher<EveryMatrixSocketResponse<EveryMatrix.Discipline>, EveryMatrix.APIError> {

        let sportId = sportType.rawValue
        let operatorId = Env.appSession.operatorId
        let publisher = TSManager.shared.registerOnEndpoint(.sportsStatus(operatorId: operatorId,
                                                                              language: language,
                                                                              sportId: sportId),
                                                            decodingType: EveryMatrixSocketResponse<EveryMatrix.Discipline>.self)

            .map { (subscriptionContent: TSSubscriptionContent<EveryMatrixSocketResponse<EveryMatrix.Discipline>>) -> EveryMatrixSocketResponse<EveryMatrix.Discipline>? in
                print("subscriptionContent \(subscriptionContent)")
                switch subscriptionContent {
                case let .updatedContent(oddsData):
                    return oddsData
                default:
                    return nil
                }
            }
            .compactMap({ $0 })

        return publisher.eraseToAnyPublisher()

    }

    func requestInitialDump(topic: String) -> AnyPublisher<String, EveryMatrix.APIError>  {
        return TSManager.shared.getModel(router: .sportsInitialDump(topic: topic), decodingType: String.self).eraseToAnyPublisher()
    }

}

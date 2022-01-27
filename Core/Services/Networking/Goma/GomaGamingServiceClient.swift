//
//  GomaGamingServiceClient.swift
//  Sportsbook
//
//  Created by Ruben Roques on 27/08/2021.
//

import Foundation
import Combine

class GomaGamingServiceClient {

    private var networkClient: NetworkManager
    
    init(networkClient: NetworkManager = NetworkManager()) {
        self.networkClient = networkClient
    }

    func reconnectSession() {
        self.networkClient = NetworkManager()
    }

    func refreshAuthToken(token: AuthToken) {
        self.networkClient.refreshAuthToken(token: token)
    }

    func sendLog(type: String, message: String) -> AnyPublisher<String, NetworkError> {
        let endpoint = GomaGamingService.log(type: type, message: message)
        let requestPublisher: AnyPublisher<String, NetworkError> = networkClient.requestEndpoint(deviceId: "logs", endpoint: endpoint)
        return requestPublisher
    }

    func requestTest(deviceId: String) -> AnyPublisher<ExampleModel?, NetworkError> {
        let endpoint = GomaGamingService.test
        let requestPublisher: AnyPublisher<ExampleModel?, NetworkError> = networkClient.requestEndpoint(deviceId: deviceId, endpoint: endpoint)
        return requestPublisher
    }

    func requestGeoLocation(deviceId: String, latitude: Double, longitude: Double) -> AnyPublisher<Bool, NetworkError> {
        let accessGrantedMessage = "User Access Granted!".lowercased()
        let endpoint = GomaGamingService.geolocation(latitude: String(latitude), longitude: String(longitude))
        let requestPublisher: AnyPublisher<MessageNetworkResponse, NetworkError> = networkClient.requestEndpoint(deviceId: deviceId, endpoint: endpoint)

        return requestPublisher
            .catch { (error: NetworkError) -> AnyPublisher<MessageNetworkResponse, NetworkError> in
                if error.errors.contains(.forbidden) {
                    return Just(MessageNetworkResponse.forbiden)
                        .setFailureType(to: NetworkError.self)
                        .eraseToAnyPublisher()
                }
                else {
                    return Fail(outputType: MessageNetworkResponse.self, failure: error)
                        .eraseToAnyPublisher()
                }
            }
            .eraseToAnyPublisher()
            .map { simpleResponse -> Bool in
                return simpleResponse.message.lowercased() == accessGrantedMessage
            }
            .eraseToAnyPublisher()

    }

    func requestSettings(deviceId: String) -> AnyPublisher<[GomaClientSettings]?, NetworkError> {
        let endpoint = GomaGamingService.settings
        let requestPublisher: AnyPublisher<[GomaClientSettings]?, NetworkError> = networkClient.requestEndpointArrayData(deviceId: deviceId, endpoint: endpoint)
        return requestPublisher
    }

    func requestPopUpInfo(deviceId: String) -> AnyPublisher<PopUpDetails?, Never> {
        let endpoint = GomaGamingService.modalPopUpDetails
        let requestPublisher: AnyPublisher<PopUpDetails?, Never> = networkClient.requestEndpoint(deviceId: deviceId, endpoint: endpoint)
            .replaceError(with: nil)
            .eraseToAnyPublisher()
        return requestPublisher
    }

    func requestUserRegister(deviceId: String, userRegisterForm: UserRegisterForm) -> AnyPublisher<MessageNetworkResponse, NetworkError> {
        let endpoint = GomaGamingService.simpleRegister(username: userRegisterForm.username,
                                                        email: userRegisterForm.email,
                                                        phone: userRegisterForm.mobile,
                                                        birthDate: userRegisterForm.birthDate,
                                                        userProviderId: userRegisterForm.userProviderId, deviceToken: userRegisterForm.deviceToken)

        let requestPublisher: AnyPublisher<MessageNetworkResponse, NetworkError> = networkClient.requestEndpoint(deviceId: deviceId, endpoint: endpoint)
        return requestPublisher
    }

    func requestLogin(deviceId: String, loginForm: UserLoginForm) -> AnyPublisher<AuthToken, NetworkError> {
        let endpoint = GomaGamingService.login(username: loginForm.username,
                                               password: loginForm.password,
                                               deviceToken: loginForm.deviceToken)
        let requestPublisher: AnyPublisher<AuthToken, NetworkError> = networkClient.requestEndpoint(deviceId: deviceId, endpoint: endpoint)
        return requestPublisher
    }

    // TODO: Code Review -
    func requestSuggestedBets(deviceId: String) -> AnyPublisher<[[GomaSuggestedBets]]?, NetworkError> {
        let endpoint = GomaGamingService.suggestedBets
        let requestPublisher: AnyPublisher<[[GomaSuggestedBets]]?, NetworkError> = networkClient.requestEndpointArrayData(deviceId: deviceId, endpoint: endpoint)
        return requestPublisher
    }

    func sendFavorites(deviceId: String, favorites: String) -> AnyPublisher<MessageNetworkResponse, NetworkError> {
        let endpoint = GomaGamingService.favorites(favorites: favorites)
        let requestPublisher: AnyPublisher<MessageNetworkResponse, NetworkError> = networkClient.requestEndpoint(deviceId: deviceId, endpoint: endpoint)
        return requestPublisher
    }

    func requestMatchStats(deviceId: String, matchId: String) -> AnyPublisher<JSON, NetworkError> {
        let endpoint = GomaGamingService.matchStats(matchId: matchId)
        let requestPublisher: AnyPublisher<JSON, NetworkError> = networkClient.requestEndpoint(deviceId: deviceId, endpoint: endpoint)
        return requestPublisher
    }

}

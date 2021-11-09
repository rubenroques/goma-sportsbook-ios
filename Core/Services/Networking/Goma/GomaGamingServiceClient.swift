//
//  GomaGamingServiceClient.swift
//  Sportsbook
//
//  Created by Ruben Roques on 27/08/2021.
//

import Foundation
import Combine

struct GomaGamingServiceClient {

    var networkClient: NetworkManager
    
    init(networkClient: NetworkManager) {
        self.networkClient = networkClient
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

    func requestLogin(deviceId: String, loginForm: UserLoginForm) -> AnyPublisher<MessageNetworkResponse, NetworkError> {
        let endpoint = GomaGamingService.login(username: loginForm.username,
                                               password: loginForm.password,
                                               deviceToken: loginForm.deviceToken)

        let requestPublisher: AnyPublisher<MessageNetworkResponse, NetworkError> = networkClient.requestEndpoint(deviceId: deviceId, endpoint: endpoint)
        return requestPublisher
    }

}

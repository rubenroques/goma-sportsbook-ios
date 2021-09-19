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

        #if DEBUG
        if ceil(latitude) == -22 && ceil(longitude) == -43 {
            return Just(false).setFailureType(to: NetworkError.self).eraseToAnyPublisher()
        }
        #endif

        let accessGrantedMessage = "User Access Granted!"
        let endpoint = GomaGamingService.geolocation(latitude: String(latitude), longitude: String(longitude))
        let requestPublisher: AnyPublisher<SimpleNetworkResponse, NetworkError> = networkClient.requestEndpoint(deviceId: deviceId, endpoint: endpoint)
        let booleanPublisher = requestPublisher.map { simpleResponse in
            return simpleResponse.message == accessGrantedMessage
        }
        return booleanPublisher.eraseToAnyPublisher()
    }

    func requestSettings(deviceId: String) -> AnyPublisher<[GomaClientSettings]?, NetworkError> {
        let endpoint = GomaGamingService.settings
        // let requestPublisher: AnyPublisher<[ClientSettings]?, NetworkError> = networkClient.requestEndpoint(deviceId: deviceId, endpoint: endpoint)
        let requestPublisher: AnyPublisher<[GomaClientSettings]?, NetworkError> = networkClient.requestEndpointArrayData(deviceId: deviceId, endpoint: endpoint)
        return requestPublisher
    }

    func requestUserRegister(deviceId: String, username: String, email: String, phone: String, birthDate: String, userProviderId: String)
    -> AnyPublisher<String?, NetworkError> {
        let endpoint = GomaGamingService.simpleRegister(username: username, email: email, phone: phone, birthDate: birthDate, userProviderId: userProviderId)
        // let requestPublisher: AnyPublisher<[ClientSettings]?, NetworkError> = networkClient.requestEndpoint(deviceId: deviceId, endpoint: endpoint)
        let requestPublisher: AnyPublisher<String?, NetworkError> = networkClient.requestEndpoint(deviceId: deviceId, endpoint: endpoint)
        return requestPublisher
    }

}

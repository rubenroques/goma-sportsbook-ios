//
//  TSManager.swift
//  Tipico
//
//  Created by Andrei Marinescu on 27/01/2020.
//  Copyright © 2020 Tipico. All rights reserved.
//
// swiftlint:disable unused_closure_parameter

import Foundation
import DictionaryCoding
import WebKit
import Combine

enum TSSubscriptionContent<T> {
    case connect(publisherIdentifiable: EndpointPublisherIdentifiable)
    case initialContent(T)
    case updatedContent(T)
    case disconnect
}

final class TSManager {

    private var globalCancellable = Set<AnyCancellable>()
    
    private let tsQueue = DispatchQueue(label: "com.goma.games.TSQueue")

    private var cancellables = Set<AnyCancellable>()

    var swampSession: SSWampSession?
    var userAgentExtractionWebView: WKWebView?
    var isConnected: Bool { return swampSession?.isConnected() ?? false }
    let origin = "https://clientsample-sports-stage.everymatrix.com/"

    init() {

        Logger.log("TSManager init")

        DispatchQueue.main.async {

            self.userAgentExtractionWebView = WKWebView()
            self.userAgentExtractionWebView?.evaluateJavaScript("navigator.userAgent") { [weak self] userAgent, error in
                guard let userAgentValue = userAgent as? String, let weakSelf = self else {
                    return
                }
                weakSelf.tsQueue.async {
                    if let cid = UserDefaults.standard.string(forKey: "CID") {
                        weakSelf.swampSession = SSWampSession(realm: TSParams.realm,
                                                          transport: WebSocketSSWampTransport(wsEndpoint: URL(string: TSParams.wsEndPoint + "?cid=\(cid)")!,
                                                                                              userAgent: userAgentValue,
                                                                                              origin: weakSelf.origin))
                    }
                    else {
                        weakSelf.swampSession = SSWampSession(realm: TSParams.realm,
                                                          transport: WebSocketSSWampTransport(wsEndpoint: URL(string: TSParams.wsEndPoint)!,
                                                                                              userAgent: userAgentValue,
                                                                                              origin: weakSelf.origin))
                    }
                    weakSelf.connect()
                    weakSelf.userAgentExtractionWebView = nil
                }
            }
        }
    }



//    class func destroySharedInstance() {
//        sharedInstance = nil
//    }

    func destroySwampSession() {
        self.disconnect()
        self.swampSession = nil
    }

    func disconnect() {
        self.swampSession?.disconnect()
    }

    func connect() {
        Logger.log("TSManager connect")
        self.swampSession?.delegate = self
        self.swampSession?.connect()
    }


    func sessionStateChanged() -> AnyPublisher<Bool, EveryMatrix.APIError> {
        return Future {[self] promise in
            tsQueue.async {
                if self.swampSession != nil {
                    if self.swampSession!.isConnected() {
                        self.swampSession?.subscribe(TSRouter.sessionStateChange.procedure, onSuccess: { subscription in
                            Logger.log("EMSessionLoginFLow - sessionStateChanged subscribed")
                            promise(.success(true))
                        }, onError: { details, errorStr in
                            promise(.failure(.requestError(value: errorStr)))
                        }) { details, results, kwResults in
                            if let code = kwResults?["code"] as? Int {

                                /**
                                0 - Session is logged-in.
                                1 - Session is expired. When all the sessions associated with the same login are idle
                                   for more than 20 minutes, they will be terminated.
                                2 - Session is logged off. This occurs when the logout method is called.

                                 3 - Session is terminated because another login occurred. When the same user is logging in a different place, all the previous logged-in sessions will be terminated.
                                 5 - Session is terminated because of the preset limitation time has been reached. If the session time limitation is enabled in Self Exclusion mode, all the sessions will be terminated when this time is reached.
                                 6 - Session is terminated because self exclusion is enabled.

                                 */
                                
                                if code == 1 {
                                    Logger.log("EMSessionLoginFLow - Expired")
                                    DispatchQueue.main.async {
                                        NotificationCenter.default.post(name: .userSessionDisconnected, object: nil)
                                    }
                                }
                                else if code == 2 {
                                    Logger.log("EMSessionLoginFLow - Logged off")
                                    DispatchQueue.main.async {
                                        NotificationCenter.default.post(name: .userSessionDisconnected, object: nil)
                                    }
                                }
                                else if code == 3 {
                                    Logger.log("EMSessionLoginFLow - Forced logout")
                                    DispatchQueue.main.async {
                                        NotificationCenter.default.post(name: .userSessionForcedLogoutDisconnected, object: nil)
                                    }
                                }
                                else if code == 5 {
                                    Logger.log("EMSessionLoginFLow - Forced logout")
                                    DispatchQueue.main.async {
                                        NotificationCenter.default.post(name: .userSessionForcedLogoutDisconnected, object: nil)
                                    }
                                }
                                else if code == 6 {
                                    Logger.log("EMSessionLoginFLow - Forced logout")
                                    DispatchQueue.main.async {
                                        NotificationCenter.default.post(name: .userSessionForcedLogoutDisconnected, object: nil)
                                    }
                                }
                                else if code == 0 {
                                    // TODO: sessionStateChange success handler to be added here - KVO mechanism as above can be used
                                    Logger.log("EMSessionLoginFLow - Logged")

                                    DispatchQueue.main.async {
                                        NotificationCenter.default.post(name: .userSessionConnected, object: nil)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    func getModel<T: Decodable>(router: TSRouter,initialDumpProcedure: String? = nil, decodingType: T.Type) -> AnyPublisher<T, EveryMatrix.APIError> {
        return Future<T, EveryMatrix.APIError> { [self] promise in
            tsQueue.async {

                guard
                    let swampSession = self.swampSession
                else {
                    promise(.failure(.notConnected))
                    return
                }

                if let initialDumpProcedure = initialDumpProcedure {
                    Logger.log("TSManager getModel initial dump - proc:\(initialDumpProcedure) url:\(router.procedure), args:\(router.args ?? [] )")
                }
                else {
                    Logger.log("TSManager getModel - url:\(router.procedure), args:\(router.args ?? [] )")
                }

                if swampSession.isConnected() {
                    swampSession.call(router.procedure, options: [:], args: router.args, kwargs: router.kwargs, onSuccess: { details, results, kwResults, arrResults in

                        do {
                            if kwResults != nil {
                                let decoder = DictionaryDecoder()
                                decoder.dateDecodingStrategy = .iso8601
                                let finalResult = try decoder.decode(decodingType, from: kwResults!)
                                promise(.success(finalResult))
                            }
                            else {
                                if arrResults != nil {
                                    let decoder = DictionaryDecoder()
                                    decoder.dateDecodingStrategy = .iso8601
                                    let finalResult = try decoder.decode(decodingType, from: arrResults!)
                                    promise(.success(finalResult))
                                }
                                else {
                                    promise(.failure(.noResultsReceived))
                                } 
                            }
                        }
                        catch {
                            //print("TSManager Decoding Error: \(error)")
                            promise(.failure( .decodingError(value: error.localizedDescription) ))
                        }
                    }, onError: { _, error, _, kwargs in
                        var desc = ""
                        if kwargs?["desc"] != nil {
                            desc = kwargs?["desc"] as! String
                        }
                        if !error.isEmpty && desc == "User is not logged in" {
                            // TODO: handle logout
                        }
                        if desc == "You must be logged in to perform this action!" {

                        }
                        promise(.failure(.requestError(value: desc.isEmpty ? error : desc)))
                    })
                }
                else {
                    promise(.failure(.notConnected))
                }

            }
        }
        .eraseToAnyPublisher()
    }

    func subscribeProcedure(procedure: TSRouter) -> AnyPublisher<Bool, EveryMatrix.APIError> {
        return Future {[self] promise in
            tsQueue.async {
                guard
                    let swampSession = self.swampSession
                else {
                    promise(.failure(.notConnected))
                    return
                }

                if swampSession.isConnected() {

                    swampSession.subscribe(procedure.procedure, onSuccess: { (subscription: Subscription) in
                        promise(.success(true))
                    }, onError: { (details: [String: Any], errorStr: String) in
                        promise(.failure(.requestError(value: errorStr)))
                    }, onEvent: {( details: [String: Any], results: [Any]?, kwResults: [String: Any]?) in
//                        if let code = kwResults?["code"] as? Int {
//                            if code == 3 {
//                                DispatchQueue.main.async {
//                                    NotificationCenter.default.post(name: .wampSocketDisconnected, object: nil)
//                                }
//                            }
//                            else if code == 0 {
//                                print("Subscribed!")
//                            }
//                        }
                    })
                }
            }
        }
        .eraseToAnyPublisher()
    }

    func subscribeEndpoint<T: Decodable>(_ endpoint: TSRouter, decodingType: T.Type) -> AnyPublisher<TSSubscriptionContent<T>, EveryMatrix.APIError> {

        let subject = PassthroughSubject<TSSubscriptionContent<T>, EveryMatrix.APIError>()

        guard
            let swampSession = self.swampSession,
            swampSession.isConnected()
        else {
            subject.send(completion: .failure(.notConnected))
            return subject.eraseToAnyPublisher()
        }


        let args: [String: Any] = endpoint.kwargs ?? [:]

        Logger.log("TSManager subscribeEndpoint - url:\(endpoint.procedure), args:\(args)")

        swampSession.subscribe(endpoint.procedure, options: args,
        onSuccess: { (subscription: Subscription) in
            subject.send(TSSubscriptionContent.connect(publisherIdentifiable: subscription))

            if let initialDumpEndpoint = endpoint.intiailDumpRequest {
                self.getModel(router: initialDumpEndpoint, decodingType: decodingType)
                    .sink { completion in
                        if case .failure(let error) = completion {
                            subject.send(TSSubscriptionContent.disconnect)
                            subject.send(completion: .failure(error))

                        }
                    } receiveValue: { decoded in
                        subject.send(.initialContent(decoded))
                    }
                    .store(in: &self.globalCancellable)
            }
        },
        onError: { (details: [String: Any], errorStr: String) in
            subject.send(TSSubscriptionContent.disconnect)
            subject.send(completion: .failure(.requestError(value: errorStr)))
        },
        onEvent: { (details: [String: Any], results: [Any]?, kwResults: [String: Any]?) in
            do {
                if kwResults != nil {
                    let decoder = DictionaryDecoder()
                    decoder.dateDecodingStrategy = .iso8601
                    let decoded = try decoder.decode(decodingType, from: kwResults!)
                    subject.send(.updatedContent(decoded))
                }
                else {
                    subject.send(completion: .failure(.noResultsReceived))
                }
            }
            catch {
                // print("TSManager Decoding Error: \(error)")
                subject.send(completion: .failure(.decodingError(value: error.localizedDescription)))
            }
        })

        return subject.handleEvents(receiveOutput: { content in

        }, receiveCompletion: { completion in
            print("completion \(completion)")
        }, receiveCancel: {

        }).eraseToAnyPublisher()

    }

    func unsubscribeFromEndpoint(endpointPublisherIdentifiable: EndpointPublisherIdentifiable) {
        guard
            let swampSession = self.swampSession,
            swampSession.isConnected()
        else {
            return
        }

        swampSession.unsubscribe(endpointPublisherIdentifiable.identificationCode) {
            ()
        } onError: { details, error in
            // print("UnregisterFromEndpoint error \(details) \(error)")
        }
    }

    func unregisterFromEndpoint(endpointPublisherIdentifiable: EndpointPublisherIdentifiable) {
        guard
            let swampSession = self.swampSession,
            swampSession.isConnected()
        else {
            return
        }

        // print("UnregisterFromEndpoint \(endpointPublisherIdentifiable.identificationCode)")
        
        swampSession.unregister(endpointPublisherIdentifiable.identificationCode) {
            ()
        } onError: { details, error in
            // print("UnregisterFromEndpoint error \(details) \(error)")
        }
    }

    func registerOnEndpoint<T: Decodable>(_ endpoint: TSRouter, decodingType: T.Type) -> AnyPublisher<TSSubscriptionContent<T>, EveryMatrix.APIError> {

        let subject = PassthroughSubject<TSSubscriptionContent<T>, EveryMatrix.APIError>()

        guard
            let swampSession = self.swampSession,
            swampSession.isConnected()
        else {
            subject.send(completion: .failure(.notConnected))
            return subject.eraseToAnyPublisher()
        }

        let args: [String: Any] = endpoint.kwargs ?? [:]

        Logger.log("TSManager registerOnEndpoint - url:\(endpoint.procedure), args:\(args)")

        swampSession.register(endpoint.procedure, options: args,
        onSuccess: { (registration: Registration) in
            subject.send(TSSubscriptionContent.connect(publisherIdentifiable: registration))

            if let initialDumpEndpoint = endpoint.intiailDumpRequest {
                self.getModel(router: initialDumpEndpoint, initialDumpProcedure: endpoint.procedure, decodingType: decodingType)
                    .sink { completion in
                        if case .failure(let error) = completion {
                            subject.send(TSSubscriptionContent.disconnect)
                            subject.send(completion: .failure(error))
                        }
                    } receiveValue: { decoded in
                        subject.send(.initialContent(decoded))
                    }
                    .store(in: &self.globalCancellable)
            }
        },
        onError: { (details: [String: Any], errorStr: String) in
            subject.send(TSSubscriptionContent.disconnect)
            subject.send(completion: .failure(.requestError(value: errorStr)))
        },
        onEvent: { (details: [String: Any], results: [Any]?, kwResults: [String: Any]?) in
            do {
                if kwResults != nil {
                    let decoder = DictionaryDecoder()
                    decoder.dateDecodingStrategy = .iso8601
                    let decoded = try decoder.decode(decodingType, from: kwResults!)
                    subject.send(.updatedContent(decoded))
                }
                else {
                    subject.send(completion: .failure(.noResultsReceived))
                }
            }
            catch {
                subject.send(completion: .failure( .decodingError(value: error.localizedDescription) ))
            }
        })
        return subject.handleEvents(receiveOutput: { content in

        }, receiveCompletion: { completion in
            print("completion \(completion)")
        }, receiveCancel: {

        }).eraseToAnyPublisher()
    }

    func registerOnEndpointAsRPC<T: Decodable>(_ endpoint: TSRouter, decodingType: T.Type) -> AnyPublisher<T, EveryMatrix.APIError> {

        let subject = PassthroughSubject<T, EveryMatrix.APIError>()

        var endpointPublisherIdentifiable: EndpointPublisherIdentifiable?

        self.registerOnEndpoint(endpoint, decodingType: decodingType)
            .sink { completion in
                subject.send(completion: completion)
            } receiveValue: { subscriptionContent in
                switch subscriptionContent {
                case .connect(let publisherIdentifiable):
                    endpointPublisherIdentifiable = publisherIdentifiable
                case .initialContent(let object):

                    subject.send(object)

                    if let endpointPublisherIdentifiableValue = endpointPublisherIdentifiable {
                        self.unregisterFromEndpoint(endpointPublisherIdentifiable: endpointPublisherIdentifiableValue)
                    }

                    subject.send(completion: .finished)
                default:
                    subject.send(completion: .finished)
                }
            }
            .store(in: &cancellables)

        return subject.eraseToAnyPublisher()

    }

}

extension TSManager: SSWampSessionDelegate {
    func ssWampSessionHandleChallenge(_ authMethod: String, extra: [String: Any]) -> String {
        return "handleChallenge"
    }
    
    func ssWampSessionConnected(_ session: SSWampSession, sessionId: Int) {

        NotificationCenter.default.post(name: .socketConnected, object: nil)

        sessionStateChanged()
            .sink(receiveCompletion: { completion in
                Logger.log("TSManager sessionStateChanged completion: \(completion)")
            }, receiveValue: { connected in
                Logger.log("TSManager sessionStateChanged \(connected)")
            })
            .store(in: &globalCancellable)

    }
    
    func ssWampSessionEnded(_ reason: String) {
        NotificationCenter.default.post(name: .userSessionDisconnected, object: nil)
        NotificationCenter.default.post(name: .socketDisconnected, object: nil)
    }
}

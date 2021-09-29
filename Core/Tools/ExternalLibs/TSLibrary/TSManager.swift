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
    case connect
    case content(T)
    case disconnect
}

final class TSManager {
    
    private var cancellable = Set<AnyCancellable>()
    
    private let tsQueue = DispatchQueue(label: "com.goma.games.TSQueue")
    
    private static var sharedInstance: TSManager?
    
    class var shared: TSManager {
        guard let sharedInstance = self.sharedInstance else {
            let sharedInstance = TSManager()
            self.sharedInstance = sharedInstance
            return sharedInstance
        }
        return sharedInstance
    }
    
    class func destroySharedInstance() {
        sharedInstance = nil
    }
    
    func destroySwampSession() {
        swampSession = nil
    }
    
    private var swampSession: SSWampSession?
    private var userAgentExtractionWebView: WKWebView?
    var isConnected: Bool { return swampSession?.isConnected() ?? false }
    private let origin = "https://clientsample-sports-stage.everymatrix.com/"
    
    private init() {

        Logger.log("TSManager init")

        DispatchQueue.main.async {

            self.userAgentExtractionWebView = WKWebView()
            self.userAgentExtractionWebView?.evaluateJavaScript("navigator.userAgent") { [weak self] userAgent, error in
                guard let usrAg = userAgent as? String, let self = self else {
                    return
                }
                self.tsQueue.async {
                    if let cid = UserDefaults.standard.string(forKey: "CID") {
                        self.swampSession = SSWampSession(realm: TSParams.realm,
                                                          transport: WebSocketSSWampTransport(wsEndpoint: URL(string: TSParams.wsEndPoint + "?cid=\(cid)")!,
                                                                                              userAgent: usrAg,
                                                                                              origin: self.origin))
                    } else {
                        self.swampSession = SSWampSession(realm: TSParams.realm,
                                                          transport: WebSocketSSWampTransport(wsEndpoint: URL(string: TSParams.wsEndPoint)!,
                                                                                              userAgent: usrAg,
                                                                                              origin: self.origin))
                    }
                    self.swampSession?.delegate = self
                    self.swampSession?.connect()
                    self.userAgentExtractionWebView = nil
                }
            }
        }
    }
    
    func sessionStateChanged() -> AnyPublisher<Bool, EveryMatrixSocketAPIError> {
        return Future {[self] promise in
            tsQueue.async {
                if self.swampSession != nil {
                    if self.swampSession!.isConnected() {
                        self.swampSession?.subscribe(TSRouter.sessionStateChange.procedure, onSuccess: { subscription in
                            promise(.success(true))
                        }, onError: { details, errorStr in
                            promise(.failure(.requestError(value: errorStr)))
                        }) { details, results, kwResults in
                            if let code = kwResults?["code"] as? Int {
                                if code == 3 {
                                    DispatchQueue.main.async {
                                        NotificationCenter.default.post(name: .wampSocketDisconnected, object: nil)
                                    }
                                }
                                else if code == 0 {
                                    // TODO: sessionStateChange success handler to be added here - KVO mechanism as above can be used
                                }
                            }
                        }
                    }
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    func getModel<T: Decodable>(router: TSRouter, decodingType: T.Type) -> AnyPublisher<T, EveryMatrixSocketAPIError> {
        return Future<T, EveryMatrixSocketAPIError> { [self] promise in
            tsQueue.async {

                guard
                    let swampSession = self.swampSession
                else {
                    promise(.failure(.notConnected))
                    return
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
                            print("TSManager Decoding Error: \(error)")
                            promise(.failure(.decodingError))
                        }
                    }, onError: { _, error, _, kwargs in
                        var desc = ""
                        if kwargs?["desc"] != nil {
                            desc = kwargs?["desc"] as! String
                        }
                        if !error.isEmpty && desc == "User is not logged in" {
                            // TODO: handle logout
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

    func subscribeProcedure(procedure: TSRouter) -> AnyPublisher<Bool, EveryMatrixSocketAPIError> {
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
                        if let code = kwResults?["code"] as? Int {
                            if code == 3 {
                                DispatchQueue.main.async {
                                    NotificationCenter.default.post(name: .wampSocketDisconnected, object: nil)
                                }
                            }
                            else if code == 0 {
                                print("Subscribed!")
                            }
                        }
                    })
                }
            }
        }
        .eraseToAnyPublisher()
    }

    func subscribeEndpoint<T: Decodable>(_ endpoint: TSRouter, decodingType: T.Type) throws -> AnyPublisher<TSSubscriptionContent<T>, EveryMatrixSocketAPIError> {

        guard
            let swampSession = self.swampSession,
            swampSession.isConnected()
        else {
            throw EveryMatrixSocketAPIError.notConnected
        }

        let subject = PassthroughSubject<TSSubscriptionContent<T>, EveryMatrixSocketAPIError>()

        let args: [String: Any] = endpoint.kwargs ?? [:]

        Logger.log("subscribeEndpoint - url:\(endpoint.procedure), args:\(args)")

        swampSession.subscribe(endpoint.procedure, options: args,
        onSuccess: { (subscription: Subscription) in
            subject.send(TSSubscriptionContent.connect)
        },
        onError: { (details: [String: Any], errorStr: String) in
            subject.send(TSSubscriptionContent.disconnect)
            subject.send(completion: .failure(.requestError(value: errorStr)))
        },
        onEvent: { (details: [String: Any], results: [Any]?, kwResults: [String: Any]?) in
            if let code = kwResults?["code"] as? Int {
                if code == 3 {
                    DispatchQueue.main.async {
                        NotificationCenter.default.post(name: .wampSocketDisconnected, object: nil)
                    }
                    subject.send(TSSubscriptionContent.disconnect)
                    subject.send(completion: .failure(.notConnected))
                }
                else if code == 0 {
                    print("Subscribed!")
                }
            }
        })

        return subject.eraseToAnyPublisher()
    }

    class func reconnect() {
        destroySharedInstance()
    }
    
    func logout(router: TSRouter) {
        swampSession?.call(router.procedure, onSuccess: { _, _, _, _ in }, onError: { _, _, _, _ in })
    }
    
    func disconnect() {
        swampSession?.disconnect()
    }
}

extension TSManager: SSWampSessionDelegate {
    func ssWampSessionHandleChallenge(_ authMethod: String, extra: [String: Any]) -> String {
        return "handleChallenge"
    }
    
    func ssWampSessionConnected(_ session: SSWampSession, sessionId: Int) {
        sessionStateChanged()
            .sink(receiveCompletion: { _ in
                NotificationCenter.default.post(name: .wampSocketConnected, object: nil)
            }, receiveValue: { value in
                Logger.log("TSManager ssWampSessionConnected\(value.description)")
            })
            .store(in: &cancellable)
    }
    
    func ssWampSessionEnded(_ reason: String) {
        NotificationCenter.default.post(name: .wampSocketDisconnected, object: nil)
    }
}

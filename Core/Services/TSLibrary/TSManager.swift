//
//  TSManager.swift
//  Tipico
//
//  Created by Andrei Marinescu on 27/01/2020.
//  Copyright © 2020 Tipico. All rights reserved.
//

import Foundation
import DictionaryCoding
import WebKit
import Combine

final class TSManager {
    
    private var cancellable = Set<AnyCancellable>()
    
    private let tsQueue = DispatchQueue(label: "com.tipico.games.TSQueue")
    
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
        DispatchQueue.main.async {
            self.userAgentExtractionWebView = WKWebView()
            self.userAgentExtractionWebView?.evaluateJavaScript("navigator.userAgent") {[weak self] (userAgent, error) in
                guard let usrAg = userAgent as? String, let self = self else {
                    return
                }
                self.tsQueue.async {
                    if let cid = UserDefaults.standard.string(forKey: "CID") {
                        self.swampSession = SSWampSession(realm: TSParams.realm, transport: WebSocketSSWampTransport(wsEndpoint:  URL(string: TSParams.wsEndPoint + "?cid=\(cid)")!, userAgent: usrAg, origin: self.origin))
                    } else {
                        self.swampSession = SSWampSession(realm: TSParams.realm, transport: WebSocketSSWampTransport(wsEndpoint:  URL(string: TSParams.wsEndPoint)!, userAgent: usrAg, origin: self.origin))
                    }
                    self.swampSession?.delegate = self
                    self.swampSession?.connect()
                    self.userAgentExtractionWebView = nil
                }
            }
        }
    }
    
    func sessionStateChanged() -> AnyPublisher<Bool, APIError> {
        return Future {[self] promise in
            tsQueue.async {
                if self.swampSession != nil {
                    if self.swampSession!.isConnected() {
                        self.swampSession?.subscribe(TSRouter.sessionStateChange.procedure, onSuccess: { (subscription) in
                            promise(.success(true))
                        }, onError: { (details, errorStr) in
                            promise(.failure(.requestError(value: errorStr)))
                        }) { (details, results, kwResults) in
                            if let code = kwResults?["code"] as? Int {
                                if code == 3 {
                                    DispatchQueue.main.async {
                                        NotificationCenter.default.post(name: .tsDisconnected, object: nil)
                                    }
                                } else if code == 0 {
                                   //TODO: sessionStateChange success handler to be added here - KVO mechanism as above can be used
                                }
                            }
                        }
                    }
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    func getModel<T: Decodable>(router: TSRouter, decodingType: T.Type) -> AnyPublisher<T, APIError> {
        return Future { [self] promise in
            tsQueue.async {
                if self.swampSession != nil {
                    if self.swampSession!.isConnected() {
                        self.swampSession?.call(router.procedure, options: [:], args: router.args, kwargs: router.kwargs, onSuccess: { (details, results, kwResults, arrResults) in
                            do {
                                if kwResults != nil {
                                    let finalResult = try DictionaryDecoder().decode(decodingType, from: kwResults!)
                                    promise(.success(finalResult))
                                } else {
                                    if arrResults != nil {
                                        let finalResult = try DictionaryDecoder().decode(decodingType, from: arrResults!)
                                        promise(.success(finalResult))
                                    } else {
                                        promise(.failure(.noResultsReceived))
                                    }
                                }
                            } catch {
                                promise(.failure(.decodingError))
                            }
                        }) { (details, error, args, kwargs) in
                            var desc = ""
                            if kwargs?["desc"] != nil {
                                desc = kwargs?["desc"] as! String
                            }
                            if !error.isEmpty && desc == "User is not logged in" {
                                //TODO: handle logout
                            }
                            promise(.failure(.requestError(value: error)))
                        }
                    }   else {
                        promise(.failure(.notConnected))
                    }
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    class func reconnect() {
        destroySharedInstance()
    }
    
    func logout(router: TSRouter) {
        swampSession?.call(router.procedure, onSuccess: { (_, _, _, _) in
        }) { (_, _, _, _) in
        }
    }
    
    func disconnect() {
        swampSession?.disconnect()
    }
}

extension TSManager: SSWampSessionDelegate {
    func ssWampSessionHandleChallenge(_ authMethod: String, extra: [String : Any]) -> String {
        return "handleChallenge"
    }
    
    func ssWampSessionConnected(_ session: SSWampSession, sessionId: Int) {
        sessionStateChanged()
            .sink(receiveCompletion: { completion in
                NotificationCenter.default.post(name: .tsConnected, object: nil)
            }, receiveValue: { value in
                print(value.description)
            })
            .store(in: &cancellable)
    }
    
    func ssWampSessionEnded(_ reason: String) {
        NotificationCenter.default.post(name: .tsDisconnected, object: nil)
    }
}

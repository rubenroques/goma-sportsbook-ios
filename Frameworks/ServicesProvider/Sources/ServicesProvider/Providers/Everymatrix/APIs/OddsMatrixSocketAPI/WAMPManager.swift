
import Foundation
import DictionaryCoding
import Combine
import UIKit

enum WAMPSubscriptionContent<T> {
    case connect(publisherIdentifiable: EndpointPublisherIdentifiable)
    case initialContent(T)
    case updatedContent(T)
    case disconnect
}

enum WAMPConnectionState {
    case connected
    case disconnected
}

final class WAMPManager {
    
    private var globalCancellable = Set<AnyCancellable>()
    
    private let tsQueue = DispatchQueue(label: "com.goma.games.WAMPQueue")
    
    private var cancellables = Set<AnyCancellable>()
    
    var connectionStatePublisher: AnyPublisher<WAMPConnectionState, Never> {
        return self.connectionStateSubject.eraseToAnyPublisher()
    }
    private var connectionStateSubject = CurrentValueSubject<WAMPConnectionState, Never>(.disconnected)
    
    var swampSession: SSWampSession?

    var isConnected: Bool { return swampSession?.isConnected() ?? false }
    
    init() {
        print("WAMPManager init")
        
        self.swampSession = self.createSwampSession()
        
        self.connect()
    }

    func createSwampSession() -> SSWampSession {
        let wsEndPoint: String
        if let cachedCIDValue = UserDefaults.standard.string(forKey: EveryMatrixUnifiedConfiguration.cacheCIDKey) {
            print("WAMPManager: cached CID found: \(cachedCIDValue)")
            wsEndPoint = WAMPSocketParams.wsEndPoint + "?cid=" + cachedCIDValue
        }
        else {
            print("WAMPManager: no CID found")
            wsEndPoint = WAMPSocketParams.wsEndPoint
        }
                
        print("WAMPManager: URL: \(wsEndPoint)")
        print("WAMPManager: Origin: \(WAMPSocketParams.origin)")
        
        let swampSession = SSWampSession(
            realm: WAMPSocketParams.realm,
            transport: WebSocketSSWampTransport(
                wsEndpoint: URL(string: wsEndPoint)!,
                userAgent: self.buildUserAgent(),
                origin: WAMPSocketParams.origin
            )
        )
        
        return swampSession
    }
    
    func buildUserAgent() -> String {
        let device = UIDevice.current
        let bundle = Bundle.main
        let appName = bundle.object(forInfoDictionaryKey: "CFBundleName") as? String ?? "App"
        let appVersion = bundle.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0"
        let buildNumber = bundle.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "1"
        
        // Get iOS version
        let osVersion = device.systemVersion.replacingOccurrences(of: ".", with: "_")
        
        // Get device model
        var systemInfo = utsname()
        uname(&systemInfo)
        let modelCode = withUnsafePointer(to: &systemInfo.machine) {
            $0.withMemoryRebound(to: CChar.self, capacity: 1) {
                String(validatingUTF8: $0)
            }
        } ?? "Unknown"
        
        // Get Darwin/CFNetwork versions
        let darwinVersion = ProcessInfo.processInfo.operatingSystemVersionString
        
        // Build User-Agent
        let userAgent = "\(appName)/\(appVersion)(\(buildNumber)) - (\(modelCode); iOS \(osVersion)) CFNetwork Darwin \(darwinVersion)"
        return userAgent
    }
    
    func destroySwampSession() {
        self.disconnect()
        self.swampSession = nil
    }
    
    func disconnect() {
        self.swampSession?.disconnect()
    }
    
    func connect() {
        print("WAMPManager connect")
        self.swampSession?.delegate = self
        self.swampSession?.connect()
    }
    
    
    func sessionStateChanged() -> AnyPublisher<Bool, EveryMatrix.APIError> {
        return Future {[self] promise in
            tsQueue.async {
                if self.swampSession != nil {
                    if self.swampSession!.isConnected() {
                        self.swampSession?.subscribe(WAMPRouter.sessionStateChange.procedure, onSuccess: { subscription in
                            print("EMSessionLoginFLow - sessionStateChanged subscribed")
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
                                    print("EMSessionLoginFLow - Expired")
                                    DispatchQueue.main.async {
                                        NotificationCenter.default.post(name: .userSessionDisconnected, object: nil)
                                    }
                                }
                                else if code == 2 {
                                    print("EMSessionLoginFLow - Logged off")
                                    DispatchQueue.main.async {
                                        NotificationCenter.default.post(name: .userSessionDisconnected, object: nil)
                                    }
                                }
                                else if code == 3 {
                                    print("EMSessionLoginFLow - Forced logout")
                                    DispatchQueue.main.async {
                                        NotificationCenter.default.post(name: .userSessionForcedLogoutDisconnected, object: nil)
                                    }
                                }
                                else if code == 5 {
                                    print("EMSessionLoginFLow - Forced logout")
                                    DispatchQueue.main.async {
                                        NotificationCenter.default.post(name: .userSessionForcedLogoutDisconnected, object: nil)
                                    }
                                }
                                else if code == 6 {
                                    print("EMSessionLoginFLow - Forced logout")
                                    DispatchQueue.main.async {
                                        NotificationCenter.default.post(name: .userSessionForcedLogoutDisconnected, object: nil)
                                    }
                                }
                                else if code == 0 {
                                    // TODO: sessionStateChange success handler to be added here - KVO mechanism as above can be used
                                    print("EMSessionLoginFLow - Logged")
                                    
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
    
    func getModel<T: Decodable>(router: WAMPRouter, initialDumpProcedure: String? = nil, decodingType: T.Type) -> AnyPublisher<T, EveryMatrix.APIError> {
        return Future<T, EveryMatrix.APIError> { [self] promise in
            tsQueue.async {
                
                guard
                    let swampSession = self.swampSession
                else {
                    promise(.failure(.notConnected))
                    return
                }
                
                if let initialDumpProcedure = initialDumpProcedure {
                    print("WAMPManager getModel initial dump - proc:\(initialDumpProcedure) url:\(router.procedure), args:\(router.args ?? [] )")
                }
                else {
                    print("WAMPManager getModel - url:\(router.procedure), args:\(router.args ?? [] ), kwargs:\(router.kwargs ?? [:] )")
                }
                
                if swampSession.isConnected() {
                    // print("🔄 WAMPManager: Making RPC call to \(router.procedure)")
                    // print("🔄 WAMPManager: Args: \(router.args ?? [])")
                    // print("🔄 WAMPManager: Kwargs: \(router.kwargs ?? [:])")
                    
                    swampSession.call(router.procedure, options: [:], args: router.args, kwargs: router.kwargs, onSuccess: { details, results, kwResults, arrResults in
                        
                        // print("✅ WAMPManager: RPC call SUCCESS for \(router.procedure)")
                        // print("✅ WAMPManager: kwResults: \(kwResults ?? [:])")
                        // print("✅ WAMPManager: arrResults: \(arrResults ?? [:])")
                        
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
                            print("🔴 WAMPManager getModel Decoding Error:")
                            print("   ├─ Target Type: \(decodingType)")
                            print("   ├─ Router: \(router.procedure)")
                            print("   ├─ Error: \(error)")
                            if let decodingError = error as? DecodingError {
                                print("   ├─ Decoding Error Details: \(decodingError.localizedDescription)")
                                switch decodingError {
                                case .keyNotFound(let key, let context):
                                    print("   ├─ Missing Key: \(key.stringValue)")
                                    print("   ├─ Context: \(context.debugDescription)")
                                case .typeMismatch(let type, let context):
                                    print("   ├─ Type Mismatch: Expected \(type)")
                                    print("   ├─ Context: \(context.debugDescription)")
                                case .valueNotFound(let type, let context):
                                    print("   ├─ Value Not Found: \(type)")
                                    print("   ├─ Context: \(context.debugDescription)")
                                case .dataCorrupted(let context):
                                    print("   ├─ Data Corrupted: \(context.debugDescription)")
                                @unknown default:
                                    break
                                }
                            }
                            if let kwResults = kwResults {
                                print("   ├─ Raw kwResults: \(kwResults)")
                            }
                            if let arrResults = arrResults {
                                print("   └─ Raw arrResults: \(arrResults)")
                            } else {
                                print("   └─ No raw data available")
                            }
                            promise(.failure( .decodingError(value: error.localizedDescription) ))
                        }
                    }, onError: { _, error, _, kwargs in
                        print("❌ WAMPManager: RPC call ERROR for \(router.procedure)")
                        print("❌ WAMPManager: Error: \(error)")
                        print("❌ WAMPManager: Error kwargs: \(kwargs ?? [:])")
                        
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
    
    //
    // Legacy. WAMP server uses registers
    func subscribeProcedure(procedure: WAMPRouter) -> AnyPublisher<Bool, EveryMatrix.APIError> {
        return Future {[self] promise in
            tsQueue.async {
                guard
                    let swampSession = self.swampSession
                else {
                    promise(.failure(.notConnected))
                    return
                }
                
                if swampSession.isConnected() {
                    
                    swampSession.subscribe(procedure.procedure, onSuccess: { (subscription: WAMPSubscription) in
                        promise(.success(true))
                    }, onError: { (details: [String: Any], errorStr: String) in
                        promise(.failure(.requestError(value: errorStr)))
                    }, onEvent: {( details: [String: Any], results: [Any]?, kwResults: [String: Any]?) in
                        if let code = kwResults?["code"] as? Int {
                            if code == 3 {
                                DispatchQueue.main.async {
                                    NotificationCenter.default.post(name: .socketDisconnected, object: nil)
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
    
    func subscribeEndpoint<T: Decodable>(_ endpoint: WAMPRouter, decodingType: T.Type) -> AnyPublisher<WAMPSubscriptionContent<T>, EveryMatrix.APIError> {
        
        let subject = PassthroughSubject<WAMPSubscriptionContent<T>, EveryMatrix.APIError>()
        
        guard
            let swampSession = self.swampSession,
            swampSession.isConnected()
        else {
            subject.send(completion: .failure(.notConnected))
            return subject.eraseToAnyPublisher()
        }
        
        
        let args: [String: Any] = endpoint.kwargs ?? [:]
        
        print("WAMPManager subscribeEndpoint - url:\(endpoint.procedure), args:\(args)")
        
        swampSession.subscribe(endpoint.procedure, options: args,
                               onSuccess: { (subscription: WAMPSubscription) in
            subject.send(WAMPSubscriptionContent.connect(publisherIdentifiable: subscription))
            
            if let initialDumpEndpoint = endpoint.intiailDumpRequest {
                self.getModel(router: initialDumpEndpoint, decodingType: decodingType)
                    .sink { completion in
                        if case .failure(let error) = completion {
                            subject.send(WAMPSubscriptionContent.disconnect)
                            subject.send(completion: .failure(error))
                            
                        }
                    } receiveValue: { decoded in
                        subject.send(.initialContent(decoded))
                    }
                    .store(in: &self.globalCancellable)
            }
        },
                               onError: { (details: [String: Any], errorStr: String) in
            subject.send(WAMPSubscriptionContent.disconnect)
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
                print("🔴 WAMPManager subscribeEndpoint Decoding Error:")
                print("   ├─ Target Type: \(decodingType)")
                print("   ├─ Endpoint: \(endpoint.procedure)")
                print("   ├─ Error: \(error)")
                if let decodingError = error as? DecodingError {
                    print("   ├─ Decoding Error Details: \(decodingError.localizedDescription)")
                    switch decodingError {
                    case .keyNotFound(let key, let context):
                        print("   ├─ Missing Key: \(key.stringValue)")
                        print("   ├─ Context: \(context.debugDescription)")
                    case .typeMismatch(let type, let context):
                        print("   ├─ Type Mismatch: Expected \(type)")
                        print("   ├─ Context: \(context.debugDescription)")
                    case .valueNotFound(let type, let context):
                        print("   ├─ Value Not Found: \(type)")
                        print("   ├─ Context: \(context.debugDescription)")
                    case .dataCorrupted(let context):
                        print("   ├─ Data Corrupted: \(context.debugDescription)")
                    @unknown default:
                        break
                    }
                }
                if let kwResults = kwResults {
                    print("   └─ Raw kwResults: \(kwResults)")
                } else {
                    print("   └─ No raw data available")
                }
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
        
        print("WAMPManager: unsubscribeFromEndpoint \(endpointPublisherIdentifiable.identificationCode)")
        
        swampSession.unsubscribe(endpointPublisherIdentifiable.identificationCode) {
            print("WAMPManager: unsubscribeFromEndpoint succeeded")
        } onError: { details, error in
            print("WAMPManager: unsubscribeFromEndpoint error \(details) \(error)")
        }
    }
    
    func registerOnEndpoint<T: Decodable>(_ endpoint: WAMPRouter, decodingType: T.Type) -> AnyPublisher<WAMPSubscriptionContent<T>, EveryMatrix.APIError> {
        
        let subject = PassthroughSubject<WAMPSubscriptionContent<T>, EveryMatrix.APIError>()
        
        guard
            let swampSession = self.swampSession
        else {
            print("WAMPManager: No swampSession available for registerOnEndpoint")
            subject.send(completion: .failure(.notConnected))
            return subject.eraseToAnyPublisher()
        }
        
        guard swampSession.isConnected() else {
            print("WAMPManager: SwampSession is not connected for registerOnEndpoint (state: \(swampSession.isConnected()))")
            subject.send(completion: .failure(.notConnected))
            return subject.eraseToAnyPublisher()
        }
        
        let args: [String: Any] = endpoint.kwargs ?? [:]
        
        print("WAMPManager: Registering on endpoint - url:\(endpoint.procedure), args:\(args)")
        
        swampSession.register(
            endpoint.procedure,
            options: args,
            onSuccess:
                { (registration: WAMPRegistration) in
                    // print("✅ WAMPManager: Successfully registered endpoint (id: \(registration.identificationCode))")
                    
                    subject.send(WAMPSubscriptionContent.connect(publisherIdentifiable: registration))
                    
                    if let initialDumpEndpoint = endpoint.intiailDumpRequest {
                        // print("📥 WAMPManager: Requesting initial dump from \(initialDumpEndpoint.procedure)")
                        self.getModel(router: initialDumpEndpoint, initialDumpProcedure: endpoint.procedure, decodingType: decodingType)
                            .sink { completion in
                                if case .failure(let error) = completion {
                                    // print("❌ WAMPManager: Initial dump failed: \(error)")
                                    subject.send(WAMPSubscriptionContent.disconnect)
                                    subject.send(completion: .failure(error))
                                } else {
                                    // print("✅ WAMPManager: Initial dump completed successfully")
                                }
                            } receiveValue: { decoded in
                                // print("📦 WAMPManager: Received initial dump data")
                                subject.send(.initialContent(decoded))
                            }
                            .store(in: &self.globalCancellable)
                    }
                },
            onError:
                { (details: [String: Any], errorStr: String) in
                    // print("❌ WAMPManager: Registration failed - \(errorStr)")
                    subject.send(WAMPSubscriptionContent.disconnect)
                    subject.send(completion: .failure(.requestError(value: errorStr)))
                },
            onEvent:
                { (details: [String: Any], results: [Any]?, kwResults: [String: Any]?) in
                    // print("🔄 WAMPManager: Received event update")
                    do {
                        if kwResults != nil {
                            let decoder = DictionaryDecoder()
                            decoder.dateDecodingStrategy = .iso8601
                            let decoded = try decoder.decode(decodingType, from: kwResults!)
                            // print("📦 WAMPManager: Successfully decoded event update")
                            subject.send(.updatedContent(decoded))
                        }
                        else {
                            // print("❌ WAMPManager: Event received but no kwResults data")
                            subject.send(completion: .failure(.noResultsReceived))
                        }
                    }
                    catch {
                        print("🔴 WAMPManager registerOnEndpoint Decoding Error:")
                        print("   ├─ Target Type: \(decodingType)")
                        print("   ├─ Endpoint: \(endpoint.procedure)")
                        print("   ├─ Error: \(error)")
                        if let decodingError = error as? DecodingError {
                            print("   ├─ Decoding Error Details: \(decodingError.localizedDescription)")
                            switch decodingError {
                            case .keyNotFound(let key, let context):
                                print("   ├─ Missing Key: \(key.stringValue)")
                                print("   ├─ Context: \(context.debugDescription)")
                            case .typeMismatch(let type, let context):
                                print("   ├─ Type Mismatch: Expected \(type)")
                                print("   ├─ Context: \(context.debugDescription)")
                            case .valueNotFound(let type, let context):
                                print("   ├─ Value Not Found: \(type)")
                                print("   ├─ Context: \(context.debugDescription)")
                            case .dataCorrupted(let context):
                                print("   ├─ Data Corrupted: \(context.debugDescription)")
                            @unknown default:
                                break
                            }
                        }
                        if let kwResults = kwResults {
                            print("   └─ Raw kwResults: \(kwResults)")
                        } else {
                            print("   └─ No raw data available")
                        }
                        subject.send(completion: .failure( .decodingError(value: error.localizedDescription) ))
                    }
                })
        
        return subject.handleEvents(receiveOutput: { content in
            
        }, receiveCompletion: { completion in
            print("WAMPManager receiveCompletion \(completion)")
        }, receiveCancel: {
            
        }).eraseToAnyPublisher()
    }
    
    
    func unregisterFromEndpoint(endpointPublisherIdentifiable: EndpointPublisherIdentifiable) {
        guard
            let swampSession = self.swampSession,
            swampSession.isConnected()
        else {
            return
        }
        
        print("WAMPManager: unregisterFromEndpoint \(endpointPublisherIdentifiable.identificationCode)")
        
        swampSession.unregister(endpointPublisherIdentifiable.identificationCode) {
            print("WAMPManager: unregisterFromEndpoint succeeded")
        } onError: { details, error in
            print("WAMPManager: unregisterFromEndpoint error \(details) \(error)")
        }
    }
    
    //
    // Performs a register that halts as soon as it has the initial dump
    func registerOnEndpointAsRPC<T: Decodable>(_ endpoint: WAMPRouter, decodingType: T.Type) -> AnyPublisher<T, EveryMatrix.APIError> {
        
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

extension WAMPManager: SSWampSessionDelegate {
    func ssWampSessionHandleChallenge(_ authMethod: String, extra: [String: Any]) -> String {
        return "handleChallenge"
    }
    
    func ssWampSessionConnected(_ session: SSWampSession, sessionId: Int) {
        print("WAMPManager: WebSocket connected, establishing WAMP session...")
        
        NotificationCenter.default.post(name: .socketConnected, object: nil)
        
        sessionStateChanged()
            .sink(receiveCompletion: { completion in
                print("WAMPManager: sessionStateChanged receiveCompletion: \(completion)")
                switch completion {
                case .failure(let error):
                     print("WAMPManager: Failed to establish WAMP session: \(error)")
                case .finished:
                    break
                }
            }, receiveValue: { [weak self] connected in
                print("WAMPManager: sessionStateChanged receiveValue: \(connected)")
                if connected {
                    print("WAMPManager: WAMP session ready - emitting .connected state")
                    self?.connectionStateSubject.send(.connected)
                } else {
                    print("WAMPManager: WAMP session not ready")
                }
            })
            .store(in: &globalCancellable)
        
    }
    
    func ssWampSessionEnded(_ reason: String) {
        
        self.connectionStateSubject.send(.disconnected)
        
        NotificationCenter.default.post(name: .userSessionDisconnected, object: nil)
        NotificationCenter.default.post(name: .socketDisconnected, object: nil)
    }
}

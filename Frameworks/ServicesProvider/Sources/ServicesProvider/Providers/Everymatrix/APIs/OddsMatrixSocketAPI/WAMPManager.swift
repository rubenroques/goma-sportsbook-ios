
import Foundation
import DictionaryCoding
import Combine
import UIKit
import GomaLogger

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
        GomaLogger.debug(.realtime, category: "EM_WAMP", "WAMPManager init")
        
        self.swampSession = self.createSwampSession()
        
        self.connect()
    }

    func createSwampSession() -> SSWampSession {
        let wsEndPoint: String
        if let cachedCIDValue = UserDefaults.standard.string(forKey: EveryMatrixUnifiedConfiguration.cacheCIDKey) {
            GomaLogger.debug(.realtime, category: "EM_WAMP", "Cached CID found: \(cachedCIDValue)")
            wsEndPoint = WAMPSocketParams.wsEndPoint + "?cid=" + cachedCIDValue
        }
        else {
            GomaLogger.debug(.realtime, category: "EM_WAMP", "No CID found")
            wsEndPoint = WAMPSocketParams.wsEndPoint
        }

        GomaLogger.debug(.realtime, category: "EM_WAMP", "URL: \(wsEndPoint)")
        GomaLogger.debug(.realtime, category: "EM_WAMP", "Origin: \(WAMPSocketParams.origin)")
        
        guard let websocketHostnameServerURL = URL(string: wsEndPoint) else {
            fatalError("Invalid Webocket URL")
        }
        
        let swampSession = SSWampSession(
            realm: WAMPSocketParams.realm,
            transport: WebSocketSSWampTransport(
                wsEndpoint: websocketHostnameServerURL,
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
        GomaLogger.info(.realtime, category: "EM_WAMP", "WAMPManager connect")
        self.swampSession?.delegate = self
        self.swampSession?.connect()
    }
    
    
    func sessionStateChanged() -> AnyPublisher<Bool, EveryMatrix.APIError> {
        return Future {[self] promise in
            tsQueue.async {
                if self.swampSession != nil {
                    if self.swampSession!.isConnected() {
                        self.swampSession?.subscribe(WAMPRouter.sessionStateChange.procedure, onSuccess: { subscription in
                            GomaLogger.info(.realtime, category: "EM_WAMP", "SessionStateChanged subscribed")
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
                                    GomaLogger.info(.realtime, category: "EM_WAMP", "Session expired")
                                    DispatchQueue.main.async {
                                        NotificationCenter.default.post(name: .userSessionDisconnected, object: nil)
                                    }
                                }
                                else if code == 2 {
                                    GomaLogger.info(.realtime, category: "EM_WAMP", "Session logged off")
                                    DispatchQueue.main.async {
                                        NotificationCenter.default.post(name: .userSessionDisconnected, object: nil)
                                    }
                                }
                                else if code == 3 {
                                    GomaLogger.info(.realtime, category: "EM_WAMP", "Session forced logout (another login)")
                                    DispatchQueue.main.async {
                                        NotificationCenter.default.post(name: .userSessionForcedLogoutDisconnected, object: nil)
                                    }
                                }
                                else if code == 5 {
                                    GomaLogger.info(.realtime, category: "EM_WAMP", "Session forced logout (time limit)")
                                    DispatchQueue.main.async {
                                        NotificationCenter.default.post(name: .userSessionForcedLogoutDisconnected, object: nil)
                                    }
                                }
                                else if code == 6 {
                                    GomaLogger.info(.realtime, category: "EM_WAMP", "Session forced logout (self exclusion)")
                                    DispatchQueue.main.async {
                                        NotificationCenter.default.post(name: .userSessionForcedLogoutDisconnected, object: nil)
                                    }
                                }
                                else if code == 0 {
                                    // TODO: sessionStateChange success handler to be added here - KVO mechanism as above can be used
                                    GomaLogger.info(.realtime, category: "EM_WAMP", "Session logged in")

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
                    GomaLogger.debug(.realtime, category: "EM_WAMP", "getModel initial dump - proc:\(initialDumpProcedure) url:\(router.procedure), args:\(router.args ?? [])")
                }
                else {
                    GomaLogger.debug(.realtime, category: "EM_WAMP", "getModel - url:\(router.procedure), args:\(router.args ?? []), kwargs:\(router.kwargs ?? [:])")
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
                            GomaLogger.error(.realtime, category: "EM_WAMP", "getModel Decoding Error - Type: \(decodingType), Router: \(router.procedure), Error: \(error)")
                            if let decodingError = error as? DecodingError {
                                switch decodingError {
                                case .keyNotFound(let key, let context):
                                    GomaLogger.debug(.realtime, category: "EM_WAMP", "Missing Key: \(key.stringValue), Context: \(context.debugDescription)")
                                case .typeMismatch(let type, let context):
                                    GomaLogger.debug(.realtime, category: "EM_WAMP", "Type Mismatch: Expected \(type), Context: \(context.debugDescription)")
                                case .valueNotFound(let type, let context):
                                    GomaLogger.debug(.realtime, category: "EM_WAMP", "Value Not Found: \(type), Context: \(context.debugDescription)")
                                case .dataCorrupted(let context):
                                    GomaLogger.debug(.realtime, category: "EM_WAMP", "Data Corrupted: \(context.debugDescription)")
                                @unknown default:
                                    break
                                }
                            }
                            if let kwResults = kwResults {
                                GomaLogger.debug(.realtime, category: "EM_WAMP", "Raw kwResults: \(kwResults)")
                            }
                            if let arrResults = arrResults {
                                GomaLogger.debug(.realtime, category: "EM_WAMP", "Raw arrResults: \(arrResults)")
                            }
                            promise(.failure( .decodingError(value: error.localizedDescription) ))
                        }
                    }, onError: { _, error, _, kwargs in
                        GomaLogger.error(.realtime, category: "EM_WAMP", "RPC call ERROR for \(router.procedure): \(error), kwargs: \(kwargs ?? [:])")
                        
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
                                GomaLogger.debug(.realtime, category: "EM_WAMP", "Subscribed to procedure: \(procedure.procedure)")
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

        GomaLogger.debug(.realtime, category: "EM_WAMP", "subscribeEndpoint - url:\(endpoint.procedure), args:\(args)")
        
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
                GomaLogger.error(.realtime, category: "EM_WAMP", "subscribeEndpoint Decoding Error - Type: \(decodingType), Endpoint: \(endpoint.procedure), Error: \(error)")
                if let decodingError = error as? DecodingError {
                    switch decodingError {
                    case .keyNotFound(let key, let context):
                        GomaLogger.debug(.realtime, category: "EM_WAMP", "Missing Key: \(key.stringValue), Context: \(context.debugDescription)")
                    case .typeMismatch(let type, let context):
                        GomaLogger.debug(.realtime, category: "EM_WAMP", "Type Mismatch: Expected \(type), Context: \(context.debugDescription)")
                    case .valueNotFound(let type, let context):
                        GomaLogger.debug(.realtime, category: "EM_WAMP", "Value Not Found: \(type), Context: \(context.debugDescription)")
                    case .dataCorrupted(let context):
                        GomaLogger.debug(.realtime, category: "EM_WAMP", "Data Corrupted: \(context.debugDescription)")
                    @unknown default:
                        break
                    }
                }
                if let kwResults = kwResults {
                    GomaLogger.debug(.realtime, category: "EM_WAMP", "Raw kwResults: \(kwResults)")
                }
                subject.send(completion: .failure(.decodingError(value: error.localizedDescription)))
            }
        })

        return subject.handleEvents(receiveOutput: { content in

        }, receiveCompletion: { completion in
            GomaLogger.debug(.realtime, category: "EM_WAMP", "subscribeEndpoint completion: \(completion)")
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

        GomaLogger.debug(.realtime, category: "EM_WAMP", "unsubscribeFromEndpoint \(endpointPublisherIdentifiable.identificationCode)")

        swampSession.unsubscribe(endpointPublisherIdentifiable.identificationCode) {
            GomaLogger.debug(.realtime, category: "EM_WAMP", "unsubscribeFromEndpoint succeeded")
        } onError: { details, error in
            GomaLogger.error(.realtime, category: "EM_WAMP", "unsubscribeFromEndpoint error: \(details) \(error)")
        }
    }
    
    func registerOnEndpoint<T: Decodable>(_ endpoint: WAMPRouter, decodingType: T.Type) -> AnyPublisher<WAMPSubscriptionContent<T>, EveryMatrix.APIError> {
        
        let subject = PassthroughSubject<WAMPSubscriptionContent<T>, EveryMatrix.APIError>()
        
        guard
            let swampSession = self.swampSession
        else {
            GomaLogger.error(.realtime, category: "EM_WAMP", "No swampSession available for registerOnEndpoint")
            subject.send(completion: .failure(.notConnected))
            return subject.eraseToAnyPublisher()
        }

        guard swampSession.isConnected() else {
            GomaLogger.error(.realtime, category: "EM_WAMP", "SwampSession is not connected for registerOnEndpoint (state: \(swampSession.isConnected()))")
            subject.send(completion: .failure(.notConnected))
            return subject.eraseToAnyPublisher()
        }

        let args: [String: Any] = endpoint.kwargs ?? [:]

        GomaLogger.debug(.realtime, category: "EM_WAMP", "Registering on endpoint - url:\(endpoint.procedure), args:\(args)")
        
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
                        GomaLogger.error(.realtime, category: "EM_WAMP", "registerOnEndpoint Decoding Error - Type: \(decodingType), Endpoint: \(endpoint.procedure), Error: \(error)")
                        if let decodingError = error as? DecodingError {
                            switch decodingError {
                            case .keyNotFound(let key, let context):
                                GomaLogger.debug(.realtime, category: "EM_WAMP", "Missing Key: \(key.stringValue), Context: \(context.debugDescription)")
                            case .typeMismatch(let type, let context):
                                GomaLogger.debug(.realtime, category: "EM_WAMP", "Type Mismatch: Expected \(type), Context: \(context.debugDescription)")
                            case .valueNotFound(let type, let context):
                                GomaLogger.debug(.realtime, category: "EM_WAMP", "Value Not Found: \(type), Context: \(context.debugDescription)")
                            case .dataCorrupted(let context):
                                GomaLogger.debug(.realtime, category: "EM_WAMP", "Data Corrupted: \(context.debugDescription)")
                            @unknown default:
                                break
                            }
                        }
                        if let kwResults = kwResults {
                            GomaLogger.debug(.realtime, category: "EM_WAMP", "Raw kwResults: \(kwResults)")
                        }
                        subject.send(completion: .failure( .decodingError(value: error.localizedDescription) ))
                    }
                })

        return subject.handleEvents(receiveOutput: { content in

        }, receiveCompletion: { completion in
            GomaLogger.debug(.realtime, category: "EM_WAMP", "registerOnEndpoint completion: \(completion)")
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

        GomaLogger.debug(.realtime, category: "EM_WAMP", "unregisterFromEndpoint \(endpointPublisherIdentifiable.identificationCode)")

        swampSession.unregister(endpointPublisherIdentifiable.identificationCode) {
            GomaLogger.debug(.realtime, category: "EM_WAMP", "unregisterFromEndpoint succeeded")
        } onError: { details, error in
            GomaLogger.error(.realtime, category: "EM_WAMP", "unregisterFromEndpoint error: \(details) \(error)")
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
        GomaLogger.info(.realtime, category: "EM_WAMP", "WebSocket connected, establishing WAMP session...")

        NotificationCenter.default.post(name: .socketConnected, object: nil)

        sessionStateChanged()
            .sink(receiveCompletion: { completion in
                GomaLogger.debug(.realtime, category: "EM_WAMP", "sessionStateChanged receiveCompletion: \(completion)")
                switch completion {
                case .failure(let error):
                    GomaLogger.error(.realtime, category: "EM_WAMP", "Failed to establish WAMP session: \(error)")
                case .finished:
                    break
                }
            }, receiveValue: { [weak self] connected in
                GomaLogger.debug(.realtime, category: "EM_WAMP", "sessionStateChanged receiveValue: \(connected)")
                if connected {
                    GomaLogger.info(.realtime, category: "EM_WAMP", "WAMP session ready - emitting .connected state")
                    self?.connectionStateSubject.send(.connected)
                } else {
                    GomaLogger.debug(.realtime, category: "EM_WAMP", "WAMP session not ready")
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

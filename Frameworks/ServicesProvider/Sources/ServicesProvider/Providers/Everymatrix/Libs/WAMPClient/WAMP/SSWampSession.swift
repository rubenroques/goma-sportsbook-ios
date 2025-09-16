//
// //  SSWampSession.swift
//  Tipico
//
//  Created by Andrei Marinescu on 20/12/2019.
//  Copyright © 2019 Tipico. All rights reserved.
//

import Foundation

public typealias CallCallback = (_ details: [String: Any], _ results: [Any]?, _ kwResults: [String: Any]?, _ arrResults: [String: [AnyObject]]?) -> Void
public typealias ErrorCallCallback = (_ details: [String: Any], _ error: String, _ args: [Any]?, _ kwargs: [String: Any]?) -> Void

// public typealias RegisterCallback = (registration: Registration) -> Void
// public typealias ErrorRegisterCallback = (details: [String: AnyObject], error: String) -> Void
// public typealias SSWampProc = (args: [AnyObject]?, kwargs: [String: AnyObject]?) -> AnyObject
// public typealias UnregisterCallback = () -> Void
// public typealias ErrorUnregsiterCallback = (details: [String: AnyObject], error: String) -> Void

public typealias SubscribeCallback = (_ subscription: WAMPSubscription) -> Void
public typealias ErrorSubscribeCallback = (_ details: [String: Any], _ error: String) -> Void
public typealias UnsubscribeCallback = () -> Void
public typealias ErrorUnsubscribeCallback = (_ details: [String: Any], _ error: String) -> Void

public typealias PublishCallback = () -> Void
public typealias ErrorPublishCallback = (_ details: [String: Any], _ error: String) -> Void

public typealias RegisterCallback = (_ registration: WAMPRegistration) -> Void
public typealias ErrorUnregisterCallback = (_ details: [String: Any], _ error: String) -> Void
public typealias ErrorRegisterCallback = (_ details: [String: Any], _ error: String) -> Void
public typealias UnregisterCallback = () -> Void

public typealias EventCallback = (_ details: [String: Any], _ results: [Any]?, _ kwResults: [String: Any]?) -> Void

protocol EndpointPublisherIdentifiable {
    var identificationCode: Int { get }
}

open class WAMPSubscription {
    fileprivate weak var session: SSWampSession?
    internal let subscription: Int
    internal let eventCallback: EventCallback
    fileprivate var isActive: Bool = true

    internal init(session: SSWampSession, subscription: Int, onEvent: @escaping EventCallback) {
        self.session = session
        self.subscription = subscription
        self.eventCallback = onEvent
    }

    internal func invalidate() {
        self.isActive = false
    }

    open func cancel(_ onSuccess: @escaping UnsubscribeCallback, onError: @escaping ErrorUnsubscribeCallback) {
        if !self.isActive {
            onError([:], "Subscription already inactive.")
        }
        self.session?.unsubscribe(self.subscription, onSuccess: onSuccess, onError: onError)
    }
}

extension WAMPSubscription: EndpointPublisherIdentifiable {
    var identificationCode: Int {
        return self.subscription
    }
}

open class WAMPRegistration {
    fileprivate weak var session: SSWampSession?
    internal let registration: Int
    internal let eventCallback: EventCallback
    fileprivate var isActive: Bool = true

    internal init(session: SSWampSession, registration: Int, onEvent: @escaping EventCallback) {
        self.session = session
        self.registration = registration
        self.eventCallback = onEvent
    }

    internal func invalidate() {
        self.isActive = false
    }

    open func cancel(_ onSuccess: @escaping UnregisterCallback, onError: @escaping ErrorUnregisterCallback) {
        if !self.isActive {
            onError([:], "Subscription already inactive.")
        }
        self.session?.unregister(self.registration, onSuccess: onSuccess, onError: onError)
    }
}

extension WAMPRegistration: EndpointPublisherIdentifiable {
    var identificationCode: Int {
        return self.registration
    }
}

// public class Registration {
//    private let session: SSWampSession
// }

public protocol SSWampSessionDelegate: AnyObject {
    func ssWampSessionHandleChallenge(_ authMethod: String, extra: [String: Any]) -> String
    func ssWampSessionConnected(_ session: SSWampSession, sessionId: Int)
    func ssWampSessionEnded(_ reason: String)
}

open class SSWampSession: SSWampTransportDelegate {

    weak var delegate: SSWampSessionDelegate?
    fileprivate let supportedRoles: [SSWampRole] = [.Caller, .Subscriber, .Publisher]
    fileprivate let clientName = "iOSGomaSportsbookApp"
    fileprivate let realm: String
    fileprivate var transport: SSWampTransport
    fileprivate let authmethods: [String]?
    fileprivate let authid: String?
    fileprivate let authrole: String?
    fileprivate let authextra: [String: Any]?
    fileprivate var currRequestId: Int = 1
    fileprivate var serializer: SSWampSerializer?
    fileprivate var sessionId: Int?
    fileprivate var routerSupportedRoles: [SSWampRole]?

    fileprivate var callRequests = ThreadSafeDictionary<Int, (callback: CallCallback, errorCallback: ErrorCallCallback)>()

    fileprivate var subscribeRequests = ThreadSafeDictionary<Int, (callback: SubscribeCallback, errorCallback: ErrorSubscribeCallback, eventCallback: EventCallback)>()
    fileprivate var subscriptions = ThreadSafeDictionary<Int, WAMPSubscription>()
    fileprivate var unsubscribeRequests = ThreadSafeDictionary<Int, (subscription: Int, callback: UnsubscribeCallback, errorCallback: ErrorUnsubscribeCallback)>()

    fileprivate var registerRequests = ThreadSafeDictionary<Int, (callback: RegisterCallback, errorCallback: ErrorRegisterCallback, eventCallback: EventCallback)>()
    fileprivate var registers = ThreadSafeDictionary<Int, WAMPRegistration>()
    fileprivate var unregisterRequests = ThreadSafeDictionary<Int, (subscription: Int, callback: UnregisterCallback, errorCallback: ErrorUnregisterCallback)>()

    fileprivate var publishRequests = ThreadSafeDictionary<Int, (callback: PublishCallback, errorCallback: ErrorPublishCallback)>()
    
    init(realm: String, transport: SSWampTransport, authmethods: [String]?=nil, authid: String?=nil, authrole: String?=nil, authextra: [String: Any]?=nil) {
        self.realm = realm
        self.transport = transport
        self.authmethods = authmethods
        self.authid = authid
        self.authrole = authrole
        self.authextra = authextra
        self.transport.delegate = self
    }

    final public func isConnected() -> Bool {
        return self.sessionId != nil
    }

    public func printMemoryLogs() {
        print("------------- SSWampSession - Memory Logs ------------")
        print("SubscribeRequests \(subscribeRequests.count)" )
        print("Subscriptions \(subscriptions.count)" )
        print("RegisterRequests  \(registerRequests.count)" )
        print("Registers  \(registers.count)" )
        print("------------  ------------  ------------  ------------")

    }

    final public func connect() {
        self.transport.connect()
    }

    final public func disconnect(_ reason: String = "wamp.error.close_realm") {
        self.sendMessage(GoodbyeSSWampMessage(details: [:], reason: reason))
    }

    open func call(_ proc: String, options: [String: Any]=[:], args: [Any]?=nil, kwargs: [String: Any]?=nil, onSuccess: @escaping CallCallback, onError: @escaping ErrorCallCallback) {
        let callRequestId = self.generateRequestId()
        // print("🟦 SSWampSession.call: Starting call to \(proc) with requestId=\(callRequestId)")
        // print("🟦 SSWampSession.call: args=\(args ?? []), kwargs=\(kwargs ?? [:])")
        // print("🟦 SSWampSession.call: sessionId=\(sessionId ?? -1), isConnected=\(isConnected())")
        
        // Tell router to dispatch call
        self.sendMessage(CallSSWampMessage(requestId: callRequestId, options: options, proc: proc, args: args, kwargs: kwargs))
        
        // Store request ID to handle result
        // print("🟦 SSWampSession.call: Storing callbacks for requestId=\(callRequestId)")
        self.callRequests[callRequestId] = (callback: onSuccess, errorCallback: onError )
        // print("🟦 SSWampSession.call: Total pending call requests: \(callRequests.count)")
    }

    // public func register(proc: String, options: [String: AnyObject]=[:], onSuccess: RegisterCallback, onError: ErrorRegisterCallback, onFire: SSWampProc) {
    // }

    open func register(_ topic: String, options: [String: Any]=[:], onSuccess: @escaping RegisterCallback, onError: @escaping ErrorRegisterCallback, onEvent: @escaping EventCallback) {
        // assert topic is a valid WAMP uri
        let registerRequestId = self.generateRequestId()
        // Tell router to subscribe client on a topic
        self.sendMessage(RegisterSSWampMessage.init(requestId: registerRequestId, options: options, proc: topic))
        // Store request ID to handle result
        self.registerRequests[registerRequestId] = (callback: onSuccess, errorCallback: onError, eventCallback: onEvent)
    }

    internal func unregister(_ registration: Int, onSuccess: @escaping UnsubscribeCallback, onError: @escaping ErrorUnsubscribeCallback) {
        let unregisterRequestId = self.generateRequestId()
        // Tell router to unsubscribe me from some subscription
        self.sendMessage(UnregisterSSWampMessage(requestId: unregisterRequestId, registration: registration))
        // Store request ID to handle result
        self.unregisterRequests[unregisterRequestId] = (registration, onSuccess, onError)
    }

    open func subscribe(_ topic: String, options: [String: Any]=[:], onSuccess: @escaping SubscribeCallback, onError: @escaping ErrorSubscribeCallback, onEvent: @escaping EventCallback) {
        // assert topic is a valid WAMP uri
        let subscribeRequestId = self.generateRequestId()
        // Tell router to subscribe client on a topic
        self.sendMessage(SubscribeSSWampMessage(requestId: subscribeRequestId, options: options, topic: topic))
        // Store request ID to handle result
        self.subscribeRequests[subscribeRequestId] = (callback: onSuccess, errorCallback: onError, eventCallback: onEvent)
    }

    internal func unsubscribe(_ subscription: Int, onSuccess: @escaping UnsubscribeCallback, onError: @escaping ErrorUnsubscribeCallback) {
        let unsubscribeRequestId = self.generateRequestId()
        // Tell router to unsubscribe me from some subscription
        self.sendMessage(UnsubscribeSSWampMessage(requestId: unsubscribeRequestId, subscription: subscription))
        // Store request ID to handle result
        self.unsubscribeRequests[unsubscribeRequestId] = (subscription, onSuccess, onError)
    }
    
    // without acknowledging
    open func publish(_ topic: String, options: [String: Any]=[:], args: [Any]?=nil, kwargs: [String: Any]?=nil) {
        // assert topic is a valid WAMP uri
        let publishRequestId = self.generateRequestId()
        // Tell router to publish the event
        self.sendMessage(PublishSSWampMessage(requestId: publishRequestId, options: options, topic: topic, args: args, kwargs: kwargs))
        // We don't need to store the request, because it's unacknowledged anyway
    }

    // with acknowledging
    open func publish(_ topic: String, options: [String: Any]=[:], args: [Any]?=nil, kwargs: [String: Any]?=nil, onSuccess: @escaping PublishCallback, onError: @escaping ErrorPublishCallback) {
        // add acknowledge to options, so we get callbacks
        var options = options
        options["acknowledge"] = true
        // assert topic is a valid WAMP uri
        let publishRequestId = self.generateRequestId()
        // Tell router to publish the event
        self.sendMessage(PublishSSWampMessage(requestId: publishRequestId, options: options, topic: topic, args: args, kwargs: kwargs))
        // Store request ID to handle result
        self.publishRequests[publishRequestId] = (callback: onSuccess, errorCallback: onError)
    }
   
    func ssWampTransportDidDisconnect(_ error: Error?, reason: String?) {
        if reason != nil {
            self.delegate?.ssWampSessionEnded(reason!)
        }
        else if error != nil {
            self.delegate?.ssWampSessionEnded("Unexpected error: \(error!.localizedDescription)")
        }
        else {
            self.delegate?.ssWampSessionEnded("Unknown error.")
        }
    }

    func ssWampTransportDidConnectWithSerializer(_ serializer: SSWampSerializer) {
        self.serializer = serializer

        var roles = [String: Any]()
        for role in self.supportedRoles {
            // For now basic profile, (demands empty dicts)
            roles[role.rawValue] = [:]
        }

        var details: [String: Any] = [:]

        if let authmethods = self.authmethods {
            details["authmethods"] = authmethods
        }
        if let authid = self.authid {
            details["authid"] = authid
        }
        if let authrole = self.authrole {
            details["authrole"] = authrole
        }
        if let authextra = self.authextra {
            details["authextra"] = authextra
        }

        details["agent"] = self.clientName
        details["roles"] = roles
        self.sendMessage(HelloSSWampMessage(realm: self.realm, details: details))
    }

    open func ssWampTransportReceivedData(_ data: Data) {
        if let payload = self.serializer?.unpack(data) {
            if let message = SSWampMessages.createMessage(payload) {
                self.handleMessage(message)
            }
        }
    }
    
    // swiftlint:disable cyclomatic_complexity
    // swiftlint:disable function_body_length
    fileprivate func handleMessage(_ message: SSWampMessage) {
        switch message {
        case let message as ChallengeSSWampMessage:
            if let authResponse = self.delegate?.ssWampSessionHandleChallenge(message.authMethod, extra: message.extra) {
                self.sendMessage(AuthenticateSSWampMessage(signature: authResponse, extra: [:]))
            }
            else {
                print("There was no delegate, aborting.")
                self.abort()
            }
        case let message as WelcomeSSWampMessage:
            self.sessionId = message.sessionId
            let routerRoles = message.details["roles"]! as! [String: [String: Any]]
            self.routerSupportedRoles = routerRoles.keys.map { SSWampRole(rawValue: $0)! }
            self.delegate?.ssWampSessionConnected(self, sessionId: message.sessionId)

        case let message as GoodbyeSSWampMessage:
            if message.reason != "wamp.error.goodbye_and_out" {
                // Means it's not our initiated goodbye, and we should reply with goodbye
                self.sendMessage(GoodbyeSSWampMessage(details: [:], reason: "wamp.error.goodbye_and_out"))
            }
            self.transport.disconnect(message.reason)

        case let message as AbortSSWampMessage:
            self.transport.disconnect(message.reason)

        case let message as ResultSSWampMessage:
            let requestId = message.requestId
            // print("🟩 SSWampSession.handleMessage: Received ResultSSWampMessage for requestId=\(requestId)")
            // print("🟩 SSWampSession.handleMessage: details=\(message.details)")
            // print("🟩 SSWampSession.handleMessage: kwResults=\(message.kwResults ?? [:])")
            
            // TODO: Thread 13: EXC_BAD_ACCESS (code=1, address=0x18)
            if let (callback, _) = self.callRequests[requestId] {
                // print("🟩 SSWampSession.handleMessage: Found callback for requestId=\(requestId), calling success callback")
                callback(message.details, message.results, message.kwResults, message.arrResults)
                self.callRequests[requestId] = nil
                // print("🟩 SSWampSession.handleMessage: Removed requestId=\(requestId) from callRequests")
            }
            else {
                // print("🟩 SSWampSession.handleMessage: ERROR - No callback found for requestId=\(requestId)")
                // print("🟩 SSWampSession.handleMessage: Current callRequests count: \(callRequests.count)")
            }

        case let message as RegisteredSSWampMessage:
            let requestId = message.requestId
            if let (callback, _, eventCallback) = self.registerRequests[requestId] {
                // Notify user and delegate him to unsubscribe this subscription
                let registration = WAMPRegistration(session: self, registration: message.registration, onEvent: eventCallback)
                callback(registration)

                self.registerRequests[requestId] = nil

                // Subscription succeeded, we should store event callback for when it's fired
                self.registers[message.registration] = registration
            }
            else {
                // log this erroneous situation
            }
        case let message as UnregisteredSSWampMessage:
            let requestId = message.requestId
            if let (subscription, callback, _) = self.unregisterRequests[requestId] {
                if let subscriptionIn = self.registers[subscription] {
                    subscriptionIn.invalidate()
                    callback()
                    self.registers[subscription] = nil
                    self.unregisterRequests[requestId] = nil
                }
                else {
                    // log this erroneous situation
                }
            }
            else {
                // log this erroneous situation
            }

        case let message as SubscribedSSWampMessage:
            let requestId = message.requestId
            if let (callback, _, eventCallback) = self.subscribeRequests[requestId] {
                // Notify user and delegate him to unsubscribe this subscription
                let subscription = WAMPSubscription(session: self, subscription: message.subscription, onEvent: eventCallback)
                callback(subscription)

                self.subscribeRequests[requestId] = nil

                // Subscription succeeded, we should store event callback for when it's fired
                self.subscriptions[message.subscription] = subscription
            }
            else {
                // log this erroneous situation
            }

        //
        case let message as EventSSWampMessage:
            if let subscription = self.subscriptions[message.subscription] {
                subscription.eventCallback(message.details, message.args, message.kwargs)
            }
            else {
                // log this erroneous situation
            }

        //
        case let message as UnsubscribedSSWampMessage:
            let requestId = message.requestId
            if let (subscription, callback, _) = self.unsubscribeRequests[requestId] {
                if let subscriptionIn = self.subscriptions[subscription] {
                    subscriptionIn.invalidate()
                    callback()
                    self.unsubscribeRequests[requestId] = nil
                    self.subscriptions[subscription] = nil
                }
                else {
                    // log this erroneous situation
                }
            }
            else {
                // log this erroneous situation
            }
        case let message as PublishedSSWampMessage:
            let requestId = message.requestId
            if let (callback, _) = self.publishRequests[requestId] {
                callback()
                self.publishRequests[requestId] = nil
            }
            else {
                // log this erroneous situation
            }

        //
        case let message as ErrorSSWampMessage:
            switch message.requestType {
            case SSWampMessages.call:
                // print("🟥 SSWampSession.handleMessage: Received ErrorSSWampMessage for CALL requestId=\(message.requestId)")
                // print("🟥 SSWampSession.handleMessage: error=\(message.error)")
                // print("🟥 SSWampSession.handleMessage: details=\(message.details)")
                // print("🟥 SSWampSession.handleMessage: kwargs=\(message.kwargs ?? [:])")
                
                if let (_, errorCallback) = self.callRequests[message.requestId] {
                    // print("🟥 SSWampSession.handleMessage: Found error callback for requestId=\(message.requestId), calling error callback")
                    errorCallback(message.details, message.error, message.args, message.kwargs)
                    self.callRequests[message.requestId] = nil
                    // print("🟥 SSWampSession.handleMessage: Removed requestId=\(message.requestId) from callRequests")
                }
                else {
                    // print("🟥 SSWampSession.handleMessage: ERROR - No error callback found for requestId=\(message.requestId)")
                }
            case SSWampMessages.subscribe:
                if let (_, errorCallback, _) = self.subscribeRequests[message.requestId] {
                    errorCallback(message.details, message.error)
                    self.subscribeRequests[message.requestId] = nil
                }
                else {
                    // log this erroneous situation
                }
            case SSWampMessages.unsubscribe:
                if let (_, _, errorCallback) = self.unsubscribeRequests[message.requestId] {
                    errorCallback(message.details, message.error)
                    self.unsubscribeRequests[message.requestId] = nil
                }
                else {
                    // log this erroneous situation
                }
            case SSWampMessages.publish:
                if let(_, errorCallback) = self.publishRequests[message.requestId] {
                    errorCallback(message.details, message.error)
                    self.publishRequests[message.requestId] = nil
                }
                else {
                    // log this erroneous situation
                }
            default:
                return
            }

        case _ as AuthenticateSSWampMessage:
            ()
            return
        case _ as PublishSSWampMessage:
            ()
            return
        case _ as UnsubscribeSSWampMessage:
            ()
            return
        case _ as SubscribeSSWampMessage:
            ()
            return

        case _ as YieldSSWampMessage:
            ()
            return
        case _ as UnregisterSSWampMessage:
            ()
            return
        case _ as RegisterSSWampMessage:
            ()
            return
        case let message as InvocationSSWampMessage:
            if let registration = self.registers[message.registration] {
                registration.eventCallback(message.details, message.args, message.kwargs)

                let yieldMessage = YieldSSWampMessage(requestId: message.registration, options: [:])
                self.sendMessage(yieldMessage)
            }
            else {
                // log this erroneous situation
                print("InvocationSSWampMessage cannot found a register \(message) ")
            }
            // send YieldSSWampMessage
            return
        case _ as CallSSWampMessage:
            ()
            return
        case _ as HelloSSWampMessage:
            ()
            return
        default:
            print("message default fallback")
            return
        }
    }

    fileprivate func abort() {
        if self.sessionId != nil {
            return
        }
        self.sendMessage(AbortSSWampMessage(details: [:], reason: "wamp.error.system_shutdown"))
        self.transport.disconnect("No challenge delegate found.")
    }

    fileprivate func sendMessage(_ message: SSWampMessage) {
        let marshalledMessage = message.marshal()
        // print("🟨 SSWampSession.sendMessage: Sending message type=\(type(of: message))")
        // print("🟨 SSWampSession.sendMessage: Marshalled=\(marshalledMessage)")
        
        if let data = self.serializer?.pack(marshalledMessage as [Any]) {
            // print("🟨 SSWampSession.sendMessage: Packed data size=\(data.count) bytes")
            self.transport.sendData(data)
            // print("🟨 SSWampSession.sendMessage: Data sent to transport")
        } else {
            // print("🟨 SSWampSession.sendMessage: ERROR - Failed to pack message data")
        }
    }

    fileprivate func generateRequestId() -> Int {
        self.currRequestId += 1
        return self.currRequestId
    }
}

fileprivate class ThreadSafeDictionary<V: Hashable,T>: Collection {
    
    private var dictionary: [V: T]
    private let concurrentQueue = DispatchQueue(label: "Dictionary Barrier Queue",
                                                attributes: .concurrent)
    var startIndex: Dictionary<V, T>.Index {
        self.concurrentQueue.sync {
            return self.dictionary.startIndex
        }
    }

    var endIndex: Dictionary<V, T>.Index {
        self.concurrentQueue.sync {
            return self.dictionary.endIndex
        }
    }

    init(dict: [V: T] = [V:T]()) {
        self.dictionary = dict
    }
    // this is because it is an apple protocol method
    // swiftlint:disable identifier_name
    func index(after i: Dictionary<V, T>.Index) -> Dictionary<V, T>.Index {
        self.concurrentQueue.sync {
            return self.dictionary.index(after: i)
        }
    }
    // swiftlint:enable identifier_name
    subscript(key: V) -> T? {
        set(newValue) {
            self.concurrentQueue.async(flags: .barrier) {[weak self] in
                self?.dictionary[key] = newValue
            }
        }
        get {
            self.concurrentQueue.sync {
                return self.dictionary[key]
            }
        }
    }

    // has implicity get
    subscript(index: Dictionary<V, T>.Index) -> Dictionary<V, T>.Element {
        self.concurrentQueue.sync {
            return self.dictionary[index]
        }
    }
    
    func removeValue(forKey key: V) {
        self.concurrentQueue.async(flags: .barrier) {[weak self] in
            self?.dictionary.removeValue(forKey: key)
        }
    }

    func removeAll() {
        self.concurrentQueue.async(flags: .barrier) {[weak self] in
            self?.dictionary.removeAll()
        }
    }

}

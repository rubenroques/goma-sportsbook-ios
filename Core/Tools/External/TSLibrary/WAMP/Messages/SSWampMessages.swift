//
//  SSWampMessages.swift
//  Tipico
//
//  Created by Andrei Marinescu on 20/12/2019.
//  Copyright © 2019 Tipico. All rights reserved.
//

import Foundation

enum SSWampMessages: Int {

    case hello = 1
    case welcome = 2
    case abort = 3
    case goodbye = 6

    case error = 8

    case publish = 16
    case published = 17
    case subscribe = 32
    case subscribed = 33
    case unsubscribe = 34
    case unsubscribed = 35
    case event = 36

    case call = 48
    case result = 50
    case register = 64
    case registered = 65
    case unregister = 66
    case unregistered = 67
    case invocation = 68
    case yield = 70

    case challenge = 4
    case authenticate = 5

    /// payload consists of all data related to a message, WIHTHOUT the first one - the message identifier
    typealias WampMessageFactory = (_ payload: [Any]) -> SSWampMessage

    // Split into 2 dictionaries because Swift compiler thinks a single one is too complex
    // Perhaps find a better solution in the future

    fileprivate static let mapping1: [SSWampMessages: WampMessageFactory] = [
        SSWampMessages.error: ErrorSSWampMessage.init,

        // Session
        SSWampMessages.hello: HelloSSWampMessage.init,
        SSWampMessages.welcome: WelcomeSSWampMessage.init,
        SSWampMessages.abort: AbortSSWampMessage.init,
        SSWampMessages.goodbye: GoodbyeSSWampMessage.init,

        // Auth
        SSWampMessages.challenge: ChallengeSSWampMessage.init,
        SSWampMessages.authenticate: AuthenticateSSWampMessage.init
    ]

    fileprivate static let mapping2: [SSWampMessages: WampMessageFactory] = [
        // RPC
        SSWampMessages.call: CallSSWampMessage.init,
        SSWampMessages.result: ResultSSWampMessage.init,
        SSWampMessages.register: RegisterSSWampMessage.init,
        SSWampMessages.registered: RegisteredSSWampMessage.init,
        SSWampMessages.invocation: InvocationSSWampMessage.init,
        SSWampMessages.yield: YieldSSWampMessage.init,
        SSWampMessages.unregister: UnregisterSSWampMessage.init,
        SSWampMessages.unregistered: UnregisteredSSWampMessage.init,

        // PubSub
        SSWampMessages.publish: PublishSSWampMessage.init,
        SSWampMessages.published: PublishedSSWampMessage.init,
        SSWampMessages.event: EventSSWampMessage.init,
        SSWampMessages.subscribe: SubscribeSSWampMessage.init,
        SSWampMessages.subscribed: SubscribedSSWampMessage.init,
        SSWampMessages.unsubscribe: UnsubscribeSSWampMessage.init,
        SSWampMessages.unsubscribed: UnsubscribedSSWampMessage.init
    ]

    static func createMessage(_ payload: [Any]) -> SSWampMessage? {
        if let messageType = SSWampMessages(rawValue: payload[0] as! Int) {
            if let messageFactory = mapping1[messageType] {
                return messageFactory(Array(payload[1..<payload.count]))
            }
            if let messageFactory = mapping2[messageType] {
                return messageFactory(Array(payload[1..<payload.count]))
            }
        }
        return nil
    }
}

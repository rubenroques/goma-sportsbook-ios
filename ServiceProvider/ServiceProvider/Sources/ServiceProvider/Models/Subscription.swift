//
//  SubscriptionIdentifier.swift
//  
//
//  Created by Ruben Roques on 11/10/2022.
//

import Foundation

public protocol UnsubscriptionController: AnyObject {
    func unsubscribe(subscription: Subscription)
}

public protocol AnySubscription: Hashable, Equatable, Identifiable {

}

public class Subscription: AnySubscription {
    
    public var id: String
    public var unsubscriptionPayloadData: Data {
        return self.subscriptionData
    }
    
    private let subscriptionData: Data
    private weak var unsubscriber: UnsubscriptionController?
    
    init(contentType: String, contentId: String, token: String, unsubscriber: UnsubscriptionController) {
        
        let bodyString =
        """
        {
            "subscriberId": "\(token)",
            "contentId": {
                "type": "\(contentType)",
                "id": "\(contentId)"
            },
            "clientContext": {
                "language": "\(SportRadarConstants.socketLanguageCode)",
                "ipAddress": "127.0.0.1"
            }
        }
        """
        
        self.id = bodyString.MD5()
        self.subscriptionData = bodyString.data(using: String.Encoding.utf8) ?? Data()
        
        self.unsubscriber = unsubscriber
        
        print("ServerProvider.Subscription.Debug created \(self.id) \(contentType) \(contentId)")
    }
    
    deinit {
        print("ServerProvider.Subscription.Debug dinit \(self.id)")
        unsubscriber?.unsubscribe(subscription: self)
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(subscriptionData)
        hasher.combine(id)
    }
    
    public static func == (lhs: Subscription, rhs: Subscription) -> Bool {
        return lhs.id == rhs.id && lhs.subscriptionData == rhs.subscriptionData
    }
        
}

public class SubscriptionGroup: AnySubscription {

    public var id: String
    private var subscriptions: [Subscription]

    init(id: String) {
        self.id = id
        self.subscriptions = []
    }

    deinit {
        print("ServerProvider.SubscriptionGroup.Debug dinit \(self.id)")
        print("ServerProvider.SubscriptionGroup.Debug subscription init will be called too")
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(subscriptions)
        hasher.combine(id)
    }

    public static func == (lhs: SubscriptionGroup, rhs: SubscriptionGroup) -> Bool {
        return lhs.id == rhs.id && lhs.subscriptions == rhs.subscriptions
    }

}

public class TopicIdentifier: Codable, Hashable, Equatable, Identifiable {
    
    public let id: String
    
    private var contentType: String
    private var contentId: String
    
    enum CodingKeys: String, CodingKey {
        case contentType = "type"
        case contentId = "id"
    }
    
    public required init(contentType: String, contentId: String) {
        self.contentType = contentType
        self.contentId = contentId
        
        self.id = "\(contentType)-\(contentId)".MD5()
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        let contentId = try container.decode(String.self, forKey: .contentId)
        let contentType = try container.decode(String.self, forKey: .contentType)
        
        self.contentType = contentType
        self.contentId = contentId
        
        self.id = "\(contentType)-\(contentId)".MD5()
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    public static func == (lhs: TopicIdentifier, rhs: TopicIdentifier) -> Bool {
        return lhs.id == rhs.id
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.contentType, forKey: .contentType)
        try container.encode(self.contentId, forKey: .contentId)
    }
    
}

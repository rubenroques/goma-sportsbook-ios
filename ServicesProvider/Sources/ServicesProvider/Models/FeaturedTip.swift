//
//  FeaturedTip.swift
//  ServicesProvider
//
//  Created by Ruben Roques on 19/02/2025.
//

import Foundation

public typealias FeaturedTips = [FeaturedTip]

public struct FeaturedTip {
    public var id: String
    
    public var stake: Double
    public var odd: Double
    
    public var status: String
    public var type: String
    
    public var selections: [FeaturedTipSelection]
    public var user: FeaturedTipUser

    public init(id: String,
     stake: Double,
     odd: Double,
     status: String,
     type: String,
     selections: [FeaturedTipSelection],
     user: FeaturedTipUser) {
        self.id = id
        self.stake = stake
        self.odd = odd
        self.status = status
        self.type = type
        self.selections = selections
        self.user = user
    }
}

public struct FeaturedTipSelection {
    
    public var id: String
    public var marketId: String
    public var outcomeId: String
    public var marketName: String
    public var outcomeName: String
    public var odd: Double
    public var event: Event
    
}

public struct FeaturedTipUser {
    
    public var id: String
    public var name: String?
    public var code: String?
    public var avatar: String?

    public init(id: String, name: String?, code: String?, avatar: String?) {
        self.id = id
        self.name = name
        self.code = code
        self.avatar = avatar
    }
}

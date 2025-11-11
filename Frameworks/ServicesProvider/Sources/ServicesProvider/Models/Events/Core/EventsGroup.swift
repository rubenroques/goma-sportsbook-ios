//
//  EventsGroup.swift
//
//
//  Created by Ruben Roques on 11/10/2022.
//

import Foundation

public class EventsGroup {
    public var events: Events
    public var marketGroupId: String?
    public var title: String?
    public var mainMarkets: [MainMarket]?

    public init(events: Events, marketGroupId: String?, title: String? = nil, mainMarkets: [MainMarket]? = nil) {
        self.events = events
        self.marketGroupId = marketGroupId
        self.title = title
        self.mainMarkets = mainMarkets
    }
}

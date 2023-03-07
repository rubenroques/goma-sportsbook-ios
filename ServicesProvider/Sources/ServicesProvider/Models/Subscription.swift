//
//  SubscriptionIdentifier.swift
//  
//
//  Created by Ruben Roques on 11/10/2022.
//

import Foundation
import Extensions

public protocol UnsubscriptionController: AnyObject {
    func unsubscribe(subscription: Subscription)
}

public class Subscription: Hashable, Identifiable {
    
    public var id: String

    public var contentIdentifier: ContentIdentifier
    public var sessionToken: String

    var associatedSubscriptions: [Subscription] = []
    private weak var unsubscriber: UnsubscriptionController?

    init(contentIdentifier: ContentIdentifier, sessionToken: String, unsubscriber: UnsubscriptionController) {
        self.contentIdentifier = contentIdentifier
        self.sessionToken = sessionToken
        self.id = contentIdentifier.id
        self.unsubscriber = unsubscriber
    }

    init(contentType: ContentType, contentRoute: ContentRoute, sessionToken: String, unsubscriber: UnsubscriptionController) {

        self.contentIdentifier = ContentIdentifier(contentType: contentType, contentRoute: contentRoute)
        self.id = self.contentIdentifier.id
        self.sessionToken = sessionToken
        self.unsubscriber = unsubscriber
    }
    
    deinit {
        print("ServiceProvider.Subscription.Debug dinit \(self)")
        unsubscriber?.unsubscribe(subscription: self)
    }

    @discardableResult
    func associateSubscription(_ subscription: Subscription) -> Bool {
        if self.contentIdentifier.pageableId != subscription.contentIdentifier.pageableId {
            return false
        }
        self.associatedSubscriptions.append(subscription)
        return true
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(contentIdentifier)
    }
    
    public static func == (lhs: Subscription, rhs: Subscription) -> Bool {
        return lhs.id == rhs.id && lhs.contentIdentifier == rhs.contentIdentifier
    }
        
}


extension Subscription: CustomStringConvertible {
    public var description: String {
        return "Subscription: \(self.id) \(self.contentIdentifier)"
    }
}

public enum ContentType: String, Codable {
    case liveEvents = "liveDataSummaryAdvancedListBySportType"
    case preLiveEvents = "eventListBySportTypeDate"

    case liveSports = "inplaySportListBySportType"
    case preLiveSports = "sportTypeByDate"

    case eventDetails = "event"
    case eventGroup = "eventGroup"
    case eventSummary = "eventSummary"

    case market = "market"
}

public enum ContentRoute {

    case liveEvents(sportAlphaId: String, pageIndex: Int)
    case preLiveEvents(sportAlphaId: String, startDate: Date?, endDate: Date?, pageIndex: Int, eventCount: Int, sortType: EventListSort)

    case liveSports
    case preLiveSports(startDate: Date?, endDate: Date?)

    case eventDetails(eventId: String)
    case eventGroup(marketGroupId: String)
    case eventSummary(eventId: String)

    case market(marketId: String)

    var fullRoute: String {
        switch self {
        case .liveEvents(let sportAlphaId, let pageIndex):
            return "\(sportAlphaId)/\(pageIndex)"
        case .preLiveEvents(let sportAlphaId, let startDate, let endDate, let pageIndex, let eventCount, let sortType):
            let dateRange = ContentDateFormatter.getDateRangeId(startDate: startDate, endDate: endDate)
            return "\(sportAlphaId)/\(dateRange)/\(pageIndex)/\(eventCount)/\(sortType.rawValue)"

        case .liveSports:
            return ""
        case .preLiveSports(let startDate, let endDate):
            let dateRange = ContentDateFormatter.getDateRangeId(startDate: startDate, endDate: endDate)
            return dateRange

        case .eventDetails(let eventId):
            return eventId
        case .eventGroup(let marketGroupId):
            return marketGroupId
        case .eventSummary(let eventId):
            return eventId
        case .market(let marketId):
            return marketId
        }
    }

    var pageableRoute: String {
        switch self {
        case .liveEvents(let sportAlphaId, _):
            return sportAlphaId
        case .preLiveEvents(let sportAlphaId, let startDate, let endDate, _, let eventCount, let sortType):
            let dateRange = ContentDateFormatter.getDateRangeId(startDate: startDate, endDate: endDate)
            return "\(sportAlphaId)/\(dateRange)/\(eventCount)/\(sortType.rawValue)"
        case .liveSports:
            return ""
        case .preLiveSports:
            return ""
        case .eventDetails(let eventId):
            return eventId
        case .eventGroup(let marketGroupId):
            return marketGroupId
        case .eventSummary(let eventId):
            return eventId
        case .market(let marketId):
            return marketId
        }
    }

    var eventCount: Int? {
        switch self {
        case .liveEvents(_, _):
            return nil
        case .preLiveEvents(_, _, _, _, let eventCount, _):
            return eventCount
        case .liveSports:
            return nil
        case .preLiveSports:
            return nil
        case .eventDetails:
            return nil
        case .eventGroup:
            return nil
        case .eventSummary:
            return nil
        case .market:
            return nil
        }
    }
}

public class ContentIdentifier: Decodable, Hashable, Equatable, Identifiable {
    
    public let id: String

    public let pageableId: String

    public var contentType: ContentType
    public var contentRoute: ContentRoute

    public var pageableRoute: String {
        self.contentRoute.pageableRoute
    }

    enum CodingKeys: String, CodingKey {
        case contentType = "type"
        case contentRoute = "id"
    }
    
    public required init(contentType: ContentType,
                         contentRoute: ContentRoute) {
        self.contentType = contentType
        self.contentRoute = contentRoute
        
        self.id = "\(contentType.rawValue)-\(contentRoute.fullRoute)".MD5()
        self.pageableId = "\(contentType.rawValue)-\(contentRoute.pageableRoute)".MD5()
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        let contentType = try container.decode(ContentType.self, forKey: .contentType)
        self.contentType = contentType
        let contentRouteRawString = try container.decode(String.self, forKey: .contentRoute)
        let contentRouteRawParts = contentRouteRawString.components(separatedBy: "/")

        switch contentType {
        case .liveEvents:
            guard
                let sportId = contentRouteRawParts[safe: 0],
                let pageIndex = Int(contentRouteRawParts[safe: 1] ?? "")
            else {
                let context = DecodingError.Context(codingPath: [CodingKeys.contentRoute], debugDescription: "Not a valid contentRoute path")
                throw DecodingError.valueNotFound(ContentRoute.self, context)
            }
            self.contentRoute = ContentRoute.liveEvents(sportAlphaId: sportId, pageIndex: pageIndex)

        case .preLiveEvents:
            guard
                let sportId = contentRouteRawParts[safe: 0],
                let pageIndex = Int(contentRouteRawParts[safe: 3] ?? ""),
                let eventCount = Int(contentRouteRawParts[safe: 4] ?? ""),
                let sortTypeString = contentRouteRawParts[safe: 5],
                let sortType = EventListSort(rawValue: sortTypeString)
            else {
                let context = DecodingError.Context(codingPath: [CodingKeys.contentRoute], debugDescription: "Not a valid contentRoute path")
                throw DecodingError.valueNotFound(ContentRoute.self, context)
            }

            let startDateString = contentRouteRawParts[safe: 1] ?? ""
            let startDate = ContentDateFormatter.dateFromString(dateString: startDateString)
            let endDateString = contentRouteRawParts[safe: 2] ?? ""
            let endDate = ContentDateFormatter.dateFromString(dateString: endDateString)

            self.contentRoute = ContentRoute.preLiveEvents(sportAlphaId: sportId,
                                                           startDate: startDate,
                                                           endDate: endDate,
                                                           pageIndex: pageIndex,
                                                           eventCount: eventCount,
                                                           sortType: sortType)
        case .liveSports:
            self.contentRoute = ContentRoute.liveSports
        case .preLiveSports:
            let startDateString = contentRouteRawParts[safe: 0] ?? ""
            let startDate = ContentDateFormatter.dateFromString(dateString: startDateString)
            let endDateString = contentRouteRawParts[safe: 1] ?? ""
            let endDate = ContentDateFormatter.dateFromString(dateString: endDateString)

            self.contentRoute = ContentRoute.preLiveSports(startDate: startDate, endDate: endDate)

        case .eventDetails:
            self.contentRoute = ContentRoute.eventDetails(eventId: contentRouteRawString)
        case .eventGroup:
            self.contentRoute = ContentRoute.eventGroup(marketGroupId: contentRouteRawString)
        case .eventSummary:
            self.contentRoute = ContentRoute.eventSummary(eventId: contentRouteRawString)
        case .market:
            self.contentRoute = ContentRoute.market(marketId: contentRouteRawString)
        }

        self.id = "\(contentType)-\(contentRoute.fullRoute)".MD5()
        self.pageableId = "\(contentType.rawValue)-\(contentRoute.pageableRoute)".MD5()
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(pageableId)
    }
    
    public static func == (lhs: ContentIdentifier, rhs: ContentIdentifier) -> Bool {
        return lhs.id == rhs.id && lhs.pageableId == rhs.pageableId
    }

}

extension ContentIdentifier: CustomStringConvertible {
    public var description: String {
        return "[\(self.contentType.rawValue)] \(self.contentRoute.fullRoute)"
    }
}

struct ContentDateFormatter {

    static func getDateRangeId(startDate: Date? = nil, endDate: Date? = nil) -> String {
        // TODO: Re-check dates with hour and minute after confirmation with SportRadar
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd"

        let startDateDefault: Date = startDate ?? Date()
        let endDateDefault: Date = endDate ?? Calendar.current.date(byAdding: .day, value: 365, to: startDateDefault) ?? Date()

        let startDateId = dateFormatter.string(from: startDateDefault)
        let endDateId = dateFormatter.string(from: endDateDefault)

        let dateRangeId = "\(startDateId)0000/\(endDateId)2359"

        return dateRangeId
    }

    static func dateFromString(dateString: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMddHHmm"
        return dateFormatter.date(from: dateString)
    }

}

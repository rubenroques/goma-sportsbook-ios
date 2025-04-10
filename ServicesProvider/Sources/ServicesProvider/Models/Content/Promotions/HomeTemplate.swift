//
//  HomeTemplate.swift
//
//
//  Created on: May 15, 2024
//

import Foundation

public struct HomeTemplate: Codable, Equatable, Hashable {
    public let id: String
    public let type: String
    public let widgets: [HomeWidget]

    public init(id: String, type: String, widgets: [HomeWidget]) {
        self.id = id
        self.type = type
        self.widgets = widgets
    }

}

public enum HomeWidget: Codable, Equatable, Hashable {
    case alertBanners(WidgetData)
    case banners(WidgetData)
    case carouselEvents(WidgetData)
    case stories(WidgetData)
    case heroCardEvents(WidgetData)
    case highlightedLiveEvents(WidgetData)
    case betSwipe(WidgetData)
    case highlightedEvents(WidgetData)
    case boostedEvents(WidgetData)
    case proChoices(WidgetData)
    case topCompetitions(WidgetData)
    case suggestedBets(WidgetData)
    case popularEvents(WidgetData)
    case favorites(WidgetData)
    case featuredTips(WidgetData)
    case news(WidgetData)

    public init?(id: String,
                 type: String,
                 description: String,
                 userState: String,
                 sortOrder: Int,
                 orientation: String?) {

        let widgetData = WidgetData.init(id: id,
                                         type: type,
                                         description: description,
                                         userState: userState,
                                         sortOrder: sortOrder,
                                         orientation: orientation)


        // Use the actual widget names from the API
        switch type.lowercased() {
        case "alertbanners":
            self = .alertBanners(widgetData)
        case "banners":
            self = .banners(widgetData)
        case "carouselevents":
            self = .carouselEvents(widgetData)
        case "stories":
            self = .stories(widgetData)
        case "herocardevents":
            self = .heroCardEvents(widgetData)
        case "highlightedliveevents":
            self = .highlightedLiveEvents(widgetData)
        case "betswipe":
            self = .betSwipe(widgetData)
        case "highlightedevents":
            self = .highlightedEvents(widgetData)
        case "boostedevents":
            self = .boostedEvents(widgetData)
        case "prochoices":
            self = .proChoices(widgetData)
        case "topcompetitions":
            self = .topCompetitions(widgetData)
        case "suggestedbets":
            self = .suggestedBets(widgetData)
        case "popularevents":
            self = .popularEvents(widgetData)
        case "favorites":
            self = .favorites(widgetData)
        case "featuredtips":
            self = .featuredTips(widgetData)
        case "news":
            self = .news(widgetData)
        default:
            return nil
        }

    }

    public struct WidgetData: Codable, Equatable, Hashable {
        public let id: String
        public let type: String
        public let description: String
        public let userState: UserState
        public let sortOrder: Int
        public let orientation: Orientation?

        public enum Orientation: String, Codable, Equatable, Hashable {
            case horizontal
            case vertical
            case notSupported
        }

        public enum UserState: String, Codable, Equatable, Hashable {
            case authenticated
            case anonymous
            case any
        }

        init(id: String,
             type: String,
             description: String,
             userState: String,
             sortOrder: Int,
             orientation: String?) {

            let userStateEnum: WidgetData.UserState
            switch userState {
            case "authenticated": userStateEnum = .authenticated
            case "anonymous": userStateEnum = .anonymous
            default: userStateEnum = .any
            }

            var orientationEnum: WidgetData.Orientation? = nil
            if let orientationStr = orientation {
                orientationEnum = WidgetData.Orientation(rawValue: orientationStr)
            }

            self.id = id
            self.type = type
            self.description = description
            self.sortOrder = sortOrder
            self.userState = userStateEnum
            self.orientation = orientationEnum
        }
    }

    // Properties that access the associated value
    public var widgetData: WidgetData {
        switch self {
        case .alertBanners(let data),
                .banners(let data),
                .carouselEvents(let data),
                .stories(let data),
                .heroCardEvents(let data),
                .highlightedLiveEvents(let data),
                .betSwipe(let data),
                .highlightedEvents(let data),
                .boostedEvents(let data),
                .proChoices(let data),
                .topCompetitions(let data),
                .suggestedBets(let data),
                .popularEvents(let data),
                .favorites(let data),
                .featuredTips(let data),
                .news(let data):
            return data
        }
    }

    // Convenience accessors
    public var id: String { return widgetData.id }
    public var type: String { return widgetData.type }
    public var description: String { return widgetData.description }
    public var userType: WidgetData.UserState { return widgetData.userState }
    public var sortOrder: Int { return widgetData.sortOrder }
    public var orientation: WidgetData.Orientation? { return widgetData.orientation }

}

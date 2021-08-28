//
//  AnalyticsClient.swift
//  Sportsbook
//
//  Created by Ruben Roques on 29/07/2021.
//

import Foundation
import FirebaseAnalytics

struct AnalyticsClient {

    enum Event {
        case login
        case logout
    }

    static func logEvent(event: Event) {

        var eventTypeKey = ""
        var parameters: [String: String]?

        switch event {
        case .login:
            eventTypeKey = AnalyticsEventLogin
            parameters = ["login_method": "Email"]
        case .logout:
            eventTypeKey = "logout"
        }

        Analytics.logEvent(eventTypeKey, parameters: parameters)
    }
}

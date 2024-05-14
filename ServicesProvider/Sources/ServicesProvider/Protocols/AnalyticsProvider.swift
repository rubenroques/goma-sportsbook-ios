//
//  File.swift
//  
//
//  Created by Ruben Roques on 14/05/2024.
//

import Foundation

protocol AnalyticsEvent {
    var type: String { get }
    var data: [String: Any]? { get }
}

protocol AnalyticsProvider {
    func trackEvent(_ event: AnalyticsEvent, userIdentifer: String?)
}

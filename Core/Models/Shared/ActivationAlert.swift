//
//  ActivationAlertData.swift
//  Sportsbook
//
//  Created by André Lascas on 17/11/2021.
//

import Foundation

struct ActivationAlert {
    var title: String
    var description: String
    var linkLabel: String
    var alertType: ActivationAlertType
    var ctaUrl: String?  // Add optional ctaUrl for server alerts
}

enum ActivationAlertType {
    case email
    case profile
    case documents
    case server  // New case for server-side alerts
}

typealias HomeAlerts = [HomeAlert]

struct HomeAlert {
    var title: String?
    var subtitle: String?
    var ctaText: String?
    var ctaLink: String?
}

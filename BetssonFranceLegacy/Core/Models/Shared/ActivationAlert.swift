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
}

enum ActivationAlertType {
    case email
    case profile
    case documents
}

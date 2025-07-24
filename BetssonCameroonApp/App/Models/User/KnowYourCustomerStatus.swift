//
//  KnowYourCustomerStatus.swift
//  BetssonCameroonApp
//
//  Created by Ruben Roques on 22/07/2025.
//

import Foundation

enum KnowYourCustomerStatus: String, Codable, Hashable {
    case request
    case passConditional
    case pass

    var statusName: String {
        switch self {
        case .request: return localized("pending")
        case .passConditional: return localized("pre_validated")
        case .pass: return localized("validated")

        }
    }
}

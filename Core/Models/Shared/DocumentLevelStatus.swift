//
//  DocumentLevelStatus.swift
//  Sportsbook
//
//  Created by André Lascas on 20/09/2023.
//

import Foundation

struct CurrentDocumentLevelStatus {
    var status: DocumentStatus
    var levelName: DocumentLevelName
}

enum DocumentStatus {
    case completed
    case pending
    case rejected
    case initial
    case none

    init(status: String, result: String? = nil) {

        switch status {
        case "completed":
            if let result {
                if result == "GREEN" {
                    self = .completed
                }
                else {
                    self = .rejected
                }
            }
            else {
                self = .completed
            }
        case "rejected":
            self = .rejected
        case "pending":
            self = .pending
        case "init":
            self = .initial
        default:
            self = .none
        }

    }
}

enum DocumentLevelName {
    case identificationLevel
    case poaLevel
    case none

    init(levelName: String) {

        switch levelName {
        case "kyc-level-1-id-verification", "kyc-level-1-id-verification-UAT":
            self = .identificationLevel
        case "kyc-level-2-poa-verification", "kyc-level-2-poa-verification-UAT":
            self = .poaLevel
        default:
            self = .none
        }

    }
}

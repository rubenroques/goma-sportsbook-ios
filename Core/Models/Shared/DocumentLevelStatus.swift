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
    case none

    init(status: String) {

        switch status {
        case "completed":
            self = .completed
        case "rejected":
            self = .rejected
        case "pending":
            self = .pending
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
        case "kyc-level-1-id-verification":
            self = .identificationLevel
        case "kyc-level-2-poa-verification":
            self = .poaLevel
        default:
            self = .none
        }

    }
}

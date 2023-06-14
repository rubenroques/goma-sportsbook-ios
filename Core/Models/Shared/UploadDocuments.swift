//
//  UploadDocuments.swift
//  Sportsbook
//
//  Created by André Lascas on 25/01/2023.
//

import Foundation

struct DocumentInfo {
    var id: String
    var typeName: String
    var status: DocumentState
    var uploadedFiles: [DocumentFileInfo]
    var typeGroup: DocumentTypeGroup?
}

struct DocumentFileInfo {
    var id: String
    var name: String
    var status: FileState
    var uploadDate: Date?
    var retry: Bool?
    var documentTypeGroup: DocumentTypeGroup
}

enum FileState {
    case pendingApproved
    case approved
    case failed
    case rejected
    case incomplete

    init?(code: String) {

        if code == "NOT_REVIEWED" {
            self = .pendingApproved
        }
        else if code == "APPROVED" {
            self = .approved
        }
        else {
            self = .failed
        }
    }

    var statusName: String {
        switch self {
        case .pendingApproved:
            return localized("pending_approval")
        case .approved:
            return localized("approved")
        case .failed:
            return localized("failed")
        case .rejected:
            return localized("rejected")
        case .incomplete:
            return localized("incomplete")
        }
    }
}

enum DocumentTypeCode {
    case identification
    case proofAddress
    case ibanProof
    case others

    init?(code: String) {

        if code == "IDENTITY_CARD" {
            self = .identification
        }
        else if code == "POA" {
            self = .proofAddress
        }
        else if code == "RIB" {
            self = .ibanProof
        }
        else if code == "OTHERS" {
            self = .others
        }
        else {
            return nil
        }
    }

    var codeName: String {
        switch self {
        case .identification:
            return localized("identification")
        case .proofAddress:
            return localized("proof_of_address")
        case .ibanProof:
            return localized("iban_proof")
        case .others:
            return localized("others")
        }
    }
}

enum DocumentUploadState {
    case preUpload
    case uploading
    case uploaded
    case documentReceived
    case addAnother
}

enum DocumentTypeGroup {
    case identityCard
    case passport
    case drivingLicense
    case residenceId
    case proofAddress
    case rib
    case other
    case none

    init?(externalCode: String) {
        if externalCode == "ID_CARD" {
            self = .identityCard
        }
        else if externalCode == "RESIDENCE_PERMIT" {
            self = .residenceId
        }
        else if externalCode == "DRIVERS" {
            self = .drivingLicense
        }
        else if externalCode == "PASSPORT" {
            self = .passport
        }
        else if externalCode == "UTILITY_BILL" {
            self = .proofAddress
        }
        else if externalCode == "RIB" {
            self = .rib
        }
        else {
            return nil
        }
    }

    var code: String {
        switch self {
        case .identityCard:
            return "IDENTITY_CARD"
        case .residenceId:
            return "RESIDENCE_ID"
        case .drivingLicense:
            return "DRIVING_LICENCE"
        case .passport:
            return "PASSPORT"
        case .proofAddress:
            return "POA"
        case .rib:
            return "RIB"
        case .other:
            return "OTHERS"
        default:
            return ""
        }
    }

    var codeName: String {
        switch self {
        case .identityCard:
            return localized("identity_card")
        case .residenceId:
            return localized("residence_id")
        case .drivingLicense:
            return localized("driving_licence")
        case .passport:
            return localized("passport")
        case .proofAddress:
            return localized("utility_bill")
        case .rib:
            return localized("rib")
        case .other:
            return "others"
        case .none:
            return "none"
        }
    }
    var levelName: String {
        switch self {
        case .identityCard:
            return "ID Verifiication"
        case .residenceId:
            return "ID Verifiication"
        case .drivingLicense:
            return "ID Verifiication"
        case .passport:
            return "ID Verifiication"
        case .proofAddress:
            return "POA Verification"
        case .rib:
            return "RIB Verification"
        case .other:
            return "Others Verification"
        case .none:
            return ""
        }
    }
}

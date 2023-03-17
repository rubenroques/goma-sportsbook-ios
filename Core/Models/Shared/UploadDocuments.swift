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
}

struct DocumentFileInfo {
    var id: String
    var name: String
    var status: FileState
}

enum FileState {
    case pendingApproved
    case approved
    case failed

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
        }
    }
}

enum DocumentTypeCode {
    case identification
    case proofAddress
    case ibanProof

    init?(code: String) {

        if code == "IDENTITY_CARD" {
            self = .identification
        }
        else if code == "OTHERS" {
            self = .proofAddress
        }
        else if code == "RIB" {
            self = .ibanProof
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

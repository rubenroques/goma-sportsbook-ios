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
        else if code == "REVIEWED" {
            self = .approved
        }
        else {
            self = .failed
        }
    }

    var statusName: String {
        switch self {
        case .pendingApproved:
            return "Pending Approved"
        case .approved:
            return "Approved"
        case .failed:
            return "Failed"
        }
    }
}

enum DocumentTypeCode {
    case identification
    case proofAddress

    init?(code: String) {

        if code == "IDENTITY_CARD" {
            self = .identification
        }
        else if code == "Utility Bill " {
            self = .proofAddress
        }
        else {
            return nil
        }
    }

    var codeName: String {
        switch self {
        case .identification:
            return "Identification"
        case .proofAddress:
            return "Proof of address"
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

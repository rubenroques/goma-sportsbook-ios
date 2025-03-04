//
//  File.swift
//  
//
//  Created by André Lascas on 12/06/2023.
//

import Foundation

public struct ApplicantDataResponse: Codable {
    public var externalUserId: String?
    public var info: ApplicantDataInfo?
    public var reviewData: ApplicantReviewData?
    public var description: String?

    enum CodingKeys: String, CodingKey {
        case externalUserId = "externalUserId"
        case info = "info"
        case reviewData = "review"
        case description = "description"
    }
}

public struct ApplicantDataInfo: Codable {
    public var applicantDocs: [ApplicantDoc]?

    enum CodingKeys: String, CodingKey {
        case applicantDocs = "idDocs"
    }
}

public struct ApplicantDoc: Codable {
    public var docType: String

    enum CodingKeys: String, CodingKey {
        case docType = "idDocType"
    }

}

public struct ApplicantReviewData: Codable {
    public var attemptCount: Int
    public var createDate: String
    public var reviewDate: String?
    public var reviewResult: ApplicantReviewResult?
    public var reviewStatus: String
    public var levelName: String

    enum CodingKeys: String, CodingKey {
        case attemptCount = "attemptCnt"
        case createDate = "createDate"
        case reviewDate = "reviewDate"
        case reviewResult = "reviewResult"
        case reviewStatus = "reviewStatus"
        case levelName = "levelName"
    }
}

public struct ApplicantReviewResult: Codable {
    public var reviewAnswer: String
    public var reviewRejectType: String?
    public var moderationComment: String?

    enum CodingKeys: String, CodingKey {
        case reviewAnswer = "reviewAnswer"
        case reviewRejectType = "reviewRejectType"
        case moderationComment = "moderationComment"
    }
}

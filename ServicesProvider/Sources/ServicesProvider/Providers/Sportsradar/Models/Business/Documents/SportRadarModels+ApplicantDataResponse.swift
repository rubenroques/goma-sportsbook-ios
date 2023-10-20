//
//  SportRadarModels+ApplicantDataResponse.swift
//  
//
//  Created by André Lascas on 12/06/2023.
//

import Foundation

extension SportRadarModels {

    struct ApplicantRootResponse: Codable {
        var status: String
        var message: String?
        var data: ApplicantDataResponse

        enum CodingKeys: String, CodingKey {
            case status = "status"
            case message = "message"
            case data = "data"
        }
    }

    struct ApplicantDataResponse: Codable {
        var externalUserId: String?
        var info: ApplicantDataInfo?
        var reviewData: ApplicantReviewData?
        var description: String?

        enum CodingKeys: String, CodingKey {
            case externalUserId = "externalUserId"
            case info = "info"
            case reviewData = "review"
            case description = "description"
        }
    }

    struct ApplicantDataInfo: Codable {
        var applicantDocs: [ApplicantDoc]?

        enum CodingKeys: String, CodingKey {
            case applicantDocs = "idDocs"
        }
    }

    struct ApplicantDoc: Codable {
        var docType: String

        enum CodingKeys: String, CodingKey {
            case docType = "idDocType"
        }

    }

    struct ApplicantReviewData: Codable {
        var attemptCount: Int
        var createDate: String
        var reviewDate: String?
        var reviewResult: ApplicantReviewResult?
        var reviewStatus: String
        var levelName: String

        enum CodingKeys: String, CodingKey {
            case attemptCount = "attemptCnt"
            case createDate = "createDate"
            case reviewDate = "reviewDate"
            case reviewResult = "reviewResult"
            case reviewStatus = "reviewStatus"
            case levelName = "levelName"
        }
    }

    struct ApplicantReviewResult: Codable {
        var reviewAnswer: String
        var reviewRejectType: String?
        var moderationComment: String?

        enum CodingKeys: String, CodingKey {
            case reviewAnswer = "reviewAnswer"
            case reviewRejectType = "reviewRejectType"
            case moderationComment = "moderationComment"
        }
    }


}

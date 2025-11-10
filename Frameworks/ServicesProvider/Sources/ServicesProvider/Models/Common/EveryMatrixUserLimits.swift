//
//  EveryMatrixUserLimits.swift
//  ServicesProvider
//
//  Created by Claude on 07/11/2025.
//

import Foundation

public struct UserLimitsResponse: Codable {
    public let limits: [UserLimit]
}

public struct UserLimit: Codable {
    public let id: String
    public let playerId: String
    public let domainId: String
    public let amount: Double
    public let currency: String
    public let period: String
    public let type: String
    public let products: [String]
    public let walletTypes: [String]
}

public struct UserLimitRequest: Encodable {
    public let amount: Double
    public let currency: String
    public let period: String
    public let type: String
    public let products: [String]
    public let walletTypes: [String]

    public init(amount: Double,
                currency: String,
                period: String,
                type: String,
                products: [String],
                walletTypes: [String]) {
        self.amount = amount
        self.currency = currency
        self.period = period
        self.type = type
        self.products = products
        self.walletTypes = walletTypes
    }
}

public struct UserTimeoutRequest: Encodable {
    public let coolOff: CoolOffPayload

    public struct CoolOffPayload: Encodable {
        public let period: String
        public let coolOffReason: String
        public let coolOffDescription: String
        public let unsatisfiedReason: String
        public let unsatisfiedDescription: String
        public let sendNotificationEmail: Bool

        public init(period: String,
                    coolOffReason: String,
                    coolOffDescription: String,
                    unsatisfiedReason: String,
                    unsatisfiedDescription: String,
                    sendNotificationEmail: Bool) {
            self.period = period
            self.coolOffReason = coolOffReason
            self.coolOffDescription = coolOffDescription
            self.unsatisfiedReason = unsatisfiedReason
            self.unsatisfiedDescription = unsatisfiedDescription
            self.sendNotificationEmail = sendNotificationEmail
        }
    }

    public init(coolOff: CoolOffPayload) {
        self.coolOff = coolOff
    }
}

public struct SelfExclusionRequest: Encodable {
    public let selfExclusion: SelfExclusionPayload

    public struct SelfExclusionPayload: Encodable {
        public let period: String
        public let sendNotificationEmail: Bool
        public let selfExclusionReason: String
        public let expiryDate: String?

        public init(period: String,
                    sendNotificationEmail: Bool,
                    selfExclusionReason: String,
                    expiryDate: String?) {
            self.period = period
            self.sendNotificationEmail = sendNotificationEmail
            self.selfExclusionReason = selfExclusionReason
            self.expiryDate = expiryDate
        }
    }

    public init(selfExclusion: SelfExclusionPayload) {
        self.selfExclusion = selfExclusion
    }
}

public struct UpdateUserLimitRequest: Encodable {
    public let amount: Double
    public let skipCoolOff: Bool

    public init(amount: Double, skipCoolOff: Bool) {
        self.amount = amount
        self.skipCoolOff = skipCoolOff
    }
}

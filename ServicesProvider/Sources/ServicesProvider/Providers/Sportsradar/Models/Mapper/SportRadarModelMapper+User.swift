//
//  SportRadarError.swift
//
//
//  Created by Ruben Roques on 10/10/2022.
//

import Foundation

extension SportRadarModelMapper {

    static func userProfile(fromPlayerInfoResponse playerInfoResponse: SportRadarModels.PlayerInfoResponse) -> UserProfile? {

        var userRegistrationStatus = UserRegistrationStatus.quickOpen
        switch playerInfoResponse.registrationStatus ?? "" {
        case "QUICK_OPEN": userRegistrationStatus = .quickOpen
        case "QUICK_REG": userRegistrationStatus = .quickRegister
        case "PLAYER": userRegistrationStatus = .completed
        default: userRegistrationStatus = .quickOpen
        }

        var avatarName: String?
        var godfatherCode: String?
        var placeOfBirth: String?
        var additionalStreetLine: String?

        for extraInfo in playerInfoResponse.extraInfos ?? [] {
            switch extraInfo.key {
            case "avatar": avatarName = extraInfo.value
            case "godfatherCode": godfatherCode = extraInfo.value
            case "placeOfBirth": placeOfBirth = extraInfo.value
            case "streetLine2": additionalStreetLine = extraInfo.value
            default: ()
            }
        }

        return UserProfile(userIdentifier: playerInfoResponse.partyId,
                           username: playerInfoResponse.userId,
                           email: playerInfoResponse.email,
                           firstName: playerInfoResponse.firstName,
                           lastName: playerInfoResponse.lastName,
                           birthDate: playerInfoResponse.birthDateFormatted,
                           gender: playerInfoResponse.gender,
                           nationalityCode: playerInfoResponse.nationality,
                           countryCode: playerInfoResponse.country,
                           personalIdNumber: playerInfoResponse.idCardNumber,
                           address: playerInfoResponse.address,
                           province: playerInfoResponse.province,
                           city: playerInfoResponse.city,
                           postalCode: playerInfoResponse.postalCode,
                           emailVerificationStatus: EmailVerificationStatus(fromStringKey:  playerInfoResponse.emailVerificationStatus),
                           userRegistrationStatus: userRegistrationStatus,
                           avatarName: avatarName,
                           godfatherCode: godfatherCode,
                           placeOfBirth: placeOfBirth,
                           additionalStreetLine: additionalStreetLine,
                           kycStatus: playerInfoResponse.kycStatus)

    }

    static func userOverview(fromInternalLoginResponse loginResponse: SportRadarModels.LoginResponse) -> UserOverview? {
        guard
            let sessionKey = loginResponse.sessionKey,
            let username = loginResponse.username,
            let email = loginResponse.email
        else {
            return nil
        }
        return UserOverview(sessionKey: sessionKey,
                            username: username,
                            email: email,
                            partyID: loginResponse.partyId,
                            language: loginResponse.language,
                            currency: loginResponse.currency,
                            parentID: loginResponse.parentId,
                            level: loginResponse.level,
                            userType: loginResponse.userType,
                            isFirstLogin: loginResponse.isFirstLogin,
                            registrationStatus: loginResponse.registrationStatus,
                            country: loginResponse.country,
                            kycStatus: loginResponse.kycStatus,
                            lockStatus: loginResponse.lockStatus)
    }

    static func userWallet(fromBalanceResponse playerInfoResponse: SportRadarModels.BalanceResponse) -> UserWallet {
        return UserWallet(vipStatus: playerInfoResponse.vipStatus,
                           currency: playerInfoResponse.currency,
                           loyaltyPoint: playerInfoResponse.loyaltyPoint,
                           totalString: playerInfoResponse.totalBalance,
                           total: playerInfoResponse.totalBalanceNumber,
                           withdrawableString: playerInfoResponse.withdrawableBalance,
                           withdrawable: playerInfoResponse.withdrawableBalanceNumber,
                           bonusString: playerInfoResponse.bonusBalance,
                           bonus: playerInfoResponse.bonusBalanceNumber,
                           pendingBonusString: playerInfoResponse.pendingBonusBalance,
                           pendingBonus: playerInfoResponse.pendingBonusBalanceNumber,
                           casinoPlayableBonusString: playerInfoResponse.casinoPlayableBonusBalance,
                           casinoPlayableBonus: playerInfoResponse.casinoPlayableBonusBalanceNumber,
                           sportsbookPlayableBonusString: playerInfoResponse.sportsbookPlayableBonusBalance,
                           sportsbookPlayableBonus: playerInfoResponse.sportsbookPlayableBonusBalanceNumber,
                           withdrawableEscrowString: playerInfoResponse.withdrawableEscrowBalance,
                           withdrawableEscrow: playerInfoResponse.withdrawableEscrowBalanceNumber,
                           totalWithdrawableString: playerInfoResponse.totalWithdrawableBalance,
                           totalWithdrawable: playerInfoResponse.totalWithdrawableBalanceNumber,
                           withdrawRestrictionAmountString: playerInfoResponse.withdrawRestrictionAmount,
                           withdrawRestrictionAmount: playerInfoResponse.withdrawRestrictionAmountNumber,
                           totalEscrowString: playerInfoResponse.totalEscrowBalance,
                           totalEscrow: playerInfoResponse.totalEscrowBalanceNumber)
    }

}

extension SportRadarModelMapper {

    static func documentTypesResponse(fromDocumentTypesResponse internalDocumentTypesResponse: SportRadarModels.DocumentTypesResponse) -> DocumentTypesResponse {

        let documentTypes = internalDocumentTypesResponse.documentTypes.map({ documentType -> DocumentType in
            let documentType = Self.documentType(fromDocumentType: documentType)

            return documentType

        })

        return DocumentTypesResponse(status: internalDocumentTypesResponse.status, documentTypes: documentTypes)
    }

    static func documentType(fromDocumentType internalDocumentType: SportRadarModels.DocumentType) -> DocumentType {

        return DocumentType(documentType: internalDocumentType.documentType, issueDateRequired: internalDocumentType.issueDateRequired, expiryDateRequired: internalDocumentType.expiryDateRequired, documentNumberRequired: internalDocumentType.documentNumberRequired)
    }

    static func userDocumentsResponse(fromUserDocumentsResponse internalUserDocumentsResponse: SportRadarModels.UserDocumentsResponse) -> UserDocumentsResponse {

        let userDocuments = internalUserDocumentsResponse.userDocuments.map({ userDocument -> UserDocument in
            let userDocument = Self.userDocument(fromUserDocument: userDocument)

            return userDocument

        })

        return UserDocumentsResponse(status: internalUserDocumentsResponse.status, userDocuments: userDocuments)
    }

    static func userDocument(fromUserDocument internalUserDocument: SportRadarModels.UserDocument) -> UserDocument {

        return UserDocument(documentType: internalUserDocument.documentType, fileName: internalUserDocument.fileName, status: internalUserDocument.status)
    }

    static func uploadDocumentResponse(fromUploadDocumentResponse internalUploadDocumentResponse: SportRadarModels.UploadDocumentResponse) -> UploadDocumentResponse {

        return UploadDocumentResponse(status: internalUploadDocumentResponse.status)
    }

    static func paymentsResponse(fromPaymentsResponse internalPaymentsResponse: SportRadarModels.PaymentsResponse) -> PaymentsResponse {

        let depositMethods = internalPaymentsResponse.depositMethods.map({ depositMethod -> DepositMethod in
            let depositMethod = Self.depositMethod(fromDepositMethod: depositMethod)

            return depositMethod

        })

        return PaymentsResponse(status: internalPaymentsResponse.status, depositMethods: depositMethods)
    }

    static func depositMethod(fromDepositMethod internalDepositMethod: SportRadarModels.DepositMethod) -> DepositMethod {

        if let methods = internalDepositMethod.methods {
            let paymentMethods = methods.map({ paymentMethod -> PaymentMethod in
                let paymentMethod = Self.paymentMethod(fromPaymentMethod: paymentMethod)

                return paymentMethod

            })

            return DepositMethod(code: internalDepositMethod.code, paymentMethod: internalDepositMethod.paymentMethod, methods: paymentMethods)
        }

        return DepositMethod(code: internalDepositMethod.code, paymentMethod: internalDepositMethod.paymentMethod, methods: [])
    }

    static func paymentMethod(fromPaymentMethod internalPaymentMethod: SportRadarModels.PaymentMethod) -> PaymentMethod {

        return PaymentMethod(name: internalPaymentMethod.name, type: internalPaymentMethod.type, brands: internalPaymentMethod.brands)
    }

    static func processDepositResponse(fromProcessDepositResponse internalProcessDepositResponse: SportRadarModels.ProcessDepositResponse) -> ProcessDepositResponse {

        return ProcessDepositResponse(status: internalProcessDepositResponse.status, paymentId: internalProcessDepositResponse.paymentId, continueUrl: internalProcessDepositResponse.continueUrl, clientKey: internalProcessDepositResponse.clientKey, sessionId: internalProcessDepositResponse.sessionId)
    }

    static func updatePaymentResponse(fromUpdatePaymentResponse internalUpdatePaymentResponse: SportRadarModels.UpdatePaymentResponse) -> UpdatePaymentResponse {

        return UpdatePaymentResponse(resultCode: internalUpdatePaymentResponse.resultCode, action: Self.updatePaymentAction(fromUpdatePaymentAction: internalUpdatePaymentResponse.action))
    }

    static func updatePaymentAction(fromUpdatePaymentAction internalUpdatePaymentAction: SportRadarModels.UpdatePaymentAction) -> UpdatePaymentAction {

        return UpdatePaymentAction(paymentMethodType: internalUpdatePaymentAction.paymentMethodType, url: internalUpdatePaymentAction.url, method: internalUpdatePaymentAction.method, type: internalUpdatePaymentAction.type)
    }

    static func personalDepositLimitsResponse(fromPersonalDepositLimitsResponse internalPersonalDepositLimitsResponse: SportRadarModels.PersonalDepositLimitResponse) -> PersonalDepositLimitResponse {

        return PersonalDepositLimitResponse(status: internalPersonalDepositLimitsResponse.status, dailyLimit: internalPersonalDepositLimitsResponse.dailyLimit, weeklyLimit: internalPersonalDepositLimitsResponse.weeklyLimit, monthlyLimit: internalPersonalDepositLimitsResponse.monthlyLimit, currency: internalPersonalDepositLimitsResponse.currency,
                                            hasPendingWeeklyLimit: internalPersonalDepositLimitsResponse.hasPendingWeeklyLimit,
                                            pendingWeeklyLimit: internalPersonalDepositLimitsResponse.pendingWeeklyLimit,
                                            pendingWeeklyLimitEffectiveDate: internalPersonalDepositLimitsResponse.pendingWeeklyLimitEffectiveDate)
    }

    static func limitsResponse(fromInternalLimitsResponse internalLimitsResponse: SportRadarModels.LimitsResponse) -> LimitsResponse {

        if let limitPending = internalLimitsResponse.pendingWagerLimit {

            return LimitsResponse(status: internalLimitsResponse.status, wagerLimit: internalLimitsResponse.wagerLimit, lossLimit: internalLimitsResponse.lossLimit, currency: internalLimitsResponse.currency,
                                  pendingWagerLimit: Self.limitPending(fromInternalLimitPending: limitPending))
        }

        return LimitsResponse(status: internalLimitsResponse.status, wagerLimit: internalLimitsResponse.wagerLimit, lossLimit: internalLimitsResponse.lossLimit, currency: internalLimitsResponse.currency,
                              pendingWagerLimit: nil)
    }

    static func limitPending(fromInternalLimitPending internalLimitPending: SportRadarModels.LimitPending) -> LimitPending {

        return LimitPending(effectiveDate: internalLimitPending.effectiveDate, limit: internalLimitPending.limit, limitNumber: internalLimitPending.limitNumber)
    }

    static func basicResponse(fromInternalBasicResponse internalBasicResponse: SportRadarModels.BasicResponse) -> BasicResponse {

        return BasicResponse(status: internalBasicResponse.status, message: internalBasicResponse.message)
    }
}


private extension EmailVerificationStatus {
    init(fromStringKey key: String) {
        switch key {
        case "VERIFIED":
            self = .verified
        default:
            self = .unverified
        }
    }
}

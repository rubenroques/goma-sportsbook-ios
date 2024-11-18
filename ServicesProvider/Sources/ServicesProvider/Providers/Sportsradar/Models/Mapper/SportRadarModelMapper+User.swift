//
//  SportRadarError.swift
//
//
//  Created by Ruben Roques on 10/10/2022.
//

import Foundation

extension SportRadarModelMapper {

    static func userProfile(fromPlayerInfoResponse playerInfoResponse: SportRadarModels.PlayerInfoResponse, withKycExpire kycExpire: String? = nil) -> UserProfile? {

        let userRegistrationStatus = UserRegistrationStatus(fromStringKey: playerInfoResponse.registrationStatus ?? "")
        let emailVerificationStatus = EmailVerificationStatus(fromStringKey:  playerInfoResponse.emailVerificationStatus)
        let knowYourCustomerStatus = KnowYourCustomerStatus(fromStringKey: playerInfoResponse.kycStatus ?? "")
        let lockedStatus = LockedStatus(fromStringKey: playerInfoResponse.lockedStatus ?? "")
        let hasMadeDeposit = playerInfoResponse.madeDeposit ?? false

        var avatarName: String?
        var godfatherCode: String?
        // var placeOfBirth: String?
        var additionalStreetLine: String?

        for extraInfo in playerInfoResponse.extraInfos ?? [] {
            switch extraInfo.key {
            case "avatar": avatarName = extraInfo.value
            case "godfatherCode": godfatherCode = extraInfo.value
            //case "placeOfBirth": placeOfBirth = extraInfo.value
            case "streetLine2": additionalStreetLine = extraInfo.value
            default: ()
            }
        }

        var currency: String?

        if playerInfoResponse.currency == "EUR" {
            currency = "€"
        }
        else if playerInfoResponse.currency == "USD" {
            currency = "$"
        }
        else if playerInfoResponse.currency == "GBP" {
            currency = "£"
        }
        else {
            currency = "€"
        }

        let nationalityCode = playerInfoResponse.birthCoutryCode ?? playerInfoResponse.nationality
        
        return UserProfile(userIdentifier: playerInfoResponse.partyId,
                           sessionKey: playerInfoResponse.sessionKey ?? "",
                           username: playerInfoResponse.userId,
                           email: playerInfoResponse.email,
                           firstName: playerInfoResponse.firstName,
                           middleName: playerInfoResponse.middleName,
                           lastName: playerInfoResponse.lastName,
                           birthDate: playerInfoResponse.birthDateFormatted,
                           gender: playerInfoResponse.gender,
                           nationalityCode: nationalityCode,
                           countryCode: playerInfoResponse.country,
                           personalIdNumber: playerInfoResponse.idCardNumber,
                           address: playerInfoResponse.address,
                           province: playerInfoResponse.province,
                           city: playerInfoResponse.city,
                           postalCode: playerInfoResponse.postalCode,
                           birthDepartment: playerInfoResponse.birthDepartment,
                           streetNumber: playerInfoResponse.streetNumber,
                           phoneNumber: playerInfoResponse.phone,
                           mobilePhone: playerInfoResponse.mobilePhone,
                           mobileCountryCode: playerInfoResponse.mobileCountryCode,
                           mobileLocalNumber: playerInfoResponse.mobileLocalNumber,
                           avatarName: avatarName,
                           godfatherCode: godfatherCode,
                           placeOfBirth: playerInfoResponse.birthCity,
                           additionalStreetLine: additionalStreetLine,
                           emailVerificationStatus: emailVerificationStatus,
                           userRegistrationStatus: userRegistrationStatus,
                           kycStatus: knowYourCustomerStatus,
                           lockedStatus: lockedStatus,
                           hasMadeDeposit: hasMadeDeposit,
                           kycExpiryDate: kycExpire,
                           currency: currency)

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

    static func cashbackBalance(fromCashbackBalance cashbackBalance: SportRadarModels.CashbackBalance) -> CashbackBalance {
        
        return CashbackBalance(status: cashbackBalance.status,
                               balance: cashbackBalance.balance,
                               message: cashbackBalance.message)
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

        let documentTypeGroup = DocumentTypeGroup.init(documentType: internalDocumentType.documentType)

        return DocumentType(documentType: internalDocumentType.documentType, issueDateRequired: internalDocumentType.issueDateRequired, expiryDateRequired: internalDocumentType.expiryDateRequired, documentNumberRequired: internalDocumentType.documentNumberRequired, documentTypeGroup: documentTypeGroup,
                            multipleFileRequired: internalDocumentType.multipleFileRequired)
    }

    static func userDocumentsResponse(fromUserDocumentsResponse internalUserDocumentsResponse: SportRadarModels.UserDocumentsResponse) -> UserDocumentsResponse {

        let userDocuments = internalUserDocumentsResponse.userDocuments.map({ userDocument -> UserDocument in
            let userDocument = Self.userDocument(fromUserDocument: userDocument)

            return userDocument

        })

        return UserDocumentsResponse(status: internalUserDocumentsResponse.status, userDocuments: userDocuments)
    }

    static func userDocument(fromUserDocument internalUserDocument: SportRadarModels.UserDocument) -> UserDocument {

        if let userDocumentFiles = internalUserDocument.userDocumentFiles {

            let mappedUserDocumentFiles = userDocumentFiles.map({ userDocumentFile -> UserDocumentFile in

                let userDocumentFile = Self.userDocumentFile(fromUserDocumentFile: userDocumentFile)

                return userDocumentFile

            })

            return UserDocument(documentType: internalUserDocument.documentType, fileName: internalUserDocument.fileName, status: internalUserDocument.status, uploadDate: internalUserDocument.uploadDate,
            userDocumentFiles: mappedUserDocumentFiles)

        }

        return UserDocument(documentType: internalUserDocument.documentType, fileName: internalUserDocument.fileName, status: internalUserDocument.status, uploadDate: internalUserDocument.uploadDate)
    }

    static func userDocumentFile(fromUserDocumentFile internalUserDocumentFile: SportRadarModels.UserDocumentFile) -> UserDocumentFile {

        return UserDocumentFile(fileName: internalUserDocumentFile.fileName)
    }

    static func uploadDocumentResponse(fromUploadDocumentResponse internalUploadDocumentResponse: SportRadarModels.UploadDocumentResponse) -> UploadDocumentResponse {

        return UploadDocumentResponse(status: internalUploadDocumentResponse.status, message: internalUploadDocumentResponse.message)
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

        return ProcessDepositResponse(status: internalProcessDepositResponse.status, paymentId: internalProcessDepositResponse.paymentId, continueUrl: internalProcessDepositResponse.continueUrl, clientKey: internalProcessDepositResponse.clientKey, sessionId: internalProcessDepositResponse.sessionId,
                                      sessionData: internalProcessDepositResponse.sessionData)
    }

    static func updatePaymentResponse(fromUpdatePaymentResponse internalUpdatePaymentResponse: SportRadarModels.UpdatePaymentResponse) -> UpdatePaymentResponse {

        var action: UpdatePaymentAction? = nil
        if let internalAction = internalUpdatePaymentResponse.action {
            action = Self.updatePaymentAction(fromUpdatePaymentAction: internalAction)
        }
        return UpdatePaymentResponse(resultCode: internalUpdatePaymentResponse.resultCode, action: action)
    }

    static func withdrawalMethodsResponse(fromWithdrawalMethodsResponse internalWithdrawalMethodsResponse: SportRadarModels.WithdrawalMethodsResponse) -> WithdrawalMethodsResponse {

        let withdrawalMethods = internalWithdrawalMethodsResponse.withdrawalMethods.map({ withdrawalMethod -> WithdrawalMethod in
            let withdrawalMethod = Self.withdrawalMethod(fromWithdrawalMethod: withdrawalMethod)

            return withdrawalMethod

        })

        return WithdrawalMethodsResponse(status: internalWithdrawalMethodsResponse.status,
                                         withdrawalMethods: withdrawalMethods)
    }

    static func withdrawalMethod(fromWithdrawalMethod internalWithdrawalMethod: SportRadarModels.WithdrawalMethod) -> WithdrawalMethod {

        return WithdrawalMethod(code: internalWithdrawalMethod.code,
                                paymentMethod: internalWithdrawalMethod.paymentMethod,
                                minimumWithdrawal: internalWithdrawalMethod.minimumWithdrawal,
                                maximumWithdrawal: internalWithdrawalMethod.maximumWithdrawal,
                                conversionRequired: internalWithdrawalMethod.conversionRequired)
    }

    static func processWithdrawalResponse(fromProcessWithdrawalResponse internalProcessWithdrawalResponse: SportRadarModels.ProcessWithdrawalResponse) -> ProcessWithdrawalResponse {

        return ProcessWithdrawalResponse(status: internalProcessWithdrawalResponse.status,
                                         paymentId: internalProcessWithdrawalResponse.paymentId,
                                         message: internalProcessWithdrawalResponse.message)
    }
    
    static func prepareWithdrawalResponse(fromPrepareWithdrawalResponse internalPrepareWithdrawalResponse: SportRadarModels.PrepareWithdrawalResponse) -> PrepareWithdrawalResponse {

        return PrepareWithdrawalResponse(status: internalPrepareWithdrawalResponse.status, conversionId: internalPrepareWithdrawalResponse.conversionId, message: internalPrepareWithdrawalResponse.message)
    }

    static func pendingWithdrawalResponse(fromPendingWithdrawalResponse internalPendingWithdrawalResponse: SportRadarModels.PendingWithdrawalResponse) -> PendingWithdrawalResponse {

        let pendingWithdrawals = internalPendingWithdrawalResponse.pendingWithdrawals.map({ pendingWithdrawal -> PendingWithdrawal in
            let pendingWithdrawal = Self.pendingWithdrawal(fromPendingWithdrawal: pendingWithdrawal)

            return pendingWithdrawal

        })

        return PendingWithdrawalResponse(status: internalPendingWithdrawalResponse.status,
                                         pendingWithdrawals: pendingWithdrawals)
    }

    static func pendingWithdrawal(fromPendingWithdrawal internalPendingWithdrawal: SportRadarModels.PendingWithdrawal) -> PendingWithdrawal {

        return PendingWithdrawal(status: internalPendingWithdrawal.status,
                                 paymentId: internalPendingWithdrawal.paymentId,
                                 amount: internalPendingWithdrawal.amount)
    }

    static func cancelWithdrawalResponse(fromCancelWithdrawalResponse internalCancelWithdrawalResponse: SportRadarModels.CancelWithdrawalResponse) -> CancelWithdrawalResponse {

        return CancelWithdrawalResponse(status: internalCancelWithdrawalResponse.status,
                                        amount: internalCancelWithdrawalResponse.amount,
                                        currency: internalCancelWithdrawalResponse.currency)
    }

    static func updatePaymentAction(fromUpdatePaymentAction internalUpdatePaymentAction: SportRadarModels.UpdatePaymentAction) -> UpdatePaymentAction {

        return UpdatePaymentAction(paymentMethodType: internalUpdatePaymentAction.paymentMethodType,
                                   url: internalUpdatePaymentAction.url,
                                   method: internalUpdatePaymentAction.method,
                                   type: internalUpdatePaymentAction.type)
    }

    static func paymentInformation(fromPaymentInformation internalPaymentInformation: SportRadarModels.PaymentInformation) -> PaymentInformation {

        let bankPaymentInfo = internalPaymentInformation.data.map({ bankPaymentInfo -> BankPaymentInfo in
            let bankPaymentInfo = Self.bankPaymentInfo(fromBankPaymentInfo: bankPaymentInfo)

            return bankPaymentInfo

        })

        return PaymentInformation(status: internalPaymentInformation.status,
                                  data: bankPaymentInfo)
    }

    static func bankPaymentInfo(fromBankPaymentInfo internalBankPaymentInfo: SportRadarModels.BankPaymentInfo) -> BankPaymentInfo {

        let bankPaymentDetails = internalBankPaymentInfo.details.map({ bankPaymentDetail -> BankPaymentDetail in

            let bankPaymentDetail = Self.bankPaymentDetail(fromBankPaymentDetail: bankPaymentDetail)

            return bankPaymentDetail

        })

        return BankPaymentInfo(id: internalBankPaymentInfo.id, partyId: internalBankPaymentInfo.partyId, type: internalBankPaymentInfo.type, description: internalBankPaymentInfo.description, priority: internalBankPaymentInfo.priority, details: bankPaymentDetails)
    }

    static func bankPaymentDetail(fromBankPaymentDetail internalBankPaymentDetail: SportRadarModels.BankPaymentDetail) -> BankPaymentDetail {

        return BankPaymentDetail(id: internalBankPaymentDetail.id, paymentInfoId: internalBankPaymentDetail.paymentInfoId, key: internalBankPaymentDetail.key, value: internalBankPaymentDetail.value)
    }

    static func addPaymentInformationResponse(fromAddPaymentInformationResponse internalAddPaymentInformationResponse: SportRadarModels.AddPaymentInformationResponse) -> AddPaymentInformationResponse {

        return AddPaymentInformationResponse(status: internalAddPaymentInformationResponse.status, message: internalAddPaymentInformationResponse.message)
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

    static func responsibleGamingLimitsResponse(fromResponsibleGamingLimitsResponse internalResponsibleGamingLimitsResponse: SportRadarModels.ResponsibleGamingLimitsResponse) -> ResponsibleGamingLimitsResponse {

        let responsibleGamingLimits = internalResponsibleGamingLimitsResponse.limits.map({ responsibleGamingLimit -> ResponsibleGamingLimit in

            let responsibleGamingLimit = Self.responsibleGamingLimit(fromResponsibleGamingLimit: responsibleGamingLimit)

            return responsibleGamingLimit

        })

        return ResponsibleGamingLimitsResponse(status: internalResponsibleGamingLimitsResponse.status, limits: responsibleGamingLimits)
    }

    static func responsibleGamingLimit(fromResponsibleGamingLimit internalResponsibleGamingLimit: SportRadarModels.ResponsibleGamingLimit) -> ResponsibleGamingLimit {
        return ResponsibleGamingLimit(id: internalResponsibleGamingLimit.id, partyId: internalResponsibleGamingLimit.partyId, limitType: internalResponsibleGamingLimit.limitType, periodType: internalResponsibleGamingLimit.periodType, effectiveDate: internalResponsibleGamingLimit.effectiveDate, expiryDate: internalResponsibleGamingLimit.expiryDate, limit: internalResponsibleGamingLimit.limit)
    }

    static func basicResponse(fromInternalBasicResponse internalBasicResponse: SportRadarModels.BasicResponse) -> BasicResponse {
        return BasicResponse(status: internalBasicResponse.status, message: internalBasicResponse.message)
    }
    
    static func mobileVerifyResponse(fromInternalMobileVerifyResponse internalMobileVerifyResponse: SportRadarModels.MobileVerifyResponse) -> MobileVerifyResponse {
        let requestIdString: String? = internalMobileVerifyResponse.requestId != nil ? String(internalMobileVerifyResponse.requestId ?? -1) : nil
        return MobileVerifyResponse(status: internalMobileVerifyResponse.status,
                                    message: internalMobileVerifyResponse.message,
                                    requestId: requestIdString)
    }
    
    static func paymentStatusResponse(fromPaymentStatusResponse paymentStatusResponse: SportRadarModels.PaymentStatusResponse) -> PaymentStatusResponse {
        return PaymentStatusResponse(status: paymentStatusResponse.status,
                                     paymentId: paymentStatusResponse.paymentId,
                                     paymentStatus: paymentStatusResponse.paymentStatus,
                                     message: paymentStatusResponse.message)
    }
    
    static func supportResponse(fromInternalSupportResponse internalSupportResponse: SportRadarModels.SupportResponse) -> SupportResponse {

        if let supportRequest = internalSupportResponse.request {
            let mappedSupportRequest = Self.supportRequest(fromInternalSupportRequest: supportRequest)

            return SupportResponse(request: mappedSupportRequest, error: internalSupportResponse.error, description: internalSupportResponse.description)

        }

        return SupportResponse(request: nil, error: internalSupportResponse.error, description: internalSupportResponse.description)
    }

    static func supportRequest(fromInternalSupportRequest internalSupportRequest: SportRadarModels.SupportRequest) -> SupportRequest {

        return SupportRequest(id: internalSupportRequest.id, status: internalSupportRequest.status)
    }

    static func transactionsHistoryResponse(fromTransactionsHistoryResponse internalTransactionsHistoryResponse: SportRadarModels.TransactionsHistoryResponse) -> TransactionsHistoryResponse {

        if let transactionDetails = internalTransactionsHistoryResponse.transactions {

            let transactions = transactionDetails.map({ transactionDetail -> TransactionDetail in
                let transactionDetail = Self.transactionDetail(fromInternalTransactionDetail: transactionDetail)

                return transactionDetail

            })

            return TransactionsHistoryResponse(status: internalTransactionsHistoryResponse.status, transactions: transactions)
        }

        return TransactionsHistoryResponse(status: internalTransactionsHistoryResponse.status, transactions: [])
    }

    static func transactionDetail(fromInternalTransactionDetail internalTransactionDetail: SportRadarModels.TransactionDetail) -> TransactionDetail {

        var transactionType = TransactionType.init(transactionType: internalTransactionDetail.type, escrowType: internalTransactionDetail.escrowType)

        if transactionType == .automatedWithdrawalThreshold {
            let transactionReference = internalTransactionDetail.reference
            
            if transactionReference == "Escrow Auto Withdrawal"
            {
                transactionType = .automatedWithdrawal
            }
        }

        let date: Date = OmegaAPIClient.parseOmegaDateString(internalTransactionDetail.dateTime) ?? Date(timeIntervalSinceReferenceDate: 0)
                
        return TransactionDetail(id: internalTransactionDetail.id,
                                 date: date,
                                 type: transactionType,
                                 amount: internalTransactionDetail.amount,
                                 postBalance: internalTransactionDetail.postBalance,
                                 amountBonus: internalTransactionDetail.amountBonus,
                                 postBalanceBonus: internalTransactionDetail.postBalanceBonus,
                                 currency: internalTransactionDetail.currency,
                                 paymentId: internalTransactionDetail.paymentId,
                                 gameTranId: internalTransactionDetail.gameTranId,
                                 reference: internalTransactionDetail.reference,
                                 escrowTranType: internalTransactionDetail.escrowTranType,
                                 escrowTranSubType: internalTransactionDetail.escrowTranSubType,
                                 escrowType: internalTransactionDetail.escrowType)
    }

    static func grantedBonusesResponse(fromGrantedBonusesResponse internalGrantedBonusesResponse: SportRadarModels.GrantedBonusResponse) -> GrantedBonusResponse {

        let bonuses = internalGrantedBonusesResponse.bonuses.map({ grantedBonus -> GrantedBonus in
            let grantedBonus = Self.grantedBonus(fromInternalGrantedBonus: grantedBonus)

            return grantedBonus

        })

        return GrantedBonusResponse(status: internalGrantedBonusesResponse.status, bonuses: bonuses)
    }

    static func grantedBonus(fromInternalGrantedBonus internalGrantedBonus: SportRadarModels.GrantedBonus) -> GrantedBonus {

        let triggerDate: Date? = OmegaAPIClient.parseOmegaDateString(internalGrantedBonus.triggerDate)
        let expiryDate: Date? = OmegaAPIClient.parseOmegaDateString(internalGrantedBonus.expiryDate)
        
        return GrantedBonus(id: internalGrantedBonus.id,
                            name: internalGrantedBonus.name,
                            status: internalGrantedBonus.status,
                            amount: internalGrantedBonus.amount,
                            triggerDate: triggerDate,
                            expiryDate: expiryDate,
                            wagerRequirement: internalGrantedBonus.wagerRequirement,
                            amountWagered: internalGrantedBonus.amountWagered)
    }

    static func availableBonusesResponse(fromAvailableBonusesResponse internalAvailableBonusesResponse: SportRadarModels.AvailableBonusResponse) -> AvailableBonusResponse {

        let bonuses = internalAvailableBonusesResponse.bonuses.map({ availableBonus -> AvailableBonus in
            let availableBonus = Self.availableBonus(fromInternAlavailableBonus: availableBonus)

            return availableBonus

        })

        return AvailableBonusResponse(status: internalAvailableBonusesResponse.status, bonuses: bonuses)
    }

    static func availableBonus(fromInternAlavailableBonus internalAvailableBonus: SportRadarModels.AvailableBonus) -> AvailableBonus {

        let triggerDate: Date? = OmegaAPIClient.parseOmegaDateString(internalAvailableBonus.triggerDate)
        let expiryDate: Date? = OmegaAPIClient.parseOmegaDateString(internalAvailableBonus.expiryDate)

        return AvailableBonus(id: internalAvailableBonus.id,
                              bonusPlanId: internalAvailableBonus.bonusPlanId,
                              name: internalAvailableBonus.name,
                              description: internalAvailableBonus.description,
                              type: internalAvailableBonus.type,
                              amount: internalAvailableBonus.amount,
                              triggerDate: triggerDate,
                              expiryDate: expiryDate,
                              wagerRequirement: internalAvailableBonus.wagerRequirement,
                              imageUrl: internalAvailableBonus.imageUrl)
    }

    static func redeemBonusesResponse(fromRedeemBonusesResponse internalRedeemBonusesResponse: SportRadarModels.RedeemBonusResponse) -> RedeemBonusResponse {

        if let redeemBonus = internalRedeemBonusesResponse.bonus {

            let bonus = Self.redeemBonus(fromRedeemBonus: redeemBonus)

            return RedeemBonusResponse(status: internalRedeemBonusesResponse.status, message: internalRedeemBonusesResponse.message, bonus: bonus)
        }

        return RedeemBonusResponse(status: internalRedeemBonusesResponse.status, message: internalRedeemBonusesResponse.message)
    }

    static func redeemBonus(fromRedeemBonus internalRedeemBonus: SportRadarModels.RedeemBonus) -> RedeemBonus {
       
        let triggerDate: Date? = OmegaAPIClient.parseOmegaDateString(internalRedeemBonus.triggerDate)
        let expiryDate: Date? = OmegaAPIClient.parseOmegaDateString(internalRedeemBonus.expiryDate)

        return RedeemBonus(id: internalRedeemBonus.id,
                           name: internalRedeemBonus.name,
                           status: internalRedeemBonus.status,
                           triggerDate: triggerDate,
                           expiryDate: expiryDate,
                           amount: internalRedeemBonus.amount,
                           wagerRequired: internalRedeemBonus.wagerRequired,
                           amountWagered: internalRedeemBonus.amountWagered)
    }

    static func userConsentResponse(fromUserConsentsResponse internalUserConsentsResponse: SportRadarModels.UserConsentsResponse) -> UserConsentsResponse {

        let userConsents = internalUserConsentsResponse.userConsents.map({ userConsent -> UserConsent in

            let userConsent = Self.userConsent(fromUserConsent: userConsent)

            return userConsent
        })

        return UserConsentsResponse(status: internalUserConsentsResponse.status, message: internalUserConsentsResponse.message, userConsents: userConsents)
    }

    static func userConsent(fromUserConsent internalUserConsent: SportRadarModels.UserConsent) -> UserConsent {

        let userConsentInfo = Self.userConsentInfo(fromUserConsentInfo: internalUserConsent.consentInfo)

        var userConsentStatus: UserConsentStatus = .unknown

        if internalUserConsent.consentStatus == "NOT_CONSENTED" {
            userConsentStatus = .notConsented
        }
        else if internalUserConsent.consentStatus == "CONSENTED" {
            userConsentStatus = .consented
        }
        else {
            userConsentStatus = .unknown
        }

        var userConsentType: UserConsentType = .unknown

        if userConsentInfo.key == "sms_promotions" {
            userConsentType = .sms
        }
        else if userConsentInfo.key == "email_promotions" {
            userConsentType = .email
        }
        else if userConsentInfo.key == "terms" {
            userConsentType = .terms
        }

        return UserConsent(info: userConsentInfo, status: userConsentStatus, type: userConsentType)
    }

    static func userConsentInfo(fromUserConsentInfo internalUserConsentInfo: SportRadarModels.UserConsentInfo) -> UserConsentInfo {

        return UserConsentInfo(id: internalUserConsentInfo.id,
                               key: internalUserConsentInfo.key,
                               name: internalUserConsentInfo.name,
                               consentVersionId: internalUserConsentInfo.consentVersionId,
                               isMandatory: internalUserConsentInfo.isMandatory)
    }

    static func accessTokenResponse(fromInternalAccessTokenResponse internalAccessTokenResponse: SportRadarModels.AccessTokenResponse) -> AccessTokenResponse {

        return AccessTokenResponse(token: internalAccessTokenResponse.token, userId: internalAccessTokenResponse.userId, description: internalAccessTokenResponse.description, code: internalAccessTokenResponse.code)
    }

    static func applicantDataResponse(fromInternalApplicantDataResponse internalApplicantDataResponse: SportRadarModels.ApplicantDataResponse) -> ApplicantDataResponse {

        if let info = internalApplicantDataResponse.info,
           let reviewData = internalApplicantDataResponse.reviewData {

            let mappedInfo = Self.applicantDataInfo(fromInternalApplicantDataInfo: info)

            let mappedReviewData = Self.applicantReviewData(fromInternalApplicantReviewData: reviewData)

            return ApplicantDataResponse(externalUserId: internalApplicantDataResponse.externalUserId, info: mappedInfo, reviewData: mappedReviewData, description: internalApplicantDataResponse.description)
        }
        else if let reviewData = internalApplicantDataResponse.reviewData {
            
            let mappedReviewData = Self.applicantReviewData(fromInternalApplicantReviewData: reviewData)

            return ApplicantDataResponse(externalUserId: internalApplicantDataResponse.externalUserId, info: nil, reviewData: mappedReviewData, description: internalApplicantDataResponse.description)
        }

        return ApplicantDataResponse(externalUserId: internalApplicantDataResponse.externalUserId, info: nil, reviewData: nil, description: internalApplicantDataResponse.description)
    }

    static func applicantDataInfo(fromInternalApplicantDataInfo internalApplicantDataInfo: SportRadarModels.ApplicantDataInfo) -> ApplicantDataInfo {

        if let applicantDocs = internalApplicantDataInfo.applicantDocs {

            let mappedApplicantDocs = applicantDocs.map({
                applicantDoc -> ApplicantDoc in

                let applicantDoc = Self.applicantDoc(fromInternalApplicantDoc: applicantDoc)

                return applicantDoc
            })

            return ApplicantDataInfo(applicantDocs: mappedApplicantDocs)
        }

        return ApplicantDataInfo(applicantDocs: [])
    }

    static func applicantDoc(fromInternalApplicantDoc internalApplicantDoc: SportRadarModels.ApplicantDoc) -> ApplicantDoc {

        return ApplicantDoc(docType: internalApplicantDoc.docType)
    }

    static func applicantReviewData(fromInternalApplicantReviewData internalApplicantReviewData: SportRadarModels.ApplicantReviewData) -> ApplicantReviewData {

        if let applicantReviewResult = internalApplicantReviewData.reviewResult {

            let mappedApplicantReviewResult = Self.applicantReviewResult(fromInternalApplicantReviewResult: applicantReviewResult)

            return ApplicantReviewData(attemptCount: internalApplicantReviewData.attemptCount, createDate: internalApplicantReviewData.createDate, reviewDate: internalApplicantReviewData.reviewDate, reviewResult: mappedApplicantReviewResult, reviewStatus: internalApplicantReviewData.reviewStatus, levelName: internalApplicantReviewData.levelName)
        }


        return ApplicantReviewData(attemptCount: internalApplicantReviewData.attemptCount, createDate: internalApplicantReviewData.createDate, reviewDate: internalApplicantReviewData.reviewDate, reviewResult: nil, reviewStatus: internalApplicantReviewData.reviewStatus,
                                   levelName: internalApplicantReviewData.levelName)
    }

    static func applicantReviewResult(fromInternalApplicantReviewResult internalApplicantReviewResult: SportRadarModels.ApplicantReviewResult) -> ApplicantReviewResult {

        return ApplicantReviewResult(reviewAnswer: internalApplicantReviewResult.reviewAnswer, reviewRejectType: internalApplicantReviewResult.reviewRejectType,
                                     moderationComment: internalApplicantReviewResult.moderationComment)
    }

    static func referralResponse(fromInternalReferralResponse internalReferralResponse: SportRadarModels.ReferralResponse) -> ReferralResponse {
        
        let referralLinks = internalReferralResponse.referralLinks.map( {
            Self.referralLink(fromInternalReferralLink: $0)
        })
        
        return ReferralResponse(status: internalReferralResponse.status, referralLinks: referralLinks)
    }
    
    static func referralLink(fromInternalReferralLink internalReferralLin: SportRadarModels.ReferralLink) -> ReferralLink {
        
        return ReferralLink(code: internalReferralLin.code, link: internalReferralLin.link)
    }
    
    static func refereesResponse(fromInternalRefereesResponse internalRefereesResponse: SportRadarModels.RefereesResponse) -> RefereesResponse {
        
        let referees = internalRefereesResponse.referees.map( {
            Self.referee(fromInternalReferee: $0)
        })
        
        return RefereesResponse(status: internalRefereesResponse.status, referees: referees)
    }
    
    static func referee(fromInternalReferee internalReferee: SportRadarModels.Referee) -> Referee {
        
        return Referee(id: internalReferee.id, username: internalReferee.username, registeredAt: internalReferee.registeredAt, kycStatus: internalReferee.kycStatus, depositPassed: internalReferee.depositPassed)
    }
}

private extension UserRegistrationStatus {
    init(fromStringKey key: String) {
        switch key.uppercased() {
        case "QUICK_OPEN":
            self = .quickOpen
        case "QUICK_REG":
            self = .quickRegister
        case "PLAYER":
            self = .completed
        default:
            self = .quickOpen
        }
    }
}

private extension EmailVerificationStatus {
    init(fromStringKey key: String) {
        switch key.uppercased() {
        case "VERIFIED":
            self = .verified
        default:
            self = .unverified
        }
    }
}

private extension KnowYourCustomerStatus {
    init(fromStringKey key: String) {
        switch key.uppercased() {
        case "PASS":
            self = .pass
        case "PASS_COND":
            self = .passConditional
        default:
            self = .request
        }
    }
}

private extension LockedStatus {
    init(fromStringKey key: String) {
        switch key.uppercased() {
        case "NOT_LOCKED":
            self = .notLocked
        case "LOCKED":
            self = .notLocked
        default:
            self = .notLocked
        }
    }
}

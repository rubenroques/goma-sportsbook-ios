//
//  OmegaAPIClient.swift
//  
//
//  Created by Ruben Roques on 24/10/2022.
//

import Foundation

/*
 username - gomafrontend
 pass - Omega123
 https://ps.omegasys.eu/ps/ips/login
 https://ps.omegasys.eu/ps/ips/openGameSession
 https://ps.omegasys.eu/ps/ips/logout
 https://ps.omegasys.eu/ps/ips/getPlayerInfo
 https://ps.omegasys.eu/ps/ips/getBalanceSimple
 https://ps.omegasys.eu/ps/ips/updatePlayerInfo
 https://ps.omegasys.eu/ps/ips/quickSignup [ get ] [ver se o email é válido]
 https://ps.omegasys.eu/ps/ips/quickSignup [ post ]
 https://ps.omegasys.eu/ps/ips/resendVerificationCode
 https://ps.omegasys.eu/ps/ips/signupConfirmation
 https://ps.omegasys.eu/ps/ips/forgotPasswordStep1And2
 https://ps.omegasys.eu/ps/ips/updatePassword
 */

enum OmegaAPIClient {
    case login(username: String, password: String)
    case openSession
    case logout
    case playerInfo
    case updatePlayerInfo(username: String?,
                          email: String?,
                          firstName: String?,
                          lastName: String?,
                          birthDate: Date?,
                          gender: String?,
                          address: String?,
                          province: String?,
                          city: String?,
                          postalCode: String?,
                          country: String?,
                          cardId: String?)
    case checkCredentialEmail(email: String)
    case checkUsername(username: String)
    case quickSignup(email: String,
                     username: String,
                     password: String,
                     birthDate: Date,
                     mobilePrefix: String,
                     mobileNumber: String,
                     countryIsoCode: String,
                     currencyCode: String)
    case signUp(email: String,
                username: String,
                password: String,
                birthDate: Date,
                mobilePrefix: String,
                mobileNumber: String,
                nationalityIso2Code: String,
                currencyCode: String,
                firstName: String,
                lastName: String,
                gender: String,
                address: String,
                city: String,
                postalCode: String,
                countryIso2Code: String,

                bonusCode: String?,
                receiveMarketingEmails: Bool?,
                avatarName: String?,
                godfatherCode: String?,

                birthDepartment: String,
                birthCity: String,
                birthCountry: String,

                streetNumber: String,
                consentedIds: [String],
                unconsentedIds: [String] )
    
    case updateExtraInfo(placeOfBirth: String?, address2: String?)

    case updateDeviceIdentifier(deviceIdentifier: String)
    
    case resendVerificationCode(username: String)
    case signupConfirmation(email: String,
                            confirmationCode: String)
    case getCountries
    case getCurrentCountry
    case forgotPassword(email: String,
                        secretQuestion: String? = nil,
                        secretAnswer: String? = nil)
    case updatePassword(oldPassword: String,
                        newPassword: String)


    case updateWeeklyDepositLimits(newLimit: Double)
    case updateWeeklyBettingLimits(newLimit: Double)
    case updateResponsibleGamingLimits(newLimit: Double)
    case getPersonalDepositLimits
    case getLimits
    case getResponsibleGamingLimits(limitType: String, periodType: String)
    case lockPlayer(isPermanent: Bool? = nil, lockPeriodUnit: String? = nil, lockPeriod: String? = nil)

    case getBalance
    case getCashbackBalance

    case quickSignupCompletion(firstName: String?,
                               lastName: String?,
                               birthDate: Date?,
                               gender: String?,
                               mobileNumber: String?,
                               address: String?,
                               province: String?,
                               city: String?,
                               postalCode: String?,
                               country: String?,
                               cardId: String?,
                               securityQuestion: String?,
                               securityAnswer: String?)

    case getDocumentTypes
    case getUserDocuments
    case uploadUserDocument(documentType: String, file: Data, body: Data, header: String)
    case uploadMultipleUserDocuments(documentType: String,
                                     files: [String: Data], body: Data, header: String)

    case getPayments
    case processDeposit(paymentMethod: String, amount: Double, option: String)
    case updatePayment(amount: Double, paymentId: String, type: String, returnUrl: String?)
    case cancelDeposit(paymentId: String)
    case checkPaymentStatus(paymentMethod: String, paymentId: String)

    case getWithdrawalsMethods
    case processWithdrawal(withdrawalMethod: String, amount: Double)
    case getPendingWithdrawals
    case cancelWithdrawal(paymentId: Int)
    case getPaymentInformation
    case addPaymentInformation(type: String, fields: String)

    case getTransactionsHistory(startDate: String, endDate: String, transactionType: [String]? = nil, pageNumber: Int? = nil, pageSize: Int? = nil)

    case getGrantedBonuses
    case redeemBonus(code: String)
    case getAvailableBonuses
    case redeemAvailableBonuses(partyId: String, bonusId: String)
    case cancelBonus(bonusId: String)
    case optOutBonus(partyId: String, bonusId: String)

    case contactUs(firstName: String, lastName: String, email: String, subject: String, message: String)

    case contactSupport(userIdentifier: String, firstName: String, lastName: String, email: String, subject: String, subjectType: String, message: String, isLogged: Bool)

    case getAllConsents
    case getUserConsents
    case setUserConsents(consentVersionIds: [Int]? = nil, unconsentVersionIds: [Int]? = nil)

    case getSumsubAccessToken(userId: String, levelName: String, body: Data? = nil, header: [String: String])
    case getSumsubApplicantData(userId: String, body: Data? = nil, header: [String: String])

    case generateDocumentTypeToken(docType: String)
    case checkDocumentationData

    case getMobileVerificationCode(mobileNumber: String)
    case verifyMobileCode(code: String, requestId: String)
}

extension OmegaAPIClient: Endpoint {
    
    var endpoint: String {
        switch self {
        case .login:
            return "/ps/ips/login"
        case .openSession:
            return "/ps/ips/openGameSession"
        case .logout:
            return "/ps/ips/logout"
        case .playerInfo:
            return "/ps/ips/getPlayerInfo"
        case .updatePlayerInfo:
            return "/ps/ips/updatePlayerInfo"
        case .checkCredentialEmail:
            return "/ps/ips/checkCredential"
        case .checkUsername:
            return "/ps/ips/getUserIdSuggestion"
        case .quickSignup:
            return "/ps/ips/quickSignup"
        case .signUp:
            return "/ps/ips/signup"
        case .resendVerificationCode:
            return "/ps/ips/resendVerificationCode"
        case .signupConfirmation:
            return "/ps/ips/signupConfirmation"
        case .getCountries:
            return "/ps/ips/getCountries"
        case .getCurrentCountry:
            return "/ps/ips/getCountryInfo"
        case .forgotPassword:
            return "/ps/ips/forgotPasswordStep1And2"
        case .updatePassword:
            return "/ps/ips/updatePassword"
        case .updateExtraInfo:
            return "/ps/ips/updateExtraInfo"
        case .updateDeviceIdentifier:
            return "/ps/ips/updateExtraInfo"

        case .updateWeeklyDepositLimits:
            return "/ps/ips/setPersonalDepositLimits"
        case .updateWeeklyBettingLimits:
            return "/ps/ips/updateWagerLimit"
        case .updateResponsibleGamingLimits:
            return "/ps/ips/updateResponsibleGamingLimit"
        case .getPersonalDepositLimits:
            return "/ps/ips/getPersonalDepositLimits"
        case .getLimits:
            return "/ps/ips/getLimits"
        case .getResponsibleGamingLimits:
            return "/ps/ips/getResponsibleGamingLimit"
        case .lockPlayer:
            return "/ps/ips/lockPlayer"

        case .getBalance:
            return "/ps/ips/getBalance"
        case .getCashbackBalance:
            return "/ps/ips/getSportRadarReportedCashbackBalance"
        case .quickSignupCompletion:
            return "/ps/ips/quickSignupCompletion"
        case .getDocumentTypes:
            return "/ps/ips/getDocumentTypes"
        case .getUserDocuments:
            return "/ps/ips/getUserDocuments"
        case .uploadUserDocument:
            return "/ps/ips/uploadUserDocument"
        case .uploadMultipleUserDocuments:
            return "/ps/ips/uploadMultiUserDocument"

        case .getPayments:
            return "/ps/ips/getDepositMethods"
        case .processDeposit:
            return "/ps/ips/processDeposit"
        case .updatePayment:
            return "/ps/ips/updatePayment"
        case .cancelDeposit:
            return "/ps/ips/cancelDeposit"
        case .checkPaymentStatus:
            return "/ps/ips/checkPaymentStatus"

        case .getWithdrawalsMethods:
            return "/ps/ips/getWithdrawalMethods"
        case .processWithdrawal:
            return "/ps/ips/processWithdrawal"
        case .getPendingWithdrawals:
            return "/ps/ips/getPendingWithdrawals"
        case .cancelWithdrawal:
            return "/ps/ips/cancelWithdrawal"
        case .getPaymentInformation:
            return "/ps/ips/getPaymentInformation"
        case .addPaymentInformation:
            return "/ps/ips/addPaymentInformation"

        case .getTransactionsHistory:
            return "/ps/ips/getTransactionHistoryByCurrency"

        case .getGrantedBonuses:
            return "/ps/ips/getBonuses"
        case .redeemBonus:
            return "/ps/ips/redeemBonus"
        case .getAvailableBonuses:
            return "/ps/ips/getEligibleOptInBonusPlans"
        case .redeemAvailableBonuses:
            return "/ps/ips/optInBonus"
        case .cancelBonus:
            return "/ps/ips/cancelBonus"
        case .optOutBonus:
            return "/ps/ips/optOutBonus"

        case .contactUs:
            return "/ps/ips/contactus"

        case .contactSupport:
            return "/api/v2/requests"

        case .getAllConsents:
            return "/ps/ips/consents"
        case .getUserConsents:
            return "/ps/ips/user/consents"
        case .setUserConsents:
            return "/ps/ips/user/consents/save"

        case .getSumsubAccessToken:
            return "/resources/accessTokens"
        case .getSumsubApplicantData(let userId, _, _):
            return "/resources/applicants/-;externalUserId=\(userId)/one"

        case .generateDocumentTypeToken:
            return "/ps/ips/generateToken"

        case .checkDocumentationData:
            return "/ps/ips/checkDocumentation"
            
        case .getMobileVerificationCode:
            return "/ps/ips/verify"
        case .verifyMobileCode:
            return "/ps/ips/verify"
        }
    }
    
    var query: [URLQueryItem]? {
        switch self {
        case .login(let username, let password):
            return [URLQueryItem(name: "username", value: username),
                    URLQueryItem(name: "password", value: password)]
        case .openSession:
            return [URLQueryItem(name: "productCode", value: "SPORT_RADAR"),
                    URLQueryItem(name: "gameId", value: "SPORTSBOOK")]
        case .logout:
            return nil
        case .playerInfo:
            return nil

        case .checkCredentialEmail(let email):
            return [URLQueryItem(name: "field", value: "email"),
                    URLQueryItem(name: "value", value: email)]
        case .checkUsername(let username):
            return [URLQueryItem(name: "userId", value: username)]

        case .quickSignup(let email, let username, let password, let birthDate,
                          let mobilePrefix, let mobileNumber, let countryIsoCode, let currencyCode):
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let birthDateString = dateFormatter.string(from: birthDate)
            
            let phoneNumber = "\(mobilePrefix)\(mobileNumber)".replacingOccurrences(of: "+", with: "")
            
            return [
                URLQueryItem(name: "username", value: username),
                URLQueryItem(name: "password", value: password),
                URLQueryItem(name: "email", value: email),
                URLQueryItem(name: "currency", value: currencyCode),
                URLQueryItem(name: "receiveEmail", value: "true"),
                URLQueryItem(name: "country", value: countryIsoCode),
                URLQueryItem(name: "birthDate", value: birthDateString),
                URLQueryItem(name: "mobile", value: phoneNumber)
            ]

        case .signUp(let email,
                     let username,
                     let password,
                     let birthDate,
                     let mobilePrefix,
                     let mobileNumber,
                     let nationalityIso2Code,
                     let currencyCode,
                     let firstName,
                     let lastName,
                     let gender,
                     let address,
                     let city,
                     let postalCode,
                     let countryIso2Code,
                     let bonusCode,
                     let receiveMarketingEmails,
                     let avatarName,
                     let godfatherCode,
                     let birthDepartment,
                     let birthCity,
                     let birthCountry,
                     let streetNumber,
                     let consentedIds,
                     let unconsentedIds):

            let phoneNumber = "\(mobilePrefix)\(mobileNumber)".replacingOccurrences(of: "+", with: "")

            var query: [URLQueryItem] = []

            query.append(URLQueryItem(name: "username", value: username))
            query.append(URLQueryItem(name: "password", value: password))
            query.append(URLQueryItem(name: "email", value: email))
            query.append(URLQueryItem(name: "currency", value: currencyCode))
            // query.append(URLQueryItem(name: "nationality", value: nationalityIso2Code))
            query.append(URLQueryItem(name: "mobile", value: phoneNumber))
            query.append(URLQueryItem(name: "city", value: city))
            query.append(URLQueryItem(name: "country", value: countryIso2Code))

            query.append(URLQueryItem(name: "firstName", value: firstName))
            query.append(URLQueryItem(name: "lastName", value: lastName))
            query.append(URLQueryItem(name: "gender", value: gender))
            query.append(URLQueryItem(name: "address", value: address))

            query.append(URLQueryItem(name: "postalCode", value: postalCode))
            query.append(URLQueryItem(name: "streetNumber", value: streetNumber))
            query.append(URLQueryItem(name: "birthDepartment", value: birthDepartment))
            query.append(URLQueryItem(name: "birthCity", value: birthCity))
            query.append(URLQueryItem(name: "birthCountry", value: birthCountry))

            let dateFromatter = DateFormatter()
            dateFromatter.dateFormat = "yyyy-MM-dd"
            let birthDateString = dateFromatter.string(from: birthDate)
            query.append(URLQueryItem(name: "birthDate", value: birthDateString))


            if let bonusCode = bonusCode { query.append(URLQueryItem(name: "bonusCode", value: bonusCode)) }
            if let receiveMarketingEmails = receiveMarketingEmails {
                query.append(URLQueryItem(name: "receiveEmail", value: receiveMarketingEmails ? "true" : "false"))
            }

            let extraInfo = """
                            {
                            "avatar":"\(avatarName ?? "")",
                            "godfatherCode":"\(godfatherCode ?? "")"
                            }
                            """
            query.append(URLQueryItem(name: "extraInfo", value: extraInfo))

            for consentedId in consentedIds {
                query.append(URLQueryItem(name: "consentedVersions[]", value: consentedId))
            }
            
            for unconsentedId in unconsentedIds {
                query.append(URLQueryItem(name: "unConsentedversions[]", value: unconsentedId))
            }
            
            
            return query

        case .updateExtraInfo(let placeOfBirth, let address2):
            var query: [URLQueryItem] = []
            let extraInfo = """
                            {
                                "placeOfBirth":"\(placeOfBirth ?? "")",
                                "streetLine2":"\(address2 ?? "")"
                            }
                            """
            query.append(URLQueryItem(name: "extraInfo", value: extraInfo))
            return query
            
        case .updateDeviceIdentifier(let deviceIdentifier):
            
            var query: [URLQueryItem] = []
            let extraInfo = """
                            {
                                "device_token_ios": "\(deviceIdentifier)",
                                "device_token_last" : "\(deviceIdentifier)"
                            }
                            """
            query.append(URLQueryItem(name: "extraInfo", value: extraInfo))
            return query
            
        case .resendVerificationCode(let username):
            return [
                URLQueryItem(name: "username", value: username),
                URLQueryItem(name: "verificationTarget", value: "email"),
            ]
        case .signupConfirmation(let email, let confirmationCode):
            return [
                URLQueryItem(name: "confirmationCode", value: confirmationCode),
                URLQueryItem(name: "email", value: email),
            ]
        case .updatePlayerInfo(let username, let email, let firstName, let lastName,
                               let birthDate, let gender, let address, let province, let city,
                               let postalCode, let country, let cardId):
            
            var query: [URLQueryItem] = []
            
            if let username = username { query.append(URLQueryItem(name: "userid", value: username)) }
            if let email = email { query.append(URLQueryItem(name: "email", value: email)) }
            
            if let firstName = firstName { query.append(URLQueryItem(name: "firstName", value: firstName)) }
            if let lastName = lastName { query.append(URLQueryItem(name: "lastName", value: lastName)) }
            if let address = address { query.append(URLQueryItem(name: "address", value: address)) }
            if let province = province { query.append(URLQueryItem(name: "province", value: province)) }
            
            if let gender = gender { query.append(URLQueryItem(name: "gender", value: gender)) }
            if let country = country { query.append(URLQueryItem(name: "country", value: country)) }
            if let birthDate = birthDate {
                let dateFromatter = DateFormatter()
                dateFromatter.dateFormat = "yyyy-MM-dd"
                let birthDateString = dateFromatter.string(from: birthDate)
                query.append(URLQueryItem(name: "birthDate", value: birthDateString))
            }
            
            if let city = city { query.append(URLQueryItem(name: "city", value: city)) }
            if let postalCode = postalCode { query.append(URLQueryItem(name: "postalCode", value: postalCode)) }
            if let cardId = cardId { query.append(URLQueryItem(name: "idCardNumber", value: cardId)) }
            
            return query
        case .getCountries:
            return nil
        case .getCurrentCountry:
            return nil
        case .forgotPassword(let email, let secretQuestion, let secretAnswer):
            var queryItemsURL: [URLQueryItem] = []

            let queryItem = URLQueryItem(name: "email", value: email)
            queryItemsURL.append(queryItem)

            if secretQuestion != nil {
                let queryItem = URLQueryItem(name: "secretQuestion", value: secretQuestion)
                queryItemsURL.append(queryItem)
            }

            if secretAnswer != nil {
                let queryItem = URLQueryItem(name: "secretAnswer", value: secretAnswer)
                queryItemsURL.append(queryItem)
            }

            return queryItemsURL
        case .updatePassword(let oldPassword, let newPassword):
            return [URLQueryItem(name: "oldPassword", value: oldPassword),
                    URLQueryItem(name: "newPassword", value: newPassword)
            ]

        case .updateWeeklyDepositLimits(let newLimit):
            let limitFormated = String(format: "%.2f", newLimit)
            return [URLQueryItem(name: "weeklyLimit", value: limitFormated)]
        case .updateWeeklyBettingLimits(let newLimit):
            let limitFormated = String(format: "%.2f", newLimit)
            return [URLQueryItem(name: "limit", value: limitFormated)]
        case .updateResponsibleGamingLimits(let newLimit):
            let limitFormated = String(format: "%.2f", newLimit)
            return [URLQueryItem(name: "limitType", value: "BALANCE_LIMIT"),
                    URLQueryItem(name: "periodType", value: "PERMANENT"),
                    URLQueryItem(name: "limit", value: limitFormated)
            ]
        case .lockPlayer(let isPermanent, let lockPeriodUnit, let lockPeriod):
            var queryItemsURL: [URLQueryItem] = []

            if isPermanent != nil {
                let queryItem = URLQueryItem(name: "isPermanent", value: "true")
                queryItemsURL.append(queryItem)
            }

            if lockPeriodUnit != nil {
                let queryItem = URLQueryItem(name: "lockPeriodUnit", value: lockPeriodUnit)
                queryItemsURL.append(queryItem)
            }

            if lockPeriod != nil {
                let queryItem = URLQueryItem(name: "lockPeriod", value: lockPeriod)
                queryItemsURL.append(queryItem)
            }

            let queryItem = URLQueryItem(name: "lockType", value: "TIMEOUT")
            queryItemsURL.append(queryItem)

            return queryItemsURL

        case .getPersonalDepositLimits:
            return nil
        case .getLimits:
            return nil
        case .getResponsibleGamingLimits(let limitType, let periodType):
            return [URLQueryItem(name: "limitTypes", value: limitType),
                    URLQueryItem(name: "periodTypes", value: periodType)
            ]

        case .getBalance:
            return nil
        case .getCashbackBalance:
            return nil

        case .quickSignupCompletion(let firstName, let lastName, let birthDate, let gender, let mobileNumber,
                                    let address, let province, let city, let postalCode, let country, let cardId, let securityQuestion, let securityAnswer):
            var query: [URLQueryItem] = []
            
            if let firstName = firstName { query.append(URLQueryItem(name: "firstName", value: firstName)) }
            if let lastName = lastName { query.append(URLQueryItem(name: "lastName", value: lastName)) }
            if let gender = gender { query.append(URLQueryItem(name: "gender", value: gender)) }
            if let mobileNumber = mobileNumber { query.append(URLQueryItem(name: "mobile", value: mobileNumber)) }
            
            if let birthDate = birthDate {
                let dateFromatter = DateFormatter()
                dateFromatter.dateFormat = "yyyy-MM-dd"
                let birthDateString = dateFromatter.string(from: birthDate)
                query.append(URLQueryItem(name: "birthDate", value: birthDateString))
            }
            
            if let address = address { query.append(URLQueryItem(name: "address", value: address)) }
            if let province = province { query.append(URLQueryItem(name: "province", value: province)) }
            if let country = country { query.append(URLQueryItem(name: "country", value: country)) }
            if let city = city { query.append(URLQueryItem(name: "city", value: city)) }
            if let postalCode = postalCode { query.append(URLQueryItem(name: "postalCode", value: postalCode)) }
            if let cardId = cardId { query.append(URLQueryItem(name: "idCardNumber", value: cardId)) }
            
            if let securityQuestion = securityQuestion { query.append(URLQueryItem(name: "securityQuestion", value: securityQuestion)) }
            if let securityAnswer = securityAnswer { query.append(URLQueryItem(name: "securityAnswer", value: securityAnswer)) }
            
            return query
        case .getDocumentTypes:
            return nil
        case .getUserDocuments:
            return nil
        case .uploadUserDocument:
            return nil
        case .uploadMultipleUserDocuments:
            return nil

        case .getPayments:

            return nil
        case .processDeposit(let paymentMethod, let amount, let option):
            let localeCode = Locale.current.languageCode
            let localeRegion = Locale.current.regionCode
            let locale = "\(localeCode ?? "fr")-\(localeRegion ?? "FR")"

            return [

                URLQueryItem(name: "paymentMethod", value: paymentMethod),
                URLQueryItem(name: "amount", value: "\(amount)"),
                URLQueryItem(name: "option", value: option),
                URLQueryItem(name: "locale", value: locale),
                URLQueryItem(name: "requestedBonusPlanId", value: "NONE")
            ]

        case .processWithdrawal(let withdrawalMethod, let amount):
            return [

                URLQueryItem(name: "paymentMethod", value: withdrawalMethod),
                URLQueryItem(name: "amount", value: "\(amount)")
            ]
        case .getPendingWithdrawals:
            return nil
        case .cancelWithdrawal(let paymentId):
            return [
                URLQueryItem(name: "paymentId", value: "\(paymentId)")
            ]
        
        case .updatePayment(let amount, let paymentId, let type, let returnUrl):
            var query = [
                URLQueryItem(name: "amount", value: "\(amount)"),
                URLQueryItem(name: "paymentId", value: paymentId),
                URLQueryItem(name: "type", value: type),
            ]
            
            if let returnUrlValue = returnUrl {
                query.append(URLQueryItem(name: "returnUrl", value: returnUrlValue))
            }
            return query

        case .cancelDeposit(let paymentId):
            return [
                URLQueryItem(name: "paymentId", value: paymentId)
            ]
        case .checkPaymentStatus(let paymentMethod, let paymentId):
            return [
                URLQueryItem(name: "paymentMethod", value: "\(paymentMethod)"),
                URLQueryItem(name: "paymentId", value: "\(paymentId)")
            ]
            
        case .getWithdrawalsMethods:
            return nil

        case .getPaymentInformation:
            return nil

        case .addPaymentInformation(let type, let fields):
            return [

                URLQueryItem(name: "type", value: type),
                URLQueryItem(name: "fields", value: fields)
            ]

        case .getTransactionsHistory(let startDate, let endDate, let transactionType, let pageNumber, let pageSize):
            var queryItemsURL: [URLQueryItem] = []

            let startDateQueryItem = URLQueryItem(name: "startDateTime", value: startDate)
            queryItemsURL.append(startDateQueryItem)

            let endDateQueryItem = URLQueryItem(name: "endDateTime", value: endDate)
            queryItemsURL.append(endDateQueryItem)

            if let transactionType {
                for tranType in transactionType {
                    let queryItem = URLQueryItem(name: "tranType", value: tranType)
                    queryItemsURL.append(queryItem)
                }
            }

            if let pageNumber {
                let queryItem = URLQueryItem(name: "pageNum", value: "\(pageNumber)")
                queryItemsURL.append(queryItem)
            }

            if let pageSize {
                let queryItem = URLQueryItem(name: "pageSize", value: "\(pageSize)")
                queryItemsURL.append(queryItem)
            }

            return queryItemsURL

        case .getGrantedBonuses:
            return nil

        case .redeemBonus(let code):
            return [
                URLQueryItem(name: "bonusCode", value: code)
            ]

        case .getAvailableBonuses:
            return nil

        case .redeemAvailableBonuses(let partyId, let bonusId):
            return [
                URLQueryItem(name: "partyId", value: partyId),
                URLQueryItem(name: "optInId", value: bonusId),
            ]

        case .cancelBonus(let bonusId):
            return [
                URLQueryItem(name: "bonusId", value: bonusId)
            ]

        case .optOutBonus(let partyId, let bonusId):
            return [
                URLQueryItem(name: "partyId", value: partyId),
                URLQueryItem(name: "bonusId", value: bonusId),
            ]

        case .contactUs(let firstName, let lastName, let email, let subject, let message):
            return [
                URLQueryItem(name: "firstName", value: firstName),
                URLQueryItem(name: "lastName", value: lastName),
                URLQueryItem(name: "email", value: email),
                URLQueryItem(name: "subject", value: subject),
                URLQueryItem(name: "message", value: message)
            ]

        case .contactSupport:
            return nil

        case .getAllConsents:
            return nil
        case .getUserConsents:
            return nil

        case .setUserConsents(let consentVersionIds, let unconsentVersionIds):

            var queryItemsURL: [URLQueryItem] = []


            if let consentVersionIds {
                for consentId in consentVersionIds {
                    let queryItem = URLQueryItem(name: "consentedVersions", value: "\(consentId)")
                    queryItemsURL.append(queryItem)
                }
            }

            if let unconsentVersionIds {
                for unconsentId in unconsentVersionIds {
                    let queryItem = URLQueryItem(name: "unConsentedVersions", value: "\(unconsentId)")
                    queryItemsURL.append(queryItem)
                }
            }

            return queryItemsURL

        case .getSumsubAccessToken(let userId, let levelName, _, _):
            return [

                URLQueryItem(name: "userId", value: userId),
                URLQueryItem(name: "levelName", value: levelName)
//                URLQueryItem(name: "ttlInSecs", value: "600")

            ]

        case .getSumsubApplicantData:
            return nil

        case .generateDocumentTypeToken(let docType):
            return [

                URLQueryItem(name: "target", value: "SUMSUB"),
                URLQueryItem(name: "docType", value: docType)

            ]

        case .checkDocumentationData:
            return [
                URLQueryItem(name: "target", value: "SUMSUB"),
                URLQueryItem(name: "resultType", value: "OVERALL")
            ]
            
        case .getMobileVerificationCode(let mobileNumber):
            return [
                URLQueryItem(name: "verificationType", value: "MOBILE"),
                URLQueryItem(name: "verificationValue", value: mobileNumber)
            ]
        
        case .verifyMobileCode(let code, let requestId):
            return [
                URLQueryItem(name: "verificationRequestId", value: requestId),
                URLQueryItem(name: "verificationCode", value: code)
            ]

        }
    }
    
    
    var method: HTTP.Method {
        switch self {
        case .login: return .get
        case .openSession: return .get
        case .logout: return .get
        case .playerInfo: return .get
        case .updatePlayerInfo: return .get
        case .checkCredentialEmail: return .get
        case .checkUsername: return .get
        case .quickSignup: return .get
        case .signUp: return .get
        case .resendVerificationCode: return .get
        case .signupConfirmation: return .get
        case .getCountries: return .get
        case .getCurrentCountry: return .get
        case .forgotPassword: return .get
        case .updatePassword: return .get
        case .updateExtraInfo: return .post
        case .updateDeviceIdentifier: return .post

        case .updateWeeklyDepositLimits: return .get
        case .updateWeeklyBettingLimits: return .get
        case .updateResponsibleGamingLimits: return .get
        case .getPersonalDepositLimits: return .get
        case .getLimits: return .get
        case .getResponsibleGamingLimits: return .get
        case .lockPlayer: return .post

        case .getBalance: return .get
        case .getCashbackBalance: return .get

        case .quickSignupCompletion: return .get
        case .getDocumentTypes: return .get
        case .getUserDocuments: return .get
        case .uploadUserDocument: return .post
        case .uploadMultipleUserDocuments: return .post

        case .getPayments: return .get
        case .processDeposit: return .post
        case .updatePayment: return .post
        case .cancelDeposit: return .post
        case .checkPaymentStatus: return .post
            
        case .getWithdrawalsMethods: return .get
        case .processWithdrawal: return .post
        case .getPendingWithdrawals: return .get
        case .cancelWithdrawal: return .post
        case .getPaymentInformation: return .get
        case .addPaymentInformation: return .post

        case .getTransactionsHistory: return .get

        case .getGrantedBonuses: return .get
        case .redeemBonus: return .post
        case .getAvailableBonuses: return .get
        case .redeemAvailableBonuses: return .post
        case .cancelBonus: return .post
        case .optOutBonus: return .post
        case .contactUs: return .get
        case .contactSupport: return .post

        case .getAllConsents: return .get
        case .getUserConsents: return .get
        case .setUserConsents: return .post

        case .getSumsubAccessToken: return .post
        case .getSumsubApplicantData: return .get

        case .generateDocumentTypeToken: return .get
        case .checkDocumentationData: return .get
            
        case .getMobileVerificationCode: return .get
        case .verifyMobileCode: return .get
        }
    }
    
    var body: Data? {
        switch self {
        case .uploadUserDocument( _, _, let body, _):
            return body
//        case .processDeposit(let sessionKey, let paymentMethod, let amount, let option):
//            let bodyString =
//                        """
//                        {
//                            "sessionKey": "\(sessionKey)",
//                            "paymentMethod": "\(paymentMethod)",
//                            "amount": \(amount),
//                            "option": "\(option)"
//                        }
//                        """
//            return bodyString.data(using: String.Encoding.utf8) ?? Data()
        case .uploadMultipleUserDocuments( _, _, let body, _):
            return body
        case .contactSupport(let userIdentifier, let firstName, let lastName, let email, let subject, let subjectType, let message, _):
            let bodyString =
            """
            {
            "request": {
                "requester": {
                    "name": "\(userIdentifier)",
                    "email": "\(email)"
                    },
                "custom_fields": [
                    {
                    "11249444074770": "\(firstName)"
                    },
                    {
                    "11249427898002": "\(lastName)"
                    },
                    {
                    "11096886022546": "\(subjectType)"
                    }
                ],
                "subject": "\(subject)",
                "comment": {
                    "body": "\(message)"
                }
            }
            }
            """
            return bodyString.data(using: String.Encoding.utf8) ?? Data()

        case .getSumsubAccessToken( _, _, let body, _):
            return body

        default:
            return nil
        }
        //return nil
        /*
         let body = """
         {"type": "\(type)","text": "\(message)"}
         """
         let data = body.data(using: String.Encoding.utf8)!
         return data
         */
    }
    
    var requireSessionKey: Bool {
        switch self {
        case .login: return false
        case .openSession: return true
        case .logout: return true
        case .playerInfo: return true
        case .updatePlayerInfo: return true
        case .checkCredentialEmail: return false
        case .checkUsername: return false
        case .quickSignup: return false
        case .signUp: return false
        case .resendVerificationCode: return false
        case .signupConfirmation: return false
        case .getCountries: return false
        case .getCurrentCountry: return false
        case .forgotPassword: return false
        case .updatePassword: return true
        case .updateExtraInfo: return true
        case .updateDeviceIdentifier: return true
            
        case .updateWeeklyDepositLimits: return true
        case .updateWeeklyBettingLimits: return true
        case .updateResponsibleGamingLimits: return true
        case .getPersonalDepositLimits: return true
        case .getLimits: return true
        case .getResponsibleGamingLimits: return true
        case .lockPlayer: return true

        case .getBalance: return true
        case .getCashbackBalance: return true
        case .quickSignupCompletion: return true
        case .getDocumentTypes: return false
        case .getUserDocuments: return true
        case .uploadUserDocument: return true
        case .uploadMultipleUserDocuments: return true

        case .getPayments: return true
        case .processDeposit: return true
        case .updatePayment: return true
        case .cancelDeposit: return true
        case .checkPaymentStatus: return true
            
        case .getWithdrawalsMethods: return true
        case .processWithdrawal: return true
        case .getPendingWithdrawals: return true
        case .cancelWithdrawal: return true
        case .getPaymentInformation: return true
        case .addPaymentInformation: return true

        case .getTransactionsHistory: return true

        case .getGrantedBonuses: return true
        case .redeemBonus: return true
        case .getAvailableBonuses: return true
        case .redeemAvailableBonuses: return true
        case .cancelBonus: return true
        case .optOutBonus: return true
            
        case .contactUs: return false
        case .contactSupport: return false

        case .getAllConsents: return false
        case .getUserConsents: return true
        case .setUserConsents: return true

        case .getSumsubAccessToken: return false
        case .getSumsubApplicantData: return false

        case .generateDocumentTypeToken: return true
        case .checkDocumentationData: return true
            
        case .getMobileVerificationCode: return false
        case .verifyMobileCode: return false
        }
    }
    
    var url: String {

        switch self {
        case .contactSupport:
            return SportRadarConfiguration.shared.supportHostname
        case .getSumsubAccessToken:
            return SportRadarConfiguration.shared.sumsubHostname
        case .getSumsubApplicantData:
            return SportRadarConfiguration.shared.sumsubHostname
        default:
            return SportRadarConfiguration.shared.pamHostname
        }


    }
    
    var headers: HTTP.Headers? {
        switch self {
        case .uploadUserDocument( _, _, _, let header):
            let customHeaders = [
                "Content-Type": header,
                "app-origin": "ios",
            ]
            return customHeaders
        case .uploadMultipleUserDocuments( _, _, _, let header):
            let customHeaders = [
                "Content-Type": header,
                "app-origin": "ios",
            ]
            return customHeaders
        case .getSumsubAccessToken(_ , _, _, let header):
            return header
        case .getSumsubApplicantData( _, _,  let header):
            return header
        case .contactSupport(_, _, _, let email, _, _, _, let isLogged):

            if isLogged {
                let authPassword = "GIpqQMrDwD2JnNUEUF7vOm2ilGMEyZ5wnIOSuURP"

                if let authData = (email + "/token" + ":" + authPassword).data(using: .utf8)?.base64EncodedString() {

                    let headers = [
                        "Accept-Encoding": "gzip, deflate",
                        "Content-Type": "application/json; charset=UTF-8",
                        "Accept": "application/json",
                        "app-origin": "ios",
                        "Authorization": "Basic \(authData)"
                    ]
                    return headers
                }
            }

            let headers = [
                "Accept-Encoding": "gzip, deflate",
                "Content-Type": "application/json; charset=UTF-8",
                "Accept": "application/json",
                "app-origin": "ios",
            ]
            return headers

        default:
            let defaultHeaders = [
                "Accept-Encoding": "gzip, deflate",
                "Content-Type": "application/json; charset=UTF-8",
                "Accept": "application/json",
                "app-origin": "ios",
            ]
            return defaultHeaders
        }

    }
    
    var cachePolicy: URLRequest.CachePolicy {
        return .reloadIgnoringLocalCacheData
    }
    
    var timeout: TimeInterval {
        return TimeInterval(20)
    }
    
}

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
                firstName: String?,
                lastName: String?,
                gender: String?,
                address: String?,
                province: String?,
                city: String,
                postalCode: String?,
                countryIso2Code: String,
                cardId: String?,
                securityQuestion: String?,
                securityAnswer: String?,
                bonusCode: String?,
                receiveMarketingEmails: Bool?,
                avatarName: String?,
                placeOfBirth: String?,
                additionalStreetAddress: String?,
                godfatherCode: String?)

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

    case getBalance
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

    case getPayments
    case processDeposit(paymentMethod: String, amount: Double, option: String)
    case updatePayment(paymentMethod: String, amount: Double, paymentId: String, type: String, issuer: String)
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

        case .updateWeeklyDepositLimits:
            return "/ps/ips/setPersonalDepositLimits"
        case .updateWeeklyBettingLimits:
            return "/ps/ips/updateWagerLimit"

        case .getBalance:
            return "/ps/ips/getBalanceSimple"
        case .quickSignupCompletion:
            return "/ps/ips/quickSignupCompletion"
        case .getDocumentTypes:
            return "/ps/ips/getDocumentTypes"
        case .getUserDocuments:
            return "/ps/ips/getUserDocuments"
        case .uploadUserDocument:
            return "/ps/ips/uploadUserDocument"

        case .getPayments:
            return "/ps/ips/getDepositMethods"
        case .processDeposit:
            return "/ps/ips/processDeposit"
        case .updatePayment:
            return "/ps/ips/updatePayment"
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

        case .signUp(let email, let username, let password,
                     let birthDate, let mobilePrefix, let mobileNumber, let nationalityIso2Code,
                     let currencyCode, let firstName, let lastName,
                     let gender, let address, let province, let city, let postalCode, let countryIso2Code,
                     let cardId, let securityQuestion, let securityAnswer,
                     let bonusCode, let receiveMarketingEmails, let avatarName,
                     let placeOfBirth, let additionalStreetAddress, let godfatherCode):

            let phoneNumber = "\(mobilePrefix)\(mobileNumber)".replacingOccurrences(of: "+", with: "")

            var query: [URLQueryItem] = []

            query.append(URLQueryItem(name: "username", value: username))
            query.append(URLQueryItem(name: "password", value: password))
            query.append(URLQueryItem(name: "email", value: email))
            query.append(URLQueryItem(name: "currency", value: currencyCode))
            query.append(URLQueryItem(name: "nationality", value: nationalityIso2Code))
            query.append(URLQueryItem(name: "mobile", value: phoneNumber))
            query.append(URLQueryItem(name: "city", value: city))
            query.append(URLQueryItem(name: "country", value: countryIso2Code))

            let dateFromatter = DateFormatter()
            dateFromatter.dateFormat = "yyyy-MM-dd"
            let birthDateString = dateFromatter.string(from: birthDate)
            query.append(URLQueryItem(name: "birthDate", value: birthDateString))

            if let firstName = firstName { query.append(URLQueryItem(name: "firstName", value: firstName)) }
            if let lastName = lastName { query.append(URLQueryItem(name: "lastName", value: lastName)) }
            if let gender = gender { query.append(URLQueryItem(name: "gender", value: gender)) }
            if let address = address { query.append(URLQueryItem(name: "address", value: address)) }
            if let province = province { query.append(URLQueryItem(name: "province", value: province)) }

            if let postalCode = postalCode { query.append(URLQueryItem(name: "postalCode", value: postalCode)) }
            if let cardId = cardId { query.append(URLQueryItem(name: "idCardNumber", value: cardId)) }
            if let securityQuestion = securityQuestion { query.append(URLQueryItem(name: "securityQuestion", value: securityQuestion)) }
            if let securityAnswer = securityAnswer { query.append(URLQueryItem(name: "securityAnswer", value: securityAnswer)) }

            if let bonusCode = bonusCode { query.append(URLQueryItem(name: "bonusCode", value: bonusCode)) }
            if let receiveMarketingEmails = receiveMarketingEmails {
                query.append(URLQueryItem(name: "receiveEmail", value: receiveMarketingEmails ? "true" : "false"))
            }

            var extraInfo = """
                            {
                            "avatar":"\(avatarName ?? "")",
                            "placeOfBirth":"\(placeOfBirth ?? "")",
                            "streetLine2":"\(additionalStreetAddress ?? "")",
                            "godfatherCode":"\(godfatherCode ?? "")"
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

        case .getBalance:
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

        case .getPayments:

            return nil
        case .processDeposit(let paymentMethod, let amount, let option):
            return [

                URLQueryItem(name: "paymentMethod", value: paymentMethod),
                URLQueryItem(name: "amount", value: "\(amount)"),
                URLQueryItem(name: "option", value: option)
            ]

        case .updatePayment(let paymentMethod, let amount, let paymentId, let type, let issuer):
            return [

                URLQueryItem(name: "paymentMethod", value: paymentMethod),
                URLQueryItem(name: "amount", value: "\(amount)"),
                URLQueryItem(name: "paymentId", value: paymentId),
                URLQueryItem(name: "type", value: type),
                URLQueryItem(name: "issuer", value: issuer)
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
        case .updateWeeklyDepositLimits: return .get
        case .updateWeeklyBettingLimits: return .get
        case .getBalance: return .get
        case .quickSignupCompletion: return .get
        case .getDocumentTypes: return .get
        case .getUserDocuments: return .get
        case .uploadUserDocument: return .post
        case .getPayments: return .get
        case .processDeposit: return .post
        case .updatePayment: return .post
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
        case .updateWeeklyDepositLimits: return true
        case .updateWeeklyBettingLimits: return true
        case .getBalance: return true
        case .quickSignupCompletion: return true
        case .getDocumentTypes: return false
        case .getUserDocuments: return true
        case .uploadUserDocument: return true
        case .getPayments: return true
        case .processDeposit: return true
        case .updatePayment: return true
        }
    }
    
    var url: String {

        return SportRadarConstants.pamHostname
    }
    
    var headers: HTTP.Headers? {
        switch self {
        case .uploadUserDocument( _, _, _, let header):
            let customHeaders = [
                "Content-Type": header
            ]
            return customHeaders
        default:
            let defaultHeaders = [
                "Accept-Encoding": "gzip, deflate",
                "Content-Type": "application/json; charset=UTF-8",
                "Accept": "application/json"
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

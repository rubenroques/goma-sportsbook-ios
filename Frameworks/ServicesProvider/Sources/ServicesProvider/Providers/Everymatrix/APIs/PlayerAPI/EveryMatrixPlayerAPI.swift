//
//  EveryMatrixAPI.swift
//  ServicesProvider
//
//  Created by André Lascas on 09/07/2025.
//

import Foundation
import GomaPerformanceKit

enum EveryMatrixPlayerAPI {
    
    case login(username: String, password: String)
    case getRegistrationConfig
    case registerStep(form: PhoneSignUpForm)
    case register(registrationId: String)
    case getUserProfile(userId: String)
    case getUserBalance(userId: String)
    case getResponsibleGamingLimits(userId: String, periodTypes: String?, limitTypes: String?)
    case setUserLimit(userId: String, request: UserLimitRequest)
    case setTimeOut(userId: String, request: UserTimeoutRequest)
    case setSelfExclusion(userId: String, request: SelfExclusionRequest)
    case updateUserLimit(userId: String, limitId: String, request: UpdateUserLimitRequest)
    case deleteUserLimit(userId: String, limitId: String, request: DeleteUserLimitRequest)
    case getUserLimits(userId: String, periodTypes: String?)
    //
    case getBankingWebView(userId: String, parameters: EveryMatrix.GetPaymentSessionRequest)
    case getWageringTransactions(userId: String, startDate: String, endDate: String, pageNumber: Int?)
    case getBankingTransactions(userId: String, startDate: String, endDate: String, pageNumber: Int?, types: String?, states: [String]?)
    //
    case getRecentlyPlayedGames(playerId: String, language: String, platform: String, offset: Int, limit: Int)
    case getMostPlayedGames(playerId: String, language: String, platform: String, offset: Int, limit: Int)

    // Betting Offer Booking API endpoints
    case createBookingCode(bettingOfferIds: [String], originalSelectionsLength: Int)
    case getFromBookingCode(code: String)

    // Odds Boost / Bonus Wallet API
    case getSportsBonusWallets(request: EveryMatrix.OddsBoostWalletRequest)
    
    // Password Reset endpoints
    case getResetPasswordTokenId(mobileNumber: String, mobilePrefix: String)
    case validateResetPasswordCode(tokenId: String, validationCode: String)
    case resetPasswordWithHashKey(hashKey: String, plainTextPassword: String, isUserHash: Bool)
    
    // Bonus
    case getAvailableBonus
    case getGrantedBonus

    // User Info SSE Stream
    case getUserInformationUpdatesSSE(userId: String)
}

extension EveryMatrixPlayerAPI: Endpoint {
    var url: String {
        switch self {
        default:
            return EveryMatrixUnifiedConfiguration.shared.playerAPIBaseURL
        }
    }
    
    var endpoint: String {
        switch self {
        case .login:
            return "/v1/player/legislation/login"
        case .getRegistrationConfig:
            return "/v1/player/legislation/registration/config"
        case .registerStep:
            return "/v1/player/legislation/registration/step"
        case .register:
            return "/v1/player/legislation/register"
        case .getUserProfile(let userId):
            return "/v1/player/\(userId)/details"
        case .getUserBalance(let userId):
            return "/v2/player/\(userId)/balance"
        case .getResponsibleGamingLimits(let userId, _, _):
            return "/v1/player/\(userId)/limits/monetary"
        case .setUserLimit(let userId, _):
            return "/v1/player/\(userId)/limits/monetary"
        case .setTimeOut(let userId, _):
            return "/v1/player/\(userId)/limits/session"
        case .setSelfExclusion(let userId, _):
            return "/v1/player/\(userId)/limits/session"
        case .updateUserLimit(let userId, let limitId, _):
            return "/v1/player/\(userId)/limits/monetary/\(limitId)"
        case .deleteUserLimit(let userId, let limitId, _):
            return "/v1/player/\(userId)/limits/monetary/\(limitId)"
        case .getUserLimits(let userId, _):
            return "/v1/player/\(userId)/limits/monetary"
        case .getBankingWebView(let userId, _):
            return "/v1/player/\(userId)/payment/GetPaymentSession"
        case .getWageringTransactions(let userId, _, _, _):
            return "/v1/player/\(userId)/transactions/wagering"
        case .getBankingTransactions(let userId, _, _, _, _, _):
            return "/v1/player/\(userId)/transactions/banking"
        case .getRecentlyPlayedGames(let playerId, _, _, _, _):
            return "/v1/player/\(playerId)/games/last-played"
        case .getMostPlayedGames(let playerId, _, _, _, _):
            return "/v1/player/\(playerId)/games/most-played"
        case .createBookingCode:
            return "/v2/sports/bets/book"
        case .getFromBookingCode(let code):
            return "/v2/sports/bets/book/\(code)"
        
        case .getSportsBonusWallets:
            return "/v1/bonus/wallets/sports"

        case .getResetPasswordTokenId:
            return "/v1/player/resetPasswordByMobilePhone"
        case .validateResetPasswordCode:
            return "/v1/player/resetPasswordByMobilePhone/validate"
        case .resetPasswordWithHashKey:
            return "/v1/player/ResetPasswordByHashKey"
        case .getAvailableBonus:
            return "/v1/bonus/applicable"
        case .getGrantedBonus:
            return "/v1/bonus/granted"
        case .getUserInformationUpdatesSSE(let userId):
            return "/v2/player/\(userId)/information/updates"
        }
    }
    
    var query: [URLQueryItem]? {
        switch self {
        case .getWageringTransactions(_, let startDate, let endDate, let pageNumber):
            var queryItems = [
                URLQueryItem(name: "startDate", value: startDate),
                URLQueryItem(name: "endDate", value: endDate)
            ]
            if let pageNumber = pageNumber {
                queryItems.append(URLQueryItem(name: "page", value: String(pageNumber)))
            }
            return queryItems
        case .getBankingTransactions(_, let startDate, let endDate, let pageNumber, let types, let states):
            var queryItems = [
                URLQueryItem(name: "startDate", value: startDate),
                URLQueryItem(name: "endDate", value: endDate)
            ]
            if let pageNumber = pageNumber {
                queryItems.append(URLQueryItem(name: "page", value: String(pageNumber)))
            }
            if let types = types {
                queryItems.append(URLQueryItem(name: "types", value: types))
            }
            if let states = states, !states.isEmpty {
                states.forEach { state in
                    queryItems.append(URLQueryItem(name: "states", value: state))
                }
            }
            return queryItems
        case .getResponsibleGamingLimits(_, let periodTypes, let limitTypes):
            var queryItems: [URLQueryItem] = []
            if let periodTypes = periodTypes, !periodTypes.isEmpty {
                queryItems.append(URLQueryItem(name: "periodTypes", value: periodTypes))
            }
            if let limitTypes = limitTypes, !limitTypes.isEmpty {
                queryItems.append(URLQueryItem(name: "limitTypes", value: limitTypes))
            }
            return queryItems.isEmpty ? nil : queryItems
        case .setUserLimit:
            return nil
        case .setTimeOut:
            return nil
        case .setSelfExclusion:
            return nil
        case .updateUserLimit:
            return nil
        case .deleteUserLimit(_, _, let request):
            return [URLQueryItem(name: "skipCoolOff", value: request.skipCoolOff ? "true" : "false")]
        case .getUserLimits(_, let periodTypes):
            guard let periodTypes = periodTypes, !periodTypes.isEmpty else {
                return nil
            }
            return [URLQueryItem(name: "periodTypes", value: periodTypes)]
        case .getRecentlyPlayedGames(_, let language, let platform, let offset, let limit):
            return [
                URLQueryItem(name: "language", value: language),
                URLQueryItem(name: "platform", value: platform),
                URLQueryItem(name: "offset", value: String(offset)),
                URLQueryItem(name: "limit", value: String(limit)),
                URLQueryItem(name: "period", value: "Last7Days"),
                URLQueryItem(name: "unique", value: "true"),
                URLQueryItem(name: "dataSources", value: "Lobby1"),
                URLQueryItem(name: "hasGameModel", value: "true"),
                URLQueryItem(name: "order", value: "DESCENDING")
            ]
        case .getMostPlayedGames(_, let language, let platform, let offset, let limit):
            return [
                URLQueryItem(name: "language", value: language),
                URLQueryItem(name: "platform", value: platform),
                URLQueryItem(name: "offset", value: String(offset)),
                URLQueryItem(name: "limit", value: String(limit)),
                URLQueryItem(name: "period", value: "Last7Days"),
                URLQueryItem(name: "unique", value: "true"),
                URLQueryItem(name: "dataSources", value: "Lobby1"),
                URLQueryItem(name: "hasGameModel", value: "true"),
                URLQueryItem(name: "order", value: "DESCENDING")
            ]
        case .getResetPasswordTokenId(let mobileNumber, let mobilePrefix):
            return [
                URLQueryItem(name: "mobileNumber", value: mobileNumber),
                URLQueryItem(name: "mobilePrefix", value: mobilePrefix)
            ]
        case .validateResetPasswordCode(let tokenId, let validationCode):
            return [
                URLQueryItem(name: "tokenId", value: tokenId),
                URLQueryItem(name: "validationCode", value: validationCode)
            ]
        case .getAvailableBonus:
            return [
                URLQueryItem(name: "language", value: EveryMatrixUnifiedConfiguration.shared.defaultLanguage)
            ]
        case .getGrantedBonus:
            return [
                URLQueryItem(name: "language", value: EveryMatrixUnifiedConfiguration.shared.defaultLanguage)
            ]
        default:
            return nil
        }
    }
    
    var headers: HTTP.Headers? {

        switch self {
        case .getUserProfile, .getUserBalance, .getWageringTransactions, .getBankingTransactions, .getResponsibleGamingLimits, .setUserLimit, .setTimeOut, .setSelfExclusion, .updateUserLimit, .deleteUserLimit, .getUserLimits:
            let headers = [
                "Content-Type": "application/json",
                "User-Agent": "GOMA/native-app/iOS",
                "X-Session-Type": "others",
                "Accept": "application/json"
            ]
            return headers
        case .getUserInformationUpdatesSSE:
            return [
                "Accept": "text/event-stream",
                "User-Agent": "GOMA/native-app/iOS",
                "X-Session-Type": "others"
            ]
        case .getBankingWebView:
            return [
                "Content-Type": "application/json",
                "Accept": "application/json"
            ]
        case .resetPasswordWithHashKey:
            return [
                "Content-Type": "application/json",
                "Accept": "application/json"
            ]
        default:
            let headers = EveryMatrixUnifiedConfiguration.shared.defaultHeaders
            return headers
        }

    }
    
    var cachePolicy: URLRequest.CachePolicy {
        return EveryMatrixUnifiedConfiguration.shared.defaultCachePolicy
    }
    
    var method: HTTP.Method {
        switch self {
        case .login:
            return .post
        case .getRegistrationConfig:
            return .get
        case .registerStep:
            return .post
        case .register:
            return .put
        case .getUserProfile:
            return .get
        case .getUserBalance:
            return .get
        case .getResponsibleGamingLimits:
            return .get
        case .setUserLimit:
            return .post
        case .setTimeOut:
            return .put
        case .setSelfExclusion:
            return .put
        case .updateUserLimit:
            return .put
        case .deleteUserLimit:
            return .delete
        case .getUserLimits:
            return .get
        
        case .getBankingWebView:
            return .post
        case .getWageringTransactions, .getBankingTransactions:
            return .get
        
        case .getRecentlyPlayedGames:
            return .get
        case .getMostPlayedGames:
            return .get
        
        case .createBookingCode:
            return .post
        case .getFromBookingCode:
            return .get
        
        case .getSportsBonusWallets:
            return .put

        case .getResetPasswordTokenId:
            return .post
        case .validateResetPasswordCode:
            return .post
        case .resetPasswordWithHashKey:
            return .post
        case .getAvailableBonus:
            return .get
        case .getGrantedBonus:
            return .get
        case .getUserInformationUpdatesSSE:
            return .get
        }
    }
    
    var body: Data? {
        switch self {
        case .login(let username, let password):
            let body = """
                       {
                        "username": "\(username)",
                        "password": "\(password)"
                       }
                       """
            
            let data = body.data(using: String.Encoding.utf8)!
            
            return data
        case .registerStep(let form):
            var registerUserDto: [String: Any] = [
                "Mobile": form.phone,
                "MobilePrefix": form.phonePrefix,
                "Password": form.password,
                "TermsAndConditions": true
            ]

            // Add optional fields if present
            if let firstName = form.firstName {
                registerUserDto["FirstnameOnDocument"] = firstName
            }
            if let lastName = form.lastName {
                registerUserDto["LastNameOnDocument"] = lastName
            }
            if let birthDate = form.birthDate {
                registerUserDto["BirthDate"] = birthDate
            }

            let bodyDict: [String: Any] = [
                "Step": "Step1",
                "RegistrationId": form.registrationId,
                "RegisterUserDto": registerUserDto
            ]

            let data = try! JSONSerialization.data(withJSONObject: bodyDict, options: [])

            return data
        case .register(let registrationId):
            let body = """
                       {
                        "registrationId": "\(registrationId)"
                       }
                       """
            
            let data = body.data(using: String.Encoding.utf8)!
            
            return data
        case .getBankingWebView(_, let parameters):
            return try? JSONEncoder().encode(parameters)
        case .createBookingCode(let bettingOfferIds, let originalSelectionsLength):
            let selections = bettingOfferIds.map { BookingSelection(bettingOfferId: $0) }
            let request = BookingRequest(selections: selections, originalSelectionsLength: originalSelectionsLength)
            return try? JSONEncoder().encode(request)
        case .setUserLimit(_, let request):
            return try? JSONEncoder().encode(request)
        case .setTimeOut(_, let request):
            return try? JSONEncoder().encode(request)
        case .setSelfExclusion(_, let request):
            return try? JSONEncoder().encode(request)
        case .updateUserLimit(_, _, let request):
            return try? JSONEncoder().encode(request)
        case .getSportsBonusWallets(let request):
            return try? JSONEncoder().encode(request)

        case .resetPasswordWithHashKey(let hashKey, let plainTextPassword, let isUserHash):
            let bodyDict: [String: Any] = [
                "hashKey": hashKey,
                "plainTextPassword": plainTextPassword,
                "isUserHash": isUserHash
            ]
            return try? JSONSerialization.data(withJSONObject: bodyDict, options: [])
        default:
            return nil
        }
    }
    
    var timeout: TimeInterval {
        return EveryMatrixUnifiedConfiguration.shared.defaultTimeout

    }
    
    var requireSessionKey: Bool {
        switch self {
        case .getUserProfile:
            return true
        case .getUserBalance:
            return true
        case .getResponsibleGamingLimits:
            return true
        case .setUserLimit:
            return true
        case .setTimeOut:
            return true
        case .setSelfExclusion:
            return true
        case .updateUserLimit:
            return true
        case .deleteUserLimit:
            return true
        case .getUserLimits:
            return true
        case .getBankingWebView:
            return true
        case .getWageringTransactions, .getBankingTransactions:
            return true
        case .getRecentlyPlayedGames:
            return true
        case .getSportsBonusWallets:
            return true
        case .getAvailableBonus:
            return true
        case .getGrantedBonus:
            return true
        case .getUserInformationUpdatesSSE:
            return true
        default:
            return false
        }

    }
    
    var comment: String? {
        switch self {
        case .getResponsibleGamingLimits:
            return "getResponsibleGamingLimits"
        case .setUserLimit:
            return "setUserLimit"
        case .setTimeOut:
            return "setTimeOut"
        case .setSelfExclusion:
            return "setSelfExclusion"
        case .updateUserLimit:
            return "updateUserLimit"
        case .deleteUserLimit:
            return "deleteUserLimit"
        case .getUserLimits:
            return "getUserLimits"
        default:
            return nil
        }
    }

    // MARK: - Performance Tracking

    var performanceFeature: PerformanceFeature? {
        switch self {
        // Login tracking
        case .login:
            return .login

        // Registration tracking
        case .registerStep, .register:
            return .register

        // Banking tracking - distinguish deposit vs withdraw
        case .getBankingWebView(_, let parameters):
            // Check transaction type in request parameters
            let type = parameters.type.lowercased()
            if type == "deposit" {
                return .deposit
            } else if type == "withdraw" || type == "withdrawal" {
                return .withdraw
            }
            // Default to deposit if ambiguous
            return .deposit

        // Don't track other endpoints
        case .getRegistrationConfig, .getUserProfile, .getUserBalance,
             .getResponsibleGamingLimits, .setUserLimit, .setTimeOut,
             .setSelfExclusion, .updateUserLimit, .deleteUserLimit,
             .getUserLimits, .getWageringTransactions, .getBankingTransactions,
             .getRecentlyPlayedGames, .getMostPlayedGames, .createBookingCode,
             .getFromBookingCode, .getSportsBonusWallets, .getResetPasswordTokenId,
             .validateResetPasswordCode, .resetPasswordWithHashKey,
             .getAvailableBonus, .getGrantedBonus, .getUserInformationUpdatesSSE:
            return nil
        }
    }

}

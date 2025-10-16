//
//  EveryMatrixAPI.swift
//  ServicesProvider
//
//  Created by André Lascas on 09/07/2025.
//

import Foundation

enum EveryMatrixPlayerAPI {
    case login(username: String, password: String)
    case getRegistrationConfig
    case registerStep(form: PhoneSignUpForm)
    case register(registrationId: String)
    case getUserProfile(userId: String)
    case getUserBalance(userId: String)
    case getBankingWebView(userId: String, parameters: EveryMatrix.GetPaymentSessionRequest)
    case getWageringTransactions(userId: String, startDate: String, endDate: String, pageNumber: Int?)
    case getBankingTransactions(userId: String, startDate: String, endDate: String, pageNumber: Int?)
    case getRecentlyPlayedGames(playerId: String, language: String, platform: String, offset: Int, limit: Int)
    case getMostPlayedGames(playerId: String, language: String, platform: String, offset: Int, limit: Int)

    // Betting Offer Booking API endpoints
    case createBookingCode(bettingOfferIds: [String], originalSelectionsLength: Int)
    case getFromBookingCode(code: String)

    // Odds Boost / Bonus Wallet API
    case getSportsBonusWallets(request: EveryMatrix.OddsBoostWalletRequest)
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
        case .getBankingWebView(let userId, _):
            return "/v1/player/\(userId)/payment/GetPaymentSession"
        case .getWageringTransactions(let userId, _, _, _):
            return "/v1/player/\(userId)/transactions/wagering"
        case .getBankingTransactions(let userId, _, _, _):
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
        case .getBankingTransactions(_, let startDate, let endDate, let pageNumber):
            var queryItems = [
                URLQueryItem(name: "startDate", value: startDate),
                URLQueryItem(name: "endDate", value: endDate)
            ]
            if let pageNumber = pageNumber {
                queryItems.append(URLQueryItem(name: "page", value: String(pageNumber)))
            }
            return queryItems
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
        default:
            return nil
        }
    }
    
    var headers: HTTP.Headers? {

        switch self {
        case .getUserProfile, .getUserBalance, .getWageringTransactions, .getBankingTransactions:
            let headers = [
                "Content-Type": "application/json",
                "User-Agent": "GOMA/native-app/iOS",
                "X-Session-Type": "others",
                "Accept": "application/json"
            ]
            return headers
        case .getBankingWebView:
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
        case .getSportsBonusWallets(let request):
            return try? JSONEncoder().encode(request)
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
        case .getBankingWebView:
            return true
        case .getWageringTransactions, .getBankingTransactions:
            return true
        case .getRecentlyPlayedGames:
            return true
        case .getSportsBonusWallets:
            return true
        default:
            return false
        }

    }
    
    var comment: String? {
        return nil
    }

}

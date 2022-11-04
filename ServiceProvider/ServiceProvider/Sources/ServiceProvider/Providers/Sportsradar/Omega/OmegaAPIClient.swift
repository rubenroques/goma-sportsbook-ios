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
    case openSession(productCode: String, gameId: String)
    case logout
    case playerInfo
    case balanceSimple
    case updatePlayerInfo(username: String?, email: String?, firstName: String?, lastName: String?,
                          birthDate: Date?, gender: String?, address: String?, province: String?,
                          city: String?, postalCode: String?, country: String?, cardId: String?)
    case checkCredentialEmail(email: String)
    case quickSignup(email: String, username: String, password: String, birthDate: Date,
                     mobilePrefix: String, mobileNumber: String, countryIsoCode: String, currencyCode: String)
    case resendVerificationCode(username: String)
    case signupConfirmation(email: String, confirmationCode: String)

    case getCountries
    case getCurrentCountry

    case forgotPassword(email: String, secretQuestion: String? = nil, secretAnswer: String? = nil)
    case updatePassword(oldPassword: String, newPassword: String)
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
        case .balanceSimple:
            return "/ps/ips/getBalanceSimple"
        case .updatePlayerInfo:
            return "/ps/ips/updatePlayerInfo"
        case .checkCredentialEmail:
            return "/ps/ips/checkCredential"
        case .quickSignup:
            return "/ps/ips/quickSignup"
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
        }
    }
    
    var query: [URLQueryItem]? {
        switch self {
        case .login(let username, let password):
            return [URLQueryItem(name: "username", value: username),
                    URLQueryItem(name: "password", value: password)]
        case .openSession(let productCode, let gameId):
            return [URLQueryItem(name: "productCode", value: productCode),
                    URLQueryItem(name: "gameId", value: gameId)]
        case .logout:
            return nil
        case .playerInfo:
            return nil
        case .balanceSimple:
            return nil
        case .checkCredentialEmail(let email):
            return [URLQueryItem(name: "field", value: "email"),
                    URLQueryItem(name: "value", value: email)]
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
                URLQueryItem(name: "mobile", value: phoneNumber),
            ]
        case .resendVerificationCode(let username):
            return [
                URLQueryItem(name: "username", value: username),
                URLQueryItem(name: "verificationTarget", value: "email"),
            ]
        case .signupConfirmation(let email, let confirmationCode):
            return [
                URLQueryItem(name: "confirmationCode", value: confirmationCode),
                URLQueryItem(name: "email", value: email),
                // URLQueryItem(name: "ipAddress", value: Self.getIPAddress()),
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
            return [
                //URLQueryItem(name: "ipAddress", value: Self.getIPAddress()),
            ]
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
        }
    }
    
    
    var method: HTTP.Method {
        switch self {
        case .login: return .get
        case .openSession: return .get
        case .logout: return .get
        case .playerInfo: return .get
        case .balanceSimple: return .get
        case .updatePlayerInfo: return .get
        case .checkCredentialEmail: return .get
        case .quickSignup: return .get
        case .resendVerificationCode: return .get
        case .signupConfirmation: return .get
        case .getCountries: return .get
        case .getCurrentCountry: return .get
        case .forgotPassword: return .get
        case .updatePassword: return .get
        }
    }
    
    var body: Data? {
        return nil
        
        /**
         let body = """
         {"type": "\(type)","text": "\(message)"}
         """
         let data = body.data(using: String.Encoding.utf8)!
         return data
         */
    }
    
    var requireSessionKey: Bool {
        switch self {
        case .openSession, .logout, .playerInfo, .balanceSimple, .updatePlayerInfo, .updatePassword:
            return true
        default:
            return false
        }
    }
    
    var url: String {
        return "https://ps.omegasys.eu"
    }
    
    var headers: HTTP.Headers? {
        let defaultHeaders = [
            "Accept-Encoding": "gzip, deflate",
            "Content-Type": "application/json; charset=UTF-8",
            "Accept": "application/json"
        ]
        return defaultHeaders
    }
    
    var cachePolicy: URLRequest.CachePolicy {
        return .reloadIgnoringLocalCacheData
    }
    
    var timeout: TimeInterval {
        return TimeInterval(20)
    }
    
}
extension OmegaAPIClient {
    static func getIPAddress() -> String {
        var address: String?
        var ifaddr: UnsafeMutablePointer<ifaddrs>? = nil
        if getifaddrs(&ifaddr) == 0 {
            var ptr = ifaddr
            while ptr != nil {
                defer { ptr = ptr?.pointee.ifa_next }
                
                guard let interface = ptr?.pointee else { return "" }
                let addrFamily = interface.ifa_addr.pointee.sa_family
                if addrFamily == UInt8(AF_INET) || addrFamily == UInt8(AF_INET6) {
                    
                    // wifi = ["en0"]
                    // wired = ["en2", "en3", "en4"]
                    // cellular = ["pdp_ip0","pdp_ip1","pdp_ip2","pdp_ip3"]
                    let name: String = String(cString: (interface.ifa_name))
                    if  name == "en0" || name == "en2" || name == "en3" || name == "en4" || name == "pdp_ip0" || name == "pdp_ip1" || name == "pdp_ip2" || name == "pdp_ip3" {
                        var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                        getnameinfo(interface.ifa_addr, socklen_t((interface.ifa_addr.pointee.sa_len)), &hostname, socklen_t(hostname.count), nil, socklen_t(0), NI_NUMERICHOST)
                        address = String(cString: hostname)
                    }
                }
            }
            freeifaddrs(ifaddr)
        }
        return address ?? ""
    }
}

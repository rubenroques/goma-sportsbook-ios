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
 */

enum OmegaAPIClient {
    case login(username: String, password: String)
    case openSession(sessionKey: String, productCode: String, gameId: String)
    case logout(sessionKey: String)
    case playerInfo(sessionKey: String)
    case balanceSimple(sessionKey: String)
    case updateUserInfo(sessionKey: String)
    case checkCredentialEmail(email: String)
    case quickSignup(email: String, username: String, password: String, birthDate: Date,
                     mobilePrefix: String, mobileNumber: String, countryIsoCode: String, currencyCode: String)
    case resendVerificationCode(username: String)
    case signupConfirmation(email: String, confirmationCode: String)
    
    case getCountries
    case getCurrentCountry
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
        case .updateUserInfo:
            return "/ps/ips/updateUserInfo"
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
        }
    }
    
    var query: [URLQueryItem]? {
        switch self {
        case .login(let username, let password):
            return [URLQueryItem(name: "username", value: username),
                    URLQueryItem(name: "password", value: password)]
        case .openSession(let sessionKey, let productCode, let gameId):
            return [URLQueryItem(name: "sessionKey", value: sessionKey),
                    URLQueryItem(name: "productCode", value: productCode),
                    URLQueryItem(name: "gameId", value: gameId)]
        case .logout(let sessionKey):
            return [URLQueryItem(name: "sessionKey", value: sessionKey)]
        
        case .playerInfo(let sessionKey):
            return [URLQueryItem(name: "sessionKey", value: sessionKey)]
        case .balanceSimple(let sessionKey):
            return [URLQueryItem(name: "sessionKey", value: sessionKey)]
        case .updateUserInfo(let sessionKey):
            return [URLQueryItem(name: "sessionKey", value: sessionKey)]
        
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
        case .getCountries:
            return nil
        case .getCurrentCountry:
            return [
                //URLQueryItem(name: "ipAddress", value: Self.getIPAddress()),
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
        case .updateUserInfo: return .get
        case .checkCredentialEmail: return .get
        case .quickSignup: return .get
        case .resendVerificationCode: return .get
        case .signupConfirmation: return .get
        case .getCountries: return .get
        case .getCurrentCountry: return .get
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

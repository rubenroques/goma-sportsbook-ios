//
//  SumsubDataProvider.swift
//  
//
//  Created by André Lascas on 13/06/2023.
//

import Foundation
import Combine
import CryptoKit

public class SumsubDataProvider {

    // Sumsub keys
    let sumsubAppToken = "sbx:yjCFqKsuTX6mTY7XMFFPe6hR.v9i5YpFrNND0CeLcZiHeJnnejrCUDZKT"
    let sumsubSecretKey = "4PH7gdufQfrFpFS35gJiwz9d2NFZs4kM"
    let customAllowedEncodingSet = NSCharacterSet(charactersIn:" ").inverted

    init() {

    }

    public func getSumsubAccessToken(userId: String, levelName: String) -> AnyPublisher<AccessTokenResponse, ServiceProviderError> {

        let urlString = "https://api.sumsub.com/resources/accessTokens?userId=\(userId)&levelName=\(levelName)".addingPercentEncoding(withAllowedCharacters: self.customAllowedEncodingSet) ?? ""

        let secretKeyData = self.sumsubSecretKey.data(using: String.Encoding.utf8) ?? Data()

        guard let url = URL(string: urlString) else {
            return Fail(error: ServiceProviderError.invalidResponse).eraseToAnyPublisher()
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        let urlPath = url.path + "?\(url.query ?? "")"
        let headers = generateSignatureHeaders(url: urlPath, method: request.httpMethod ?? "", secretKeyData: secretKeyData, appToken: self.sumsubAppToken)

        for (key, header) in headers {
            request.addValue(header, forHTTPHeaderField: key)
        }

        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { data, response -> Data in
                guard let httpResponse = response as? HTTPURLResponse,
                      (200...299).contains(httpResponse.statusCode) else {
                    throw ServiceProviderError.internalServerError
                }
                return data
            }
            .decode(type: AccessTokenResponse.self, decoder: JSONDecoder())
            .mapError { error -> ServiceProviderError in
                if let error = error as? ServiceProviderError {
                    return error
                } else {
                    return .internalServerError
                }
            }
            .eraseToAnyPublisher()

    }

    public func getApplicantData(userId: String) -> AnyPublisher<ApplicantDataResponse, ServiceProviderError> {

        let urlString = "https://api.sumsub.com/resources/applicants/-;externalUserId=\(userId)/one".addingPercentEncoding(withAllowedCharacters: self.customAllowedEncodingSet) ?? ""

        let secretKeyData = self.sumsubSecretKey.data(using: .utf8) ?? Data()

        guard let url = URL(string: urlString) else {
            return Fail(error: ServiceProviderError.invalidResponse).eraseToAnyPublisher()
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        let urlPath = url.path
        let headers = generateSignatureHeaders(url: urlPath, method: request.httpMethod ?? "", secretKeyData: secretKeyData, appToken: self.sumsubAppToken)

        for (key, header) in headers {
            request.addValue(header, forHTTPHeaderField: key)
        }

        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { data, response -> Data in
                guard let httpResponse = response as? HTTPURLResponse,
                      (200...299).contains(httpResponse.statusCode) else {
                    throw ServiceProviderError.internalServerError
                }
                return data
            }
            .decode(type: ApplicantDataResponse.self, decoder: JSONDecoder())
            .mapError { error -> ServiceProviderError in
                if let error = error as? ServiceProviderError {
                    return error
                } else {
                    return .internalServerError
                }
            }
            .eraseToAnyPublisher()
    }

    private func generateSignatureHeaders(url: String, method: String, bodyData: Data? = nil, secretKeyData: Data, appToken: String) -> [String: String] {

        let ts = Int(Date().timeIntervalSince1970)

        var dataToSign = "\(ts)\(method.uppercased())\(url)"

        if let bodyData {
            dataToSign += String(data: bodyData, encoding: .utf8) ?? ""
        }

        let data = Data(dataToSign.utf8)

        let hmac = HMAC<SHA256>.authenticationCode(for: data, using: SymmetricKey(data: secretKeyData))
        let signature = hmac.compactMap { String(format: "%02x", $0) }.joined()

        let headers = [
            "X-App-Token": "\(appToken)",
            "X-App-Access-Sig": signature,
            "X-App-Access-Ts": "\(ts)"
        ]

        return headers
    }
}

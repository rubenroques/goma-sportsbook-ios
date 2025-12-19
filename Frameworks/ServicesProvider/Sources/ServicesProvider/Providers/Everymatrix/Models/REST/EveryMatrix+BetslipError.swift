//
//  EveryMatrixBetAPIError.swift
//  ServicesProvider
//
//  Created by Leonardo Soares on 19/12/2025.
//

import Foundation

extension EveryMatrix {
    
    struct BetslipError: Decodable {
        let response: BetslipErrorResponse?
        
        struct BetslipErrorResponse: Decodable {
            let errorCode: String?
            let errorMessage: String?
        }
    }
}

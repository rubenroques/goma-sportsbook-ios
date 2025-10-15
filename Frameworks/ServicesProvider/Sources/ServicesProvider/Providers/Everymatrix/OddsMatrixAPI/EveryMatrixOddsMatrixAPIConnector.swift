//
//  EveryMatrixOddsMatrixAPIConnector.swift
//  ServicesProvider
//
//  Created by André Lascas on 14/08/2025.
//

import Foundation
import Combine

class EveryMatrixOddsMatrixAPIConnector: EveryMatrixBaseConnector {

    private var cancellables: Set<AnyCancellable> = []

    init(sessionCoordinator: EveryMatrixSessionCoordinator,
         session: URLSession = .shared,
         decoder: JSONDecoder = JSONDecoder()) {
        super.init(sessionCoordinator: sessionCoordinator,
                   apiIdentifier: "OddsMatrix",
                   session: session,
                   decoder: decoder)
    }
    
} 

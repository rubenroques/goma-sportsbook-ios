//
//  EveryMatrixRecsysAPIConnector.swift
//
//  Connector for the RecSys API, aligned with EveryMatrixBaseConnector behavior.
//

import Foundation
import Combine

class EveryMatrixRecsysAPIConnector: EveryMatrixBaseConnector {
    
    init(sessionCoordinator: EveryMatrixSessionCoordinator,
         session: URLSession = .shared,
         decoder: JSONDecoder = JSONDecoder()) {
        super.init(sessionCoordinator: sessionCoordinator,
                   apiIdentifier: "RecsysAPI",
                   session: session,
                   decoder: decoder)
    }
    
    // Additional RecSys-specific helpers can be added here if needed.
}



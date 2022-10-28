//
//  File.swift
//  
//
//  Created by Ruben Roques on 26/10/2022.
//

import Foundation
import Combine

struct OmegaSessionAccessToken: SessionAccessToken {
    var hash: String
}

class OmegaConnector: NSObject, Connector {
    
    var token: SessionAccessToken?
    
    var connectionStateSubject: CurrentValueSubject<ConnectorState, Error> = .init(.connected)
    var connectionStatePublisher: AnyPublisher<ConnectorState, Error> {
        connectionStateSubject.eraseToAnyPublisher()
    }
    
    func connect() {
        
    }
    
    func refreshConnection() {
        
    }
    
    func disconnect() {
        
    }
    
}

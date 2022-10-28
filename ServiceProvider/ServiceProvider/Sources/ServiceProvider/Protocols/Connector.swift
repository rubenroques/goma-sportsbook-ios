//
//  File.swift
//  
//
//  Created by Ruben Roques on 07/10/2022.
//

import Foundation
import Combine

protocol SessionAccessToken {
    var hash: String { get }
}

public enum ConnectorState {
    case connected
    case disconnected
}

protocol Connector {
    
    var token: SessionAccessToken? { get set }
 
    var connectionStatePublisher: AnyPublisher<ConnectorState, Error> { get }
    
    func connect()
    func refreshConnection()
    func disconnect()
    
}

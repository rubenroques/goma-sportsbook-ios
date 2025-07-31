//
//  File.swift
//  
//
//  Created by Ruben Roques on 07/10/2022.
//

import Foundation
import Combine

public enum ConnectorState {
    case connected
    case disconnected
}

public protocol Connector {
 
    var connectionStatePublisher: AnyPublisher<ConnectorState, Never> { get }
    
}

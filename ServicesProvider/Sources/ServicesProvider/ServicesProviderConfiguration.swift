//
//  File.swift
//  
//
//  Created by Ruben Roques on 27/09/2023.
//

import Foundation

public struct ServicesProviderConfiguration {
    
    public enum Environment {
        case production // PROD
        case staging // UAT
        case development
    }
    
    private(set) var environment: Environment = .production
    
    public init(environment: Environment = .production) {
        self.environment = environment
    }
    
}

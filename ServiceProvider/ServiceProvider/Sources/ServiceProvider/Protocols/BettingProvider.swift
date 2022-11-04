//
//  BettingProvider.swift
//  
//
//  Created by Ruben Roques on 29/09/2022.
//

import Foundation
import Combine

protocol BettingProvider {
    
    init(connector: any Connector)
    
}

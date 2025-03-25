//
//  AppSession.swift
//  Sportsbook
//
//  Created by Ruben Roques on 07/10/2021.
//

import Foundation
import Combine

class AppSession {

    var operatorId: String = "2474"
    var currency: String = "EUR"
    var language: String = "en"

}

struct BusinessModulesManager {
    
    private var businessModules: BusinessModules
    
    init(businessModules: BusinessModules) {
        self.businessModules = businessModules
    }
    
    var isSocialFeaturesEnabled: Bool {
        for module in businessModules where module.name.lowercased() == "social features" {
            return module.enabled
        }
        return false
    }
    
}

//
//  HelloSSWampMessage.swift
//  Tipico
//
//  Created by Andrei Marinescu on 20/12/2019.
//  Copyright © 2019 Tipico. All rights reserved.
//

import Foundation

/// [HELLO, realm|string, details|dict]
class HelloSSWampMessage: SSWampMessage {
    
    let realm: String
    let details: [String: Any]
    
    init(realm: String, details: [String: Any]) {
        self.realm = realm
        self.details = details
    }
        
    required init(payload: [Any]) {
        self.realm = payload[0] as! String
        self.details = payload[1] as! [String: Any]
    }
    
    func marshal() -> [Any] {
        return [SSWampMessages.hello.rawValue, self.realm, self.details]
    }
}

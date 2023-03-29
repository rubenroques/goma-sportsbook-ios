//
//  RegisteredSSWampMessage.swift
//  Tipico
//
//  Created by Andrei Marinescu on 20/12/2019.
//  Copyright © 2019 Tipico. All rights reserved.
//

import Foundation

/// [REGISTERED, requestId|number, registration|number]
class RegisteredSSWampMessage: SSWampMessage {
    
    let requestId: Int
    let registration: Int
    
    init(requestId: Int, registration: Int) {
        self.requestId = requestId
        self.registration = registration
    }
        
    required init(payload: [Any]) {
        self.requestId = payload[0] as! Int
        self.registration = payload[1] as! Int
    }
    
    func marshal() -> [Any] {
        return [SSWampMessages.registered.rawValue, self.requestId, self.registration]
    }
}

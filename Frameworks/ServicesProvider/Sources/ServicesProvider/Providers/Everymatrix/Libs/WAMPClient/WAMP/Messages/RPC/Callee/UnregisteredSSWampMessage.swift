//
//  UnregisteredSSWampMessage.swift
//  Tipico
//
//  Created by Andrei Marinescu on 20/12/2019.
//  Copyright © 2019 Tipico. All rights reserved.
//

import Foundation

/// [UNREGISTERED, requestId|number]
class UnregisteredSSWampMessage: SSWampMessage {
    
    let requestId: Int
    
    init(requestId: Int) {
        self.requestId = requestId
    }
        
    required init(payload: [Any]) {
        self.requestId = payload[0] as! Int
    }
    
    func marshal() -> [Any] {
        return [SSWampMessages.unregistered.rawValue, self.requestId]
    }
}

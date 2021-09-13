//
//  AbortSSWampMessage.swift
//  Tipico
//
//  Created by Andrei Marinescu on 20/12/2019.
//  Copyright © 2019 Tipico. All rights reserved.
//

import Foundation

/// [ABORT, details|dict, reason|uri]
class AbortSSWampMessage: SSWampMessage {
    
    let details: [String: AnyObject]
    let reason: String
    
    init(details: [String: AnyObject], reason: String) {
        self.details = details
        self.reason = reason
    }
        
    required init(payload: [Any]) {
        self.details = payload[0] as! [String: AnyObject]
        self.reason = payload[1] as! String
    }
    
    func marshal() -> [Any] {
        return [SSWampMessages.abort.rawValue, self.details, self.reason]
    }
}

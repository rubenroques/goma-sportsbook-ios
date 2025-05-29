//
//  WelcomeSSWampMessage.swift
//  Tipico
//
//  Created by Andrei Marinescu on 20/12/2019.
//  Copyright © 2019 Tipico. All rights reserved.
//

import Foundation

/// [WELCOME, sessionId|number, details|Dict]
class WelcomeSSWampMessage: SSWampMessage {
    
    let sessionId: Int
    let details: [String: AnyObject]
    
    init(sessionId: Int, details: [String: AnyObject]) {
        self.sessionId = sessionId
        self.details = details
    }
        
    required init(payload: [Any]) {
        self.sessionId = payload[0] as! Int
        self.details = payload[1] as! [String: AnyObject]
    }
    
    func marshal() -> [Any] {
        return [SSWampMessages.welcome.rawValue, self.sessionId, self.details]
    }
}

//
//  UnsubscribedSSWampMessage.swift
//  Tipico
//
//  Created by Andrei Marinescu on 20/12/2019.
//  Copyright © 2019 Tipico. All rights reserved.
//

import Foundation

/// [UNSUBSCRIBED, requestId|number]
class UnsubscribedSSWampMessage: SSWampMessage {
    
    let requestId: Int
    
    init(requestId: Int) {
        self.requestId = requestId
    }
    
    required init(payload: [Any]) {
        self.requestId = payload[0] as! Int
    }
    
    func marshal() -> [Any] {
        return [SSWampMessages.unsubscribed.rawValue, self.requestId]
    }
}

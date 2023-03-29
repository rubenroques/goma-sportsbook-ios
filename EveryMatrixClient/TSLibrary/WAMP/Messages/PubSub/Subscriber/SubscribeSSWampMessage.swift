//
//  SubscribeSSWampMessage.swift
//  Tipico
//
//  Created by Andrei Marinescu on 20/12/2019.
//  Copyright © 2019 Tipico. All rights reserved.
//

import Foundation

/// [SUBSCRIBE, requestId|number, options|dict, topic|string]
class SubscribeSSWampMessage: SSWampMessage {
    
    let requestId: Int
    let options: [String: Any]
    let topic: String
    
    init(requestId: Int, options: [String: Any], topic: String) {
        self.requestId = requestId
        self.options = options
        self.topic = topic
    }
    
    required init(payload: [Any]) {
        self.requestId = payload[0] as! Int
        self.options = payload[1] as! [String: Any]
        self.topic = payload[2] as! String
    }
    
    func marshal() -> [Any] {
        return [SSWampMessages.subscribe.rawValue, self.requestId, self.options, self.topic]
    }
}

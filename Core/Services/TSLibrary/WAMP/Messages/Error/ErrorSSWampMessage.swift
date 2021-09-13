//
//  ErrorSSWampMessage.swift
//  Tipico
//
//  Created by Andrei Marinescu on 20/12/2019.
//  Copyright © 2019 Tipico. All rights reserved.
//

import Foundation

/// [ERROR, requestType|number, requestId|number, details|dict, error|string, args|array?, kwargs|dict?]
class ErrorSSWampMessage: SSWampMessage {
    let requestType: SSWampMessages
    let requestId: Int
    let details: [String: Any]
    let error: String
    let args: [Any]?
    let kwargs: [String: Any]?
    
    init(requestType: SSWampMessages, requestId: Int, details: [String: Any], error: String, args: [Any]?=nil, kwargs: [String: Any]?=nil) {
        self.requestType = requestType
        self.requestId = requestId
        self.details = details
        self.error = error
        self.args = args
        self.kwargs = kwargs
    }
        
    required init(payload: [Any]) {
        self.requestType = SSWampMessages(rawValue: payload[0] as! Int)!
        self.requestId = payload[1] as! Int
        self.details = payload[2] as! [String: Any]
        self.error = payload[3] as! String
        
        self.args = payload[safe: 4] as? [Any]
        self.kwargs = payload[safe: 5] as? [String: Any]
    }
    
    func marshal() -> [Any] {
        var marshalled: [Any] = [SSWampMessages.error.rawValue, self.requestType.rawValue, self.requestId, self.details, self.error]
        if let args = self.args {
            marshalled.append(args)
            if let kwargs = self.kwargs {
                marshalled.append(kwargs)
            }
        } else {
            if let kwargs = self.kwargs {
                marshalled.append([])
                marshalled.append(kwargs)
            }
        }
        return marshalled
    }
}

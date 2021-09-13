//
//  RegisterSSWampMessage.swift
//  Tipico
//
//  Created by Andrei Marinescu on 20/12/2019.
//  Copyright © 2019 Tipico. All rights reserved.
//

import Foundation

/// [Register, requestId|number, options|dict, proc|string]
class RegisterSSWampMessage: SSWampMessage {
    
    let requestId: Int
    let options: [String: AnyObject]
    let proc: String
    
    init(requestId: Int, options: [String: AnyObject], proc: String) {
        self.requestId = requestId
        self.options = options
        self.proc = proc
    }
    
    required init(payload: [Any]) {
        self.requestId = payload[0] as! Int
        self.options = payload[1] as! [String: AnyObject]
        self.proc = payload[2] as! String
    }
    
    func marshal() -> [Any] {
        return [SSWampMessages.register.rawValue, self.requestId, self.options, self.proc]
    }
}

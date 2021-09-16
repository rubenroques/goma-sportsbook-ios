//
//  AuthenticateSSWampMessage.swift
//  Tipico
//
//  Created by Andrei Marinescu on 20/12/2019.
//  Copyright © 2019 Tipico. All rights reserved.
//

import Foundation

/// [AUTHENTICATE, signature|string, extra|dict]
class AuthenticateSSWampMessage: SSWampMessage {
    
    let signature: String
    let extra: [String: Any]
    
    init(signature: String, extra: [String: AnyObject]) {
        self.signature = signature
        self.extra = extra
    }

    required init(payload: [Any]) {
        self.signature  = payload[0] as! String
        self.extra = payload[1] as! [String: Any]
    }
    
    func marshal() -> [Any] {
        return [SSWampMessages.authenticate.rawValue, self.signature, self.extra]
    }
}

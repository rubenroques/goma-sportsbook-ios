//
//  ChallengeSSWampMessage.swift
//  Tipico
//
//  Created by Andrei Marinescu on 20/12/2019.
//  Copyright © 2019 Tipico. All rights reserved.
//

import Foundation

/// [CHALLENGE, authMethod|string, extra|dict]
class ChallengeSSWampMessage: SSWampMessage {
    
    let authMethod: String
    let extra: [String: Any]
    
    init(authMethod: String, extra: [String: Any]) {
        self.authMethod = authMethod
        self.extra = extra
    }
    
    required init(payload: [Any]) {
        self.authMethod = payload[0] as! String
        self.extra = payload[1] as! [String: Any]
    }
    
    func marshal() -> [Any] {
        return [SSWampMessages.challenge.rawValue, self.authMethod, self.extra]
    }
}

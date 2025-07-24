//
//  PublishedSSWampMessage.swift
//  Tipico
//
//  Created by Andrei Marinescu on 20/12/2019.
//  Copyright © 2019 Tipico. All rights reserved.
//

import Foundation

/// [PUBLISHED, requestId|number, options|dict, topic|String, args|list?, kwargs|dict?]
class PublishedSSWampMessage: SSWampMessage {
    
    let requestId: Int
    let publication: Int
    
    init(requestId: Int, publication: Int) {
        self.requestId = requestId
        self.publication = publication
    }
    
    required init(payload: [Any]) {
        self.requestId = payload[0] as! Int
        self.publication = payload[1] as! Int
    }
    
    func marshal() -> [Any] {
        let marshalled: [Any] = [SSWampMessages.published.rawValue, self.requestId, self.publication]
        return marshalled
    }
}

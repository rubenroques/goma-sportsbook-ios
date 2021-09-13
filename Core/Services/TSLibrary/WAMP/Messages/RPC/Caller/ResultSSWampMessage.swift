//
//  ResultSSWampMessage.swift
//  Tipico
//
//  Created by Andrei Marinescu on 20/12/2019.
//  Copyright © 2019 Tipico. All rights reserved.
//

import Foundation

/// [RESULT, requestId|number, details|dict, args|array?, kwargs|dict?]
class ResultSSWampMessage: SSWampMessage {
    
    let requestId: Int
    let details: [String: AnyObject]
    let results: [AnyObject]?
    let kwResults: [String: AnyObject]?
    let arrResults: [String: [AnyObject]]?
    
    
    init(requestId: Int, details: [String: AnyObject], results: [AnyObject]?=nil, kwResults: [String: AnyObject]?=nil, arrResults: [String: [AnyObject]]? = nil) {
        self.requestId = requestId
        self.details = details
        self.results = results
        self.kwResults = kwResults
        self.arrResults = arrResults
    }
    
    required init(payload: [Any]) {
        self.requestId = payload[0] as! Int
        self.details = payload[1] as! [String: AnyObject]
        self.results  = payload[safe: 2] as? [AnyObject]
        self.kwResults = payload[safe: 3] as? [String: AnyObject]
        if self.kwResults == nil {
            if let value = payload[safe: 3] as? [AnyObject] {
                self.arrResults = ["locallyInjectedKey" : value]
            } else {
                self.arrResults = nil
            }
        } else {
            self.arrResults = nil
        }
    }
    
    func marshal() -> [Any] {
        var marshalled: [Any] = [SSWampMessages.result.rawValue, self.requestId, self.details]
        if let results = self.results {
            marshalled.append(results)
            if let kwResults = self.kwResults {
                marshalled.append(kwResults)
            }
        } else {
            if let kwResults = self.kwResults {
                marshalled.append([])
                marshalled.append(kwResults)
            }
        }
        return marshalled
    }
    
}

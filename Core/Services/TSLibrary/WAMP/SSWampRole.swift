//
//  SSWampRole.swift
//  Tipico
//
//  Created by Andrei Marinescu on 20/12/2019.
//  Copyright © 2019 Tipico. All rights reserved.
//

import Foundation

enum SSWampRole: String {
    //Client roles
    // swiftlint:disable identifier_name
    case Caller = "caller"
    case Callee = "callee"
    case Subscriber = "subscriber"
    case Publisher = "publisher"
    
    //Route roles
    case Broker = "broker"
    case Dealer = "dealer"
}

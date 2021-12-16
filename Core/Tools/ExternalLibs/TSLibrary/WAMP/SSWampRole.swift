//
//  SSWampRole.swift
//  Tipico
//
//  Created by Andrei Marinescu on 20/12/2019.
//  Copyright © 2019 Tipico. All rights reserved.
//

import Foundation

enum SSWampRole: String {
    // swiftlint:disable identifier_name
    // Client roles
    case Caller = "caller"
    case Callee = "callee"
    case Subscriber = "subscriber"
    case Publisher = "publisher"
    
    // Route roles
    case Broker = "broker"
    case Dealer = "dealer"
}

//
//  SSWampMessage.swift
//  Tipico
//
//  Created by Andrei Marinescu on 20/12/2019.
//  Copyright © 2019 Tipico. All rights reserved.
//

import Foundation

protocol SSWampMessage {
    init(payload: [Any])
    func marshal() -> [Any]
}

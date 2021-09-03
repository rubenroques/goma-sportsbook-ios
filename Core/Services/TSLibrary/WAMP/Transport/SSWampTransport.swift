//
//  SSWampTransport.swift
//  Tipico
//
//  Created by Andrei Marinescu on 20/12/2019.
//  Copyright © 2019 Tipico. All rights reserved.
//

import Foundation

protocol SSWampTransportDelegate: AnyObject {
    func ssWampTransportDidConnectWithSerializer(_ serializer: SSWampSerializer)
    func ssWampTransportDidDisconnect(_ error: Error?, reason: String?)
    func ssWampTransportReceivedData(_ data: Data)
}

protocol SSWampTransport {
    var delegate: SSWampTransportDelegate? { get set }
    func connect()
    func disconnect(_ reason: String)
    func sendData(_ data: Data)
}

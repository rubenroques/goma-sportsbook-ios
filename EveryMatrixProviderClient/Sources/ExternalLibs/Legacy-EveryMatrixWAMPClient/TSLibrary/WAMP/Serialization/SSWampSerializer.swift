//
//  SSWampSerializer.swift
//  Tipico
//
//  Created by Andrei Marinescu on 20/12/2019.
//  Copyright © 2019 Tipico. All rights reserved.
//

import Foundation

protocol SSWampSerializer {
    func pack(_ data: [Any]) -> Data?
      func unpack(_ data: Data) -> [Any]?
}

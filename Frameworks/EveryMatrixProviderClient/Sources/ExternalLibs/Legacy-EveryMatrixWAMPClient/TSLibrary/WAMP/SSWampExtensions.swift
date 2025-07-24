//
//  SSWampExtensions.swift
//  Tipico
//
//  Created by Andrei Marinescu on 20/12/2019.
//  Copyright © 2019 Tipico. All rights reserved.
//

import Foundation

extension Collection {    
    subscript (safe index: Index) -> Iterator.Element? {
           return index >= startIndex && index < endIndex ? self[index] : nil
       }
}

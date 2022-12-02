//
//  Array Extentions.swift
//  
//
//  Created by Ruben Roques on 01/12/2022.
//

import Foundation

public extension Array {
    subscript(safe index: Int) -> Element? {
        guard index >= 0, index < endIndex else {
            return nil
        }
        return self[index]
    }
}


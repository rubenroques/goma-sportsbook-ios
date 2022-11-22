//
//  EventListSort.swift
//  
//
//  Created by Ruben Roques on 21/11/2022.
//

import Foundation

public enum EventListSort {
    case date
    case popular
    
    var id: String {
        switch self {
        case .date:
            return "D"
        case .popular:
            return "T"
        }
    }
    
}

//
//  Publisher+Extensions.swift
//  
//
//  Created by Ruben Roques on 04/12/2022.
//

import Foundation
import Combine

public extension Publisher where Failure == Never {
    func weakAssign<T: AnyObject>(to keyPath: ReferenceWritableKeyPath<T, Output>, on object: T) -> AnyCancellable {
        self.sink { [weak object] value in
            object?[keyPath: keyPath] = value
        }
    }
}

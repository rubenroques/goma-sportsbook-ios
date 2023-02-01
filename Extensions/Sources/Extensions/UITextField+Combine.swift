//
//  File.swift
//  
//
//  Created by Ruben Roques on 16/01/2023.
//

import UIKit
import Combine

public extension UITextField {

    var textPublisher: AnyPublisher<String, Never> {
        NotificationCenter.default.publisher(
            for: UITextField.textDidChangeNotification,
            object: self
        )
        .compactMap { ($0.object as? UITextField)?.text }
        .eraseToAnyPublisher()
    }

}

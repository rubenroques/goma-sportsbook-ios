//
//  RegisterStep.swift
//
//
//  Created by André Lascas on 08/01/2024.
//

import Foundation

public struct RegisterStep {
    var forms: [FormStep]

    public init(forms: [FormStep]) {
        self.forms = forms
    }

}

public extension Optional where Wrapped == String {
    
    var isEmptyOrNil: Bool {
        return self?.isEmpty ?? true
    }
    
}

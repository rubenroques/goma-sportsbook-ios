//
//  NotEmpty.swift
//  AllGoals
//
//  Created by Ruben Roques on 19/12/2019.
//  Copyright © 2019 GOMA Development. All rights reserved.
//

import Foundation

extension Array {
    var isNotEmpty: Bool {
        return !isEmpty
    }
}

extension String {
    var isNotEmpty: Bool {
        return !isEmpty
    }
}

extension Dictionary {
    var isNotEmpty: Bool {
        return !isEmpty
    }
}

extension Set {
    var isNotEmpty: Bool {
        return !isEmpty
    }
}

//
//  UrlSchemaManager.swift
//  Sportsbook
//
//  Created by André Lascas on 03/02/2022.
//

import Foundation
import Combine

class UrlSchemaManager {

    var redirectPublisher: CurrentValueSubject<[String: String], Never>

    init() {
        self.redirectPublisher = .init([:])
    }

    func setRedirect(subject: [String: String]) {
        self.redirectPublisher.value = subject
    }
}

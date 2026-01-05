//
//  SelectOptionsViewModelProtocol.swift
//  GomaUI
//
//  Created by Claude on 07/11/2025.
//

import Foundation
import Combine

public protocol SelectOptionsViewModelProtocol {
    var title: String? { get }
    var options: [SimpleOptionRowViewModelProtocol] { get }
    var selectedOptionId: CurrentValueSubject<String?, Never> { get }
    func selectOption(withId id: String)
}

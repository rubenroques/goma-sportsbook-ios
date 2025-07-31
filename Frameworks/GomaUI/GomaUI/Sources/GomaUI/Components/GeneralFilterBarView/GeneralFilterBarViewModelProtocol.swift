//
//  GeneralFilterBarViewModelProtocol.swift
//  GomaUI
//
//  Created by André Lascas on 13/06/2025.
//

import Foundation
import Combine
import UIKit

// MARK: - Display State

public struct GeneralFilterBarItems {
    public var items: [FilterOptionItem]
    public let mainFilterItem: MainFilterItem
    

    public init(
        items: [FilterOptionItem],
        mainFilterItem: MainFilterItem
    ) {
        self.items = items
        self.mainFilterItem = mainFilterItem
    }
}

// MARK: - View Model Protocol

public protocol GeneralFilterBarViewModelProtocol {
    var generalFilterItemsPublisher: CurrentValueSubject<GeneralFilterBarItems, Never> { get }
    func updateFilterOptionItems(filterOptionItems: [FilterOptionItem])
}

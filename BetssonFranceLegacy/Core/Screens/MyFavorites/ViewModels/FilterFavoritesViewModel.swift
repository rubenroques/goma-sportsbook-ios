//
//  FilterFavoritesViewModel.swift
//  Sportsbook
//
//  Created by André Lascas on 04/08/2023.
//

import Foundation
import Combine

class FilterFavoritesViewModel {

    // MARK: - Publishers
    var selectedFilterPublisher: CurrentValueSubject<FilterFavoritesValue, Never> = .init(.time)
    private var cancellables = Set<AnyCancellable>()

    init() {
    }

    func didSelectFilter(atIndex index: Int) {

        if let selectedFilter = FilterFavoritesValue.init(filterIndex: index) {
            self.selectedFilterPublisher.send(selectedFilter)
        }
    }
}

//
//  MockSelectOptionsViewModel.swift
//  GomaUI
//
//  Created by Claude on 07/11/2025.
//

import Foundation
import Combine

public final class MockSelectOptionsViewModel: SelectOptionsViewModelProtocol {
    public let title: String?
    public let options: [SimpleOptionRowViewModelProtocol]
    public let selectedOptionId: CurrentValueSubject<String?, Never>
    public var onOptionSelected: ((String) -> Void)?
    
    public init(
        title: String? = nil,
        options: [SimpleOptionRowViewModelProtocol],
        selectedOption: String? = nil
    ) {
        self.title = title
        self.options = options
        self.selectedOptionId = CurrentValueSubject(selectedOption)
    }
    
    public func selectOption(withId id: String) {
        selectedOptionId.send(id)
        onOptionSelected?(id)
    }
    
    public static var withTitle: MockSelectOptionsViewModel {
        MockSelectOptionsViewModel(title: "Notification Preferences", options: [
            MockSimpleOptionRowViewModel(option: SortOption(id: "all", icon: nil, title: "All Notifications", count: -1, iconTintChange: false)),
            MockSimpleOptionRowViewModel(option: SortOption(id: "promotions", icon: nil, title: "Promotions", count: -1, iconTintChange: false)),
            MockSimpleOptionRowViewModel(option: SortOption(id: "none", icon: nil, title: "None", count: -1, iconTintChange: false))
        ], selectedOption: "all")
    }
    
    public static var withoutTitle: MockSelectOptionsViewModel {
        MockSelectOptionsViewModel(title: nil, options: [
            MockSimpleOptionRowViewModel.sampleSelected,
            MockSimpleOptionRowViewModel.sampleUnselected
        ], selectedOption: "selected")
    }
}

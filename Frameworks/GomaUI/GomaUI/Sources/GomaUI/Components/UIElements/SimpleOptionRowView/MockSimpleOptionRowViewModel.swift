//
//  MockSimpleOptionRowViewModel.swift
//  GomaUI
//
//  Created by Claude on 07/11/2025.
//

import Foundation

public final class MockSimpleOptionRowViewModel: SimpleOptionRowViewModelProtocol {
    public let option: SortOption
    
    public init(option: SortOption) {
        self.option = option
    }
    
    public static var sampleSelected: MockSimpleOptionRowViewModel {
        MockSimpleOptionRowViewModel(option: SortOption(
            id: "1",
            icon: nil,
            title: "Enable notifications",
            count: -1,
            iconTintChange: false
        ))
    }
    
    public static var sampleUnselected: MockSimpleOptionRowViewModel {
        MockSimpleOptionRowViewModel(option: SortOption(
            id: "2",
            icon: nil,
            title: "Receive personalized offers",
            count: -1,
            iconTintChange: false
        ))
    }
}

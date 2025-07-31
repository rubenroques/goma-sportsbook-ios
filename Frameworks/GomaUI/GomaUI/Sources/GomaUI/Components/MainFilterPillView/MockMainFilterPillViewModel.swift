//
//  MockMainFilterViewModel.swift
//  GomaUI
//
//  Created by André Lascas on 22/05/2025.
//

import Foundation
import Combine

final public class MockMainFilterPillViewModel: MainFilterPillViewModelProtocol {
    
    // MARK: - Properties
    public let mainFilterSubject: CurrentValueSubject<MainFilterItem, Never>
    public var mainFilterState: CurrentValueSubject<MainFilterStateType, Never> = .init(.notSelected)
    
    // MARK: - Initialization
    public init(mainFilter: MainFilterItem) {
        
        self.mainFilterSubject = CurrentValueSubject(mainFilter)
    }
    
    // MARK: - Protocol
    public func didTapMainFilterItem() -> QuickLinkType {
        let quickLinkType = self.mainFilterSubject.value.type
        
        return quickLinkType
    }
}

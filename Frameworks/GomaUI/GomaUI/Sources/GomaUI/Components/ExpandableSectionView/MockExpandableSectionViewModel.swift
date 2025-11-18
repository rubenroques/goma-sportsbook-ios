//
//  MockExpandableSectionViewModel.swift
//  GomaUI
//
//  Mock implementation of ExpandableSectionViewModelProtocol
//

import Foundation
import Combine

/// Mock implementation of ExpandableSectionViewModelProtocol for testing and previews
public class MockExpandableSectionViewModel: ExpandableSectionViewModelProtocol {
    
    // MARK: - Properties
    public let title: String
    
    private let isExpandedSubject: CurrentValueSubject<Bool, Never>
    public var isExpandedPublisher: AnyPublisher<Bool, Never> {
        isExpandedSubject.eraseToAnyPublisher()
    }
    
    // MARK: - Initialization
    public init(title: String, isExpanded: Bool = false) {
        self.title = title
        self.isExpandedSubject = CurrentValueSubject(isExpanded)
    }
    
    // MARK: - Actions
    public func toggleExpanded() {
        let currentValue = isExpandedSubject.value
        isExpandedSubject.send(!currentValue)
    }
    
    // MARK: - Convenience Factory Methods
    
    /// Default mock with standard configuration
    public static var defaultMock: MockExpandableSectionViewModel {
        MockExpandableSectionViewModel(title: "Information", isExpanded: false)
    }
    
    /// Mock with initially expanded state
    public static var expandedMock: MockExpandableSectionViewModel {
        MockExpandableSectionViewModel(title: "Details", isExpanded: true)
    }
    
    /// Mock with custom title
    public static func customMock(title: String, isExpanded: Bool = false) -> MockExpandableSectionViewModel {
        MockExpandableSectionViewModel(title: title, isExpanded: isExpanded)
    }
}




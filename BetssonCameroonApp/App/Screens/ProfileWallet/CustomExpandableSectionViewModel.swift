//
//  CustomExpandableSectionViewModel.swift
//  BetssonCameroonApp
//
//  Created on 17/11/2025.
//

import Foundation
import Combine
import GomaUI

final class CustomExpandableSectionViewModel: CustomExpandableSectionViewModelProtocol {
    public var title: String
    public var leadingIconName: String?
    public var collapsedIconName: String?
    public var expandedIconName: String?
    
    private let subject: CurrentValueSubject<Bool, Never>
    
    public var isExpandedPublisher: AnyPublisher<Bool, Never> {
        subject.eraseToAnyPublisher()
    }
    
    public init(
        title: String,
        isExpanded: Bool = false,
        leadingIconName: String? = "info.circle",
        collapsedIconName: String? = "chevron.down",
        expandedIconName: String? = "chevron.up"
    ) {
        self.title = title
        self.leadingIconName = leadingIconName
        self.collapsedIconName = collapsedIconName
        self.expandedIconName = expandedIconName
        self.subject = CurrentValueSubject(isExpanded)
    }
    
    public func toggleExpanded() {
        subject.send(!subject.value)
    }
}



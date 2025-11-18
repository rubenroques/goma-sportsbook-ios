//
//  MockCustomExpandableSectionViewModel.swift
//  GomaUI
//
//  Created by André on 17/11/2025.
//
//  NOTE: This is an internal mock implementation for use within the GomaUI library only.
//  For production use, create your own implementation of CustomExpandableSectionViewModelProtocol.

import Combine
import Foundation

internal final class MockCustomExpandableSectionViewModel: CustomExpandableSectionViewModelProtocol {
    internal var title: String
    internal var leadingIconName: String?
    internal var collapsedIconName: String?
    internal var expandedIconName: String?
    
    private let subject: CurrentValueSubject<Bool, Never>
    
    internal var isExpandedPublisher: AnyPublisher<Bool, Never> {
        subject.eraseToAnyPublisher()
    }
    
    internal init(
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
    
    internal func toggleExpanded() {
        subject.send(!subject.value)
    }
    
    // MARK: - Factory Helpers
    internal static var defaultCollapsed: MockCustomExpandableSectionViewModel {
        MockCustomExpandableSectionViewModel(title: "Account Overview", isExpanded: false, leadingIconName: "person.crop.circle")
    }
    
    internal static var defaultExpanded: MockCustomExpandableSectionViewModel {
        MockCustomExpandableSectionViewModel(title: "Responsible Gaming", isExpanded: true, leadingIconName: "shield.lefthalf.fill")
    }
    
    internal static func custom(title: String, icon: String?, collapsedIcon: String? = "chevron.down", expandedIcon: String? = "chevron.up", isExpanded: Bool = false) -> MockCustomExpandableSectionViewModel {
        MockCustomExpandableSectionViewModel(
            title: title,
            isExpanded: isExpanded,
            leadingIconName: icon,
            collapsedIconName: collapsedIcon,
            expandedIconName: expandedIcon
        )
    }
}


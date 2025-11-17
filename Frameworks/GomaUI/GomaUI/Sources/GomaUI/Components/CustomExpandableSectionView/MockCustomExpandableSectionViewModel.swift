//
//  MockCustomExpandableSectionViewModel.swift
//  GomaUI
//
//  Created by GPT-5.1 Codex on 17/11/2025.
//

import Combine
import Foundation

public final class MockCustomExpandableSectionViewModel: CustomExpandableSectionViewModelProtocol {
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
    
    // MARK: - Factory Helpers
    public static var defaultCollapsed: MockCustomExpandableSectionViewModel {
        MockCustomExpandableSectionViewModel(title: "Account Overview", isExpanded: false, leadingIconName: "person.crop.circle")
    }
    
    public static var defaultExpanded: MockCustomExpandableSectionViewModel {
        MockCustomExpandableSectionViewModel(title: "Responsible Gaming", isExpanded: true, leadingIconName: "shield.lefthalf.fill")
    }
    
    public static func custom(title: String, icon: String?, collapsedIcon: String? = "chevron.down", expandedIcon: String? = "chevron.up", isExpanded: Bool = false) -> MockCustomExpandableSectionViewModel {
        MockCustomExpandableSectionViewModel(
            title: title,
            isExpanded: isExpanded,
            leadingIconName: icon,
            collapsedIconName: collapsedIcon,
            expandedIconName: expandedIcon
        )
    }
}


//
//  ResponsibleGamingViewModel.swift
//  BetssonCameroonApp
//
//  Created by Claude on November 6, 2025.
//

import Foundation
import Combine
import ServicesProvider
import GomaUI

class ResponsibleGamingViewModel {
    
    // MARK: - Properties
    var cancellables = Set<AnyCancellable>()
    
    // MARK: - ExpandableSection ViewModels
    var informationSectionViewModel: ExpandableSectionViewModelProtocol
    var informationTextSectionViewModels: [TextSectionViewModelProtocol]
    
    // MARK: - Navigation Callbacks
    var onNavigateBack: (() -> Void) = { }
    
    let servicesProvider: ServicesProvider.Client
    
    // MARK: - Initialization
    init(servicesProvider: ServicesProvider.Client) {
        self.servicesProvider = servicesProvider
        
        // Initialize expandable section view model
        self.informationSectionViewModel = MockExpandableSectionViewModel(
            title: localized("information"),
            isExpanded: false
        )
        
        self.informationTextSectionViewModels = (1...15).map { index in
            let isHighlightPrimary = (12...15).contains(index)
            let titleColor = isHighlightPrimary ? StyleProvider.Color.highlightPrimary : StyleProvider.Color.textPrimary
            let descriptionColor = isHighlightPrimary ? StyleProvider.Color.highlightPrimary : StyleProvider.Color.textSecondary
            let spacing: CGFloat = index == 1 ? 8 : 12
            let content = TextSectionContent(
                title: localized("rg_information_title_\(index)"),
                description: localized("rg_information_description_\(index)"),
                titleTextColor: titleColor,
                descriptionTextColor: descriptionColor,
                titleFont: StyleProvider.fontWith(type: .semibold, size: 14),
                descriptionFont: StyleProvider.fontWith(type: .regular, size: 13),
                spacing: spacing
            )
            return MockTextSectionViewModel(content: content)
        }
    }
    
    // MARK: - Public Methods
    func navigateBack() {
        onNavigateBack()
    }
}


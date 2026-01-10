//
//  ResponsibleGameInfoViewModel.swift
//  Sportsbook
//
//  Created by André Lascas on 28/10/2025.
//

import Foundation

class ResponsibleGameInfoViewModel {
    
    // MARK: - Properties
    var aspectRatio: CGFloat = 1.0
    
    // Highlight Text Section ViewModels
    lazy var highlightTextSectionViewModel: HighlightTextSectionViewModelProtocol = {
        return HighlightTextSectionViewModel(
            title: localized("responsible_gaming_page_title_1"),
            description: localized("responsible_gaming_page_description_1")
        )
    }()
    
    lazy var highlightTextSectionViewModel2: HighlightTextSectionViewModelProtocol = {
        return HighlightTextSectionViewModel(
            title: localized("responsible_gaming_page_title_2"),
            description: localized("responsible_gaming_page_description_2")
        )
    }()
    
    lazy var highlightTextSectionViewModel3: HighlightTextSectionViewModelProtocol = {
        return HighlightTextSectionViewModel(
            title: localized("responsible_gaming_page_title_3"),
            description: localized("responsible_gaming_page_description_3")
        )
    }()
    
    // MARK: - Lifecycle
    init() {
    }
}


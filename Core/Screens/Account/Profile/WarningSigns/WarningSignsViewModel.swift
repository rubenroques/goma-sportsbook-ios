//
//  WarningSignsViewModel.swift
//  Sportsbook
//
//  Created by André Lascas on 28/10/2025.
//

import Foundation

class WarningSignsViewModel {
    // MARK: - Properties
    var aspectRatio: CGFloat = 1.0
    
    // Highlight Text Section ViewModel
    lazy var highlightTextSectionViewModel: HighlightTextSectionViewModelProtocol = {
        return HighlightTextSectionViewModel(
            title: localized("warning_signs_page_title_1"),
            description: localized("warning_signs_page_subtitle_1")
        )
    }()
    
    // MARK: - Lifecycle
    init() {}
}

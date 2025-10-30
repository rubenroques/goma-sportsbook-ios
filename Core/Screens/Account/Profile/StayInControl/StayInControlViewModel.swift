//
//  StayInControlViewModel.swift
//  Sportsbook
//
//  Created by André Lascas on 28/10/2025.
//

import Foundation

class StayInControlViewModel {
    
    // MARK: - Properties
    var aspectRatio: CGFloat = 1.0
    
    // Highlight Text Section ViewModel
    lazy var highlightTextSectionViewModel: HighlightTextSectionViewModelProtocol = {
        return HighlightTextSectionViewModel(
            title: localized("stay_in_control_page_title_1"),
            description: localized("stay_in_control_page_description_1")
        )
    }()
    
    // MARK: - Lifecycle
    init() {
    }
}


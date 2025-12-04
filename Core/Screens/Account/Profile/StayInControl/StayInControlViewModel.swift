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
    
    lazy var highlightTextSection2ViewModel: HighlightTextSectionViewModelProtocol = {
        return HighlightTextSectionViewModel(
            title: localized("stay_in_control_page_title_2"),
            description: localized("stay_in_control_page_description_2")
        )
    }()
    
    let sosLink: String = "https://www.sosjoueurs.org/"
    let gamersInfoLink: String = "https://www.joueurs-info-service.fr/?at_medium=sl&at_campaign=2024-07-01-Changer-SEA-SPF-Joueur_info_service_MCJoueursInfoService_Textuelle"
    let requestsLink: String = "https://support.betsson.fr/hc/fr/requests/new"
    
    // MARK: - Callbacks
    var onInternalLinkTapped: ((InternalLinkType) -> Void)?
    
    // MARK: - Lifecycle
    init() {
    }
    
    // MARK: - Methods
    func handleInternalLink(_ linkType: InternalLinkType) {
        self.onInternalLinkTapped?(linkType)
    }
    
    func requiresLogin(for linkType: InternalLinkType) -> Bool {
        switch linkType {
        case .history, .limits, .selfExclusion:
            return true
        case .responsibleGaming:
            return false
        }
    }
}

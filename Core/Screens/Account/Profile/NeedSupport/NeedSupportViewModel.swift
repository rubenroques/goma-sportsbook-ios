//
//  NeedSupportViewModel.swift
//  Sportsbook
//
//  Created by André Lascas on 28/10/2025.
//

import Foundation
import UIKit

class NeedSupportViewModel {
    
    // MARK: - Properties
    var aspectRatio: CGFloat = 1.0
    var contactButtonUrl: String = "https://support.betsson.fr/hc/fr/requests/new"
    var anjImageViewUrl: String = "https://anj.fr/foire-aux-questions/addiction-au-jeu"
    var sosButtonUrl: String = "https://www.sosjoueurs.org/nos-outils/test-le-jeu-et-vous"
    var anjButtonUrl: String = "https://anj.fr/ts/demande-interdiction"
    
    // Highlight Description ViewModel
    lazy var highlightDescriptionViewModel: HighlightDescriptionViewModelProtocol = {
        return HighlightDescriptionViewModel(
            texts: [
                HighlightedText(text: localized("need_support_page_description_2_part_3"), isHighlighted: false),
                HighlightedText(text: localized("need_support_page_description_2_part_4"), isHighlighted: true),
                HighlightedText(text: localized("need_support_page_description_2_part_5"), isHighlighted: false)
            ]
        )
    }()
    
    // Logo Description ViewModel
    lazy var arpejLogoActionDescriptionViewModel: LogoActionDescriptionViewModelProtocol = {
        return LogoActionDescriptionViewModel(
            logoImageName: "arpej_logo",
            descriptionText: localized("need_support_page_description_2"),
            actionUrl: "https://arpej.eu/self/"
        )
    }()
    
    // Highlight Text Section ViewModels
    lazy var highlightTextSectionViewModel: HighlightTextSectionViewModelProtocol = {
        return HighlightTextSectionViewModel(
            title: localized("need_support_page_title_3"),
            description: localized("need_support_page_description_3")
        )
    }()
    
    lazy var highlightTextSectionViewModel2: HighlightTextSectionViewModelProtocol = {
        return HighlightTextSectionViewModel(
            title: localized("need_support_page_title_4"),
            description: localized("need_support_page_description_4"),
            descriptionFont: AppFont.with(type: .semibold, size: 16)
        )
    }()
    
    // Logo Action Description ViewModels
    lazy var sosLogoViewModel: LogoActionDescriptionViewModelProtocol = {
        return LogoActionDescriptionViewModel(
            logoImageName: "sos_logo",
            descriptionText: localized("need_support_page_description_5_sos"),
            actionUrl: "https://www.sosjoueurs.org/"
        )
    }()
    
    lazy var playerInfoLogoViewModel: LogoActionDescriptionViewModelProtocol = {
        return LogoActionDescriptionViewModel(
            logoImageName: "player_info_logo",
            descriptionText: localized("need_support_page_description_5_joueurs"),
            actionUrl: "https://www.joueurs-info-service.fr/Tout-savoir-sur-le-jeu/Se-faire-aider/L-aide-specialisee"
        )
    }()
    
    lazy var gambanLogoViewModel: LogoActionDescriptionViewModelProtocol = {
        return LogoActionDescriptionViewModel(
            logoImageName: "gamban_logo",
            descriptionText: localized("need_support_page_description_5_gamban"),
            actionUrl: "https://gamban.com/fr/"
        )
    }()
    
    // MARK: - Lifecycle
    init() {
    }
}


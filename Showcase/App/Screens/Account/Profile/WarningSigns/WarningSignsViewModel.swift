//
//  WarningSignsViewModel.swift
//  Sportsbook
//
//  Created by André Lascas on 28/10/2025.
//

import Foundation

enum InternalLinkType {
    case history
    case responsibleGaming
    case stayInControl
    case limits
    case selfExclusion
}

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
    
    lazy var parentalControlHighlightTextSectionViewModel: HighlightTextSectionViewModelProtocol = {
        return HighlightTextSectionViewModel(
            title: localized("warning_signs_page_title_2"),
            description: localized("warning_signs_page_description_2")
        )
    }()
        
    var historyLink: String = "https://betsson.fr/fr/profile/history"
    var responsibleGamingLink: String = "https://betsson.fr/fr/jeu-responsable"
    var limitsLink: String = "https://betsson.fr/fr/profile/jeu-responsable/limits-management"
    var selfExclusionLink: String = "https://betsson.fr/fr/profile/jeu-responsable/self-exclusion"
    var gameInterdictionLink: String = "https://interdictiondejeux.anj.fr/demande-interdiction/presentation"
    var evalujeuImageViewUrl: String = "https://www.evalujeu.fr/"
    var childProtectionLink: String = "https://jeprotegemonenfant.gouv.fr/ecrans/vos-outils-ecran/"
    var eEnfanceLink: String = "https://e-enfance.org/informer/controle-parental/"
    var minorsProtectionLink: String = "https://anj.fr/joueurs/proteger-les-mineurs"
    var iosLink: String = "https://support.apple.com/fr-fr/105055"
    var androidLink: String = "https://play.google.com/store/apps/details?id=com.google.android.apps.kids.familylink&hl=fr"
    var microsoftLink: String = "https://support.microsoft.com/fr-fr/account-billing/configurer-microsoft-family-safety-b6280c9d-38d7-82ff-0e4f-a6cb7e659344"
    var macLink: String = "https://www.apple.com/fr/families/"
    var orangeLink: String = "https://assistance.orange.fr/ordinateurs-peripheriques/installer-et-utiliser/la-securite/controle-parental/controle-parental-d-orange-v6-pc-installer_41743-42551"
    var bouyguesLink: String = "https://www.assistance.bouyguestelecom.fr/s/article/telecharger-logiciel-controle-parental-gratuit"
    var sfrLink: String = "https://assistance.sfr.fr/gestion-client/sfrfamily-controleparental/sfr-family-controle-parental.html"
    var freeLink: String = "https://www.echosdunet.net/free/aide/controle-parental"
    
    // MARK: - Callbacks
    var onInternalLinkTapped: ((InternalLinkType) -> Void)?
    
    // MARK: - Lifecycle
    init() {}
    
    // MARK: - Methods
    func handleInternalLink(_ linkType: InternalLinkType) {
        self.onInternalLinkTapped?(linkType)
    }
    
    func requiresLogin(for linkType: InternalLinkType) -> Bool {
        switch linkType {
        case .history, .limits, .selfExclusion:
            return true
        case .responsibleGaming, .stayInControl:
            return false
        }
    }
}

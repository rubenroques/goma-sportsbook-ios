//
//  SportsbookTargetFeatures.swift
//  BetssonCameroonApp
//
//  Created by Ruben Roques on 23/07/2025.
//

import Foundation

enum SportsbookTargetFeatures: Codable, CaseIterable {

    case lockOutOfLocation

    case chat
    case tips

    case suggestedBets
    case cashout
    case cashback
    case freebets

    case casino

    case responsibleGamingForm
    case legalAgeWarning
    
    case mixMatch
    
    case homeTickets
    case userWalletBalance
    
    case featuredCompetitionInTabBar
}

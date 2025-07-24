//
//  RootActionable.swift
//  Sportsbook
//
//  Created by Ruben Roques on 16/05/2025.
//


protocol RootActionable { 
    func openMatchDetail(matchId: String)                        
    func openBetslipModalWithShareData(ticketToken: String)
    func openCompetitionDetail(competitionId: String)
    func openContactSettings()
    func openBetswipe()
    func openDeposit()
    func openBonus()
    func openDocuments()
    func openCustomerSupport()
    func openFavorites()
    func openPromotions()
    func openRegisterWithCode(code: String)
    func openResponsibleForm()
}

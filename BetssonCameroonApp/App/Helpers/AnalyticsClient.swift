//
//  AnalyticsClient.swift
//  Sportsbook
//
//  Created by Ruben Roques on 29/07/2021.
//

import Foundation
import FirebaseAnalytics
import ServicesProvider

struct AnalyticsClient {

    enum Event {
        case appStart
        case welcomeScreen
        case loginScreen
        case userLogin
        case signupScreen
        case userSignUpSuccess
        case userSignUpFail
        case userRecoverPassword
        case userLogout
        case popularEventsList
        case todayScreen
        case topCompetitionsScreen
        case competitionsScreen
        case changedSport
        case selectedSport(sportId: String)
        case appliedFilterSports
        case appliedFilterLive
        case promoBannerClicked
        case infoDialogButtonClicked
        case addToBetslip
        case firstDeposit(value: Double)
        case purchase(value: Double)
        case sosPlayers
        case playersInfo
        case evaluejeu
        case depositStarted(value: Double, bonusAvailable: String, bonusAccepted: String)
        case depositCancelled(value: Double)
        case withdrawalProcessed(value: Double)
    }

    static func sendEvent(event: Event) {
        var eventTypeKey = ""
        var parameters: [String: String]?

        switch event {
        
        case .appStart:
            eventTypeKey = "app_start"
            
        case .welcomeScreen:
            eventTypeKey = "welcome_screen_appeared"
        
        case .loginScreen:
            eventTypeKey = "login_screen_appeared"
        
        case .userLogin:
            eventTypeKey = "user_login"
            
        case .signupScreen:
            eventTypeKey = "signup_screen_appeared"
            
        case .userSignUpSuccess:
            eventTypeKey = "user_signup_success"
       
        case .userSignUpFail:
            eventTypeKey = "user_signup_fail"
            
        case .userRecoverPassword:
            eventTypeKey = "password_recovery_request"
             
        case .userLogout:
            eventTypeKey = "user_logout"
            
        case .popularEventsList:
            eventTypeKey = "mygames_screen_appeared"
            
        case .todayScreen:
            eventTypeKey = "today_screen_appeared"

        case .topCompetitionsScreen:
            eventTypeKey = "top_competitions_screen_appeared"
            
        case .competitionsScreen:
            eventTypeKey = "competitions_screen_appeared"
        
        case .changedSport:
            eventTypeKey = "changed_sport"
            
        case .selectedSport(sportId: let sportId):
            eventTypeKey = "selected_sport_id"
            parameters = ["sportId": sportId]
            
        case .appliedFilterSports:
            eventTypeKey = "applied_filter_sports"
            
        case .appliedFilterLive:
            eventTypeKey = "applied_filter_live"
            
        case .promoBannerClicked:
            eventTypeKey = "promo_banner_clicked"
            
        case .infoDialogButtonClicked:
            eventTypeKey = "info_dialog_button_clicked"
            
        case .addToBetslip:
            eventTypeKey = "add_to_betslip"
            
        case .firstDeposit(let value):
            eventTypeKey = "first_deposit"
            parameters = ["VALUE": "\(value)", "CURRENCY": "EUR"]
            
        case .purchase(let value):
            eventTypeKey = "purchase"
            parameters = ["VALUE": "\(value)", "CURRENCY": "EUR"]
            
        case .sosPlayers:
            eventTypeKey = "sos_joueur_click"
            
        case .playersInfo:
            eventTypeKey = "joueurs_info_service_click"

        case .evaluejeu:
            eventTypeKey = "evalujeu_click"
            
        case .depositStarted(let value, let bonusAvailable, let bonusAccepted):
            eventTypeKey = "deposit_started"
            parameters = ["VALUE": "\(value)",
                          "BONUS_AVAILABLE": "\(bonusAvailable)",
                          "BONUS_ACCEPTED": "\(bonusAccepted)"]
            
        case .depositCancelled(let value):
            eventTypeKey = "deposit_cancelled"
            parameters = ["VALUE": "\(value)"]
        
        case .withdrawalProcessed(let value):
            eventTypeKey = "withdrawal_processed"
            parameters = ["VALUE": "\(value)"]

        }

        Analytics.logEvent(eventTypeKey.uppercased(), parameters: parameters)
        
        print(eventTypeKey)
    }
}

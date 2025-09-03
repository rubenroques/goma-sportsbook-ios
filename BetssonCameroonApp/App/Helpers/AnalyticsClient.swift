//
//  AnalyticsClient.swift
//  Sportsbook
//
//  Created by Ruben Roques on 29/07/2021.
//

import Foundation
import FirebaseAnalytics
import XPush
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
        // Check user tracking consent
        guard UserDefaults.standard.bool(forKey: "acceptedTracking") else {
            print("Analytics tracking disabled by user consent")
            return
        }
        
        // Send to all configured analytics providers
        sendToFirebaseAnalytics(event: event)
        sendToXtremePush(event: event)
        
        print("Analytics Event: \(event)")
    }
    
    
    
    private static func sendToFirebaseAnalytics(event: Event) {
        let (eventTypeKey, parameters) = mapEventToFirebase(event)
        Analytics.logEvent(eventTypeKey.uppercased(), parameters: parameters)
    }
    
    private static func mapEventToFirebase(_ event: Event) -> (eventType: String, parameters: [String: String]?) {
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
        
        return (eventTypeKey, parameters)
    }
    
    
    private static func mapEventToXtremePush(_ event: Event) -> (eventType: String, parameters: [String: String]?) {
        switch event {
        case .appStart: return ("appStart", nil)
        case .welcomeScreen: return ("welcomeScreen", nil)
        case .loginScreen: return ("loginScreen", nil)
        case .userLogin: return ("userLogin", nil)
        case .signupScreen: return ("signupScreen", nil)
        case .userSignUpSuccess: return ("userSignUpSuccess", nil)
        case .userSignUpFail: return ("userSignUpFail", nil)
        case .userRecoverPassword: return ("userRecoverPassword", nil)
        case .userLogout: return ("userLogout", nil)
        case .popularEventsList: return ("popularEventsList", nil)
        case .todayScreen: return ("todayScreen", nil)
        case .topCompetitionsScreen: return ("topCompetitionsScreen", nil)
        case .competitionsScreen: return ("competitionsScreen", nil)
        case .changedSport: return ("changedSport", nil)
        case .selectedSport: return ("selectedSport", nil)
        case .appliedFilterSports: return ("appliedFilterSports", nil)
        case .appliedFilterLive: return ("appliedFilterLive", nil)
        case .promoBannerClicked: return ("promoBannerClicked", nil)
        case .infoDialogButtonClicked: return ("infoDialogButtonClicked", nil)
        case .addToBetslip: return ("addToBetslip", nil)
        case .firstDeposit: return ("firstDeposit", nil)
        case .purchase: return ("purchase", nil)
        case .sosPlayers: return ("sosPlayers", nil)
        case .playersInfo: return ("playersInfo", nil)
        case .evaluejeu: return ("evaluejeu", nil)
        case .depositStarted: return ("depositStarted", nil)
        case .depositCancelled: return ("depositCancelled", nil)
        case .withdrawalProcessed: return ("withdrawalProcessed", nil)
        }
    }
    
    private static func sendToXtremePush(event: Event) {
        let (eventType, parameters) = mapEventToXtremePush(event)
        XPush.hitEvent(eventType, withValues: parameters)
    }
}

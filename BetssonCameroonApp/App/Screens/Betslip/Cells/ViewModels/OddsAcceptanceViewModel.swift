//
//  OddsAcceptanceViewModel.swift
//  BetssonCameroonApp
//
//  Created by André Lascas on 08/01/2026.
//

import Foundation
import Combine
import UIKit
import GomaUI

class OddsAcceptanceViewModel: OddsAcceptanceViewModelProtocol {
    
    // MARK: - Properties
    private let dataSubject: CurrentValueSubject<OddsAcceptanceData, Never>
    
    var dataPublisher: AnyPublisher<OddsAcceptanceData, Never> {
        dataSubject.eraseToAnyPublisher()
    }
    
    var currentData: OddsAcceptanceData {
        dataSubject.value
    }
    
    // MARK: - Initialization
    init(state: OddsAcceptanceState, labelText: String = localized("accept_odds_change"), linkText: String = localized("accept_odds_change_info"), isEnabled: Bool = true) {
        let initialData = OddsAcceptanceData(state: state, labelText: labelText, linkText: linkText, isEnabled: isEnabled)
        self.dataSubject = CurrentValueSubject(initialData)
    }
    
    // MARK: - Protocol Methods
    func updateState(_ state: OddsAcceptanceState) {
        let newData = OddsAcceptanceData(state: state, labelText: currentData.labelText, linkText: currentData.linkText, isEnabled: currentData.isEnabled, isLinkTappable: currentData.isLinkTappable)
        dataSubject.send(newData)
    }

    func updateLabelText(_ text: String) {
        let newData = OddsAcceptanceData(state: currentData.state, labelText: text, linkText: currentData.linkText, isEnabled: currentData.isEnabled, isLinkTappable: currentData.isLinkTappable)
        dataSubject.send(newData)
    }

    func updateLinkText(_ text: String) {
        let newData = OddsAcceptanceData(state: currentData.state, labelText: currentData.labelText, linkText: text, isEnabled: currentData.isEnabled, isLinkTappable: currentData.isLinkTappable)
        dataSubject.send(newData)
    }

    func setEnabled(_ isEnabled: Bool) {
        let newData = OddsAcceptanceData(state: currentData.state, labelText: currentData.labelText, linkText: currentData.linkText, isEnabled: isEnabled, isLinkTappable: currentData.isLinkTappable)
        dataSubject.send(newData)
    }
    
    func onCheckboxTapped() {
        let newState: OddsAcceptanceState = currentData.state == .accepted ? .notAccepted : .accepted
        updateState(newState)
    }
    
    func onLinkTapped() {
        print("Odds Learn More link tapped! PRODUCTION")
    }
}

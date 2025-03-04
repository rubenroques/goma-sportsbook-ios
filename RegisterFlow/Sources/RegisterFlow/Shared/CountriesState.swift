//
//  CountriesState.swift
//  RegisterFlow
//
//  Created by André Lascas on 20/02/2025.
//

import Foundation
import SharedModels

enum CountriesState {
    case idle
    case loading
    case loaded(countries: [SharedModels.Country])
}

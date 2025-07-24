//
//  ServiceProviderModelMapper+Country.swift
//  BetssonCameroonApp
//
//  Created by Ruben Roques on 22/07/2025.
//

import Foundation
import ServicesProvider
import SharedModels

extension ServiceProviderModelMapper {
    
    static func country(fromServiceProviderCountry serviceProviderCountry: SharedModels.Country) -> Country {
        return Country(name: serviceProviderCountry.name,
                       capital: serviceProviderCountry.capital,
                       region: serviceProviderCountry.region,
                       iso2Code: serviceProviderCountry.iso2Code,
                       iso3Code: serviceProviderCountry.iso3Code,
                       numericCode: serviceProviderCountry.numericCode,
                       phonePrefix: serviceProviderCountry.phonePrefix)
    }
    
    static func country(fromCountry country: Country) -> SharedModels.Country? {
        return SharedModels.Country(isoCode: country.iso2Code)
    }
    
}

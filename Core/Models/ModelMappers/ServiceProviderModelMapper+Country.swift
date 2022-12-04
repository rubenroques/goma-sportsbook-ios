//
//  ServiceProviderModelMapper+Country.swift
//  Sportsbook
//
//  Created by Ruben Roques on 28/10/2022.
//

import Foundation
import ServicesProvider

extension ServiceProviderModelMapper {
    
    static func country(fromServiceProviderCountry serviceProviderCountry: ServicesProvider.Country) -> Country {
        return Country(name: serviceProviderCountry.name,
                       capital: serviceProviderCountry.capital,
                       region: serviceProviderCountry.region,
                       iso2Code: serviceProviderCountry.iso2Code,
                       iso3Code: serviceProviderCountry.iso3Code,
                       numericCode: serviceProviderCountry.numericCode,
                       phonePrefix: serviceProviderCountry.phonePrefix)
    }
    
    static func country(fromCountry country: Country) -> ServicesProvider.Country? {
        return ServicesProvider.Country(isoCode: country.iso2Code)
    }
    
}

//
//  DateUserLocation.swift
//  Sportsbook
//
//  Created by André Lascas on 20/08/2021.
//

import Foundation
import MapKit

struct DateUserLocation {

    var countryDateFormats = [
        "dd-MM-yyyy HH:mm:ss":["Others"],
        "yyyy-MM-dd HH:mm:ss":["China", "Japan", "South Korea", "North Korea", "Taiwan", "Hungary", "Mongolia", "Lithuania", "Bhutan"],
        "MM-dd-yyyy HH:mm:ss":["United States of America", "Canada"]
    ]

    func dateLocationFormat(_ country: String, _ date: Date) -> String {
        let dateFormatter = DateFormatter()

        if countryDateFormats["yyyy-MM-dd HH:mm:ss"]!.contains(country){
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        } else if countryDateFormats["MM-dd-yyyy HH:mm:ss"]!.contains(country){
            dateFormatter.dateFormat = "MM-dd-yyyy HH:mm:ss"
        } else {
            dateFormatter.dateFormat = "dd-MM-yyyy HH:mm:ss"
        }

        return dateFormatter.string(from: date)

    }
}

extension CLLocation {
    func fetchCityAndCountry(completion: @escaping (_ city: String?, _ country:  String?, _ error: Error?) -> ()) {
        CLGeocoder().reverseGeocodeLocation(self) { completion($0?.first?.locality, $0?.first?.country, $1) }
    }
}
